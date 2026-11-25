import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';

void main() {
  // A Tuesday.
  final today = DateTime(2026, 11, 24, 15);

  DateRange r(DateTime start, DateTime end) => DateRange(start, end);

  group('of', () {
    test('builds the calendar period that holds the day', () {
      expect(
        AnalyticsPeriod.of(PeriodKind.week, today).range,
        r(DateTime(2026, 11, 23), DateTime(2026, 11, 30)),
      );
      expect(
        AnalyticsPeriod.of(PeriodKind.month, today).range,
        r(DateTime(2026, 11), DateTime(2026, 12)),
      );
      expect(
        AnalyticsPeriod.of(PeriodKind.quarter, today).range,
        r(DateTime(2026, 9), DateTime(2026, 12)),
      );
      expect(
        AnalyticsPeriod.of(PeriodKind.year, today).range,
        r(DateTime(2026), DateTime(2027)),
      );
    });

    test('three months cross the year boundary', () {
      expect(
        AnalyticsPeriod.of(PeriodKind.quarter, DateTime(2026, 2, 10)).range,
        r(DateTime(2025, 12), DateTime(2026, 3)),
      );
    });

    test('custom needs a kind of its own and a non-empty range', () {
      expect(
        () => AnalyticsPeriod.of(PeriodKind.custom, today),
        throwsArgumentError,
      );
      expect(
        () => AnalyticsPeriod.custom(r(DateTime(2026), DateTime(2026))),
        throwsArgumentError,
      );
    });
  });

  group('shift', () {
    test('moves by whole calendar periods', () {
      final month = AnalyticsPeriod.of(PeriodKind.month, today);
      expect(month.shift(-1).range, r(DateTime(2026, 10), DateTime(2026, 11)));
      expect(month.shift(2).range, r(DateTime(2027), DateTime(2027, 2)));

      final quarter = AnalyticsPeriod.of(PeriodKind.quarter, today);
      expect(quarter.shift(-1).range, r(DateTime(2026, 6), DateTime(2026, 9)));

      final week = AnalyticsPeriod.of(PeriodKind.week, today);
      expect(
        week.shift(-1).range,
        r(DateTime(2026, 11, 16), DateTime(2026, 11, 23)),
      );

      final year = AnalyticsPeriod.of(PeriodKind.year, today);
      expect(year.shift(-1).range, r(DateTime(2025), DateTime(2026)));
    });

    test('a custom range moves by its own length', () {
      final custom = AnalyticsPeriod.custom(
        r(DateTime(2026, 11), DateTime(2026, 11, 11)),
      );
      expect(
        custom.shift(-1).range,
        r(DateTime(2026, 10, 22), DateTime(2026, 11)),
      );
      expect(custom.shift(-1).kind, PeriodKind.custom);
    });

    test('a week shift is safe across the DST change', () {
      // Europe's clocks go back on 25 October 2026.
      final week = AnalyticsPeriod.of(PeriodKind.week, DateTime(2026, 10, 28));
      expect(
        week.shift(-1).range,
        r(DateTime(2026, 10, 19), DateTime(2026, 10, 26)),
      );
    });
  });

  group('toDate and comparison', () {
    test('a running month is compared with the same days of the month '
        'before', () {
      final month = AnalyticsPeriod.of(PeriodKind.month, today);
      expect(month.isRunning(today), isTrue);
      expect(
        month.toDate(today),
        r(DateTime(2026, 11), DateTime(2026, 11, 25)),
      );
      expect(
        month.comparison(today),
        r(DateTime(2026, 10), DateTime(2026, 10, 25)),
      );
    });

    test('a finished month is compared with the whole month before', () {
      final october = AnalyticsPeriod.of(PeriodKind.month, DateTime(2026, 10));
      expect(october.isRunning(today), isFalse);
      expect(october.toDate(today), october.range);
      expect(
        october.comparison(today),
        r(DateTime(2026, 9), DateTime(2026, 10)),
      );
    });

    test('the comparison never runs past the shorter month', () {
      final march = AnalyticsPeriod.of(PeriodKind.month, DateTime(2026, 3));
      final today = DateTime(2026, 3, 31);
      expect(march.comparison(today), r(DateTime(2026, 2), DateTime(2026, 3)));
    });

    test('a running week is compared with the same weekdays of the week '
        'before', () {
      final week = AnalyticsPeriod.of(PeriodKind.week, today);
      expect(
        week.comparison(today),
        r(DateTime(2026, 11, 16), DateTime(2026, 11, 18)),
      );
    });

    test('a custom range is compared with the equal-length range before', () {
      final custom = AnalyticsPeriod.custom(
        r(DateTime(2026, 11), DateTime(2026, 11, 11)),
      );
      expect(
        custom.comparison(today),
        r(DateTime(2026, 10, 22), DateTime(2026, 11)),
      );
    });

    test('a period after today has no days yet', () {
      final next = AnalyticsPeriod.of(PeriodKind.month, today).shift(1);
      expect(next.toDate(today).isEmpty, isTrue);
    });
  });

  test('hasNext is false while the next period has not started', () {
    final month = AnalyticsPeriod.of(PeriodKind.month, today);
    expect(month.hasNext(today), isFalse);
    expect(month.shift(-1).hasNext(today), isTrue);
  });

  test('granularity follows the period', () {
    AnalyticsPeriod custom(int days) =>
        AnalyticsPeriod.custom(r(DateTime(2026), DateTime(2026, 1, 1 + days)));
    expect(
      AnalyticsPeriod.of(PeriodKind.week, today).granularity,
      Granularity.day,
    );
    expect(
      AnalyticsPeriod.of(PeriodKind.month, today).granularity,
      Granularity.week,
    );
    expect(
      AnalyticsPeriod.of(PeriodKind.quarter, today).granularity,
      Granularity.week,
    );
    expect(
      AnalyticsPeriod.of(PeriodKind.year, today).granularity,
      Granularity.month,
    );
    expect(custom(14).granularity, Granularity.day);
    expect(custom(15).granularity, Granularity.week);
    expect(custom(121).granularity, Granularity.month);
  });
}
