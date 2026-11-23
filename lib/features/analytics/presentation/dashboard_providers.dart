import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/dashboard_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';

/// The dashboard's numbers for the current month, updated whenever a
/// receipt is confirmed, edited or deleted.
final Provider<AsyncValue<DashboardSummary>> dashboardSummaryProvider =
    Provider.autoDispose<AsyncValue<DashboardSummary>>((ref) {
      final today = ref.watch(clockProvider)();
      return ref
          .watch(purchaseHistoryProvider(DashboardMetrics.window(today)))
          .whenData((history) => DashboardMetrics.summary(history, today));
    });
