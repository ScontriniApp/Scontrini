import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/price_change.dart';
import 'package:scontrini/features/analytics/domain/models/price_point.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';

/// One purchase of the product: a receipt's rows of it, merged.
class ProductPurchase {
  const new({required this.point, this.storeName});

  final PricePoint point;
  final String? storeName;
}

/// What the statistics page shows for one product, from the purchase
/// history (price metrics: M5 points, M6 change) and the pantry lots.
/// Everything is derived when asked, never stored (docs/pantry_and_stats.md).
class ProductStats {
  const new({
    required this.productId,
    required this.name,
    required this.purchases,
    required this.receiptCount,
    required this.totalNetCents,
    required this.lots,
    this.categoryId,
    this.priceUnit,
    this.averageIntervalDays,
    this.priceChange,
  });

  /// Builds the statistics of [productId] over [range] from [history] (loaded
  /// for at least [range]) and every pantry lot ([lots], any product).
  factory from(
    PurchaseHistory history,
    int productId,
    DateRange range,
    List<PantryLot> lots,
  ) {
    final points = PriceMetrics.priceHistory(history, productId, range);
    final receipts = <int, DateTime>{
      for (final p in points) p.receiptId: p.purchaseDate,
    };
    final dates = receipts.values.toList()..sort();

    // The unit most purchases were in: the price chart compares like with
    // like (pieces against pieces, €/kg against €/kg).
    final unitCounts = <ProductUnit?, int>{};
    for (final p in points) {
      unitCounts[p.unit] = (unitCounts[p.unit] ?? 0) + 1;
    }
    final priceUnit = unitCounts.isEmpty
        ? null
        : (unitCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;

    final product = history.products[productId];
    final ownLots = [
      for (final lot in lots)
        if (lot.productId == productId) lot,
    ];
    return ProductStats(
      productId: productId,
      name: product?.name ?? (ownLots.isEmpty ? '' : ownLots.first.name),
      categoryId:
          product?.categoryId ??
          (ownLots.isEmpty ? null : ownLots.first.categoryId),
      purchases: [
        for (final p in points.reversed)
          ProductPurchase(point: p, storeName: history.stores[p.storeId]?.name),
      ],
      receiptCount: receipts.length,
      totalNetCents: points.fold(0, (sum, p) => sum + p.netCents),
      priceUnit: priceUnit,
      averageIntervalDays: dates.length < 2
          ? null
          : dates.last.difference(dates.first).inHours /
                24 /
                (dates.length - 1),
      priceChange: PriceMetrics.priceChange(history, productId, range),
      lots: PantrySummary.of(ownLots),
    );
  }

  final int productId;
  final String name;
  final int? categoryId;

  /// Newest first.
  final List<ProductPurchase> purchases;

  /// Receipts it was bought on.
  final int receiptCount;

  /// Paid in all, after discounts.
  final int totalNetCents;

  /// The unit of [pricePoints] (the one most purchases were in).
  final ProductUnit? priceUnit;

  /// Days between purchases on average; `null` with fewer than two.
  final double? averageIntervalDays;

  /// The latest price against the usual one (M6); `null` with too few
  /// earlier purchases.
  final PriceChange? priceChange;
  final PantrySummary lots;

  /// Purchases in [priceUnit], oldest first, for the price chart.
  List<PricePoint> get pricePoints => [
    for (final p in purchases.reversed)
      if (p.point.unit == priceUnit) p.point,
  ];

  DateTime? get lastPurchase =>
      purchases.isEmpty ? null : purchases.first.point.purchaseDate;

  /// Lowest, median and highest price paid per unit of [priceUnit].
  ({int min, int median, int max})? get unitPriceRange {
    final prices = [for (final p in pricePoints) p.netUnitPriceCents]..sort();
    if (prices.isEmpty) return null;
    final mid = prices.length ~/ 2;
    return (
      min: prices.first,
      median: prices.length.isOdd
          ? prices[mid]
          : ((prices[mid - 1] + prices[mid]) / 2).round(),
      max: prices.last,
    );
  }
}

/// The product in the pantry: what is left now and how its lots ended.
class PantrySummary {
  const new({
    required this.remaining,
    required this.active,
    required this.consumed,
    required this.discarded,
    this.unit,
  });

  factory of(List<PantryLot> lots) {
    final active = lots.where((l) => l.status == PantryLotStatus.active);
    return PantrySummary(
      remaining: active.fold(0, (sum, l) => sum + l.remainingQuantity),
      unit: active.isEmpty ? null : active.first.unit,
      active: active.length,
      consumed: lots.where((l) => l.status == PantryLotStatus.consumed).length,
      discarded: lots
          .where((l) => l.status == PantryLotStatus.discarded)
          .length,
    );
  }

  /// Left in the active lots, in [unit] (`pz`, `kg`, `l`).
  final double remaining;
  final String? unit;
  final int active;
  final int consumed;
  final int discarded;

  bool get isEmpty => active + consumed + discarded == 0;
}
