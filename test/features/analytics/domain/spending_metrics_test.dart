import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
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
}
