import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/models/category_share.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/models/store_summary.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';

import 'history_fixtures.dart';

void main() {
  final november = DateRange.month(DateTime(2026, 11));

  group('M1 totalSpending', () {
    test('sums printed totals in the range and in the previous range', () {
      final h = history([
        // Previous range: the 30 days before 1 November.
        receipt(DateTime(2026, 10), 999), // 31 days before: outside
        receipt(DateTime(2026, 10, 2, 9), 2000),
        receipt(DateTime(2026, 10, 31, 23, 30), 500),
        receipt(DateTime(2026, 11, 1, 0, 5), 1000),
        receipt(DateTime(2026, 11, 30, 23, 59), 1500),
        receipt(DateTime(2026, 12), 7777),
      ]);

      final total = SpendingMetrics.totalSpending(h, november);
      expect(total.cents, 2500);
      expect(total.previousCents, 2500);
      expect(total.deltaCents, 0);
      expect(total.changePercent, 0);
    });

    test('trusts totalCents even when the items do not add up', () {
      final h = history([
        receipt(DateTime(2026, 11, 5), 1000, items: [item(300), item(400)]),
      ]);
      expect(SpendingMetrics.totalSpending(h, november).cents, 1000);
    });

    test('percent change is null without a previous amount', () {
      final h = history([receipt(DateTime(2026, 11, 5), 1000)]);
      final total = SpendingMetrics.totalSpending(h, november);
      expect(total.previousCents, 0);
      expect(total.changePercent, isNull);

      final week = DateRange.week(DateTime(2026, 11, 18));
      final growth = SpendingMetrics.totalSpending(
        history([
          receipt(DateTime(2026, 11, 10), 2000),
          receipt(DateTime(2026, 11, 17), 2500),
        ]),
        week,
      );
      expect(growth.changePercent, 25);
    });

    test('empty history gives zero', () {
      final total = SpendingMetrics.totalSpending(
        PurchaseHistory.empty,
        november,
      );
      expect(total.cents, 0);
      expect(total.changePercent, isNull);
    });
  });

  group('M2 spendingOverTime', () {
    test('weekly buckets start on Monday, are clipped, and keep gaps', () {
      final h = history([
        receipt(DateTime(2026, 11, 1, 12), 100), // Sunday: first, partial week
        receipt(DateTime(2026, 11, 3), 200),
        receipt(DateTime(2026, 11, 8, 23, 30), 300), // still week of 2 Nov
        // No receipts in the week of 9 November.
        receipt(DateTime(2026, 11, 30), 400), // Monday: last, 1-day week
      ]);

      final buckets = SpendingMetrics.spendingOverTime(
        h,
        november,
        Granularity.week,
      );

      expect(buckets.map((b) => b.range.start), [
        DateTime(2026, 11),
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 16),
        DateTime(2026, 11, 23),
        DateTime(2026, 11, 30),
      ]);
      expect(buckets.map((b) => b.totalCents), [100, 500, 0, 0, 0, 400]);
      expect(buckets.map((b) => b.receiptCount), [1, 2, 0, 0, 0, 1]);
      expect(buckets.last.range.end, november.end);
    });

    test('monthly buckets over six months', () {
      final range = DateRange(DateTime(2026, 6), DateTime(2026, 12));
      final h = history([
        receipt(DateTime(2026, 5, 31, 23), 9999), // before the range
        receipt(DateTime(2026, 6, 15), 1000),
        receipt(DateTime(2026, 6, 30, 23, 59), 500),
        receipt(DateTime(2026, 9), 700),
        receipt(DateTime(2026, 11, 30), 300),
      ]);

      final buckets = SpendingMetrics.spendingOverTime(
        h,
        range,
        Granularity.month,
      );
      expect(buckets.map((b) => b.totalCents), [1500, 0, 0, 700, 0, 300]);
    });

    test('daily buckets stay aligned across the DST change', () {
      // Europe leaves summer time on 25 October 2026.
      final range = DateRange(DateTime(2026, 10, 24), DateTime(2026, 10, 27));
      final h = history([
        receipt(DateTime(2026, 10, 25, 23, 30), 100),
        receipt(DateTime(2026, 10, 26, 0, 30), 200),
      ]);

      final buckets = SpendingMetrics.spendingOverTime(
        h,
        range,
        Granularity.day,
      );
      expect(buckets.map((b) => b.range.start), [
        DateTime(2026, 10, 24),
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 26),
      ]);
      expect(buckets.map((b) => b.totalCents), [0, 100, 200]);
    });
  });

  group('M8 savings', () {
    test('adds item and receipt discounts, skips returns, gives the rate', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 7),
          1300,
          discountCents: 100, // basket coupon
          items: [
            item(1000, discountCents: 300),
            item(700, discountCents: 100),
            item(-200, discountCents: 50), // return: not a saving
          ],
        ),
        receipt(DateTime(2026, 11, 20), 700),
        receipt(
          DateTime(2026, 10, 20),
          1000,
          items: [item(1200, discountCents: 200)],
        ),
      ]);

      final savings = SpendingMetrics.savings(h, november);
      expect(savings.saved.cents, 500);
      expect(savings.saved.previousCents, 200);
      expect(savings.saved.changePercent, 150);
      expect(savings.paidCents, 2000);
      expect(savings.rate, 500 / 2500);
    });

    test('rate is null when nothing was bought', () {
      final savings = SpendingMetrics.savings(PurchaseHistory.empty, november);
      expect(savings.saved.cents, 0);
      expect(savings.rate, isNull);
    });
  });

  group('M3 spendingByCategory', () {
    test('sums net amounts per category, largest first', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          1500,
          items: [
            item(600, categoryId: 1),
            item(500, discountCents: 100, categoryId: 2),
            item(200), // uncategorised
            item(300, categoryId: 1),
          ],
        ),
        receipt(DateTime(2026, 11, 20), 300, items: [item(300, categoryId: 2)]),
        receipt(DateTime(2026, 10, 30), 999, items: [item(999, categoryId: 3)]),
      ]);

      final slices = SpendingMetrics.spendingByCategory(h, november);
      expect(slices, [
        const CategoryShare(
          kind: CategoryShareKind.category,
          categoryId: 1,
          cents: 900,
          share: 900 / 1800,
        ),
        const CategoryShare(
          kind: CategoryShareKind.category,
          categoryId: 2,
          cents: 700,
          share: 700 / 1800,
        ),
        const CategoryShare(
          kind: CategoryShareKind.uncategorised,
          cents: 200,
          share: 200 / 1800,
        ),
      ]);
    });

    test('spreads a basket coupon by line total, to the cent', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          800,
          discountCents: 100,
          items: [item(600, categoryId: 1), item(300, categoryId: 2)],
        ),
      ]);

      final slices = SpendingMetrics.spendingByCategory(h, november);
      // 100 × 600/900 = 66.67 → 67; 100 × 300/900 = 33.33 → 33.
      expect(
        [for (final s in slices) (s.categoryId, s.cents)],
        [(1, 533), (2, 267)],
      );
    });

    test('returns reduce their category and take no part of a coupon', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          1150,
          discountCents: 150,
          items: [
            item(1000, categoryId: 1),
            item(-200, categoryId: 1),
            item(500, categoryId: 2),
          ],
        ),
      ]);

      final slices = SpendingMetrics.spendingByCategory(h, november);
      expect(
        [for (final s in slices) (s.categoryId, s.cents)],
        [
          (1, 700), // 1000 − 100 coupon − 200 return
          (2, 450), // 500 − 50 coupon
        ],
      );
    });

    test('puts what the items do not explain in Other, last', () {
      final h = history([
        // Items short of the total by 300.
        receipt(
          DateTime(2026, 11, 3),
          1000,
          items: [item(300, categoryId: 1), item(400, categoryId: 2)],
        ),
        // Items over the total by 100.
        receipt(DateTime(2026, 11, 4), 500, items: [item(600, categoryId: 1)]),
        // No items at all; and a coupon with nothing to spread it over.
        receipt(DateTime(2026, 11, 5), 2000),
        receipt(DateTime(2026, 11, 6), 0, discountCents: 50),
      ]);

      final slices = SpendingMetrics.spendingByCategory(h, november);
      expect(slices.map((s) => s.kind), [
        CategoryShareKind.category,
        CategoryShareKind.category,
        CategoryShareKind.other,
      ]);
      expect(slices.last.cents, 300 - 100 + 2000);
      expect(slices.last.categoryId, isNull);

      final sum = slices.fold(0, (total, s) => total + s.cents);
      expect(sum, SpendingMetrics.totalSpending(h, november).cents);
      expect(
        slices.fold<double>(0, (total, s) => total + s.share),
        closeTo(1, 1e-9),
      );
    });

    test('leaves out slices that net to zero', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          400,
          items: [
            item(400, categoryId: 1),
            item(250, discountCents: 250, categoryId: 2), // free
          ],
        ),
      ]);

      final slices = SpendingMetrics.spendingByCategory(h, november);
      expect(slices.map((s) => s.categoryId), [1]);
    });

    test('rolls sub-categories up to their top-level category', () {
      final h =
          history([
            receipt(
              DateTime(2026, 11, 3),
              600,
              items: [
                item(100, categoryId: 2),
                item(200, categoryId: 3),
                item(300, categoryId: 4),
              ],
            ),
          ]).copyWith(
            categories: {
              1: const CategoryInfo(id: 1, name: 'Food', icon: 'x', color: 0),
              2: const CategoryInfo(
                id: 2,
                name: 'Dairy',
                icon: 'x',
                color: 0,
                parentId: 1,
              ),
              3: const CategoryInfo(
                id: 3,
                name: 'Cheese',
                icon: 'x',
                color: 0,
                parentId: 2,
              ),
            },
          );

      final leaves = SpendingMetrics.spendingByCategory(h, november);
      expect(leaves.map((s) => s.categoryId), [4, 3, 2]);

      final rolled = SpendingMetrics.spendingByCategory(
        h,
        november,
        rollUpToParent: true,
      );
      // 4 is not in the lookup, so it stays as it is.
      expect(
        [for (final s in rolled) (s.categoryId, s.cents)],
        [(1, 300), (4, 300)],
      );
    });

    test('shares are zero when the total is not positive', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          -200,
          items: [item(-200, categoryId: 1)],
        ),
      ]);
      final slices = SpendingMetrics.spendingByCategory(h, november);
      expect(slices.single.cents, -200);
      expect(slices.single.share, 0);
    });

    test('empty history gives no slices', () {
      expect(
        SpendingMetrics.spendingByCategory(PurchaseHistory.empty, november),
        isEmpty,
      );
    });
  });

  group('M4 spendingByStore', () {
    test('totals, visits and average basket per store, largest first', () {
      final h = history([
        receipt(DateTime(2026, 11, 2), 1000, storeId: 1),
        receipt(DateTime(2026, 11, 9), 2001, storeId: 1),
        receipt(DateTime(2026, 11, 5), 4000, storeId: 2),
        receipt(DateTime(2026, 11, 6), 500), // unknown store
        receipt(DateTime(2026, 10, 30), 9999, storeId: 3), // outside
      ]);

      final stores = SpendingMetrics.spendingByStore(h, november);
      expect(stores, [
        const StoreSummary(storeId: 2, totalCents: 4000, receiptCount: 1),
        const StoreSummary(storeId: 1, totalCents: 3001, receiptCount: 2),
        const StoreSummary(totalCents: 500, receiptCount: 1),
      ]);
      expect(stores[1].averageBasketCents, 1501); // 1500.5 rounds up
      expect(stores[0].averageBasketCents, 4000);
    });

    test('ties go to more visits, then store id, unknown store last', () {
      final h = history([
        receipt(DateTime(2026, 11, 2), 1000),
        receipt(DateTime(2026, 11, 3), 1000, storeId: 7),
        receipt(DateTime(2026, 11, 4), 1000, storeId: 3),
        receipt(DateTime(2026, 11, 5), 400, storeId: 9),
        receipt(DateTime(2026, 11, 6), 600, storeId: 9),
      ]);

      final stores = SpendingMetrics.spendingByStore(h, november);
      expect(stores.map((s) => s.storeId), [9, 3, 7, null]);
    });

    test('empty history gives no stores', () {
      expect(
        SpendingMetrics.spendingByStore(PurchaseHistory.empty, november),
        isEmpty,
      );
    });
  });
}
