import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_overview.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The "Prodotti" sub-tab: most bought products and price changes. A tap
/// on a product opens its statistics (`/products/:id`).
class ProductsTab extends StatelessWidget {
  const new({required this.overview, super.key});

  final AnalyticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final day = DateFormat.MMMd(l10n.localeName);
    void open(int productId) =>
        unawaited(context.push(Routes.product(productId)));

    final noChanges =
        overview.priceRises.isEmpty && overview.priceDrops.isEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        Card(
          child: _ExpandableList(
            title: l10n.analyticsMostBoughtTitle,
            children: [
              for (final p in overview.mostBought)
                ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    l10n.analyticsTimesBought(
                      p.frequency.receiptCount,
                      day.format(p.frequency.lastPurchaseDate.toLocal()),
                    ),
                  ),
                  trailing: Text(
                    Money.format(p.frequency.netCents),
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () => open(p.frequency.productId),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(l10n.analyticsPriceChangesTitle),
                if (noChanges)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(l10n.analyticsNoPriceChanges),
                  ),
                if (overview.priceRises.isNotEmpty)
                  _ExpandableList(
                    subtitle: l10n.analyticsPriceRises,
                    children: [
                      for (final c in overview.priceRises)
                        _PriceChangeTile(change: c, onTap: open),
                    ],
                  ),
                if (overview.priceDrops.isNotEmpty)
                  _ExpandableList(
                    subtitle: l10n.analyticsPriceDrops,
                    children: [
                      for (final c in overview.priceDrops)
                        _PriceChangeTile(change: c, onTap: open),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(
                    l10n.analyticsPriceChangesHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// The first [_shown] rows, then "Mostra tutti (N)" / "Mostra meno".
class _ExpandableList extends StatefulWidget {
  const new({required this.children, this.title, this.subtitle});

  final String? title;
  final String? subtitle;
  final List<Widget> children;

  static const _shown = 5;

  @override
  State<_ExpandableList> createState() => _ExpandableListState();
}

class _ExpandableListState extends State<_ExpandableList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rows = widget.children;
    final title = widget.title;
    final subtitle = widget.subtitle;
    final canExpand = rows.length > _ExpandableList._shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) _Title(title),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              subtitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ...(_expanded || !canExpand ? rows : rows.take(_ExpandableList._shown)),
        if (canExpand)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? l10n.analyticsShowLess
                    : l10n.analyticsShowAll(rows.length),
              ),
            ),
          ),
      ],
    );
  }
}

class _PriceChangeTile extends StatelessWidget {
  const new({required this.change, required this.onTap});

  final NamedPriceChange change;
  final void Function(int productId) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = change.change;
    final unit = c.latest.unit;
    final perUnit = unit != null && unit.isMeasured ? '/${unit.dbValue}' : '';
    String price(int cents) => '${Money.format(cents)}$perUnit';
    final percent = c.changePercent ?? 0;
    final number = NumberFormat.decimalPattern(l10n.localeName);
    final sign = percent > 0 ? '+' : '−';
    return ListTile(
      title: Text(change.name),
      subtitle: Text(
        l10n.analyticsPriceVsUsual(
          price(c.latestCents),
          price(c.referenceCents),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            percent > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
          ),
          Text(
            '$sign${number.format(percent.abs().round())}%',
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
      onTap: () => onTap(c.productId),
    );
  }
}
