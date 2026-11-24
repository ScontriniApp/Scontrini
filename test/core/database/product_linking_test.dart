import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/product_key.dart';

void main() {
  test('productKey ignores case, accents, punctuation and spacing', () {
    expect(productKey('Latte intero'), 'LATTE INTERO');
    expect(productKey('  LATTE   INTERO. '), 'LATTE INTERO');
    expect(productKey("Caffè d'orzo"), 'CAFFE D ORZO');
    expect(productKey('POM. 500G'), 'POM 500G');
    expect(productKey('--- '), isEmpty);
  });

  group('AppDatabase products', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('one product per key, created once with its alias', () async {
      final a = await db.productIdFor('LATTE INTERO', unit: 'pz');
      final b = await db.productIdFor('Latte intero.');
      final c = await db.productIdFor('LATTE PS');
      expect(b, a);
      expect(c, isNot(a));
      expect(await db.productIdFor('***'), isNull);

      final product = await (db.select(
        db.products,
      )..where((p) => p.id.equals(a!))).getSingle();
      expect((product.canonicalName, product.unit), ('LATTE INTERO', 'pz'));
      final aliases = await db.select(db.productAliases).get();
      expect(aliases.map((x) => x.rawName).toSet(), {
        'LATTE INTERO',
        'LATTE PS',
      });
    });

    test('an existing product with that name gets the alias', () async {
      final id = await db
          .into(db.products)
          .insert(ProductsCompanion.insert(canonicalName: 'Pane'));
      expect(await db.productIdFor('Pane'), id);
      expect(await db.productIdFor('PANE'), id);
    });

    test('linkProducts links old rows and lots', () async {
      final receipt = await db
          .into(db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              purchaseDate: DateTime.utc(2026, 11, 20),
              totalCents: 300,
              status: ReceiptStatus.confirmed,
            ),
          );
      final lot = await db
          .into(db.pantryLots)
          .insert(
            PantryLotsCompanion.insert(
              receiptId: Value(receipt),
              name: 'Latte',
              source: PantrySource.receipt,
              initialQuantity: 1,
              addedAt: DateTime.utc(2026, 11, 20),
            ),
          );
      final manualLot = await db
          .into(db.pantryLots)
          .insert(
            PantryLotsCompanion.insert(
              name: 'Riso',
              source: PantrySource.initialStock,
              initialQuantity: 1,
              addedAt: DateTime.utc(2026, 11, 20),
            ),
          );
      for (final name in ['LATTE INTERO', 'LATTE INTERO', 'PANE']) {
        await db
            .into(db.receiptItems)
            .insert(
              ReceiptItemsCompanion.insert(
                receiptId: receipt,
                rawName: name,
                unitPriceCents: 100,
                lineTotalCents: 100,
                pantryLotId: Value(name == 'PANE' ? null : lot),
              ),
            );
      }

      await db.linkProducts();

      final rows = await (db.select(
        db.receiptItems,
      )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
      expect(rows.every((r) => r.productId != null), isTrue);
      expect(rows[0].productId, rows[1].productId);
      expect(rows[2].productId, isNot(rows[0].productId));

      final lots = {
        for (final l in await db.select(db.pantryLots).get()) l.id: l,
      };
      // Through its receipt rows, not its own name.
      expect(lots[lot]!.productId, rows[0].productId);
      expect(lots[manualLot]!.productId, await db.productIdFor('RISO'));

      // Nothing left to do the second time.
      await db.linkProducts();
      expect(await db.select(db.products).get(), hasLength(3));
    });
  });
}
