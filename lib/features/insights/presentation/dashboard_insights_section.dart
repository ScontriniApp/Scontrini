import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_providers.dart';
import 'package:scontrini/features/analytics/presentation/widgets/category_purchases_sheet.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/presentation/insights_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The dashboard's suggestions: the [shown] worth the most euros a month,
/// then "Mostra tutti". A spike opens the category's items this month; a
/// waste suggestion opens the product's statistics.
class DashboardInsightsSection extends ConsumerStatefulWidget {
  const new({super.key});

  static const shown = 3;

  @override
  ConsumerState<DashboardInsightsSection> createState() =>
      _DashboardInsightsSectionState();
}

class _DashboardInsightsSectionState
    extends ConsumerState<DashboardInsightsSection> {
  bool _expanded = false;

  void _open(Insight insight) {
    switch (insight) {
      case CategorySpikeInsight(:final categoryId):
        final slices = ref.read(dashboardSummaryProvider).value?.slices;
        final slice = slices
            ?.where((s) => s.category?.id == categoryId)
            .firstOrNull;
        if (slice != null) unawaited(showCategoryPurchases(context, slice));
      case FrequentWasteInsight(:final productId?) ||
          PriceRiseInsight(:final productId):
        unawaited(context.push(Routes.product(productId)));
      case FrequentWasteInsight():
        break;
    }
  }

  ({IconData icon, String title, String body}) _words(
    AppLocalizations l10n,
    Insight insight,
  ) {
    switch (insight) {
      case CategorySpikeInsight(
        :final categoryName,
        :final cents,
        :final usualCents,
        :final monthsCompared,
      ):
        final percent = NumberFormat.percentPattern(l10n.localeName)
            .format((cents - usualCents) / usualCents);
        return (
          icon: Icons.trending_up,
          title: l10n.insightSpikeTitle(categoryName, '+$percent'),
          body: l10n.insightSpikeBody(
            Money.format(cents),
            Money.format(usualCents),
            monthsCompared,
          ),
        );
      case FrequentWasteInsight(
        :final productName,
        :final wastedLots,
        :final closedLots,
        :final wastedCents,
        :final days,
      ):
        return (
          icon: Icons.delete_outline,
          title: l10n.insightWasteTitle(productName),
          body: l10n.insightWasteBody(
            wastedLots,
            closedLots,
            days,
            Money.format(wastedCents),
          ),
        );
      case PriceRiseInsight(
        :final productName,
        :final latestCents,
        :final usualCents,
        :final unit,
        :final storeName,
      ):
        final perUnit = unit == 'kg' || unit == 'l' ? '/$unit' : '';
        final change = NumberFormat.percentPattern(l10n.localeName)
            .format(insight.priceChange ?? 0);
        return (
          icon: Icons.sell_outlined,
          title: l10n.insightPriceTitle(productName),
          body: l10n.insightPriceBody(
            '${Money.format(latestCents)}$perUnit',
            '${Money.format(usualCents)}$perUnit',
            storeName ?? 'none',
            '+$change',
            Money.format(insight.monthlyImpactCents),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final insights = ref.watch(insightsProvider).value ?? const <Insight>[];
    final canExpand = insights.length > DashboardInsightsSection.shown;
    final rows = _expanded || !canExpand
        ? insights
        : insights.take(DashboardInsightsSection.shown);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.dashboardInsightsTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (insights.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.dashboardInsightsEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final insight in rows)
              Builder(
                builder: (context) {
                  final w = _words(l10n, insight);
                  return ListTile(
                    leading: Icon(w.icon),
                    title: Text(w.title),
                    subtitle: Text(w.body),
                    isThreeLine: true,
                    onTap: () => _open(insight),
                  );
                },
              ),
            if (canExpand)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? l10n.analyticsShowLess
                        : l10n.analyticsShowAll(insights.length),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
