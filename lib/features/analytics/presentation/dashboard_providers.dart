import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/utils/async_values.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/dashboard_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/domain/models/shopping_suggestion.dart';
import 'package:scontrini/features/analytics/domain/shopping_suggestions.dart';

/// The dashboard's numbers for the current month, updated whenever a
/// receipt is confirmed, edited or deleted.
final Provider<AsyncValue<DashboardSummary>> dashboardSummaryProvider =
    Provider.autoDispose<AsyncValue<DashboardSummary>>((ref) {
      final today = ref.watch(clockProvider)();
      return mapAsync(
        ref.watch(purchaseHistoryProvider(DashboardMetrics.window(today))),
        (history) => DashboardMetrics.summary(history, today),
      );
    });

/// The next-shopping list for today, updated as receipts and the pantry
/// change.
final Provider<AsyncValue<List<ShoppingSuggestion>>>
shoppingSuggestionsProvider =
    Provider.autoDispose<AsyncValue<List<ShoppingSuggestion>>>((ref) {
      final today = ref.watch(clockProvider)();
      final purchases = ref.watch(
        purchaseHistoryProvider(ShoppingSuggestions.window(today)),
      );
      final pantry = ref.watch(pantryHistoryProvider);
      return combineAsync(
        purchases,
        pantry,
        (p, q) => ShoppingSuggestions.forToday(p, q, today),
      );
    });
