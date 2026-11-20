import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/models/savings.dart';
import 'package:scontrini/features/analytics/domain/models/time_bucket.dart';

/// Spending metrics (M1, M2, M8) as pure functions over a
/// [PurchaseHistory].
///
/// Comparisons with the previous period read receipts before `range`, so the
/// history must be loaded with `range.extendBack(range.days)`; otherwise the
/// previous amounts come out as zero.
abstract final class SpendingMetrics {
  /// M1: sum of `totalCents` of the receipts in [range], compared with the
  /// previous equal-length range. Trusts the printed totals, not the items.
  static PeriodAmount totalSpending(PurchaseHistory history, DateRange range) =>
      PeriodAmount(
        cents: _sumTotals(history, range),
        previousCents: _sumTotals(history, range.previous()),
      );

  /// M2: M1 per day, ISO week or month. Returns one bucket per period in
  /// [range], including empty ones, so the chart's time axis has no gaps; the
  /// first and last buckets are clipped to [range].
  static List<TimeBucket> spendingOverTime(
    PurchaseHistory history,
    DateRange range,
    Granularity granularity,
  ) {
    final buckets = range.split(granularity);
    final totals = List.filled(buckets.length, 0);
    final counts = List.filled(buckets.length, 0);

    // Receipts are few (hundreds a year), so a linear scan per receipt over
    // the buckets is fine; buckets are sorted, so stop at the first match.
    for (final receipt in history.receiptsIn(range)) {
      final i = buckets.indexWhere((b) => b.contains(receipt.purchaseDate));
      totals[i] += receipt.totalCents;
      counts[i]++;
    }

    return [
      for (var i = 0; i < buckets.length; i++)
        TimeBucket(
          range: buckets[i],
          totalCents: totals[i],
          receiptCount: counts[i],
        ),
    ];
  }

  /// M8: item and receipt-level discounts in [range] (returns excluded),
  /// compared with the previous equal-length range, plus the amount paid
  /// so the UI can show the savings rate.
  static Savings savings(PurchaseHistory history, DateRange range) => Savings(
    saved: PeriodAmount(
      cents: _sumSavings(history, range),
      previousCents: _sumSavings(history, range.previous()),
    ),
    paidCents: _sumTotals(history, range),
  );

  static int _sumTotals(PurchaseHistory history, DateRange range) =>
      history.receiptsIn(range).fold(0, (sum, r) => sum + r.totalCents);

  static int _sumSavings(PurchaseHistory history, DateRange range) =>
      history.receiptsIn(range).fold(0, (sum, r) => sum + r.savingsCents);
}
