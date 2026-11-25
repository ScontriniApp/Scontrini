import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/utils/async_values.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/analytics_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_overview.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_overview.dart';
import 'package:scontrini/features/analytics/domain/pantry_metrics.dart';

/// The period the analytics tab shows; both sub-tabs share it. Starts on the
/// current month and is kept while the app runs.
final NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>
analyticsPeriodProvider = NotifierProvider(AnalyticsPeriodNotifier.new);

class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  DateTime get _today => ref.read(clockProvider)();

  /// When the current period was chosen, for [followToday].
  late DateTime _chosenOn;

  void _set(AnalyticsPeriod period) {
    _chosenOn = _today;
    state = period;
  }

  @override
  AnalyticsPeriod build() {
    _chosenOn = _today;
    return AnalyticsPeriod.of(PeriodKind.month, _chosenOn);
  }

  /// Switches to [kind], on the period that holds the last day shown so far
  /// (so going from October to "week" shows October's last week).
  void select(PeriodKind kind) {
    if (kind == state.kind) return;
    final shown = state.toDate(_today);
    final lastDay = shown.isEmpty
        ? shown.start
        : DateTime(shown.end.year, shown.end.month, shown.end.day - 1);
    _set(AnalyticsPeriod.of(kind, lastDay));
  }

  /// One period back (-1) or forward (+1); never past today.
  void shift(int steps) {
    if (steps > 0 && !state.hasNext(_today)) return;
    _set(state.shift(steps));
  }

  void custom(DateRange range) => _set(AnalyticsPeriod.custom(range));

  /// After a refresh: when the period held the day it was chosen on (the
  /// current week, month, …) and no longer holds today, the day changed
  /// while the app was open, so move to the period that holds today. A
  /// period the user went back to, or a custom range, stays.
  void followToday() {
    final today = _today;
    if (state.kind == PeriodKind.custom) return;
    if (state.range.contains(_chosenOn) && !state.range.contains(today)) {
      _set(AnalyticsPeriod.of(state.kind, today));
    }
  }
}

/// The analytics tab's numbers for the selected period, updated whenever a
/// receipt is confirmed, edited or deleted.
final Provider<AsyncValue<AnalyticsOverview>> analyticsOverviewProvider =
    Provider.autoDispose<AsyncValue<AnalyticsOverview>>((ref) {
      final today = ref.watch(clockProvider)();
      final period = ref.watch(analyticsPeriodProvider);
      return mapAsync(
        ref.watch(
          purchaseHistoryProvider(AnalyticsMetrics.window(period, today)),
        ),
        (history) => AnalyticsMetrics.overview(history, period, today),
      );
    });

/// The "Dispensa" sub-tab's numbers for the selected period: the same
/// purchase history as [analyticsOverviewProvider] plus the pantry.
final Provider<AsyncValue<PantryOverview>> pantryOverviewProvider =
    Provider.autoDispose<AsyncValue<PantryOverview>>((ref) {
      final today = ref.watch(clockProvider)();
      final period = ref.watch(analyticsPeriodProvider);
      final purchases = ref.watch(
        purchaseHistoryProvider(AnalyticsMetrics.window(period, today)),
      );
      final pantry = ref.watch(pantryHistoryProvider);
      return combineAsync(
        purchases,
        pantry,
        (p, q) => PantryMetrics.overview(p, q, period, today),
      );
    });
