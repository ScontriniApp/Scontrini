import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/analytics/data/analytics_dao.dart';
import 'package:scontrini/features/analytics/data/demo_history_seed.dart';
import 'package:scontrini/features/analytics/domain/models/category_share.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';

void main() {
  final today = DateTime(2026, 11, 23);
  final november = DateRange.month(DateTime(2026, 11));
  final everything = DateRange(DateTime(2026), DateTime(2027));

  group('demoPurchases', () {
    test('is the same for the same day', () {
      String describe(List<DemoPurchase> ps) => [
        for (final p in ps)
          [
            p.localDate,
            p.store,
            p.totalCents,
            for (final l in p.lines) '${l.rawName}:${l.quantity}',
          ].join(' '),
      ].join('\n');
      expect(describe(demoPurchases(today)), describe(demoPurchases(today)));
    });

    test('covers 26 weeks up to today, oldest first, with no returns', () {
      final purchases = demoPurchases(today);
      final dates = [for (final p in purchases) p.localDate];
      expect(dates, orderedEquals([...dates]..sort()));
      expect(dates.first.isBefore(DateTime(2026, 5, 27)), isFalse);
      expect(dates.last.isBefore(DateTime(2026, 11, 24)), isTrue);
      expect(
        purchases.expand((p) => p.lines).every((l) => l.lineTotalCents > 0),
        isTrue,
      );
      expect(
        purchases.where((p) => p.status == ReceiptStatus.draft),
        hasLength(1),
      );
    });

    test('follows today, so the current month is never empty', () {
      final march = demoPurchases(DateTime(2027, 3, 10));
      expect(march.last.localDate.month, 3);
      expect(march.first.localDate.year, 2026);
    });
  });

  group('seedDemoHistory', () {
    late AppDatabase db;
    late PurchaseHistory history;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final result = await seedDemoHistory(db, today: today);
      expect(result, (confirmed: 42, drafts: 1, items: 310));
      history = await AnalyticsDao(db).loadHistory(everything);
    });
    tearDown(() => db.close());

    String category(int? id) => history.categories[id]!.name;

    test('loads as 42 confirmed receipts in 3 stores', () {
      expect(history.receipts, hasLength(42));
      expect(history.stores, hasLength(3));
      expect(history.products, hasLength(DemoProduct.values.length));
      expect(SpendingMetrics.totalSpending(history, november).cents, 10518);
    });

    test('milk rises 12% and coffee drops 15%', () {
      int productId(DemoProduct p) => history.products.values
          .singleWhere((i) => i.name == p.canonicalName)
          .id;
      final milk = PriceMetrics.priceChange(
        history,
        productId(DemoProduct.milk),
        november,
      )!;
      expect((milk.referenceCents, milk.latestCents), (129, 145));
      final coffee = PriceMetrics.priceChange(
        history,
        productId(DemoProduct.coffee),
        november,
      )!;
      expect((coffee.referenceCents, coffee.latestCents), (459, 389));
    });

    test('meat is the top category of the last 30 days', () {
      final shares = SpendingMetrics.spendingByCategory(
        history,
        DateRange.lastDays(30, now: today),
      );
      expect(category(shares.first.categoryId), 'Carne e pesce');
      expect(shares.first.share, greaterThan(0.3));
    });

    test('drinks spike this month and savings grow', () {
      int drinks(DateRange range) =>
          SpendingMetrics.spendingByCategory(history, range)
              .singleWhere(
                (s) =>
                    s.categoryId != null && category(s.categoryId) == 'Bevande',
              )
              .cents;
      final before = [
        for (final m in [8, 9, 10]) drinks(DateRange.month(DateTime(2026, m))),
      ];
      final average = before.reduce((a, b) => a + b) / before.length;
      expect(drinks(november), greaterThan(1.3 * average));

      final saved = SpendingMetrics.savings(history, november).saved;
      expect(saved.changePercent, greaterThan(50));
    });

    test('has the uncategorised, Other and empty-week cases', () {
      final kinds = {
        for (final s in SpendingMetrics.spendingByCategory(history, everything))
          s.kind,
      };
      expect(
        kinds,
        containsAll([CategoryShareKind.uncategorised, CategoryShareKind.other]),
      );
      final weeks = SpendingMetrics.spendingOverTime(
        history,
        DateRange(DateTime(2026, 8), DateTime(2026, 10)),
        Granularity.week,
      );
      expect(weeks.where((b) => b.receiptCount == 0), hasLength(1));
    });

    test('weighed items keep their price per kg', () {
      final apples = history.receipts
          .expand((r) => r.items)
          .where((i) => i.rawName == DemoProduct.apples.rawName);
      expect(apples, isNotEmpty);
      for (final item in apples) {
        expect(item.quantity, inInclusiveRange(0.6, 1.4));
        expect(item.netUnitPriceCents, closeTo(229, 1));
      }
    });

    test('seeding again replaces the demo history', () async {
      await seedDemoHistory(db, today: today);
      expect(await db.select(db.receipts).get(), hasLength(43));
      expect(await db.select(db.stores).get(), hasLength(3));
      expect(
        await db.select(db.products).get(),
        hasLength(DemoProduct.values.length),
      );
    });

    test('removing leaves real receipts and their products alone', () async {
      final milk =
          await (db.select(db.products)..where(
                (p) => p.canonicalName.equals(DemoProduct.milk.canonicalName),
              ))
              .getSingle();
      final realStore = await db
          .into(db.stores)
          .insert(StoresCompanion.insert(name: 'Real store'));
      final real = await db
          .into(db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              storeId: Value(realStore),
              purchaseDate: DateTime.utc(2026, 11, 2, 9),
              totalCents: 129,
              status: ReceiptStatus.confirmed,
            ),
          );
      await db
          .into(db.receiptItems)
          .insert(
            ReceiptItemsCompanion.insert(
              receiptId: real,
              productId: Value(milk.id),
              rawName: 'LATTE',
              unitPriceCents: 129,
              lineTotalCents: 129,
            ),
          );
      final categories = await db.select(db.categories).get();

      await removeDemoHistory(db);

      expect((await db.select(db.receipts).get()).map((r) => r.id), [real]);
      expect((await db.select(db.stores).get()).map((s) => s.id), [realStore]);
      expect((await db.select(db.products).get()).map((p) => p.id), [milk.id]);
      expect((await db.select(db.productAliases).get()).map((a) => a.rawName), [
        DemoProduct.milk.rawName,
      ]);
      expect(await db.select(db.categories).get(), categories);
    });
  });
}
