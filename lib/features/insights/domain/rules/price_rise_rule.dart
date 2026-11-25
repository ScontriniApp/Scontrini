import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';

/// A product whose latest shelf price is well above what it usually cost
/// at the same store.
///
/// For each product bought in the last [recentDays] days, its latest
/// purchase is compared with the median full unit price of its purchases at
/// the **same store and unit** in the [referenceDays] days before. Same
/// store, because stores price differently: buying at a dearer shop once is
/// not a rise. Full price, because an offer is not a change in price. Per
/// kg or l for weighed rows, as the receipt prints them.
///
/// Fires at [minChangePercent] or more, with at least [minReferencePoints]
/// earlier purchases there, when the rise costs at least
/// [minMonthlyImpactCents] a month at the quantity usually bought.
class PriceRiseRule implements InsightRule {
  const new({
    this.minReferencePoints = 3,
    this.minChangePercent = 10,
    this.minMonthlyImpactCents = 20,
  });

  /// The latest purchase must be this recent.
  static const recentDays = 30;

  /// The window before it that the usual price is taken from.
  static const referenceDays = 90;

  final int minReferencePoints;
  final double minChangePercent;
  final int minMonthlyImpactCents;

  @override
  List<Insight> evaluate(InsightInput input) {
    final history = input.purchases;
    final recent = DateRange.lastDays(recentDays, now: input.today);

    final byProduct = <int, List<PricePoint>>{};
    for (final p in PriceMetrics.pricePoints(
      history,
      InsightInput.window(input.today),
    )) {
      (byProduct[p.productId] ??= []).add(p);
    }

    final insights = <Insight>[];
    for (final MapEntry(key: productId, value: points) in byProduct.entries) {
      // Points are oldest first.
      final latest = points.last;
      if (!recent.contains(latest.purchaseDate)) continue;

      final day = DateRange.day(latest.purchaseDate).start;
      final window = DateRange(day, day).extendBack(referenceDays);
      final sameUnit = [
        for (final p in points)
          if (p.unit == latest.unit && p.quantity > 0) p,
      ];
      final reference = [
        for (final p in sameUnit)
          if (p.storeId == latest.storeId && window.contains(p.purchaseDate))
            p.fullUnitPriceCents,
      ];
      if (reference.length < minReferencePoints) continue;

      final usual = _median(reference);
      if (usual <= 0) continue;
      final latestCents = latest.fullUnitPriceCents;
      if ((latestCents - usual) * 100 < minChangePercent * usual) continue;

      // How much is bought in a month: the reference window's quantity, any
      // store, in the same unit.
      final bought = sameUnit
          .where((p) => window.contains(p.purchaseDate))
          .fold<double>(0, (sum, p) => sum + p.quantity);
      final monthly = bought * 30 / referenceDays;

      final insight = Insight.priceRise(
        productId: productId,
        productName: history.products[productId]?.name ?? '#$productId',
        latestCents: latestCents,
        usualCents: usual,
        referenceCount: reference.length,
        monthlyQuantity: monthly,
        unit: latest.unit?.dbValue,
        storeName: history.stores[latest.storeId]?.name,
      );
      if (insight.monthlyImpactCents >= minMonthlyImpactCents) {
        insights.add(insight);
      }
    }
    return insights;
  }

  static int _median(List<int> values) {
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }
}
