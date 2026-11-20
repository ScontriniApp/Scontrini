import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';

part 'price_change.freezed.dart';

/// A product's latest unit price against its reference price (M6).
@freezed
abstract class PriceChange with _$PriceChange {
  const factory({
    required int productId,

    /// The latest purchase in the range.
    required PricePoint latest,

    /// Median unit price of the earlier purchases in the reference window,
    /// rounded to the nearest cent.
    required int referenceCents,

    /// How many earlier purchases the median is taken over.
    required int referenceCount,
    required PriceBasis basis,
  }) = _PriceChange;

  const new _();

  int get latestCents => latest.unitPriceCents(basis);

  int get deltaCents => latestCents - referenceCents;

  /// Change in percent, or `null` when the reference price is zero.
  double? get changePercent =>
      referenceCents == 0 ? null : deltaCents / referenceCents * 100;
}
