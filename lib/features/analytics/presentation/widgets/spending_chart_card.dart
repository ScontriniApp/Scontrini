import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/time_bucket.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Spending over time (M2): one bar per day, week or month of the period.
/// A tap on a bar shows its total and receipts.
class SpendingChartCard extends StatelessWidget {
  const new({required this.buckets, required this.granularity, super.key});

  final List<TimeBucket> buckets;
  final Granularity granularity;

  /// Most axis labels drawn; with more bars, every n-th is labelled.
  static const _maxLabels = 7;

  String _label(TimeBucket b, String locale) => switch (granularity) {
    // A week's days by name, a longer run of days by number.
    Granularity.day when buckets.length <= 7 => DateFormat.E(
      locale,
    ).format(b.range.start),
    Granularity.day => DateFormat.d(locale).format(b.range.start),
    Granularity.week => DateFormat('d/M', locale).format(b.range.start),
    Granularity.month => DateFormat.MMM(locale).format(b.range.start),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final color = ChartPalette.series(context, 0);
    final most = buckets.fold(0, (m, b) => b.totalCents > m ? b.totalCents : m);
    final every = (buckets.length / _maxLabels).ceil();
    final day = DateFormat.MMMd(locale);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analyticsOverTime, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: most == 0 ? 1 : most / 100 * 1.15,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: theme.colorScheme.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) =>
                            value == meta.max || value == meta.min
                            ? const SizedBox.shrink()
                            : SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  '${value.round()} €',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= buckets.length || i % every != 0) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _label(buckets[i], locale),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, _, _, _) {
                        final b = buckets[group.x];
                        final last = DateTime(
                          b.range.end.year,
                          b.range.end.month,
                          b.range.end.day - 1,
                        );
                        final when = b.range.days == 1
                            ? day.format(b.range.start)
                            : '${day.format(b.range.start)} – '
                                  '${day.format(last)}';
                        return BarTooltipItem(
                          '$when\n${Money.format(b.totalCents)}\n'
                          '${l10n.dashboardReceiptCount(b.receiptCount)}',
                          theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onInverseSurface,
                          ),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (final (i, b) in buckets.indexed)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: b.totalCents / 100,
                            color: color,
                            width: buckets.length > 20 ? 6 : 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.analyticsOverTimeHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
