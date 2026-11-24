import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';

/// The kinds of period the analytics tab can show.
enum PeriodKind {
  /// An ISO week, Monday to Sunday.
  week,

  /// A calendar month.
  month,

  /// Three calendar months, ending with the month of the anchor day.
  quarter,

  /// A calendar year.
  year,

  /// Any range of days the user picks.
  custom,
}

/// The period the analytics tab shows: a calendar week, month, three months
/// or year, or a custom range.
///
/// Calendar periods compare with the previous calendar period (November with
/// October), not with the previous equal-length range: "vs last month" then
/// means what it says. While a period is still running, both sides stop at
/// the same day: 1–24 November is compared with 1–24 October. A custom range
/// compares with the equal-length range before it, as the spec says.
@immutable
class AnalyticsPeriod {
  const new _(this.kind, this.range);

  /// The [kind] period that contains [day]. [kind] must not be
  /// [PeriodKind.custom] (use [AnalyticsPeriod.custom]).
  factory of(PeriodKind kind, DateTime day) {
    final d = day.toLocal();
    return switch (kind) {
      PeriodKind.week => ._(kind, DateRange.week(d)),
      PeriodKind.month => ._(kind, DateRange.month(d)),
      PeriodKind.quarter => ._(
        kind,
        DateRange(DateTime(d.year, d.month - 2), DateTime(d.year, d.month + 1)),
      ),
      PeriodKind.year => ._(
        kind,
        DateRange(DateTime(d.year), DateTime(d.year + 1)),
      ),
      PeriodKind.custom => throw ArgumentError.value(
        kind,
        'kind',
        'use AnalyticsPeriod.custom',
      ),
    };
  }

  /// A range the user picked. It must hold at least one day.
  factory custom(DateRange range) {
    if (range.isEmpty) {
      throw ArgumentError.value(range, 'range', 'is empty');
    }
    return ._(PeriodKind.custom, range);
  }

  final PeriodKind kind;

  /// The whole period, including days after today.
  final DateRange range;

  /// The period [steps] periods later (earlier when negative). A custom range
  /// moves by its own length.
  AnalyticsPeriod shift(int steps) {
    final s = range.start;
    return switch (kind) {
      PeriodKind.week => .of(
        kind,
        DateTime(s.year, s.month, s.day + 7 * steps),
      ),
      PeriodKind.month => .of(kind, DateTime(s.year, s.month + steps)),
      // `of` anchors on the last of the three months.
      PeriodKind.quarter => .of(
        kind,
        DateTime(s.year, s.month + 2 + 3 * steps),
      ),
      PeriodKind.year => .of(kind, DateTime(s.year + steps)),
      PeriodKind.custom => .custom(
        DateRange(
          DateTime(s.year, s.month, s.day + range.days * steps),
          DateTime(s.year, s.month, s.day + range.days * (steps + 1)),
        ),
      ),
    };
  }

  /// The days of the period up to and including [today]: the whole period
  /// once it is over, empty if it starts after today.
  DateRange toDate(DateTime today) {
    final end = DateRange.day(today).end;
    if (!end.isBefore(range.end)) return range;
    if (!end.isAfter(range.start)) return DateRange(range.start, range.start);
    return DateRange(range.start, end);
  }

  /// Whether the period has days after [today].
  bool isRunning(DateTime today) => toDate(today) != range;

  /// Whether the next period has started by [today].
  bool hasNext(DateTime today) =>
      !shift(1).range.start.isAfter(DateRange.day(today).start);

  /// What [toDate] is compared with: the previous calendar period, cut to as
  /// many days as [toDate] has (and never longer than that period); for a
  /// custom range, the equal-length range before it.
  DateRange comparison(DateTime today) {
    final current = toDate(today);
    if (kind == PeriodKind.custom) return current.previous();
    final previous = shift(-1).range;
    if (!isRunning(today)) return previous;
    final s = previous.start;
    final end = DateTime(s.year, s.month, s.day + current.days);
    return DateRange(s, end.isAfter(previous.end) ? previous.end : end);
  }

  /// Bar size of the spending chart: days for a week, weeks for a month or
  /// three months, months for a year. A custom range picks by its length.
  Granularity get granularity => switch (kind) {
    PeriodKind.week => Granularity.day,
    PeriodKind.month || PeriodKind.quarter => Granularity.week,
    PeriodKind.year => Granularity.month,
    PeriodKind.custom =>
      range.days <= 14
          ? Granularity.day
          : range.days <= 120
          ? Granularity.week
          : Granularity.month,
  };

  @override
  bool operator ==(Object other) =>
      other is AnalyticsPeriod && other.kind == kind && other.range == range;

  @override
  int get hashCode => Object.hash(kind, range);

  @override
  String toString() => 'AnalyticsPeriod($kind, $range)';
}
