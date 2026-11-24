import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/analytics/data/analytics_dao.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';

void main() {
  late AppDatabase db;
  late AnalyticsDao dao;
  final november = DateRange.month(DateTime(2026, 11));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AnalyticsDao(db);
  });
  tearDown(() => db.close());

  /// Inserts a receipt bought at [localDate] (stored in UTC, like the app).
  Future<int> addReceipt(
    DateTime localDate,
    int totalCents, {
    ReceiptStatus status = ReceiptStatus.confirmed,
    int discountCents = 0,
    int? storeId,
  }) => db
      .into(db.receipts)
      .insert(
        ReceiptsCompanion.insert(
          purchaseDate: localDate.toUtc(),
          totalCents: totalCents,
          discountCents: Value(discountCents),
          storeId: Value(storeId),
          status: status,
        ),
      );

  Future<int> addItem(
    int receiptId,
    int lineTotalCents, {
    String rawName = 'ITEM',
    double quantity = 1,
    String unit = 'pz',
    int discountCents = 0,
    int? productId,
    int? categoryId,
  }) => db
      .into(db.receiptItems)
      .insert(
        ReceiptItemsCompanion.insert(
          receiptId: receiptId,
          rawName: rawName,
          quantity: Value(quantity),
          unit: Value(unit),
          unitPriceCents: (lineTotalCents / quantity).round(),
          lineTotalCents: lineTotalCents,
          discountCents: Value(discountCents),
          productId: Value(productId),
          categoryId: Value(categoryId),
        ),
      );

  Future<int> categoryId(String name) async => (await (db.select(
    db.categories,
  )..where((c) => c.name.equals(name))).getSingle()).id;

  test(
    'an empty database gives no receipts but the seeded categories',
    () async {
      final history = await dao.loadHistory(november);
      expect(history.isEmpty, isTrue);
      expect(history.categories, isNotEmpty);
      expect(history.products, isEmpty);
      expect(history.stores, isEmpty);
    },
  );

  test('reads only confirmed receipts on local days in the range', () async {
    await addReceipt(DateTime(2026, 10, 31, 23, 30), 100); // day before
    final first = await addReceipt(DateTime(2026, 11, 1, 0, 5), 200);
    final last = await addReceipt(DateTime(2026, 11, 30, 23, 59), 300);
    await addReceipt(DateTime(2026, 12), 400); // day after
    await addReceipt(DateTime(2026, 11, 15), 500, status: ReceiptStatus.draft);
    final middle = await addReceipt(DateTime(2026, 11, 10), 600);

    final history = await dao.loadHistory(november);
    expect(history.receipts.map((r) => r.id), [first, middle, last]);

    final receipt = history.receipts.first;
    expect(receipt.purchaseDate.isUtc, isTrue);
    expect(receipt.purchaseDate, DateTime(2026, 11, 1, 0, 5).toUtc());
    expect(SpendingMetrics.totalSpending(history, november).cents, 1100);
  });

  test("the row's unit wins over the product's", () async {
    final melon = await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            canonicalName: 'Melone',
            unit: const Value('pz'),
          ),
        );
    final receiptId = await addReceipt(DateTime(2026, 11, 5), 300);
    await addItem(
      receiptId,
      300,
      rawName: 'MELONE',
      quantity: 1.5,
      unit: 'kg',
      productId: melon,
    );
    await addItem(receiptId, 0, rawName: 'SENZA PRODOTTO', unit: 'l');

    final items = (await dao.loadHistory(november)).receipts.single.items;
    expect(items.map((i) => i.unit), [ProductUnit.kilogram, ProductUnit.litre]);
  });

  test('items resolve category and unit, with the lookups filled', () async {
    final dairy = await categoryId('Latticini e uova');
    final fruit = await categoryId('Frutta e verdura');
    final storeId = await db
        .into(db.stores)
        .insert(
          StoresCompanion.insert(
            name: 'Esselunga',
            vatNumber: const Value('IT01255720169'),
          ),
        );
    await db.into(db.stores).insert(StoresCompanion.insert(name: 'Unused'));
    final milk = await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            canonicalName: 'Latte intero 1 l',
            categoryId: Value(dairy),
            unit: const Value('pz'),
          ),
        );
    final apples = await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            canonicalName: 'Mele',
            categoryId: Value(fruit),
            unit: const Value('kg'),
          ),
        );

    final receiptId = await addReceipt(
      DateTime(2026, 11, 5),
      560,
      discountCents: 20,
      storeId: storeId,
    );
    await addItem(receiptId, 129, rawName: 'LATTE PS', productId: milk);
    await addItem(
      receiptId,
      240,
      rawName: 'MELE',
      quantity: 0.8,
      unit: 'kg',
      discountCents: 40,
      productId: apples,
      categoryId: dairy, // corrected by hand: the item's own category wins
    );
    await addItem(receiptId, 251, rawName: 'SCONOSCIUTO');

    final history = await dao.loadHistory(november);
    final receipt = history.receipts.single;
    expect(receipt.storeId, storeId);
    expect(receipt.discountCents, 20);
    expect(
      [
        for (final i in receipt.items)
          (i.rawName, i.productId, i.categoryId, i.unit),
      ],
      [
        ('LATTE PS', milk, dairy, ProductUnit.piece),
        ('MELE', apples, dairy, ProductUnit.kilogram),
        ('SCONOSCIUTO', null, null, ProductUnit.piece),
      ],
    );
    final weighed = receipt.items[1];
    expect(weighed.quantity, 0.8);
    expect(weighed.netCents, 200);
    expect(weighed.netUnitPriceCents, 250);

    expect(history.products.keys, unorderedEquals([milk, apples]));
    expect(history.products[apples]!.name, 'Mele');
    expect(history.products[apples]!.categoryId, fruit);
    expect(history.stores.keys, [storeId]);
    expect(history.stores[storeId]!.vatNumber, 'IT01255720169');
    expect(history.categories[dairy]!.name, 'Latticini e uova');
  });

  test(
    'items of drafts and of receipts outside the range are left out',
    () async {
      final draft = await addReceipt(
        DateTime(2026, 11, 5),
        100,
        status: ReceiptStatus.draft,
      );
      await addItem(draft, 100);
      final october = await addReceipt(DateTime(2026, 10, 5), 100);
      await addItem(october, 100);
      final kept = await addReceipt(DateTime(2026, 11, 6), 100);
      await addItem(kept, 100);

      final history = await dao.loadHistory(november);
      expect(history.receipts.single.items, hasLength(1));
    },
  );

  test('watchHistory follows confirmations, edits and deletions', () async {
    final draft = await addReceipt(
      DateTime(2026, 11, 5),
      300,
      status: ReceiptStatus.draft,
    );
    final itemId = await addItem(draft, 300);

    final updates = StreamIterator(dao.watchHistory(november));
    addTearDown(updates.cancel);

    Future<PurchaseHistory> next() async {
      expect(await updates.moveNext(), isTrue);
      return updates.current;
    }

    expect((await next()).isEmpty, isTrue);

    await (db.update(db.receipts)..where((r) => r.id.equals(draft))).write(
      const ReceiptsCompanion(status: Value(ReceiptStatus.confirmed)),
    );
    expect((await next()).receipts.single.id, draft);

    await (db.update(db.receiptItems)..where((i) => i.id.equals(itemId))).write(
      const ReceiptItemsCompanion(discountCents: Value(50)),
    );
    expect((await next()).receipts.single.items.single.netCents, 250);

    await (db.delete(db.receipts)..where((r) => r.id.equals(draft))).go();
    expect((await next()).isEmpty, isTrue);
  });

  test(
    'purchaseHistoryProvider reads through the overridden database',
    () async {
      await addReceipt(DateTime(2026, 11, 5), 700);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final provider = purchaseHistoryProvider(november);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final history = await container.read(provider.future);
      expect(history.receipts.single.totalCents, 700);
    },
  );
}
