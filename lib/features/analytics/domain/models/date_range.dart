import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';

/// A half-open range of whole local days, `[start, end)`.
///
/// Both ends are local midnights. Purchase dates are stored in UTC, so
/// [contains] converts them to local time first: a Saturday-night purchase
/// belongs to Saturday.
///
/// Arithmetic is done on calendar days, not on `Duration`s, so ranges stay
/// correct across daylight-saving changes.
@immutable
class DateRange {
  /// Creates a range from [start] (inclusive) to [end] (exclusive). Times of
  /// day are dropped, so both ends become local midnights.
  new(DateTime start, DateTime end)
    : start = _dateOnly(start),
      end = _dateOnly(end) {
    if (this.end.isBefore(this.start)) {
      throw ArgumentError('end ($end) is before start ($start)');
    }
  }

  /// The single local day containing [day].
  factory day(DateTime day) {
    final d = day.toLocal();
    return DateRange(d, DateTime(d.year, d.month, d.day + 1));
  }

  /// The ISO week (Monday to Sunday) containing [day].
  factory week(DateTime day) {
    final d = day.toLocal();
    final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
    return DateRange(
      monday,
      DateTime(monday.year, monday.month, monday.day + 7),
    );
  }

  /// The calendar month containing [day].
  factory month(DateTime day) {
    final d = day.toLocal();
    return DateRange(DateTime(d.year, d.month), DateTime(d.year, d.month + 1));
  }

  /// The [days] whole days ending with the day that contains [now]
  /// (e.g. "the last 30 days").
  factory lastDays(int days, {required DateTime now}) {
    final end = DateRange.day(now).end;
    return DateRange(DateTime(end.year, end.month, end.day - days), end);
  }

  /// First day in the range, local midnight.
  final DateTime start;

  /// First day after the range, local midnight.
  final DateTime end;

  /// Number of calendar days in the range.
  int get days => _utcDate(end).difference(_utcDate(start)).inDays;

  bool get isEmpty => days == 0;

  /// Whether the instant [time] (UTC or local) falls on a day in the range.
  bool contains(DateTime time) {
    final local = time.toLocal();
    return !local.isBefore(start) && local.isBefore(end);
  }

  /// The range of the same number of days that ends where this one starts.
  /// Used for "change vs previous period".
  DateRange previous() =>
      DateRange(DateTime(start.year, start.month, start.day - days), start);

  /// This range extended backwards by [days] days, e.g. to load the history
  /// a reference price or a previous period needs.
  DateRange extendBack(int days) =>
      DateRange(DateTime(start.year, start.month, start.day - days), end);

  /// Splits the range into consecutive buckets. The first and last buckets
  /// are clipped to the range, so a range that starts mid-week begins with a
  /// partial week.
  List<DateRange> split(Granularity granularity) {
    final buckets = <DateRange>[];
    var cursor = start;
    while (cursor.isBefore(end)) {
      final full = switch (granularity) {
        Granularity.day => DateRange.day(cursor),
        Granularity.week => DateRange.week(cursor),
        Granularity.month => DateRange.month(cursor),
      };
      final bucketEnd = full.end.isAfter(end) ? end : full.end;
      buckets.add(DateRange(cursor, bucketEnd));
      cursor = bucketEnd;
    }
    return buckets;
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange(${_fmt(start)}, ${_fmt(end)})';

  static DateTime _dateOnly(DateTime t) {
    final local = t.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime _utcDate(DateTime t) => DateTime.utc(t.year, t.month, t.day);

  static String _fmt(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}
