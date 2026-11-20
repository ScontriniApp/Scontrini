import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';

part 'time_bucket.freezed.dart';

/// Spending in one day, week or month of a spending-over-time chart.
@freezed
abstract class TimeBucket with _$TimeBucket {
  const factory({
    required DateRange range,
    required int totalCents,
    required int receiptCount,
  }) = _TimeBucket;
}
