import 'package:intl/intl.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';

/// Labels for analytics periods: "novembre 2026", "17 nov – 23 nov 2026",
/// "set – nov 2026", "2026".
abstract final class PeriodFormat {
  /// [range] as a label; a whole [kind] period gets that period's name
  /// rather than its first and last day.
  static String range(
    DateRange range,
    String locale, {
    PeriodKind kind = PeriodKind.custom,
  }) {
    if (range.isEmpty) return '';
    final first = range.start;
    final last = DateTime(range.end.year, range.end.month, range.end.day - 1);
    final whole =
        kind != PeriodKind.custom &&
        AnalyticsPeriod.of(kind, first).range == range;
    if (whole) {
      switch (kind) {
        case PeriodKind.month:
          return DateFormat.yMMMM(locale).format(first);
        case PeriodKind.quarter:
          return '${DateFormat.MMM(locale).format(first)} – '
              '${DateFormat.yMMM(locale).format(last)}';
        case PeriodKind.year:
          return DateFormat.y(locale).format(first);
        case PeriodKind.week:
        case PeriodKind.custom:
          break;
      }
    }
    if (first == last) return DateFormat.yMMMd(locale).format(first);
    final start = first.year == last.year
        ? DateFormat.MMMd(locale).format(first)
        : DateFormat.yMMMd(locale).format(first);
    return '$start – ${DateFormat.yMMMd(locale).format(last)}';
  }

  /// The selected period's label.
  static String period(AnalyticsPeriod period, String locale) =>
      range(period.range, locale, kind: period.kind);
}
