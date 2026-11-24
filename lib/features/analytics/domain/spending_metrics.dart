import 'package:scontrini/features/analytics/domain/models/category_share.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/models/savings.dart';
import 'package:scontrini/features/analytics/domain/models/store_summary.dart';
import 'package:scontrini/features/analytics/domain/models/time_bucket.dart';
import 'package:scontrini/features/analytics/domain/proportional_split.dart';

/// Spending metrics (M1–M4, M8) as pure functions over a
/// [PurchaseHistory].
///
/// Comparisons with the previous period read receipts before `range`, so the
/// history must be loaded with `range.extendBack(range.days)`; otherwise the
/// previous amounts come out as zero.
abstract final class SpendingMetrics {
  /// M1: sum of `totalCents` of the receipts in [range], compared with
  /// [previous] (by default the previous equal-length range). Trusts the
  /// printed totals, not the items.
  static PeriodAmount totalSpending(
    PurchaseHistory history,
    DateRange range, {
    DateRange? previous,
  }) => PeriodAmount(
    cents: _sumTotals(history, range),
    previousCents: _sumTotals(history, previous ?? range.previous()),
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

  /// M3: net spending per category in [range], largest first, with the
  /// uncategorised items in their own slice and an "Other" slice last.
  ///
  /// Each item counts its net amount (line total minus its own discount).
  /// A receipt-level discount (basket coupon) is spread over the receipt's
  /// non-returned items in proportion to their line totals, in whole cents.
  /// Whatever the items of a receipt leave unexplained of its printed total
  /// goes to "Other", so the slices always add up to M1. Slices of zero are
  /// left out.
  ///
  /// With [rollUpToParent], a sub-category counts towards its top-level
  /// category.
  static List<CategoryShare> spendingByCategory(
    PurchaseHistory history,
    DateRange range, {
    bool rollUpToParent = false,
  }) {
    // Key null = uncategorised.
    final byCategory = <int?, int>{};
    var otherCents = 0;

    for (final receipt in history.receiptsIn(range)) {
      final coupon = _couponParts(receipt);
      var allocated = 0;
      for (var i = 0; i < receipt.items.length; i++) {
        final item = receipt.items[i];
        final key = rollUpToParent
            ? _topLevel(history, item.categoryId)
            : item.categoryId;
        final cents = item.netCents - coupon[i];
        byCategory[key] = (byCategory[key] ?? 0) + cents;
        allocated += cents;
      }
      otherCents += receipt.totalCents - allocated;
    }

    final total = byCategory.values.fold(otherCents, (sum, c) => sum + c);
    double shareOf(int cents) => total > 0 ? cents / total : 0;

    final slices = [
      for (final MapEntry(:key, :value) in byCategory.entries)
        if (value != 0)
          CategoryShare(
            kind: key == null
                ? CategoryShareKind.uncategorised
                : CategoryShareKind.category,
            categoryId: key,
            cents: value,
            share: shareOf(value),
          ),
    ]..sort(_byAmountThenCategory);

    return [
      ...slices,
      if (otherCents != 0)
        CategoryShare(
          kind: CategoryShareKind.other,
          cents: otherCents,
          share: shareOf(otherCents),
        ),
    ];
  }

  /// M4: printed totals per store in [range], with the number of receipts
  /// and the average basket, largest total first. Receipts with no known
  /// store are grouped under a `null` store.
  static List<StoreSummary> spendingByStore(
    PurchaseHistory history,
    DateRange range,
  ) {
    final totals = <int?, int>{};
    final counts = <int?, int>{};
    for (final receipt in history.receiptsIn(range)) {
      final key = receipt.storeId;
      totals[key] = (totals[key] ?? 0) + receipt.totalCents;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return [
      for (final MapEntry(:key, :value) in totals.entries)
        StoreSummary(
          storeId: key,
          totalCents: value,
          receiptCount: counts[key]!,
        ),
    ]..sort((a, b) {
      final byTotal = b.totalCents.compareTo(a.totalCents);
      if (byTotal != 0) return byTotal;
      final byVisits = b.receiptCount.compareTo(a.receiptCount);
      if (byVisits != 0) return byVisits;
      return _compareIdsNullLast(a.storeId, b.storeId);
    });
  }

  /// M8: item and receipt-level discounts in [range] (returns excluded),
  /// compared with [previous] (by default the previous equal-length range),
  /// plus the amount paid so the UI can show the savings rate.
  static Savings savings(
    PurchaseHistory history,
    DateRange range, {
    DateRange? previous,
  }) => Savings(
    saved: PeriodAmount(
      cents: _sumSavings(history, range),
      previousCents: _sumSavings(history, previous ?? range.previous()),
    ),
    paidCents: _sumTotals(history, range),
  );

  static int _sumTotals(PurchaseHistory history, DateRange range) =>
      history.receiptsIn(range).fold(0, (sum, r) => sum + r.totalCents);

  static int _sumSavings(PurchaseHistory history, DateRange range) =>
      history.receiptsIn(range).fold(0, (sum, r) => sum + r.savingsCents);

  /// Each item's part of [receipt]'s basket coupon, weighted by line total;
  /// returned lines get none. All zero when there is no coupon or nothing to
  /// spread it over (then it ends up in "Other").
  static List<int> _couponParts(PurchaseReceipt receipt) {
    final weights = [
      for (final i in receipt.items)
        if (i.isReturn) 0 else i.lineTotalCents,
    ];
    if (receipt.discountCents <= 0 || weights.every((w) => w == 0)) {
      return List.filled(weights.length, 0);
    }
    return splitProportionally(receipt.discountCents, weights);
  }

  /// The top-level ancestor of [categoryId]. Unknown ids, and parent loops,
  /// stop the walk where they are.
  static int? _topLevel(PurchaseHistory history, int? categoryId) {
    var id = categoryId;
    final seen = <int>{};
    while (id != null && seen.add(id)) {
      final parent = history.categories[id]?.parentId;
      if (parent == null) break;
      id = parent;
    }
    return id;
  }

  /// Largest amount first; ties by category id, uncategorised last.
  static int _byAmountThenCategory(CategoryShare a, CategoryShare b) {
    final byAmount = b.cents.compareTo(a.cents);
    return byAmount != 0
        ? byAmount
        : _compareIdsNullLast(a.categoryId, b.categoryId);
  }

  static int _compareIdsNullLast(int? a, int? b) => switch ((a, b)) {
    (null, null) => 0,
    (null, _) => 1,
    (_, null) => -1,
    (final a?, final b?) => a.compareTo(b),
  };
}
