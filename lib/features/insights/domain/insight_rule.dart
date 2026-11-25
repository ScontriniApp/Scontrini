import 'package:scontrini/features/analytics/domain/dashboard_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/rules/price_rise_rule.dart';

/// What every rule reads: the confirmed purchases of [window], the whole
/// pantry, and today.
class InsightInput {
  const new({
    required this.purchases,
    required this.pantry,
    required this.today,
  });

  /// The purchase history rules need loaded: the current month and the
  /// three before (category spike), or the last 30 days plus the 90 before
  /// them (price rise), whichever starts earlier.
  static DateRange window(DateTime today) {
    final dashboard = DashboardMetrics.window(today);
    final prices = DateRange.lastDays(
      PriceRiseRule.recentDays,
      now: today,
    ).extendBack(PriceRiseRule.referenceDays);
    return prices.start.isBefore(dashboard.start) ? prices : dashboard;
  }

  final PurchaseHistory purchases;
  final PantryHistory pantry;
  final DateTime today;
}

/// One kind of suggestion. Pure: same input, same insights.
// One method on purpose: the engine treats every rule alike.
abstract interface class InsightRule {
  List<Insight> evaluate(InsightInput input);
}
