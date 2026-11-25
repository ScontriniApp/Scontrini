import 'package:scontrini/features/analytics/domain/models/category_share.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';

/// A category whose spending so far this month is well above the same days
/// of the last [comparedMonths] months.
///
/// Same days, not whole months: on the 10th, 1–10 November is compared with
/// 1–10 October, September and August, so the rule is fair early in the
/// month too. Only months with any receipt count (a month away on holiday
/// is not a usual month), and at least [minMonths] are needed. Before the
/// [minDay]th the month holds one or two trips, too few to call a trend.
class CategorySpikeRule implements InsightRule {
  const new({
    this.comparedMonths = 3,
    this.minMonths = 2,
    this.minDay = 7,
    this.minRatio = 1.3,
    this.minExtraCents = 1000,
  });

  final int comparedMonths;
  final int minMonths;
  final int minDay;

  /// Month to date must be at least this many times the usual amount...
  final double minRatio;

  /// ...and at least this much above it, so small categories don't fire on
  /// a single extra item.
  final int minExtraCents;

  @override
  List<Insight> evaluate(InsightInput input) {
    final d = input.today.toLocal();
    if (d.day < minDay) return const [];
    final history = input.purchases;
    final monthToDate = DateRange(
      DateTime(d.year, d.month),
      DateRange.day(d).end,
    );

    Map<int, int> byCategory(DateRange range) => {
      for (final s in SpendingMetrics.spendingByCategory(history, range))
        if (s.kind == CategoryShareKind.category) s.categoryId!: s.cents,
    };

    final earlier = <Map<int, int>>[];
    for (var k = 1; k <= comparedMonths; k++) {
      final whole = DateRange.month(DateTime(d.year, d.month - k));
      if (!history.receipts.any((r) => whole.contains(r.purchaseDate))) {
        continue;
      }
      final end = DateTime(whole.start.year, whole.start.month, d.day + 1);
      earlier.add(
        byCategory(
          DateRange(whole.start, end.isAfter(whole.end) ? whole.end : end),
        ),
      );
    }
    if (earlier.length < minMonths) return const [];

    return [
      for (final MapEntry(key: id, value: cents) in byCategory(
        monthToDate,
      ).entries)
        if (_spike(cents, earlier, id) case final usual?)
          Insight.categorySpike(
            categoryId: id,
            categoryName: history.categories[id]?.name ?? '#$id',
            cents: cents,
            usualCents: usual,
            monthsCompared: earlier.length,
          ),
    ];
  }

  /// The usual amount when [cents] is a spike against it, else null. A
  /// category new this month (usual 0) is not a spike: nothing to compare.
  int? _spike(int cents, List<Map<int, int>> earlier, int id) {
    final usual =
        (earlier.fold(0, (sum, m) => sum + (m[id] ?? 0)) / earlier.length)
            .round();
    if (usual <= 0) return null;
    return cents >= usual * minRatio && cents - usual >= minExtraCents
        ? usual
        : null;
  }
}
