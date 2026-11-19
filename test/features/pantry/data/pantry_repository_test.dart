import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

void main() {
  late AppDatabase db;
  late PantryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PantryRepository(db, clock: () => DateTime.utc(2026, 11, 19, 12));
  });
  tearDown(() => db.close());

  Future<int> receipt({ReceiptStatus status = ReceiptStatus.confirmed}) => db
      .into(db.receipts)
      .insert(
        ReceiptsCompanion.insert(
          purchaseDate: DateTime.utc(2026, 11, 18),
          totalCents: 1000,
          status: status,
        ),
      );

  Future<int> item(
    int receiptId,
    String name, {
    double quantity = 1,
    int cents = 100,
    int discount = 0,
    String unit = 'pz',
    int? productId,
  }) => db
      .into(db.receiptItems)
      .insert(
        ReceiptItemsCompanion.insert(
          receiptId: receiptId,
          rawName: name,
          quantity: Value(quantity),
          unit: Value(unit),
          unitPriceCents: cents,
          lineTotalCents: cents,
          discountCents: Value(discount),
          productId: Value(productId),
        ),
      );

  /// Receipt with the given rows, all put in the pantry; returns lot ids.
  Future<List<int>> stocked(List<(String, double)> rows) async {
    final r = await receipt();
    for (final (name, qty) in rows) {
      await item(r, name, quantity: qty);
    }
    return [
      for (final card in await repo.triageCards(r))
        await repo.addFromReceipt(r, card),
    ];
  }

  Future<int> purchaseRows() async =>
      (await db.select(db.receiptItems).get()).length;

  group('triage', () {
    test('merges repeated rows of one receipt into one card', () async {
      final r = await receipt();
      await item(r, 'YOGURT BIANCO', cents: 120);
      await item(r, 'LATTE PS 1L', cents: 129);
      await item(r, 'yogurt  bianco', cents: 120, discount: 20);

      final cards = await repo.triageCards(r);

      expect(cards.map((c) => c.name), ['YOGURT BIANCO', 'LATTE PS 1L']);
      expect(cards.first.quantity, 2);
      expect(cards.first.priceCents, 220);
      expect(cards.first.receiptItemIds, hasLength(2));
    });

    test('rejects draft receipts', () async {
      final r = await receipt(status: ReceiptStatus.draft);
      await item(r, 'LATTE');
      expect(() => repo.triageCards(r), throwsStateError);
    });

    test('skips products not tracked in the pantry', () async {
      final shopper = await db
          .into(db.products)
          .insert(
            ProductsCompanion.insert(
              canonicalName: 'Shopper',
              trackInPantry: const Value(false),
            ),
          );
      final r = await receipt();
      await item(r, 'SHOPPER', productId: shopper);
      await item(r, 'PANE');

      expect((await repo.triageCards(r)).map((c) => c.name), ['PANE']);
    });

    test('adding a card links its rows and creates no purchase', () async {
      final r = await receipt();
      await item(r, 'LATTE', quantity: 2, cents: 258);
      final before = await purchaseRows();

      final card = (await repo.triageCards(r)).single;
      final lotId = await repo.addFromReceipt(r, card, name: 'Latte');
      final lot = await repo.lot(lotId);

      expect(await purchaseRows(), before);
      expect(lot.name, 'Latte');
      expect(lot.initialQuantity, 2);
      expect(lot.remainingQuantity, 2);
      expect(lot.priceCents, 258);
      expect(await repo.triageCards(r), isEmpty);
      expect(() => repo.addFromReceipt(r, card), throwsStateError);
    });
  });

  group('movements', () {
    test('consume never goes below zero', () async {
      final [lot] = await stocked([('LATTE', 2)]);

      await repo.consume(lot, 1.5);
      await repo.consume(lot, 5);

      final ledger = LotLedger(await repo.events(lot));
      expect(ledger.remaining, 0);
      expect(ledger.consumed, 2);
      expect(ledger.status, PantryLotStatus.consumed);
    });

    test('slider up is a recount, not consumption', () async {
      final [lot] = await stocked([('PASTA', 1)]);

      await repo.setRemaining(lot, 0.25);
      await repo.setRemaining(lot, 0.5);
      await repo.setRemaining(lot, 7); // clamped to the initial quantity

      final ledger = LotLedger(await repo.events(lot));
      expect(ledger.remaining, 1);
      expect(ledger.consumed, 0.75);
      expect(ledger.effectiveEvents.last.reason, PantryEventReason.recount);
    });

    test('discard throws away only what is left', () async {
      final [lot] = await stocked([('PANE', 1)]);

      await repo.consume(lot, 0.4);
      await repo.discard(lot, PantryEventReason.spoiled);

      final ledger = LotLedger(await repo.events(lot));
      expect(ledger.consumed, 0.4);
      expect(ledger.discarded, 0.6);
      expect(ledger.status, PantryLotStatus.discarded);
      expect(
        () => repo.discard(lot, PantryEventReason.recount),
        throwsArgumentError,
      );
    });

    test('undo cancels the latest movements like a stack', () async {
      final [lot] = await stocked([('UOVA', 6)]);

      await repo.consume(lot, 2);
      await repo.discard(lot, PantryEventReason.expired);
      expect(await repo.undoLast(lot), isTrue); // discard
      expect((await repo.lot(lot)).remainingQuantity, 4);
      expect(await repo.undoLast(lot), isTrue); // consume
      expect(await repo.undoLast(lot), isFalse); // only the stock-in is left

      final ledger = LotLedger(await repo.events(lot));
      expect(ledger.remaining, 6);
      expect(ledger.consumed, 0);
      expect(ledger.discarded, 0);
    });

    test('manual lots: receipt source is refused', () async {
      final id = await repo.addManual(
        name: 'Riso',
        quantity: 1,
        source: PantrySource.initialStock,
      );
      expect((await repo.lot(id)).source, PantrySource.initialStock);
      expect(
        () => repo.addManual(
          name: 'Riso',
          quantity: 1,
          source: PantrySource.receipt,
        ),
        throwsArgumentError,
      );
    });

    test('watchLots hides closed lots unless asked', () async {
      final [milk, bread] = await stocked([('LATTE', 1), ('PANE', 1)]);
      await repo.consume(bread, 1);

      final active = await repo.watchLots().first;
      final all = await repo.watchLots(includeClosed: true).first;

      expect(active.map((l) => l.id), [milk]);
      expect(all.map((l) => l.id).toSet(), {milk, bread});
    });
  });

  group('corrections', () {
    test('quantity correction edits the purchase and the lot', () async {
      final r = await receipt();
      final row = await item(r, 'LATTE', quantity: 2);
      final lot = await repo.addFromReceipt(
        r,
        (await repo.triageCards(r)).single,
      );
      await repo.consume(lot, 1);
      final before = await purchaseRows();

      await repo.correctItemQuantity(row, 3);

      expect(await purchaseRows(), before);
      final corrected = await repo.lot(lot);
      expect(corrected.initialQuantity, 3);
      expect(corrected.remainingQuantity, 2);
      final ledger = LotLedger(await repo.events(lot));
      expect(ledger.consumed, 1);
      expect(ledger.undoTarget, isNull);
    });

    test('a correction below what was used empties the lot', () async {
      final r = await receipt();
      final row = await item(r, 'YOGURT', quantity: 3);
      final lot = await repo.addFromReceipt(
        r,
        (await repo.triageCards(r)).single,
      );
      await repo.consume(lot, 2.5);

      await repo.correctItemQuantity(row, 1);

      final corrected = await repo.lot(lot);
      expect(corrected.initialQuantity, 1);
      expect(corrected.remainingQuantity, 0);
      expect(LotLedger(await repo.events(lot)).consumed, 2.5);
    });
  });

  group('deleting a receipt', () {
    test('removes its rows, its lots and their events', () async {
      final r = await receipt();
      await item(r, 'LATTE', quantity: 2);
      final lot = await repo.addFromReceipt(
        r,
        (await repo.triageCards(r)).single,
      );
      await repo.consume(lot, 1);
      final other = await repo.addManual(
        name: 'Latte',
        quantity: 1,
        source: PantrySource.manualPurchase,
      );

      await (db.delete(db.receipts)..where((x) => x.id.equals(r))).go();

      expect(await db.select(db.receiptItems).get(), isEmpty);
      final lots = await db.select(db.pantryLots).get();
      expect(lots.map((l) => l.id), [other]);
      final events = await db.select(db.pantryEvents).get();
      expect(events.every((e) => e.lotId == other), isTrue);
    });

    test('a receipt lot must have a receipt', () async {
      expect(
        () => db
            .into(db.pantryLots)
            .insert(
              PantryLotsCompanion.insert(
                name: 'Latte',
                source: PantrySource.receipt,
                initialQuantity: 1,
                addedAt: DateTime.utc(2026),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
