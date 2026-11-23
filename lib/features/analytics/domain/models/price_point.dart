import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';

part 'price_point.freezed.dart';

/// Which unit price a price comparison uses.
enum PriceBasis {
  /// What was paid per unit, after the line's discount.
  net,

  /// Shelf price per unit, ignoring the discount.
  full,
}

/// One purchase of a product, for price history (M5), price change (M6) and
/// frequency (M7).
///
/// A purchase occasion: all rows of the same product and unit on one receipt
/// are merged, with their quantities and amounts summed, so a product
/// printed twice on a receipt is one point, not two.
@freezed
abstract class PricePoint with _$PricePoint {
  const factory({
    required int productId,
    required int receiptId,

    /// Instant of purchase (UTC, like `PurchaseReceipt.purchaseDate`).
    required DateTime purchaseDate,

    /// Pieces, or kg/l for weighed items. Always positive.
    required double quantity,

    /// Amount paid for the rows, after their discounts.
    required int netCents,

    /// Amount of the rows before their discounts.
    required int fullCents,
    int? storeId,
    ProductUnit? unit,
  }) = _PricePoint;

  const new _();

  /// Price paid per piece, kg or l, rounded to the nearest cent.
  int get netUnitPriceCents => (netCents / quantity).round();

  /// Shelf price per piece, kg or l, rounded to the nearest cent.
  int get fullUnitPriceCents => (fullCents / quantity).round();

  bool get isDiscounted => netCents < fullCents;

  int unitPriceCents(PriceBasis basis) => switch (basis) {
    PriceBasis.net => netUnitPriceCents,
    PriceBasis.full => fullUnitPriceCents,
  };
}
