import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/price_change.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

/// Price metrics (M5, M6) as pure functions over a [PurchaseHistory].
///
/// Only priceable rows count ([PurchaseItem.isPriceable]): matched to a
/// product, not a return, positive quantity.
///
/// M6 reads purchases before `range`, so the history must be loaded with
/// `range.extendBack(referenceDays)`; otherwise there are too few reference
/// points and it returns `null`.
abstract final class PriceMetrics {
  /// Default reference window of M6, in days.
  static const defaultReferenceDays = 90;

  /// Fewest earlier purchases M6 needs for a reference price.
  static const defaultMinReferencePoints = 3;

  /// The purchase occasions in [range], oldest first, optionally of one
  /// product only. Rows of the same product and unit on one receipt become
  /// one [PricePoint].
  static List<PricePoint> pricePoints(
    PurchaseHistory history,
    DateRange range, {
    int? productId,
  }) => _points(history.receiptsIn(range), productId: productId);

  /// M5: every purchase of [productId] in [range], oldest first, with its
  /// unit price, store and unit. A product bought both by the piece and by
  /// weight has points in both units; the UI charts them apart.
  static List<PricePoint> priceHistory(
    PurchaseHistory history,
    int productId,
    DateRange range,
  ) => pricePoints(history, range, productId: productId);

  /// M6: the latest unit price of [productId] in [range] against the median
  /// of its purchases in the [referenceDays] days before that purchase's day,
  /// counting only purchases in the same unit.
  ///
  /// `null` when the product was not bought in [range] or the window holds
  /// fewer than [minReferencePoints] purchases. The median rather than the
  /// last price keeps one promotion from looking like a trend.
  static PriceChange? priceChange(
    PurchaseHistory history,
    int productId,
    DateRange range, {
    PriceBasis basis = PriceBasis.net,
    int referenceDays = defaultReferenceDays,
    int minReferencePoints = defaultMinReferencePoints,
  }) => _change(
    _points(history.receipts, productId: productId),
    range,
    basis: basis,
    referenceDays: referenceDays,
    minReferencePoints: minReferencePoints,
  );

  /// M6 for every product bought in [range] that has enough reference
  /// points, keyed by product id. Same rules as [priceChange].
  static Map<int, PriceChange> priceChanges(
    PurchaseHistory history,
    DateRange range, {
    PriceBasis basis = PriceBasis.net,
    int referenceDays = defaultReferenceDays,
    int minReferencePoints = defaultMinReferencePoints,
  }) {
    final byProduct = <int, List<PricePoint>>{};
    for (final point in _points(history.receipts)) {
      (byProduct[point.productId] ??= []).add(point);
    }
    return {
      for (final MapEntry(:key, :value) in byProduct.entries)
        key: ?_change(
          value,
          range,
          basis: basis,
          referenceDays: referenceDays,
          minReferencePoints: minReferencePoints,
        ),
    };
  }

  /// [points] must be of one product, oldest first.
  static PriceChange? _change(
    List<PricePoint> points,
    DateRange range, {
    required PriceBasis basis,
    required int referenceDays,
    required int minReferencePoints,
  }) {
    final latest = points.lastWhereOrNull(
      (p) => range.contains(p.purchaseDate),
    );
    if (latest == null) return null;

    final day = DateRange.day(latest.purchaseDate).start;
    final window = DateRange(day, day).extendBack(referenceDays);
    final reference = [
      for (final p in points)
        if (p.unit == latest.unit && window.contains(p.purchaseDate))
          p.unitPriceCents(basis),
    ];
    if (reference.isEmpty || reference.length < minReferencePoints) {
      return null;
    }

    return PriceChange(
      productId: latest.productId,
      latest: latest,
      referenceCents: _median(reference),
      referenceCount: reference.length,
      basis: basis,
    );
  }

  static List<PricePoint> _points(
    Iterable<PurchaseReceipt> receipts, {
    int? productId,
  }) {
    final points = <PricePoint>[];
    for (final receipt in receipts) {
      // Insertion order keeps the receipt's row order.
      final occasions = <(int, ProductUnit?), PricePoint>{};
      for (final item in receipt.items) {
        if (!item.isPriceable) continue;
        if (productId != null && item.productId != productId) continue;
        final key = (item.productId!, item.unit);
        final seen = occasions[key];
        occasions[key] = seen == null
            ? PricePoint(
                productId: item.productId!,
                receiptId: receipt.id,
                purchaseDate: receipt.purchaseDate,
                storeId: receipt.storeId,
                unit: item.unit,
                quantity: item.quantity,
                netCents: item.netCents,
                fullCents: item.lineTotalCents,
              )
            : seen.copyWith(
                quantity: seen.quantity + item.quantity,
                netCents: seen.netCents + item.netCents,
                fullCents: seen.fullCents + item.lineTotalCents,
              );
      }
      points.addAll(occasions.values);
    }
    return points;
  }

  /// Median rounded to the nearest cent; [values] must not be empty.
  static int _median(List<int> values) {
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }
}

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
