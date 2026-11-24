import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

final _receipt = ParsedReceipt(
  storeName: 'CARREFOUR MARKET',
  vatNumber: '02924950963',
  address: 'VIA ROMA 12, MILANO',
  purchaseDate: DateTime(2026, 11, 23, 18, 30),
  totalCents: 488,
  items: const [
    ParsedItem(
      rawName: 'LATTE INTERO',
      unitPriceCents: 129,
      lineTotalCents: 129,
    ),
    ParsedItem(
      rawName: 'MELE GOLDEN',
      unitPriceCents: 199,
      lineTotalCents: 100,
      quantity: 0.5,
      unit: QuantityUnit.kilogram,
    ),
    ParsedItem(rawName: 'MOZZARELLA', unitPriceCents: 259, lineTotalCents: 259),
  ],
);

void main() {
  late AppDatabase db;
  late ReceiptRepository receipts;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    receipts = ReceiptRepository(db, clock: () => DateTime(2026, 11, 24, 9));
  });

  tearDown(() => db.close());

  test('saves a confirmed receipt with its store, rows and hash', () async {
    final id = await receipts.saveConfirmed(
      _receipt,
      sourcePath: '/receipts/1.jpg',
      rawOcrText: 'LATTE INTERO 1,29',
    );

    final saved = await (db.select(
      db.receipts,
    )..where((r) => r.id.equals(id))).getSingle();
    expect(saved.status, ReceiptStatus.confirmed);
    expect(saved.totalCents, 488);
    expect(saved.transactionHash, hasLength(64));
    expect(saved.sourcePath, '/receipts/1.jpg');
    expect(
      saved.purchaseDate.isAtSameMomentAs(DateTime(2026, 11, 23, 18, 30)),
      isTrue,
    );

    final store = await db.select(db.stores).getSingle();
    expect(store.vatNumber, '02924950963');
    expect(saved.storeId, store.id);

    final rows = await (db.select(
      db.receiptItems,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    expect(rows.map((r) => (r.rawName, r.quantity, r.unit)), [
      ('LATTE INTERO', 1.0, 'pz'),
      ('MELE GOLDEN', 0.5, 'kg'),
      ('MOZZARELLA', 1.0, 'pz'),
    ]);
  });

  test('rows get a category from the seeded keywords', () async {
    await receipts.saveConfirmed(_receipt);
    final rows = await db.select(db.receiptItems).get();
    expect(rows.where((r) => r.categoryId != null), isNotEmpty);
  });

  test('the same receipt saved twice is one receipt', () async {
    final first = await receipts.saveConfirmed(_receipt);
    final second = await receipts.saveConfirmed(_receipt);
    expect(second, first);
    expect(await db.select(db.receipts).get(), hasLength(1));
    expect(await db.select(db.stores).get(), hasLength(1));
  });

  test(
    'a receipt without date or total is dated now and sums its rows',
    () async {
      final id = await receipts.saveConfirmed(
        _receipt.copyWith(purchaseDate: null, totalCents: null),
      );
      final saved = await (db.select(
        db.receipts,
      )..where((r) => r.id.equals(id))).getSingle();
      expect(
        saved.purchaseDate.isAtSameMomentAs(DateTime(2026, 11, 24, 9)),
        isTrue,
      );
      expect(saved.totalCents, 488);
    },
  );

  test('a saved receipt can be sorted into the pantry', () async {
    final id = await receipts.saveConfirmed(_receipt);
    final pantry = PantryRepository(db);
    final cards = await pantry.triageCards(id);
    expect(cards.map((c) => c.name), [
      'LATTE INTERO',
      'MELE GOLDEN',
      'MOZZARELLA',
    ]);

    await pantry.addFromReceipt(id, cards[0]);
    await pantry.addFromReceipt(id, cards[1]);
    final lots = await db.select(db.pantryLots).get();
    expect(lots.map((l) => (l.name, l.initialQuantity, l.unit)), [
      ('LATTE INTERO', 1.0, 'pz'),
      ('MELE GOLDEN', 0.5, 'kg'),
    ]);
    // Only the skipped card is left for a later triage.
    expect((await pantry.triageCards(id)).map((c) => c.name), ['MOZZARELLA']);
  });

  test('categories chosen by hand win over the keywords', () async {
    final frozen = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Surgelati'))).getSingle();
    await receipts.saveConfirmed(
      _receipt,
      categoryIds: [null, frozen.id, null],
    );
    final rows = await (db.select(
      db.receiptItems,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    expect(rows[1].categoryId, frozen.id);
    expect(rows[0].categoryId, isNotNull); // LATTE: from the keywords
    expect(
      () => receipts.saveConfirmed(_receipt, categoryIds: [null]),
      throwsArgumentError,
    );
  });

  test('history lists confirmed receipts, newest first', () async {
    final photo = await receipts.saveConfirmed(
      _receipt,
      sourcePath: '/receipts/1.jpg',
    );
    final manual = await receipts.saveConfirmed(
      ParsedReceipt(
        purchaseDate: DateTime(2026, 11, 24, 10),
        totalCents: 150,
        items: const [
          ParsedItem(rawName: 'Pane', unitPriceCents: 150, lineTotalCents: 150),
        ],
      ),
    );
    await db
        .into(db.receipts)
        .insert(
          ReceiptsCompanion.insert(
            purchaseDate: DateTime.utc(2026, 11, 25),
            totalCents: 1,
            status: ReceiptStatus.draft,
          ),
        );

    final history = await receipts.watchHistory().first;
    expect(history.map((r) => (r.id, r.itemCount, r.manual, r.storeName)), [
      (manual, 1, true, null),
      (photo, 3, false, 'CARREFOUR MARKET'),
    ]);
    expect(history.last.purchaseDate, DateTime(2026, 11, 23, 18, 30));
  });

  test('a receipt reads back with its rows and goes on delete', () async {
    final id = await receipts.saveConfirmed(_receipt);
    final pantry = PantryRepository(db);
    await pantry.addFromReceipt(id, (await pantry.triageCards(id)).first);

    final detail = (await receipts.watchReceipt(id).first)!;
    expect(detail.summary.totalCents, 488);
    expect(detail.lines.map((l) => (l.name, l.quantity, l.unit, l.netCents)), [
      ('LATTE INTERO', 1.0, 'pz', 129),
      ('MELE GOLDEN', 0.5, 'kg', 100),
      ('MOZZARELLA', 1.0, 'pz', 259),
    ]);

    final gone = receipts.watchReceipt(id).firstWhere((d) => d == null);
    await receipts.delete(id);
    expect(await gone, isNull);
    expect(await db.select(db.receiptItems).get(), isEmpty);
    expect(await db.select(db.pantryLots).get(), isEmpty);
  });

  test('rows are linked to a product by name, across receipts', () async {
    await receipts.saveConfirmed(_receipt);
    await receipts.saveConfirmed(
      ParsedReceipt(
        purchaseDate: DateTime(2026, 11, 24, 10),
        totalCents: 129,
        items: const [
          ParsedItem(
            rawName: 'Latte intero',
            unitPriceCents: 129,
            lineTotalCents: 129,
          ),
        ],
      ),
    );
    final rows = await (db.select(
      db.receiptItems,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    expect(rows.every((r) => r.productId != null), isTrue);
    expect(rows.last.productId, rows.first.productId);
    expect(await db.select(db.products).get(), hasLength(3));
  });
}
