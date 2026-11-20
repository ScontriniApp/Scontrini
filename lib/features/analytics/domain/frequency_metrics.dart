import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_frequency.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';

/// Frequency metric (M7) as a pure function over a [PurchaseHistory].
abstract final class FrequencyMetrics {
  /// M7: products bought in [range], ranked by the number of receipts they
  /// appear on, then by quantity, then by product id. Only priceable rows
  /// count (matched, not returns); several rows of a product on one receipt
  /// are one purchase.
  static List<ProductFrequency> mostFrequent(
    PurchaseHistory history,
    DateRange range,
  ) {
    final byProduct = <int, _Tally>{};
    for (final point in PriceMetrics.pricePoints(history, range)) {
      final tally = byProduct[point.productId] ??= _Tally();
      // A product in two units on one receipt is still one receipt.
      if (tally.receiptIds.add(point.receiptId)) {
        tally.last = point.purchaseDate;
      }
      tally
        ..quantity += point.quantity
        ..netCents += point.netCents;
    }

    return [
      for (final MapEntry(:key, :value) in byProduct.entries)
        ProductFrequency(
          productId: key,
          receiptCount: value.receiptIds.length,
          quantity: value.quantity,
          netCents: value.netCents,
          lastPurchaseDate: value.last!,
        ),
    ]..sort((a, b) {
      final byReceipts = b.receiptCount.compareTo(a.receiptCount);
      if (byReceipts != 0) return byReceipts;
      final byQuantity = b.quantity.compareTo(a.quantity);
      if (byQuantity != 0) return byQuantity;
      return a.productId.compareTo(b.productId);
    });
  }
}

class _Tally {
  final receiptIds = <int>{};
  double quantity = 0;
  int netCents = 0;

  /// Points come oldest first, so the last new receipt is the latest.
  DateTime? last;
}
