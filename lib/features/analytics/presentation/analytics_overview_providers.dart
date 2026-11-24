import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/analytics_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_overview.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';

/// The period the analytics tab shows; both sub-tabs share it. Starts on the
/// current month and is kept while the app runs.
final NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>
analyticsPeriodProvider = NotifierProvider(AnalyticsPeriodNotifier.new);

class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  DateTime get _today => ref.read(clockProvider)();

  @override
  AnalyticsPeriod build() => AnalyticsPeriod.of(PeriodKind.month, _today);

  /// Switches to [kind], on the period that holds the last day shown so far
  /// (so going from October to "week" shows October's last week).
  void select(PeriodKind kind) {
    if (kind == state.kind) return;
    final shown = state.toDate(_today);
    final lastDay = shown.isEmpty
        ? shown.start
        : DateTime(shown.end.year, shown.end.month, shown.end.day - 1);
    state = AnalyticsPeriod.of(kind, lastDay);
  }

  /// One period back (-1) or forward (+1); never past today.
  void shift(int steps) {
    if (steps > 0 && !state.hasNext(_today)) return;
    state = state.shift(steps);
  }

  void custom(DateRange range) => state = AnalyticsPeriod.custom(range);
}

/// The analytics tab's numbers for the selected period, updated whenever a
/// receipt is confirmed, edited or deleted.
final Provider<AsyncValue<AnalyticsOverview>> analyticsOverviewProvider =
    Provider.autoDispose<AsyncValue<AnalyticsOverview>>((ref) {
      final today = ref.watch(clockProvider)();
      final period = ref.watch(analyticsPeriodProvider);
      return ref
          .watch(
            purchaseHistoryProvider(AnalyticsMetrics.window(period, today)),
          )
          .whenData(
            (history) => AnalyticsMetrics.overview(history, period, today),
          );
    });
