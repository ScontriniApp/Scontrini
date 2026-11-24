import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/domain/models/price_change.dart';
import 'package:scontrini/features/analytics/domain/models/product_frequency.dart';
import 'package:scontrini/features/analytics/domain/models/savings.dart';
import 'package:scontrini/features/analytics/domain/models/store_summary.dart';
import 'package:scontrini/features/analytics/domain/models/time_bucket.dart';

part 'analytics_overview.freezed.dart';

/// Everything the analytics tab shows for one period.
@freezed
abstract class AnalyticsOverview with _$AnalyticsOverview {
  const factory({
    /// The period shown.
    required AnalyticsPeriod period,

    /// The days of the period up to today.
    required DateRange range,

    /// What [range] is compared with (see `AnalyticsPeriod.comparison`).
    required DateRange comparedRange,

    /// M1 over [range], against [comparedRange].
    required PeriodAmount total,
    required int receiptCount,

    /// M2 over the whole period (days after today are empty buckets).
    required List<TimeBucket> buckets,
    required Granularity granularity,

    /// M3: every category with spending, largest first, then the rest.
    required List<DashboardSlice> categories,

    /// M4, largest total first.
    required List<NamedStore> stores,

    /// M8 over [range], against [comparedRange].
    required Savings savings,

    /// M7, most receipts first.
    required List<NamedFrequency> mostBought,

    /// M6 on the full price, at least `AnalyticsMetrics.minPriceChange`
    /// up, largest rise first.
    required List<NamedPriceChange> priceRises,

    /// The same, down, largest drop first.
    required List<NamedPriceChange> priceDrops,
  }) = _AnalyticsOverview;

  const new _();

  bool get isEmpty => receiptCount == 0;
}

/// An M4 row with the store's name (null when the store is unknown).
@freezed
abstract class NamedStore with _$NamedStore {
  const factory({required StoreSummary summary, String? name}) = _NamedStore;
}

/// An M7 row with the product's name.
@freezed
abstract class NamedFrequency with _$NamedFrequency {
  const factory({required ProductFrequency frequency, required String name}) =
      _NamedFrequency;
}

/// An M6 result with the product's name.
@freezed
abstract class NamedPriceChange with _$NamedPriceChange {
  const factory({required PriceChange change, required String name}) =
      _NamedPriceChange;
}
