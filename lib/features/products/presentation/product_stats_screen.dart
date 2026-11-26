import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/products/domain/product_stats.dart';
import 'package:scontrini/features/products/presentation/product_stats_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// One product's statistics: how often it is bought, the prices paid
/// (chart, range, latest against the usual), every purchase (a tap opens
/// its receipt) and how its pantry lots went.
class ProductStatsScreen extends ConsumerWidget {
  const new({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(productStatsProvider(productId));
    return Scaffold(
      appBar: AppBar(title: Text(stats.value?.name ?? '')),
      body: switch (stats) {
        AsyncData(:final value) => _Body(stats: value),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends StatelessWidget {
  const new({required this.stats});

  final ProductStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final day = DateFormat.yMMMd(l10n.localeName);
    final last = stats.lastPurchase;
    final interval = stats.averageIntervalDays;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (stats.purchases.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l10n.productStatsNoPurchases),
          )
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tile(
                label: l10n.productStatsBought,
                value: l10n.productStatsTimes(stats.receiptCount),
              ),
              if (last != null)
                _Tile(
                  label: l10n.productStatsLastPurchase,
                  value: day.format(last.toLocal()),
                ),
              if (interval != null)
                _Tile(
                  label: l10n.productStatsEvery,
                  value: l10n.productStatsDays(interval.round()),
                ),
              _Tile(
                label: l10n.productStatsTotal,
                value: Money.format(stats.totalNetCents),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PricesCard(stats: stats),
          const SizedBox(height: 16),
          Text(l10n.productStatsPurchases, style: theme.textTheme.titleMedium),
          for (final purchase in stats.purchases)
            _PurchaseTile(purchase: purchase),
        ],
        const SizedBox(height: 16),
        _PantryCard(summary: stats.lots),
      ],
    );
  }
}

/// A small figure with its label.
class _Tile extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

String _perUnit(AppLocalizations l10n, ProductUnit? unit) => switch (unit) {
  ProductUnit.kilogram => l10n.productStatsPricePerKg,
  ProductUnit.litre => l10n.productStatsPricePerLitre,
  _ => l10n.productStatsPricePerPiece,
};

class _PricesCard extends StatelessWidget {
  const new({required this.stats});

  final ProductStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final range = stats.unitPriceRange;
    final change = stats.priceChange;
    final percent = change?.changePercent;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              '${l10n.productStatsPrices} · ${_perUnit(l10n, stats.priceUnit)}',
              style: theme.textTheme.titleMedium,
            ),
            if (stats.pricePoints.length >= 2)
              _PriceChart(points: stats.pricePoints)
            else
              Text(l10n.productStatsOnePrice, style: theme.textTheme.bodySmall),
            if (range != null && stats.pricePoints.length >= 2)
              Row(
                children: [
                  for (final (label, cents) in [
                    (l10n.productStatsMin, range.min),
                    (l10n.productStatsUsual, range.median),
                    (l10n.productStatsMax, range.max),
                  ])
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: theme.textTheme.bodySmall),
                          Text(
                            Money.format(cents),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            if (change != null && percent != null)
              Row(
                spacing: 8,
                children: [
                  Icon(
                    percent > 2
                        ? Icons.trending_up
                        : percent < -2
                        ? Icons.trending_down
                        : Icons.trending_flat,
                    size: 20,
                  ),
                  Expanded(
                    child: Text(
                      percent.abs() <= 2
                          ? l10n.productStatsChangeSame
                          : percent > 0
                          ? l10n.productStatsChangeUp(_percent(percent))
                          : l10n.productStatsChangeDown(_percent(-percent)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// [percent] as `12%`; changes within ±2 % read as "as usual".
  static String _percent(double percent) => '${percent.round()}%';
}

/// Unit price paid over time: one series, a 2 px line with dots, a
/// recessive grid, a touch tooltip with the date and the price.
class _PriceChart extends StatelessWidget {
  const new({required this.points});

  /// Oldest first, at least two.
  final List<PricePoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = ChartPalette.series(context, 0);
    final first = points.first.purchaseDate;
    double x(PricePoint p) => p.purchaseDate.difference(first).inHours / 24;
    final spots = [
      for (final p in points) FlSpot(x(p), p.netUnitPriceCents / 100),
    ];
    final ys = spots.map((s) => s.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = maxY == minY ? (maxY * 0.1 + 0.1) : (maxY - minY) * 0.15;
    final day = DateFormat.MMMd(l10n.localeName);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final lastX = spots.last.x;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: (minY - pad).clamp(0, double.infinity),
          maxY: maxY + pad,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    Money.format((value * 100).round()),
                    style: muted,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: lastX > 0 ? lastX : 1,
                getTitlesWidget: (value, meta) {
                  // First and last purchase only.
                  if (value != 0 && value != lastX) {
                    return const SizedBox.shrink();
                  }
                  final date = first.add(
                    Duration(minutes: (value * 24 * 60).round()),
                  );
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(day.format(date.toLocal()), style: muted),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  _tooltip(
                    points[spot.spotIndex],
                    day,
                    TextStyle(color: theme.colorScheme.onInverseSurface),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: color,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

LineTooltipItem _tooltip(PricePoint point, DateFormat day, TextStyle style) {
  final date = day.format(point.purchaseDate.toLocal());
  return LineTooltipItem(
    '$date\n${Money.format(point.netUnitPriceCents)}',
    style,
  );
}

/// One purchase: day, store, quantity, what was paid; opens the receipt.
class _PurchaseTile extends StatelessWidget {
  const new({required this.purchase});

  final ProductPurchase purchase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final point = purchase.point;
    final unit = point.unit?.dbValue ?? 'pz';
    final details = [
      ?purchase.storeName,
      formatQuantity(l10n, point.quantity, unit),
      if (point.quantity != 1 || unit != 'pz')
        '${Money.format(point.netUnitPriceCents)} / ${unitLabel(l10n, unit)}',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        DateFormat.yMMMd(l10n.localeName).format(point.purchaseDate.toLocal()),
      ),
      subtitle: Text(details.join(' · ')),
      trailing: Text(
        Money.format(point.netCents),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => context.push(Routes.receiptOver(point.receiptId)),
    );
  }
}

class _PantryCard extends StatelessWidget {
  const new({required this.summary});

  final PantrySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = summary.unit;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(l10n.productStatsPantry, style: theme.textTheme.titleMedium),
            Text(
              summary.active == 0 || unit == null
                  ? l10n.productStatsPantryNone
                  : l10n.productStatsPantryNow(
                      formatQuantity(l10n, summary.remaining, unit),
                    ),
            ),
            if (summary.consumed + summary.discarded > 0)
              Text(
                l10n.productStatsLotsEnded(summary.consumed, summary.discarded),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
