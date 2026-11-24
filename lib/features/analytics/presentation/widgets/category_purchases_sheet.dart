import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Shows the items behind a dashboard category slice: name, price paid and
/// date of purchase, newest first. [restLabel] names the slice without a
/// category (default "Altre categorie").
Future<void> showCategoryPurchases(
  BuildContext context,
  DashboardSlice slice, {
  String? restLabel,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.6,
    minChildSize: 0.3,
    maxChildSize: 0.95,
    builder: (context, controller) => CategoryPurchasesList(
      slice: slice,
      controller: controller,
      restLabel: restLabel,
    ),
  ),
);

class CategoryPurchasesList extends StatelessWidget {
  const new({required this.slice, this.controller, this.restLabel, super.key});

  final DashboardSlice slice;
  final ScrollController? controller;
  final String? restLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final unassigned = slice.unassignedCents;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: ChartPalette.series(context, slice.colorSlot),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  slice.category?.name ??
                      restLabel ??
                      l10n.dashboardOtherCategories,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                Money.format(slice.cents),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.dashboardItemCount(slice.purchases.length),
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ),
        const SizedBox(height: 8),
        for (final p in slice.purchases) _PurchaseTile(purchase: p),
        if (unassigned != 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              l10n.dashboardUnassigned(Money.format(unassigned)),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
      ],
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  const new({required this.purchase});

  final CategoryPurchase purchase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final p = purchase;
    final unit = p.unit;
    final details = [
      DateFormat.yMMMd(locale).format(p.purchaseDate.toLocal()),
      ?p.storeName,
      if (unit != null && unit.isMeasured)
        '${NumberFormat.decimalPattern(locale).format(p.quantity)} '
            '${unit.dbValue}'
      else if (p.quantity != 1)
        '× ${NumberFormat.decimalPattern(locale).format(p.quantity)}',
    ].join(' · ');
    final category = p.categoryName;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(p.name),
      subtitle: Text(
        [details, if (p.name != p.rawName) p.rawName, ?category].join('\n'),
      ),
      isThreeLine: p.name != p.rawName || category != null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(Money.format(p.netCents), style: theme.textTheme.bodyLarge),
          if (p.isDiscounted)
            Text(
              Money.format(p.fullCents),
              semanticsLabel: l10n.dashboardFullPrice(
                Money.format(p.fullCents),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }
}
