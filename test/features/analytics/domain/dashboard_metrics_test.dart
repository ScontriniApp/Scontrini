import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/dashboard_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

import 'history_fixtures.dart';

const categoryInfo = {
  1: CategoryInfo(id: 1, name: 'Frutta', icon: 'eco', color: 0),
  2: CategoryInfo(id: 2, name: 'Carne', icon: 'set_meal', color: 0),
  3: CategoryInfo(id: 3, name: 'Latte', icon: 'egg', color: 0),
  4: CategoryInfo(id: 4, name: 'Pane', icon: 'bakery', color: 0),
  5: CategoryInfo(id: 5, name: 'Bevande', icon: 'drink', color: 0),
  6: CategoryInfo(id: 6, name: 'Casa', icon: 'home', color: 0),
  7: CategoryInfo(id: 7, name: 'Dispensa', icon: 'kitchen', color: 0),
  8: CategoryInfo(id: 8, name: 'Surgelati', icon: 'ac_unit', color: 0),
  // Ninth by id: past the eight chart colours.
  9: CategoryInfo(id: 9, name: 'Altro', icon: 'more', color: 0),
};

PurchaseHistory withCategories(List<PurchaseReceipt> receipts) =>
    history(receipts).copyWith(categories: categoryInfo);

void main() {
  final today = DateTime(2026, 11, 23, 15);

  test('window: the current month to today and the three before', () {
    expect(
      DashboardMetrics.window(today),
      DateRange(DateTime(2026, 8), DateTime(2026, 11, 24)),
    );
  });

  test('month to date against the same days of earlier months', () {
    final h = withCategories([
      receipt(DateTime(2026, 8, 10), 9000),
      receipt(DateTime(2026, 8, 28), 5000), // after the 23rd: not compared
      // September has no receipt: left out of the average.
      receipt(DateTime(2026, 10, 2), 11000),
      receipt(DateTime(2026, 11, 3), 4000),
      receipt(DateTime(2026, 11, 23, 20), 2000),
    ]);
    final s = DashboardMetrics.summary(h, today);
    expect(s.month, DateRange.month(today));
    expect(
      s.monthToDate,
      DateRange(DateTime(2026, 11), DateTime(2026, 11, 24)),
    );
    expect(s.monthToDateCents, 6000);
    expect(s.receiptCount, 2);
    expect(s.usualCents, 10000); // (9000 + 11000) / 2
    expect(s.changePercent, closeTo(-40, 1e-9));
    expect(s.hasHistory, isTrue);
  });

  test('the same days are clipped to a shorter month', () {
    final h = withCategories([
      receipt(DateTime(2026, 2, 28), 3000),
      receipt(DateTime(2026, 3, 31), 1000),
    ]);
    final s = DashboardMetrics.summary(h, DateTime(2026, 3, 31));
    expect(s.usualCents, 3000);
  });

  test('no earlier receipts: no usual amount', () {
    final h = withCategories([receipt(DateTime(2026, 11, 3), 4000)]);
    final s = DashboardMetrics.summary(h, today);
    expect(s.usualCents, isNull);
    expect(s.changePercent, isNull);
  });

  test('every category with a colour is its own slice; the ninth joins '
      'the rest', () {
    final h = withCategories([
      receipt(
        DateTime(2026, 11, 3),
        2350,
        items: [
          item(300, categoryId: 1),
          item(700, categoryId: 2),
          item(500, categoryId: 3),
          item(400, categoryId: 4),
          item(100, categoryId: 5),
          item(150, categoryId: 6),
          item(80, categoryId: 9), // no colour of its own
          item(70), // uncategorised
        ],
      ), // 50 more than the items: the "Other" gap
    ]);
    final slices = DashboardMetrics.summary(h, today).slices;
    expect(
      [for (final s in slices) (s.category?.name, s.cents, s.colorSlot)],
      [
        ('Carne', 700, 1),
        ('Latte', 500, 2),
        ('Pane', 400, 3),
        ('Frutta', 300, 0),
        ('Casa', 150, 5),
        ('Bevande', 100, 4),
        (null, 200, null), // 80 + 70 + 50
      ],
    );
    expect(slices.fold<double>(0, (sum, s) => sum + s.share), closeTo(1, 1e-9));
    expect(
      {for (final p in slices.last.purchases) p.categoryName},
      {'Altro', null},
    );
  });

  test('each slice lists its items, newest first; the rest mixes', () {
    final h =
        withCategories([
          receipt(
            DateTime(2026, 11, 3),
            1500,
            storeId: 7,
            items: [
              item(700, categoryId: 2, rawName: 'POLLO', productId: 1),
              item(300, categoryId: 1, rawName: 'MELE'),
              item(200, categoryId: 3, rawName: 'LATTE'),
              item(100, categoryId: 4, rawName: 'PANE'),
              item(50, categoryId: 5, rawName: 'ACQUA'),
              item(150, rawName: 'ART. 1'),
            ],
          ),
          receipt(
            DateTime(2026, 11, 20),
            640,
            items: [
              item(800, discountCents: 160, categoryId: 2, rawName: 'MANZO'),
            ],
          ),
          receipt(
            DateTime(2026, 10, 20), // last month: not listed
            500,
            items: [item(500, categoryId: 2, rawName: 'POLLO')],
          ),
        ]).copyWith(
          products: {1: const ProductInfo(id: 1, name: 'Petto di pollo')},
          stores: {7: const StoreInfo(id: 7, name: 'Aurora')},
        );
    final slices = DashboardMetrics.summary(h, today).slices;

    final meat = slices.first;
    expect(meat.category?.name, 'Carne');
    expect(
      [for (final p in meat.purchases) (p.name, p.netCents, p.isDiscounted)],
      [('MANZO', 640, true), ('Petto di pollo', 700, false)],
    );
    expect(meat.purchases.last.rawName, 'POLLO');
    expect(meat.purchases.last.storeName, 'Aurora');
    expect(meat.purchases.last.purchaseDate, DateTime(2026, 11, 3).toUtc());
    expect(meat.unassignedCents, 0);

    final rest = slices.last;
    expect(rest.category, isNull);
    expect(
      [for (final p in rest.purchases) (p.name, p.categoryName)],
      [('ART. 1', null)],
    );
  });

  test('an empty month has no slices but keeps the history flag', () {
    final h = withCategories([receipt(DateTime(2026, 10, 3), 4000)]);
    final s = DashboardMetrics.summary(h, today);
    expect(s.slices, isEmpty);
    expect(s.monthToDateCents, 0);
    expect(s.hasHistory, isTrue);
  });
}
