import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';

void main() {
  group('DateRange', () {
    test('drops the time of day and rejects an end before the start', () {
      final range = DateRange(
        DateTime(2026, 11, 3, 18, 30),
        DateTime(2026, 11, 5, 9),
      );
      expect(range.start, DateTime(2026, 11, 3));
      expect(range.end, DateTime(2026, 11, 5));
      expect(range.days, 2);
      expect(
        () => DateRange(DateTime(2026, 11, 5), DateTime(2026, 11, 3)),
        throwsArgumentError,
      );
    });

    test('week starts on Monday (ISO)', () {
      // Sunday 22 November 2026.
      final week = DateRange.week(DateTime(2026, 11, 22, 20));
      expect(week.start, DateTime(2026, 11, 16));
      expect(week.end, DateTime(2026, 11, 23));
      expect(DateRange.week(DateTime(2026, 11, 16)), week);
    });

    test('month and lastDays', () {
      expect(
        DateRange.month(DateTime(2026, 12, 31)),
        DateRange(DateTime(2026, 12), DateTime(2027)),
      );
      final last30 = DateRange.lastDays(30, now: DateTime(2026, 11, 20, 10));
      expect(last30.end, DateTime(2026, 11, 21));
      expect(last30.start, DateTime(2026, 10, 22));
      expect(last30.days, 30);
    });

    test('counts calendar days across a daylight-saving change', () {
      // Europe leaves summer time on 25 October 2026 (a 25-hour day).
      final october = DateRange.month(DateTime(2026, 10, 10));
      expect(october.days, 31);
      expect(october.split(Granularity.day), hasLength(31));
      expect(
        october.previous(),
        DateRange(DateTime(2026, 8, 31), october.start),
      );
    });

    test('contains uses the local day of a UTC instant', () {
      final saturday = DateRange.day(DateTime(2026, 11, 21));
      final lateSaturday = DateTime(2026, 11, 21, 23, 30).toUtc();
      expect(saturday.contains(lateSaturday), isTrue);
      expect(saturday.contains(DateTime(2026, 11, 22)), isFalse);
      expect(saturday.contains(DateTime(2026, 11, 20, 23, 59)), isFalse);
    });

    test('previous and extendBack', () {
      final range = DateRange(DateTime(2026, 11, 10), DateTime(2026, 11, 20));
      expect(
        range.previous(),
        DateRange(DateTime(2026, 10, 31), DateTime(2026, 11, 10)),
      );
      expect(
        range.extendBack(90),
        DateRange(DateTime(2026, 8, 12), DateTime(2026, 11, 20)),
      );
    });

    test('split clips the first and last buckets to the range', () {
      // Wednesday 4 to Saturday 21 November.
      final range = DateRange(DateTime(2026, 11, 4), DateTime(2026, 11, 21));
      expect(range.split(Granularity.week), [
        DateRange(DateTime(2026, 11, 4), DateTime(2026, 11, 9)),
        DateRange(DateTime(2026, 11, 9), DateTime(2026, 11, 16)),
        DateRange(DateTime(2026, 11, 16), DateTime(2026, 11, 21)),
      ]);
      expect(
        DateRange(
          DateTime(2026, 6),
          DateTime(2026, 12),
        ).split(Granularity.month),
        hasLength(6),
      );
      expect(
        DateRange(DateTime(2026, 6), DateTime(2026, 6)).split(Granularity.day),
        isEmpty,
      );
    });
  });
}
