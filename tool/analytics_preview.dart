// Prints the analytics metrics computed on a seeded sample history, as a
// quick look at the numbers before the screens exist.
//
// Run from the project root:
//   dart run --packages=.dart_tool/package_config.json tool/analytics_preview.dart
// ignore_for_file: avoid_print
import 'dart:math';

import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/granularity.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/spending_metrics.dart';

void main() {
  final rng = Random(7);
  final receipts = <PurchaseReceipt>[];
  var id = 1;
  // ~3 receipts a week from June to November 2026.
  for (
    var d = DateTime(2026, 6);
    d.isBefore(DateTime(2026, 11, 21));
    d = DateTime(d.year, d.month, d.day + 1)
  ) {
    if (rng.nextDouble() > 0.43) continue;
    final items = <PurchaseItem>[];
    for (var i = 0; i < 4 + rng.nextInt(10); i++) {
      final line = 80 + rng.nextInt(600);
      final disc = rng.nextDouble() < 0.15 ? (line * 0.3).round() : 0;
      items.add(
        PurchaseItem(
          id: id++,
          rawName: 'ITEM',
          unitPriceCents: line,
          lineTotalCents: line,
          discountCents: disc,
        ),
      );
    }
    final coupon = rng.nextDouble() < 0.05 ? 300 : 0;
    final total = items.fold(0, (s, i) => s + i.netCents) - coupon;
    receipts.add(
      PurchaseReceipt(
        id: id++,
        purchaseDate: DateTime(
          d.year,
          d.month,
          d.day,
          9 + rng.nextInt(12),
        ).toUtc(),
        totalCents: total,
        discountCents: coupon,
        items: items,
      ),
    );
  }
  final h = PurchaseHistory(receipts: receipts);
  final november = DateRange.month(DateTime(2026, 11));

  String pct(double? p) =>
      p == null ? 'n/a' : '${p >= 0 ? '+' : ''}${p.toStringAsFixed(1)}%';
  String bars(List<({String label, int cents, int n})> rows) {
    final max = rows.map((r) => r.cents).reduce((a, b) => a > b ? a : b);
    return rows
        .map((r) {
          final w = max == 0 ? 0 : (r.cents * 40 / max).round();
          return '  ${r.label.padRight(11)} ${'█' * w}${' ' * (40 - w)} '
              '${Money.format(r.cents).padLeft(11)}  (${r.n} receipts)';
        })
        .join('\n');
  }

  String d(DateTime t) =>
      '${t.day.toString().padLeft(2)}/${t.month.toString().padLeft(2, '0')}';
  DateTime lastDay(DateRange r) =>
      DateTime(r.end.year, r.end.month, r.end.day - 1);
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  print(
    'Sample history: ${receipts.length} confirmed receipts, Jun–Nov 2026\n',
  );
  final m1 = SpendingMetrics.totalSpending(h, november);
  print(
    'M1  November total: ${Money.format(m1.cents)}   '
    'previous 30 days: ${Money.format(m1.previousCents)}   '
    'change: ${pct(m1.changePercent)}\n',
  );

  print('M2  November by ISO week (first/last bucket clipped):');
  print(
    bars([
      for (final b in SpendingMetrics.spendingOverTime(
        h,
        november,
        Granularity.week,
      ))
        (
          label: '${d(b.range.start)}–${d(lastDay(b.range))}',
          cents: b.totalCents,
          n: b.receiptCount,
        ),
    ]),
  );
  print('\nM2  Last 6 months by month:');
  print(
    bars([
      for (final b in SpendingMetrics.spendingOverTime(
        h,
        DateRange(DateTime(2026, 6), DateTime(2026, 12)),
        Granularity.month,
      ))
        (
          label: months[b.range.start.month],
          cents: b.totalCents,
          n: b.receiptCount,
        ),
    ]),
  );

  final m8 = SpendingMetrics.savings(h, november);
  print(
    '\nM8  November savings: ${Money.format(m8.saved.cents)} '
    '(${((m8.rate ?? 0) * 100).toStringAsFixed(1)}% of full price)   '
    'previous: ${Money.format(m8.saved.previousCents)}   '
    'change: ${pct(m8.saved.changePercent)}',
  );
  print(
    '    → "Hai risparmiato ${Money.format(m8.saved.cents)} '
    '(${((m8.rate ?? 0) * 100).round()}%) con gli sconti"',
  );
}
