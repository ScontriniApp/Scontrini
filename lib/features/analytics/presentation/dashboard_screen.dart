import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/app/tab_reselect.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_providers.dart';
import 'package:scontrini/features/analytics/presentation/refresh_analytics.dart';
import 'package:scontrini/features/analytics/presentation/widgets/category_pie_card.dart';
import 'package:scontrini/features/analytics/presentation/widgets/month_total_card.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shopping_list_card.dart';
import 'package:scontrini/features/insights/presentation/dashboard_insights_section.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Home: the month so far, categories, next shopping and suggestions. Tap
/// the Home tab again to refresh (pulling down does nothing on purpose).
class DashboardScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _refresh = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(dashboardSummaryProvider);
    ref.listen(tabReselectProvider, (_, tap) {
      if (tap?.branch == ShellBranch.home) {
        unawaited(_refresh.currentState?.show());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refresh,
        onRefresh: () => refreshPurchasesAndPantry(ref, dashboardWindows(ref)),
        // Only a tap on the open tab refreshes: scrolling past the top must
        // not reload the page.
        notificationPredicate: (_) => false,
        child: switch (summary) {
          AsyncData(:final value) when value.hasHistory => ListView(
            // Room at the bottom so the last card scrolls clear of the
            // "Aggiungi" button.
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              MonthTotalCard(summary: value),
              const SizedBox(height: 12),
              CategoryPieCard(slices: value.slices),
              const SizedBox(height: 12),
              const ShoppingListCard(),
              const SizedBox(height: 12),
              const DashboardInsightsSection(),
            ],
          ),
          AsyncData() => PlaceholderView(
            icon: Icons.receipt_long_outlined,
            message: l10n.dashboardEmpty,
          ),
          AsyncError(:final error) => Center(child: Text('$error')),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
