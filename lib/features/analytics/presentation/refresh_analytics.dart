import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/dashboard_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/shopping_suggestions.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';

/// Refresh (tap the open tab again): reloads the purchase history and the
/// pantry from the database, and every figure built on them is worked out
/// again for the current time, so a screen left open past midnight moves to
/// the new day.
/// Completes when the [windows] a screen shows have loaded (at most a few
/// seconds, so the spinner never hangs).
Future<void> refreshPurchasesAndPantry(
  WidgetRef ref,
  Iterable<DateRange> windows,
) async {
  ref
    ..invalidate(purchaseHistoryProvider)
    ..invalidate(pantryHistoryProvider);
  // After midnight a window is a new one nobody listens to yet: hold it
  // while waiting, or Riverpod disposes it mid-load.
  final held = [
    for (final w in windows)
      ref.listenManual(purchaseHistoryProvider(w), (_, _) {}),
    ref.listenManual(pantryHistoryProvider, (_, _) {}),
  ];
  try {
    await Future.wait<Object>([
      for (final w in windows) ref.read(purchaseHistoryProvider(w).future),
      ref.read(pantryHistoryProvider.future),
    ]).timeout(const Duration(seconds: 5), onTimeout: () => const <Object>[]);
  } finally {
    for (final h in held) {
      h.close();
    }
  }
}

/// The windows the dashboard's cards load, for today.
List<DateRange> dashboardWindows(WidgetRef ref) {
  final today = ref.read(clockProvider)();
  return [
    DashboardMetrics.window(today),
    ShoppingSuggestions.window(today),
    InsightInput.window(today),
  ];
}
