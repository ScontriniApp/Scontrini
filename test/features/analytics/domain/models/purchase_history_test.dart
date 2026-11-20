import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

void main() {
  group('PurchaseItem', () {
    test('net amount and unit price of a weighed, discounted item', () {
      const apples = PurchaseItem(
        id: 1,
        rawName: 'MELE GOLDEN',
        unitPriceCents: 249,
        lineTotalCents: 199, // 0.8 kg
        quantity: 0.8,
        discountCents: 40,
        productId: 7,
      );
      expect(apples.netCents, 159);
      expect(apples.netUnitPriceCents, 199); // 1.59 / 0.8
      expect(apples.fullUnitPriceCents, 249);
    });

    test('unmatched and returned lines are not price points', () {
      const unmatched = PurchaseItem(
        id: 1,
        rawName: 'ART. VARI',
        unitPriceCents: 100,
        lineTotalCents: 100,
      );
      const deposit = PurchaseItem(
        id: 2,
        rawName: 'RESO VUOTO',
        unitPriceCents: -10,
        lineTotalCents: -10,
        productId: 3,
      );
      expect(unmatched.isPriceable, isFalse);
      expect(unmatched.netUnitPriceCents, isNull);
      expect(deposit.isReturn, isTrue);
      expect(deposit.isPriceable, isFalse);
    });
  });

  group('PurchaseReceipt', () {
    test('savings add item and receipt discounts, not returns', () {
      final receipt = PurchaseReceipt(
        id: 1,
        purchaseDate: DateTime.utc(2026, 11, 14, 10),
        totalCents: 820,
        discountCents: 50,
        items: const [
          PurchaseItem(
            id: 1,
            rawName: 'LATTE',
            unitPriceCents: 200,
            lineTotalCents: 400,
            quantity: 2,
            discountCents: 60,
          ),
          PurchaseItem(
            id: 2,
            rawName: 'PANE',
            unitPriceCents: 540,
            lineTotalCents: 540,
          ),
          PurchaseItem(
            id: 3,
            rawName: 'RESO',
            unitPriceCents: -20,
            lineTotalCents: -20,
            discountCents: 5,
          ),
        ],
      );
      expect(receipt.itemsNetCents, 340 + 540 - 25);
      expect(receipt.savingsCents, 110);
    });
  });

  test('PurchaseHistory.receiptsIn filters by local purchase day', () {
    final history = PurchaseHistory(
      receipts: [
        PurchaseReceipt(
          id: 1,
          purchaseDate: DateTime(2026, 10, 31, 23, 30).toUtc(),
          totalCents: 100,
        ),
        PurchaseReceipt(
          id: 2,
          purchaseDate: DateTime(2026, 11, 1, 9).toUtc(),
          totalCents: 200,
        ),
      ],
    );
    final november = DateRange.month(DateTime(2026, 11));
    expect(history.receiptsIn(november).map((r) => r.id), [2]);
    expect(PurchaseHistory.empty.isEmpty, isTrue);
  });

  test('ProductUnit reads the database value', () {
    expect(ProductUnit.fromDb('kg'), ProductUnit.kilogram);
    expect(ProductUnit.fromDb('pz')?.isMeasured, isFalse);
    expect(ProductUnit.fromDb(null), isNull);
    expect(ProductUnit.fromDb('box'), isNull);
  });
}
