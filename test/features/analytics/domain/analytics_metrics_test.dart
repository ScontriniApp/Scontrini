import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/analytics_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

import 'history_fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 24, 12);
  final november = AnalyticsPeriod.of(PeriodKind.month, today);

  const milk = 1;
  const yogurt = 2;
  const coffee = 3;

  PurchaseHistory withNames(PurchaseHistory h) => h.copyWith(
    products: const {
      milk: ProductInfo(id: milk, name: 'Latte'),
      yogurt: ProductInfo(id: yogurt, name: 'Yogurt'),
      coffee: ProductInfo(id: coffee, name: 'Caffè'),
    },
    stores: const {7: StoreInfo(id: 7, name: 'Aurora')},
  );

  test('window reaches back over the comparison and the M6 reference', () {
    expect(
      AnalyticsMetrics.window(november, today),
      DateRange(DateTime(2026, 7, 3), DateTime(2026, 11, 25)),
    );
  });

  test('the total compares with the same days of the month before', () {
    final h = history([
      receipt(DateTime(2026, 10, 10), 4000),
      // After 24 October: outside the comparison.
      receipt(DateTime(2026, 10, 28), 9999),
      receipt(DateTime(2026, 11, 3), 3000, storeId: 7),
      receipt(DateTime(2026, 11, 20), 2000, storeId: 7),
    ]);
    final o = AnalyticsMetrics.overview(h, november, today);

    expect(o.total.cents, 5000);
    expect(o.total.previousCents, 4000);
    expect(o.receiptCount, 2);
    expect(
      o.comparedRange,
      DateRange(DateTime(2026, 10), DateTime(2026, 10, 25)),
    );
  });

  test('the chart covers the whole month, with empty weeks after today', () {
    final h = history([receipt(DateTime(2026, 11, 3), 3000)]);
    final o = AnalyticsMetrics.overview(h, november, today);

    // 1 Nov is a Sunday: a one-day week, then four full weeks and a partial.
    expect(o.buckets.first.range.start, DateTime(2026, 11));
    expect(o.buckets.last.range.end, DateTime(2026, 12));
    expect(o.buckets.fold(0, (s, b) => s + b.totalCents), 3000);
    expect(o.buckets.last.totalCents, 0);
  });

  test('every category is listed, stores and products carry names', () {
    final h = withNames(
      history([
        for (var i = 0; i < 6; i++)
          receipt(
            DateTime(2026, 11, 2 + i),
            600,
            storeId: 7,
            items: [item(600, categoryId: 10 + i, productId: milk)],
          ),
      ]),
    );
    final o = AnalyticsMetrics.overview(h, november, today);

    // Six categories, more than the dashboard's four, none in "rest".
    expect(o.categories, hasLength(6));
    expect(o.categories.every((s) => s.purchases.length == 1), isTrue);
    expect(o.stores.single.name, 'Aurora');
    expect(o.stores.single.summary.receiptCount, 6);
    expect(o.mostBought.single.name, 'Latte');
    expect(o.mostBought.single.frequency.receiptCount, 6);
  });

  test('price changes use the full price and skip small ones', () {
    final h = withNames(
      history([
        // Three reference purchases each, in October.
        for (final day in [5, 12, 19])
          receipt(
            DateTime(2026, 10, day),
            900,
            items: [
              item(129, productId: milk),
              item(200, productId: yogurt),
              item(459, productId: coffee),
            ],
          ),
        receipt(
          DateTime(2026, 11, 20),
          900,
          items: [
            // +12%.
            item(145, productId: milk),
            // Same shelf price, 30% off: not a drop on the full price.
            item(200, discountCents: 60, productId: yogurt),
            // −15%.
            item(389, productId: coffee),
          ],
        ),
      ]),
    );
    final o = AnalyticsMetrics.overview(h, november, today);

    expect(o.priceRises.map((c) => c.name), ['Latte']);
    expect(o.priceDrops.map((c) => c.name), ['Caffè']);
    expect(o.priceRises.single.change.referenceCents, 129);
  });

  test('an empty period is empty', () {
    final o = AnalyticsMetrics.overview(
      history([receipt(DateTime(2026, 10, 3), 1000)]),
      november,
      today,
    );
    expect(o.isEmpty, isTrue);
    expect(o.total.previousCents, 1000);
  });
}
