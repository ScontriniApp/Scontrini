import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_overview.dart';
import 'package:scontrini/features/analytics/presentation/analytics_overview_providers.dart';
import 'package:scontrini/features/analytics/presentation/period_format.dart';
import 'package:scontrini/features/analytics/presentation/widgets/pantry_tab.dart';
import 'package:scontrini/features/analytics/presentation/widgets/period_bar.dart';
import 'package:scontrini/features/analytics/presentation/widgets/products_tab.dart';
import 'package:scontrini/features/analytics/presentation/widgets/spending_tab.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The analytics tab: a period picker shared by three sub-tabs, "Spesa"
/// (totals, chart, categories, stores, savings), "Prodotti" (most bought,
/// price changes; a tap opens the product's statistics) and "Dispensa"
/// (where the spending went, waste).
class AnalyticsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(analyticsOverviewProvider);
    final pantry = ref.watch(pantryOverviewProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final today = ref.watch(clockProvider)();
    final comparedLabel = PeriodFormat.range(
      period.comparison(today),
      l10n.localeName,
      kind: period.kind,
    );

    Widget tab(Widget Function(AnalyticsOverview) builder) =>
        switch (overview) {
          AsyncData(:final value) when value.isEmpty => PlaceholderView(
            icon: Icons.insert_chart_outlined,
            message: l10n.analyticsNoReceipts,
          ),
          AsyncData(:final value) => builder(value),
          AsyncError(:final error) => Center(child: Text('$error')),
          _ => const Center(child: CircularProgressIndicator()),
        };

    final pantryTab = switch (pantry) {
      AsyncData(:final value) when !value.hasPantry => PlaceholderView(
        icon: Icons.kitchen_outlined,
        message: l10n.analyticsPantryEmpty,
      ),
      AsyncData(:final value) => PantryTab(
        overview: value,
        comparedLabel: comparedLabel,
      ),
      AsyncError(:final error) => Center(child: Text('$error')),
      _ => const Center(child: CircularProgressIndicator()),
    };

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navAnalytics),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.analyticsTabSpending),
              Tab(text: l10n.analyticsTabProducts),
              Tab(text: l10n.analyticsTabPantry),
            ],
          ),
        ),
        body: Column(
          children: [
            const PeriodBar(),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  tab((o) => SpendingTab(overview: o)),
                  tab((o) => ProductsTab(overview: o)),
                  pantryTab,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
