import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_overview.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/features/pantry/presentation/category_label.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The "Dispensa" sub-tab: where the period's spending went (used, thrown
/// away, still at home, never in the pantry) and what was thrown away in
/// the period.
class PantryTab extends StatelessWidget {
  const new({required this.overview, required this.comparedLabel, super.key});

  final PantryOverview overview;

  /// The compared period's label, for the waste change line.
  final String comparedLabel;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
    children: [
      _FateCard(fate: overview.fate),
      const SizedBox(height: 12),
      _WasteCard(overview: overview, comparedLabel: comparedLabel),
    ],
  );
}

class _Title extends StatelessWidget {
  const new(this.text, {this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = subtitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: theme.textTheme.titleMedium),
          if (sub != null)
            Text(
              sub,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// One stacked bar of the period's spending, with a legend that carries the
/// same numbers as text.
class _FateCard extends StatelessWidget {
  const new({required this.fate});

  final SpendingFate fate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final percent = NumberFormat.percentPattern(l10n.localeName);

    if (fate.isEmpty) {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(l10n.analyticsFateTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.analyticsFateNoReceipts),
            ),
          ],
        ),
      );
    }

    final notInPantry =
        '${l10n.analyticsFateNotInPantry}: '
        '${l10n.analyticsFateNotInPantryHint}.';
    final parts = [
      (l10n.analyticsFateUsed, fate.usedCents, ChartPalette.series(context, 2)),
      (
        l10n.analyticsFateWasted,
        fate.wastedCents,
        ChartPalette.series(context, 7),
      ),
      (
        l10n.analyticsFateInPantry,
        fate.inPantryCents,
        ChartPalette.series(context, 0),
      ),
      (
        l10n.analyticsFateNotInPantry,
        fate.notInPantryCents,
        ChartPalette.neutral(context),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(
              l10n.analyticsFateTitle,
              subtitle: l10n.analyticsFateSubtitle(
                Money.format(fate.totalCents),
              ),
            ),
            // The legend below carries the same numbers as text.
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        for (final (_, cents, color) in parts)
                          if (cents > 0)
                            Expanded(
                              flex: cents,
                              child: ColoredBox(color: color),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final (label, cents, color) in parts)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(label, style: theme.textTheme.bodyLarge),
                    ),
                    Text(
                      percent.format(cents / fate.totalCents),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(width: 12),
                    Text(Money.format(cents), style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                [
                  l10n.analyticsFateCoverage(
                    fate.untouchedLotCount,
                    fate.lotCount,
                  ),
                  if (fate.notInPantryCents > 0) notInPantry,
                ].join('\n'),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WasteCard extends StatelessWidget {
  const new({required this.overview, required this.comparedLabel});

  final PantryOverview overview;
  final String comparedLabel;

  String _reason(AppLocalizations l10n, PantryEventReason reason) =>
      switch (reason) {
        PantryEventReason.expired => l10n.analyticsWasteReasonExpired,
        PantryEventReason.spoiled => l10n.analyticsWasteReasonSpoiled,
        _ => l10n.analyticsWasteReasonOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final o = overview;
    final rate = o.wasteRate;
    final percent = NumberFormat.percentPattern(l10n.localeName);
    final largestCategory = o.categories.isEmpty ? 0 : o.categories.first.cents;

    Widget amountRow(String label, int cents, {VoidCallback? onTap}) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            Text(Money.format(cents), style: theme.textTheme.bodyLarge),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 20, color: muted),
          ],
        ),
      ),
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(
              l10n.analyticsWasteTitle,
              subtitle: l10n.analyticsWasteSubtitle,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Money.format(o.wasted.cents),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (rate != null)
                    Text(
                      l10n.analyticsWasteRate(percent.format(rate)),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  if (o.unpricedDiscards > 0)
                    Text(
                      l10n.analyticsWasteUnpriced(o.unpricedDiscards),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  const SizedBox(height: 8),
                  _WasteChange(amount: o.wasted, comparedLabel: comparedLabel),
                ],
              ),
            ),
            if (o.wasted.cents == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(l10n.analyticsWasteNone),
              )
            else ...[
              heading(l10n.analyticsWasteReasons),
              for (final r in o.reasons)
                amountRow(_reason(l10n, r.reason), r.cents),
              heading(l10n.analyticsWasteCategories),
              for (final c in o.categories)
                Padding(
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
                              c.category == null
                                  ? l10n.analyticsNoCategory
                                  : categoryLabel(l10n, c.category!.name),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            Money.format(c.cents),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: largestCategory == 0
                              ? 0
                              : c.cents / largestCategory,
                          minHeight: 8,
                          color: ChartPalette.series(context, c.colorSlot),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              heading(l10n.analyticsWasteProducts),
              for (final p in o.products.take(5))
                ListTile(
                  title: Text(p.name),
                  subtitle: Text(l10n.analyticsWasteLots(p.lotCount)),
                  trailing: Text(
                    Money.format(p.cents),
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: p.productId == null
                      ? null
                      : () => unawaited(
                          context.push(Routes.product(p.productId!)),
                        ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "+65% rispetto a 1 ott – 23 ott 2026: 7,45 €". Unlike spending, less is
/// better here, but the line stays neutral like the other cards.
class _WasteChange extends StatelessWidget {
  const new({required this.amount, required this.comparedLabel});

  final PeriodAmount amount;
  final String comparedLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final change = amount.changePercent;
    if (change == null) {
      return amount.cents == 0
          ? const SizedBox.shrink()
          : Text(l10n.analyticsNothingBefore(comparedLabel), style: style);
    }
    final rounded = change.round();
    final number = NumberFormat.decimalPattern(l10n.localeName);
    final sign = rounded > 0
        ? '+'
        : rounded < 0
        ? '−'
        : '';
    return Text(
      l10n.analyticsChangeVs(
        '$sign${number.format(rounded.abs())}%',
        l10n.analyticsComparedWith(
          comparedLabel,
          Money.format(amount.previousCents),
        ),
      ),
      style: style,
    );
  }
}
