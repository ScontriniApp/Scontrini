import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/insight_engine.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';

/// Today's suggestions, ranked, updated as receipts and the pantry change.
/// Shares the dashboard's purchase-history load (same window).
final Provider<AsyncValue<List<Insight>>> insightsProvider =
    Provider.autoDispose<AsyncValue<List<Insight>>>((ref) {
      final today = ref.watch(clockProvider)();
      final purchases = ref.watch(
        purchaseHistoryProvider(InsightInput.window(today)),
      );
      final pantry = ref.watch(pantryHistoryProvider);
      return switch ((purchases, pantry)) {
        (AsyncData(value: final p), AsyncData(value: final q)) => AsyncData(
          evaluateInsights(InsightInput(purchases: p, pantry: q, today: today)),
        ),
        (AsyncError(:final error, :final stackTrace), _) ||
        (
          _,
          AsyncError(:final error, :final stackTrace),
        ) => AsyncError(error, stackTrace),
        _ => const AsyncLoading(),
      };
    });
