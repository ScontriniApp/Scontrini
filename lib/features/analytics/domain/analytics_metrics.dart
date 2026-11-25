import 'package:scontrini/features/analytics/domain/dashboard_metrics.dart';
import 'package:scontrini/features/analytics/domain/frequency_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_overview.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';

/// Builds the analytics tab's [AnalyticsOverview] from the metrics.
abstract final class AnalyticsMetrics {
  /// Smallest price change, in percent either way, that the products tab
  /// lists. Smaller ones are rounding and noise.
  static const minPriceChange = 5.0;

  /// What the DAO must load for [overview]: from the start of the
  /// comparison range, minus M6's reference window, to today.
  static DateRange window(AnalyticsPeriod period, DateTime today) {
    final current = period.toDate(today);
    final compared = period.comparison(today);
    return DateRange(
      compared.start,
      current.end,
    ).extendBack(PriceMetrics.defaultReferenceDays);
  }

  static AnalyticsOverview overview(
    PurchaseHistory history,
    AnalyticsPeriod period,
    DateTime today,
  ) {
    final range = period.toDate(today);
    final compared = period.comparison(today);

    String productName(int id) => history.products[id]?.name ?? '#$id';

    // Full price, so a promotion is not read as a price drop.
    final changes =
        [
          for (final c in PriceMetrics.priceChanges(
            history,
            range,
            basis: PriceBasis.full,
          ).values)
            if ((c.changePercent ?? 0).abs() >= minPriceChange)
              NamedPriceChange(change: c, name: productName(c.productId)),
        ]..sort(
          (a, b) => b.change.changePercent!.compareTo(a.change.changePercent!),
        );

    return AnalyticsOverview(
      period: period,
      range: range,
      comparedRange: compared,
      total: SpendingMetrics.totalSpending(history, range, previous: compared),
      receiptCount: history.receiptsIn(range).length,
      buckets: SpendingMetrics.spendingOverTime(
        history,
        period.range,
        period.granularity,
      ),
      granularity: period.granularity,
      categories: DashboardMetrics.slices(history, range),
      stores: [
        for (final s in SpendingMetrics.spendingByStore(history, range))
          NamedStore(summary: s, name: history.stores[s.storeId]?.name),
      ],
      savings: SpendingMetrics.savings(history, range, previous: compared),
      mostBought: [
        for (final f in FrequencyMetrics.mostFrequent(history, range))
          NamedFrequency(frequency: f, name: productName(f.productId)),
      ],
      priceRises: [
        for (final c in changes)
          if (c.change.changePercent! > 0) c,
      ],
      priceDrops: [
        for (final c in changes.reversed)
          if (c.change.changePercent! < 0) c,
      ],
    );
  }
}
