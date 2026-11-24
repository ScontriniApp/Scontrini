import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/products/domain/product_stats.dart';

import '../../analytics/domain/history_fixtures.dart';

const _milk = 1;
const _bread = 2;

PantryLot _lot(int id, int? productId, PantryLotStatus status, double left) =>
    PantryLot(
      id: id,
      name: 'LATTE',
      unit: 'pz',
      source: PantrySource.receipt,
      initialQuantity: 2,
      remainingQuantity: left,
      status: status,
      addedAt: DateTime.utc(2026, 11),
      productId: productId,
    );

void main() {
  final range = DateRange(DateTime(2000), DateTime(2027));
  final base = history([
    receipt(
      DateTime(2026, 9),
      258,
      storeId: 7,
      items: [
        item(129, productId: _milk, unit: ProductUnit.piece),
        // Printed twice on one receipt: one purchase.
        item(129, productId: _milk, unit: ProductUnit.piece),
        item(150, productId: _bread, unit: ProductUnit.piece),
      ],
    ),
    receipt(
      DateTime(2026, 9, 11),
      139,
      items: [item(139, productId: _milk, unit: ProductUnit.piece)],
    ),
    receipt(
      DateTime(2026, 9, 21),
      119,
      items: [item(119, productId: _milk, unit: ProductUnit.piece)],
    ),
  ]);
  final h = base.copyWith(
    products: {
      _milk: const ProductInfo(
        id: _milk,
        name: 'LATTE INTERO',
        unit: ProductUnit.piece,
      ),
    },
    stores: {7: const StoreInfo(id: 7, name: 'CONAD')},
  );

  test('purchases, frequency, spend and price range of one product', () {
    final stats = ProductStats.from(h, _milk, range, const []);

    expect(stats.name, 'LATTE INTERO');
    expect(stats.receiptCount, 3);
    expect(stats.totalNetCents, 258 + 139 + 119);
    expect(stats.averageIntervalDays, closeTo(10, 0.1));
    expect(stats.lastPurchase, DateTime(2026, 9, 21).toUtc());
    // Newest first; the receipt with two rows is one purchase of 2.
    expect(stats.purchases.map((p) => p.point.quantity), [1, 1, 2]);
    expect(stats.purchases.last.storeName, 'CONAD');
    expect(stats.priceUnit, ProductUnit.piece);
    expect(stats.pricePoints.map((p) => p.netUnitPriceCents), [129, 139, 119]);
    expect(stats.unitPriceRange, (min: 119, median: 129, max: 139));
    expect(stats.lots.isEmpty, isTrue);
  });

  test('a product never bought has no purchases or prices', () {
    final stats = ProductStats.from(h, 99, range, const []);
    expect(stats.purchases, isEmpty);
    expect(stats.averageIntervalDays, isNull);
    expect(stats.unitPriceRange, isNull);
  });

  test('pantry summary counts only the product own lots', () {
    final stats = ProductStats.from(h, _milk, range, [
      _lot(1, _milk, PantryLotStatus.active, 1.5),
      _lot(2, _milk, PantryLotStatus.active, 1),
      _lot(3, _milk, PantryLotStatus.consumed, 0),
      _lot(4, _milk, PantryLotStatus.discarded, 0),
      _lot(5, _bread, PantryLotStatus.active, 2),
    ]);
    final lots = stats.lots;
    expect((lots.remaining, lots.unit), (2.5, 'pz'));
    expect((lots.active, lots.consumed, lots.discarded), (2, 1, 1));
  });
}
