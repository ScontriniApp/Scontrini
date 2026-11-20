import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';

import 'history_fixtures.dart';

const milk = 1;
const apples = 2;
const coffee = 3;

void main() {
  final november = DateRange.month(DateTime(2026, 11));

  group('M5 priceHistory', () {
    test('one point per receipt, oldest first, with store and unit', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 20),
          330,
          storeId: 2,
          items: [item(130, productId: milk, discountCents: 30)],
        ),
        receipt(
          DateTime(2026, 11, 3),
          500,
          storeId: 1,
          items: [
            // Milk printed twice: one purchase of 2.
            item(120, productId: milk),
            item(90, productId: coffee),
            item(120, productId: milk),
            item(170), // unmatched
          ],
        ),
        receipt(
          DateTime(2026, 10, 30),
          110,
          items: [item(110, productId: milk)],
        ), // outside
      ]);

      final points = PriceMetrics.priceHistory(h, milk, november);
      expect(points.map((p) => p.storeId), [1, 2]);

      final first = points.first;
      expect(first.quantity, 2);
      expect(first.netCents, 240);
      expect(first.netUnitPriceCents, 120);
      expect(first.isDiscounted, isFalse);

      final second = points.last;
      expect(second.netUnitPriceCents, 100);
      expect(second.fullUnitPriceCents, 130);
      expect(second.isDiscounted, isTrue);
      expect(second.unitPriceCents(PriceBasis.full), 130);
    });

    test('weighed items give a price per kg; units stay apart', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          690,
          items: [
            item(
              240,
              quantity: 0.8,
              productId: apples,
              unit: ProductUnit.kilogram,
            ),
            item(
              150,
              quantity: 0.4,
              productId: apples,
              unit: ProductUnit.kilogram,
            ),
            item(300, quantity: 2, productId: apples, unit: ProductUnit.piece),
          ],
        ),
      ]);

      final points = PriceMetrics.priceHistory(h, apples, november);
      expect(
        [for (final p in points) (p.unit, p.netUnitPriceCents)],
        [
          (ProductUnit.kilogram, 325), // 390 / 1.2 kg
          (ProductUnit.piece, 150),
        ],
      );
      expect(points.first.quantity, closeTo(1.2, 1e-9));
      expect(points.last.quantity, 2);
    });

    test('returns and zero quantities are not price points', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 3),
          0,
          items: [
            item(-120, productId: milk),
            item(0, quantity: 0, productId: milk),
          ],
        ),
      ]);
      expect(PriceMetrics.priceHistory(h, milk, november), isEmpty);
    });
  });

  group('M6 priceChange', () {
    // Milk at 100, 130 (once), 100, then 115 on 20 November.
    PurchaseHistory milkHistory({
      List<PurchaseReceipt> extra = const [],
    }) => history([
      receipt(DateTime(2026, 8), 50, items: [item(50, productId: milk)]),
      receipt(DateTime(2026, 8, 22), 100, items: [item(100, productId: milk)]),
      receipt(DateTime(2026, 9, 15), 130, items: [item(130, productId: milk)]),
      receipt(DateTime(2026, 10, 30), 100, items: [item(100, productId: milk)]),
      receipt(
        DateTime(2026, 11, 20, 18),
        115,
        items: [item(115, productId: milk)],
      ),
      ...extra,
    ]);

    test('latest against the median of the previous 90 days', () {
      final change = PriceMetrics.priceChange(milkHistory(), milk, november)!;
      // Window: 22 Aug–19 Nov; 1 Aug is 111 days earlier and is left out.
      expect(change.referenceCount, 3);
      expect(change.referenceCents, 100);
      expect(change.latestCents, 115);
      expect(change.deltaCents, 15);
      expect(change.changePercent, closeTo(15, 1e-9));
      expect(change.latest.purchaseDate, DateTime(2026, 11, 20, 18).toUtc());
    });

    test('purchases on the same day as the latest are not reference', () {
      final h = milkHistory(
        extra: [
          receipt(
            DateTime(2026, 11, 20, 9),
            300,
            items: [item(300, productId: milk)],
          ),
        ],
      );
      final change = PriceMetrics.priceChange(h, milk, november)!;
      expect(change.referenceCount, 3);
      expect(change.latestCents, 115);
    });

    test('median of an even count is rounded to the cent', () {
      final h = milkHistory(
        extra: [
          receipt(
            DateTime(2026, 11, 2),
            101,
            items: [item(101, productId: milk)],
          ),
        ],
      );
      // 100, 100, 101, 130 → (100 + 101) / 2 = 100.5 → 101.
      expect(PriceMetrics.priceChange(h, milk, november)!.referenceCents, 101);
    });

    test('net basis follows discounts; full basis ignores them', () {
      final h = milkHistory(
        extra: [
          receipt(
            DateTime(2026, 11, 25),
            80,
            items: [item(120, discountCents: 40, productId: milk)],
          ),
        ],
      );
      final net = PriceMetrics.priceChange(h, milk, november)!;
      expect(net.latestCents, 80);
      // Window 27 Aug–24 Nov: 130, 100, 115 (22 Aug is now outside).
      expect(net.referenceCount, 3);
      expect(net.referenceCents, 115);

      final full = PriceMetrics.priceChange(
        h,
        milk,
        november,
        basis: PriceBasis.full,
      )!;
      expect(full.latestCents, 120);
      expect(full.basis, PriceBasis.full);
    });

    test('null without enough reference points in the same unit', () {
      final h = history([
        receipt(
          DateTime(2026, 10, 2),
          100,
          items: [item(100, productId: milk)],
        ),
        receipt(
          DateTime(2026, 10, 15),
          100,
          items: [item(100, productId: milk)],
        ),
        receipt(
          DateTime(2026, 10, 20),
          100,
          items: [item(100, productId: milk, unit: ProductUnit.litre)],
        ),
        receipt(
          DateTime(2026, 11, 5),
          120,
          items: [item(120, productId: milk)],
        ),
      ]);
      expect(PriceMetrics.priceChange(h, milk, november), isNull);
      expect(
        PriceMetrics.priceChange(
          h,
          milk,
          november,
          minReferencePoints: 2,
        )?.referenceCount,
        2,
      );
    });

    test('null when the product was not bought in the range', () {
      expect(PriceMetrics.priceChange(milkHistory(), coffee, november), isNull);
      expect(
        PriceMetrics.priceChange(
          milkHistory(),
          milk,
          DateRange.month(DateTime(2026, 12)),
        ),
        isNull,
      );
    });

    test('priceChanges keeps only products with a reference price', () {
      final h = milkHistory(
        extra: [
          receipt(
            DateTime(2026, 11, 4),
            90,
            items: [item(90, productId: coffee)],
          ),
        ],
      );
      final changes = PriceMetrics.priceChanges(h, november);
      expect(changes.keys, [milk]);
      expect(changes[milk], PriceMetrics.priceChange(h, milk, november));
    });
  });
}
