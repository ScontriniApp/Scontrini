import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_providers.dart';
import 'package:scontrini/features/analytics/presentation/widgets/category_pie_card.dart';
import 'package:scontrini/features/analytics/presentation/widgets/month_total_card.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shopping_list_card.dart';
import 'package:scontrini/features/insights/presentation/dashboard_insights_section.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(dashboardSummaryProvider);

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
      body: switch (summary) {
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
    );
  }
}
