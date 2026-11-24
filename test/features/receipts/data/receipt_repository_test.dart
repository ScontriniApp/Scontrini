import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/analytics/data/analytics_dao.dart';
import 'package:scontrini/features/analytics/domain/frequency_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';
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

  group('products', () {
    Future<List<ReceiptItem>> rowsOf(int receiptId) =>
        (db.select(db.receiptItems)
              ..where((r) => r.receiptId.equals(receiptId))
              ..orderBy([(r) => OrderingTerm.asc(r.id)]))
            .get();

    ParsedReceipt later(List<ParsedItem> items, {int day = 24}) =>
        ParsedReceipt(
          storeName: 'CARREFOUR MARKET',
          vatNumber: '02924950963',
          purchaseDate: DateTime(2026, 11, day, 10),
          items: items,
        );

    test('every row gets a new product with its category and unit', () async {
      final id = await receipts.saveConfirmed(_receipt);
      final products = await (db.select(
        db.products,
      )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
      expect(products.map((p) => (p.canonicalName, p.unit)), [
        ('LATTE INTERO', 'pz'),
        ('MELE GOLDEN', 'kg'),
        ('MOZZARELLA', 'pz'),
      ]);
      final rows = await rowsOf(id);
      expect(rows.map((r) => r.productId), products.map((p) => p.id));
      expect(rows.map((r) => r.categoryId), products.map((p) => p.categoryId));
    });

    test('the same name on a later receipt reuses the product', () async {
      await receipts.saveConfirmed(_receipt);
      final second = await receipts.saveConfirmed(
        later(const [
          ParsedItem(
            rawName: 'latte  intero',
            unitPriceCents: 135,
            lineTotalCents: 135,
          ),
        ]),
      );
      expect(await db.select(db.products).get(), hasLength(3));
      final milk = await (db.select(
        db.products,
      )..where((p) => p.canonicalName.equals('LATTE INTERO'))).getSingle();
      expect((await rowsOf(second)).single.productId, milk.id);
    });

    test('a different label is a different product', () async {
      await receipts.saveConfirmed(_receipt);
      final second = await receipts.saveConfirmed(
        later(const [
          ParsedItem(
            rawName: 'LATTE INTERA',
            unitPriceCents: 135,
            lineTotalCents: 135,
          ),
        ]),
      );
      final row = (await rowsOf(second)).single;
      final product = await (db.select(
        db.products,
      )..where((p) => p.id.equals(row.productId!))).getSingle();
      expect(product.canonicalName, 'LATTE INTERA');
      expect(await db.select(db.products).get(), hasLength(4));
      expect(await db.select(db.productAliases).get(), isEmpty);
    });

    test('a user alias takes the row to its product', () async {
      final pasta = await db
          .into(db.products)
          .insert(
            ProductsCompanion.insert(
              canonicalName: 'Spaghetti n.5 500 g',
              unit: const Value('pz'),
            ),
          );
      await db
          .into(db.productAliases)
          .insert(
            ProductAliasesCompanion.insert(
              rawName: 'SPAGH BAR',
              productId: pasta,
            ),
          );
      final id = await receipts.saveConfirmed(
        later(const [
          ParsedItem(
            rawName: 'SPAGH BAR',
            unitPriceCents: 99,
            lineTotalCents: 99,
          ),
        ]),
      );
      expect((await rowsOf(id)).single.productId, pasta);
    });

    test('two rows of one product on a receipt share it', () async {
      final id = await receipts.saveConfirmed(
        later(const [
          ParsedItem(rawName: 'BANANE', unitPriceCents: 50, lineTotalCents: 50),
          ParsedItem(rawName: 'BANANE', unitPriceCents: 50, lineTotalCents: 50),
        ]),
      );
      final rows = await rowsOf(id);
      expect(rows[0].productId, isNotNull);
      expect(rows[1].productId, rows[0].productId);
      expect(await db.select(db.products).get(), hasLength(1));
    });

    test('scanned receipts reach price history and most frequent', () async {
      await receipts.saveConfirmed(_receipt);
      await receipts.saveConfirmed(
        later(const [
          ParsedItem(
            rawName: 'MELE GOLDEN',
            unitPriceCents: 249,
            lineTotalCents: 249,
            quantity: 1,
            unit: QuantityUnit.kilogram,
          ),
        ]),
      );
      final november = DateRange.month(DateTime(2026, 11));
      final history = await AnalyticsDao(db).loadHistory(november);

      final apples = history.products.values.singleWhere(
        (p) => p.name == 'MELE GOLDEN',
      );
      expect(apples.unit, ProductUnit.kilogram);
      final prices = PriceMetrics.priceHistory(history, apples.id, november);
      expect(prices.map((p) => (p.quantity, p.netUnitPriceCents)), [
        (0.5, 200),
        (1.0, 249),
      ]);

      final top = FrequencyMetrics.mostFrequent(history, november).first;
      expect((top.productId, top.receiptCount), (apples.id, 2));
    });
  });
}
