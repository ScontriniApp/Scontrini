import 'dart:math';

import 'package:scontrini/features/analytics/domain/models/category_share.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';

/// Builds the dashboard's [DashboardSummary] from the metrics.
abstract final class DashboardMetrics {
  /// Categories drawn on their own; smaller ones join the rest slice.
  static const maxCategorySlices = 4;

  /// Earlier months the usual spending is averaged over.
  static const comparedMonths = 3;

  /// What the DAO must load for [summary]: the current month up to today and
  /// the [comparedMonths] before it.
  static DateRange window(DateTime today) {
    final d = today.toLocal();
    return DateRange(
      DateTime(d.year, d.month - comparedMonths),
      DateRange.day(d).end,
    );
  }

  static DashboardSummary summary(PurchaseHistory history, DateTime today) {
    final d = today.toLocal();
    final month = DateRange.month(d);
    final monthToDate = DateRange(month.start, DateRange.day(d).end);

    // The same days (1 to today's day, clipped to the month's length) of
    // each earlier month that had any receipt.
    final earlier = <int>[];
    for (var k = 1; k <= comparedMonths; k++) {
      final whole = DateRange.month(DateTime(d.year, d.month - k));
      if (!history.receipts.any((r) => whole.contains(r.purchaseDate))) {
        continue;
      }
      final end = DateTime(whole.start.year, whole.start.month, d.day + 1);
      final days = DateRange(
        whole.start,
        end.isAfter(whole.end) ? whole.end : end,
      );
      earlier.add(SpendingMetrics.totalSpending(history, days).cents);
    }

    return DashboardSummary(
      month: month,
      monthToDate: monthToDate,
      monthToDateCents: SpendingMetrics.totalSpending(
        history,
        monthToDate,
      ).cents,
      receiptCount: history.receipts
          .where((r) => monthToDate.contains(r.purchaseDate))
          .length,
      usualCents: earlier.isEmpty
          ? null
          : (earlier.reduce((a, b) => a + b) / earlier.length).round(),
      slices: slices(history, monthToDate),
      hasHistory: history.receipts.isNotEmpty,
    );
  }

  /// Category slices of [range], largest first: up to [maxSlices]
  /// categories (all of them when null), then one slice with the rest
  /// (smaller categories, uncategorised items, the gap to the receipt
  /// totals). Each slice lists its items, newest first.
  static List<DashboardSlice> slices(
    PurchaseHistory history,
    DateRange range, {
    int? maxSlices = maxCategorySlices,
  }) {
    final shares = SpendingMetrics.spendingByCategory(history, range);
    final ids = history.categories.keys.toList()..sort();

    final named = [
      for (final s in shares)
        if (s.kind == CategoryShareKind.category && s.cents > 0) s,
    ];
    final drawn = (maxSlices == null ? named : named.take(maxSlices)).toList();
    final rest =
        shares.fold<int>(0, (sum, s) => sum + s.cents) -
        drawn.fold<int>(0, (sum, s) => sum + s.cents);

    final parts = <(int?, int)>[
      for (final s in drawn) (s.categoryId, s.cents),
      if (rest > 0) (null, rest),
    ];
    final total = parts.fold(0, (sum, p) => sum + p.$2);
    final drawnIds = {for (final s in drawn) s.categoryId};
    final purchases = _purchases(history, range);
    return [
      for (final (id, cents) in parts)
        DashboardSlice(
          cents: cents,
          share: cents / max(total, 1),
          category: id == null ? null : history.categories[id],
          colorSlot: id == null ? null : ids.indexOf(id),
          purchases: [
            for (final (categoryId, purchase) in purchases)
              if (id == null
                  ? !drawnIds.contains(categoryId)
                  : categoryId == id)
                purchase,
          ],
        ),
    ];
  }

  /// Every item bought in [range] with its category id, newest first.
  static List<(int?, CategoryPurchase)> _purchases(
    PurchaseHistory history,
    DateRange range,
  ) => [
    for (final r in history.receipts.reversed)
      if (range.contains(r.purchaseDate))
        for (final i in r.items.reversed)
          (
            i.categoryId,
            CategoryPurchase(
              itemId: i.id,
              name: history.products[i.productId]?.name ?? i.rawName,
              rawName: i.rawName,
              purchaseDate: r.purchaseDate,
              netCents: i.netCents,
              fullCents: i.lineTotalCents,
              quantity: i.quantity,
              unit: i.unit,
              storeName: history.stores[r.storeId]?.name,
              categoryName: history.categories[i.categoryId]?.name,
            ),
          ),
  ];
}
