import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';
import 'package:scontrini/features/insights/domain/rules/category_spike_rule.dart';
import 'package:scontrini/features/insights/domain/rules/frequent_waste_rule.dart';
import 'package:scontrini/features/insights/domain/rules/price_rise_rule.dart';

/// The rules the app runs, in no particular order (the engine ranks).
const List<InsightRule> defaultInsightRules = [
  CategorySpikeRule(),
  FrequentWasteRule(),
  PriceRiseRule(),
];

/// Runs [rules] and ranks what they find: most euros per month at stake
/// first, ties by kind and name so the order is stable. A product gets one
/// suggestion at most, the one worth the most.
List<Insight> evaluateInsights(
  InsightInput input, {
  List<InsightRule> rules = defaultInsightRules,
}) {
  final ranked = [for (final rule in rules) ...rule.evaluate(input)]
    ..sort((a, b) {
      final byImpact = b.monthlyImpactCents.compareTo(a.monthlyImpactCents);
      return byImpact != 0 ? byImpact : _label(a).compareTo(_label(b));
    });
  final seen = <int>{};
  final kept = <Insight>[];
  for (final insight in ranked) {
    final id = _productId(insight);
    if (id == null || seen.add(id)) kept.add(insight);
  }
  return kept;
}

int? _productId(Insight i) => switch (i) {
  CategorySpikeInsight() => null,
  FrequentWasteInsight(:final productId) => productId,
  PriceRiseInsight(:final productId) => productId,
};

String _label(Insight i) => switch (i) {
  CategorySpikeInsight(:final categoryName) => 'a:$categoryName',
  FrequentWasteInsight(:final productName) => 'b:$productName',
  PriceRiseInsight(:final productName) => 'c:$productName',
};
