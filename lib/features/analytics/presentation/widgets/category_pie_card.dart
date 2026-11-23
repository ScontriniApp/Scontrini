import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/features/analytics/presentation/widgets/category_purchases_sheet.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// This month's spending by category: a donut and, under it, a legend with
/// each category's amount and share, so no slice is read by colour alone.
/// Tapping a slice or a legend row lists that category's items.
class CategoryPieCard extends StatefulWidget {
  const new({required this.slices, super.key});

  final List<DashboardSlice> slices;

  @override
  State<CategoryPieCard> createState() => _CategoryPieCardState();
}

class _CategoryPieCardState extends State<CategoryPieCard> {
  int? _touched;

  Future<void> _open(int index) async {
    setState(() => _touched = index);
    await showCategoryPurchases(context, widget.slices[index]);
    if (mounted) setState(() => _touched = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final slices = widget.slices;
    final percent = NumberFormat.percentPattern(
      Localizations.localeOf(context).toString(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.dashboardCategoriesTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (slices.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  l10n.dashboardCategoriesEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              )
            else ...[
              const SizedBox(height: 16),
              // The legend below carries the same numbers as text.
              ExcludeSemantics(
                child: Center(
                  child: SizedBox.square(
                    dimension: 168,
                    child: PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        centerSpaceRadius: 48,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            final index =
                                response?.touchedSection?.touchedSectionIndex;
                            if (event is FlTapUpEvent &&
                                index != null &&
                                index >= 0) {
                              unawaited(_open(index));
                            }
                          },
                        ),
                        sections: [
                          for (final (i, s) in slices.indexed)
                            PieChartSectionData(
                              value: s.cents.toDouble(),
                              color: ChartPalette.series(context, s.colorSlot),
                              radius: i == _touched ? 36 : 32,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final (i, s) in slices.indexed)
                _LegendRow(
                  color: ChartPalette.series(context, s.colorSlot),
                  label: s.category?.name ?? l10n.dashboardOtherCategories,
                  amount: Money.format(s.cents),
                  share: percent.format(s.share),
                  highlighted: i == _touched,
                  onTap: () => _open(i),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  l10n.dashboardCategoryHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const new({
    required this.color,
    required this.label,
    required this.amount,
    required this.share,
    required this.highlighted,
    required this.onTap,
  });

  final Color color;
  final String label;
  final String amount;
  final String share;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: highlighted ? FontWeight.w600 : null,
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: 8),
            Text(
              share,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Text(amount, style: style),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
