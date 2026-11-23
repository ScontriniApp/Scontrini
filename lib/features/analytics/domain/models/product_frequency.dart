import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_frequency.freezed.dart';

/// How often a product was bought in a period (M7).
@freezed
abstract class ProductFrequency with _$ProductFrequency {
  const factory({
    required int productId,

    /// Number of receipts the product appears on.
    required int receiptCount,

    /// Total quantity bought (pieces, kg or l). Summed across units if the
    /// product was bought in more than one; only used to break ties.
    required double quantity,

    /// Total paid for the product, after discounts.
    required int netCents,

    /// Instant of the latest purchase (UTC).
    required DateTime lastPurchaseDate,
  }) = _ProductFrequency;
}
