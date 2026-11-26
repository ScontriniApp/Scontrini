import 'dart:async';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_overview.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/features/analytics/presentation/period_format.dart';
import 'package:scontrini/features/analytics/presentation/widgets/category_purchases_sheet.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shelf_label.dart';
import 'package:scontrini/features/analytics/presentation/widgets/spending_chart_card.dart';
import 'package:scontrini/features/pantry/presentation/category_label.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The "Spesa" sub-tab: total against the period before, spending over
/// time, categories, stores and savings.
class SpendingTab extends StatelessWidget {
  const new({required this.overview, super.key});

  final AnalyticsOverview overview;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
    children: [
      _TotalCard(overview: overview),
      const SizedBox(height: 12),
      SpendingChartCard(
        buckets: overview.buckets,
        granularity: overview.granularity,
      ),
      const SizedBox(height: 12),
      _CategoriesCard(slices: overview.categories),
      const SizedBox(height: 12),
      _StoresCard(stores: overview.stores),
      const SizedBox(height: 12),
      _SavingsCard(overview: overview),
    ],
  );
}

/// "+12% rispetto a ottobre 2026: 93,00 €", or a note when the period
/// before had nothing.
String _changeText(
  AppLocalizations l10n,
  PeriodAmount amount,
  String comparedLabel,
) {
  final change = amount.changePercent;
  if (change == null) return l10n.analyticsNothingBefore(comparedLabel);
  final number = NumberFormat.decimalPattern(l10n.localeName);
  final rounded = change.round();
  final sign = rounded > 0
      ? '+'
      : rounded < 0
      ? '−'
      : '';
  return l10n.analyticsChangeVs(
    '$sign${number.format(rounded.abs())}%',
    l10n.analyticsComparedWith(
      comparedLabel,
      Money.format(amount.previousCents),
    ),
  );
}

String _comparedLabel(BuildContext context, AnalyticsOverview overview) =>
    PeriodFormat.range(
      overview.comparedRange,
      AppLocalizations.of(context).localeName,
      kind: overview.period.kind,
    );

/// The period's total as a [ShelfLabel].
class _TotalCard extends StatelessWidget {
  const new({required this.overview});

  final AnalyticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ShelfLabel(
      title: l10n.analyticsSpent,
      cents: overview.total.cents,
      leading: l10n.dashboardReceiptCount(overview.receiptCount),
      footer: _changeText(
        l10n,
        overview.total,
        _comparedLabel(context, overview),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// Every category with spending, with a bar against the largest; a tap
/// lists its items.
class _CategoriesCard extends StatelessWidget {
  const new({required this.slices});

  final List<DashboardSlice> slices;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final percent = NumberFormat.percentPattern(l10n.localeName);
    final largest = slices.fold(0, (m, s) => s.cents > m ? s.cents : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardTitle(l10n.analyticsCategoriesTitle),
            for (final s in slices)
              InkWell(
                onTap: () => unawaited(
                  showCategoryPurchases(
                    context,
                    s,
                    restLabel: l10n.analyticsUncategorised,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.category == null
                                  ? l10n.analyticsUncategorised
                                  : categoryLabel(l10n, s.category!.name),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            percent.format(s.share),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Money.format(s.cents),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: largest == 0 ? 0 : s.cents / largest,
                          minHeight: 8,
                          color: ChartPalette.series(context, s.colorSlot),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.dashboardCategoryHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoresCard extends StatelessWidget {
  const new({required this.stores});

  final List<NamedStore> stores;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardTitle(l10n.analyticsStoresTitle),
            for (final s in stores)
              ListTile(
                title: Text(s.name ?? l10n.analyticsUnknownStore),
                subtitle: Text(
                  l10n.analyticsStoreVisits(
                    s.summary.receiptCount,
                    Money.format(s.summary.averageBasketCents),
                  ),
                ),
                trailing: Text(
                  Money.format(s.summary.totalCents),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// What the discounts saved in the period, as a [ShelfLabel].
class _SavingsCard extends StatelessWidget {
  const new({required this.overview});

  final AnalyticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final savings = overview.savings;
    final rate = savings.rate;
    final percent = NumberFormat.decimalPercentPattern(
      locale: l10n.localeName,
      decimalDigits: 1,
    );
    return ShelfLabel(
      title: l10n.analyticsSavingsTitle,
      cents: savings.saved.cents,
      leading: rate == null
          ? ''
          : l10n.analyticsSavingsRate(percent.format(rate)),
      footer: _changeText(
        l10n,
        savings.saved,
        _comparedLabel(context, overview),
      ),
    );
  }
}
