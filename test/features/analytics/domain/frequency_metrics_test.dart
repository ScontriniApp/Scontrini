import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/frequency_metrics.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

import 'history_fixtures.dart';

void main() {
  final november = DateRange.month(DateTime(2026, 11));

  group('M7 mostFrequent', () {
    test('ranks by receipts, then quantity, then product id', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 2),
          0,
          items: [
            item(100, productId: 1),
            item(100, productId: 1), // same receipt: still one
            item(300, quantity: 3, productId: 2),
            item(50, productId: 4),
          ],
        ),
        receipt(
          DateTime(2026, 11, 9),
          0,
          items: [item(100, productId: 1), item(50, productId: 3)],
        ),
        receipt(
          DateTime(2026, 11, 16),
          0,
          items: [item(100, productId: 3), item(50, productId: 2)],
        ),
        receipt(
          DateTime(2026, 10, 30),
          0,
          items: [item(100, productId: 4), item(100, productId: 4)],
        ),
      ]);

      final ranking = FrequencyMetrics.mostFrequent(h, november);
      expect(
        [for (final f in ranking) (f.productId, f.receiptCount, f.quantity)],
        [
          (2, 2, 4), // 2 receipts, 4 pieces
          (1, 2, 3), // 2 receipts, 3 pieces
          (3, 2, 2),
          (4, 1, 1), // the October receipt is outside the range
        ],
      );

      final milk = ranking[1];
      expect(milk.netCents, 300);
      expect(milk.lastPurchaseDate, DateTime(2026, 11, 9).toUtc());
    });

    test('a product in two units on one receipt counts once', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 2),
          0,
          items: [
            item(240, quantity: 0.8, productId: 1, unit: ProductUnit.kilogram),
            item(300, quantity: 2, productId: 1, unit: ProductUnit.piece),
          ],
        ),
      ]);

      final apples = FrequencyMetrics.mostFrequent(h, november).single;
      expect(apples.receiptCount, 1);
      expect(apples.quantity, closeTo(2.8, 1e-9));
      expect(apples.netCents, 540);
    });

    test('ties on receipts and quantity go to the lower product id', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 2),
          0,
          items: [item(100, productId: 9), item(100, productId: 5)],
        ),
      ]);
      expect(
        FrequencyMetrics.mostFrequent(h, november).map((f) => f.productId),
        [5, 9],
      );
    });

    test('unmatched rows and returns do not count', () {
      final h = history([
        receipt(
          DateTime(2026, 11, 2),
          0,
          items: [item(100), item(-100, productId: 1)],
        ),
      ]);
      expect(FrequencyMetrics.mostFrequent(h, november), isEmpty);
      expect(
        FrequencyMetrics.mostFrequent(PurchaseHistory.empty, november),
        isEmpty,
      );
    });
  });
}
