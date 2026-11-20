import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';

part 'purchase_history.freezed.dart';

/// Read model shared by every metric and insight rule: the confirmed
/// receipts in a loaded window, with the products, categories and stores
/// they reference.
///
/// Built by `AnalyticsDao`; everything above it is pure Dart. All amounts are
/// integer cents.
@freezed
abstract class PurchaseHistory with _$PurchaseHistory {
  const factory({
    /// Confirmed receipts, oldest first.
    required List<PurchaseReceipt> receipts,
    @Default(<int, ProductInfo>{}) Map<int, ProductInfo> products,
    @Default(<int, CategoryInfo>{}) Map<int, CategoryInfo> categories,
    @Default(<int, StoreInfo>{}) Map<int, StoreInfo> stores,
  }) = _PurchaseHistory;

  const new _();

  static const empty = PurchaseHistory(receipts: []);

  bool get isEmpty => receipts.isEmpty;

  /// Receipts whose purchase day (local time) falls in [range].
  Iterable<PurchaseReceipt> receiptsIn(DateRange range) =>
      receipts.where((r) => range.contains(r.purchaseDate));
}

/// One confirmed receipt.
@freezed
abstract class PurchaseReceipt with _$PurchaseReceipt {
  const factory({
    required int id,

    /// Instant of purchase. The database stores UTC; use
    /// [DateRange.contains] or `toLocal()` before bucketing by day.
    required DateTime purchaseDate,

    /// Amount paid as printed on the receipt. M1 trusts this rather than the
    /// sum of the items.
    required int totalCents,

    /// Discount not tied to any item (e.g. a basket coupon), positive.
    @Default(0) int discountCents,
    int? storeId,
    @Default(<PurchaseItem>[]) List<PurchaseItem> items,
  }) = _PurchaseReceipt;

  const new _();

  /// Sum of the items' net amounts. Can differ from [totalCents] when the
  /// user accepted an OCR error; M3 shows the gap as "Other".
  int get itemsNetCents => items.fold(0, (sum, i) => sum + i.netCents);

  /// Item discounts plus the receipt-level discount. Discounts on returned
  /// (negative) lines are not savings.
  int get savingsCents =>
      discountCents +
      items
          .where((i) => !i.isReturn)
          .fold(0, (sum, i) => sum + i.discountCents);
}

/// One line of a confirmed receipt.
@freezed
abstract class PurchaseItem with _$PurchaseItem {
  const factory({
    required int id,

    /// Name as printed on the receipt.
    required String rawName,

    /// Unit price as printed (full price, before discounts).
    required int unitPriceCents,

    /// Line amount before [discountCents]. Negative for returns and deposit
    /// refunds.
    required int lineTotalCents,

    /// Pieces, or kg/l for weighed items.
    @Default(1) double quantity,

    /// Discount attached to this line, positive.
    @Default(0) int discountCents,

    /// Canonical product; `null` when the line was never matched. Such items
    /// count towards spending and categories but not prices or frequency.
    int? productId,

    /// Resolved category: the item's own, else the product's. `null` means
    /// "Uncategorised". The DAO applies the fallback.
    int? categoryId,
  }) = _PurchaseItem;

  const new _();

  /// What was actually paid for this line.
  int get netCents => lineTotalCents - discountCents;

  /// Returns and deposit refunds: they reduce spending but are not price
  /// points and not savings.
  bool get isReturn => lineTotalCents < 0;

  /// Whether this line can be a price point (M5/M6) or count towards
  /// frequency (M7).
  bool get isPriceable => productId != null && !isReturn && quantity > 0;

  /// Price paid per piece, kg or l, rounded to the nearest cent, so 0.8 kg
  /// and 1.2 kg of the same product compare. `null` if not [isPriceable].
  int? get netUnitPriceCents =>
      isPriceable ? (netCents / quantity).round() : null;

  /// Full price per piece, kg or l (ignoring the discount). `null` if not
  /// [isPriceable].
  int? get fullUnitPriceCents =>
      isPriceable ? (lineTotalCents / quantity).round() : null;
}

/// A canonical product (`products`).
@freezed
abstract class ProductInfo with _$ProductInfo {
  const factory({
    required int id,
    required String name,
    int? categoryId,

    /// `null` when the unit is unknown; such products are compared only with
    /// themselves.
    ProductUnit? unit,
  }) = _ProductInfo;
}

/// A category (`categories`), for labels, chart colours and roll-up.
@freezed
abstract class CategoryInfo with _$CategoryInfo {
  const factory({
    required int id,
    required String name,

    /// Material icon name, resolved in the UI.
    required String icon,

    /// ARGB colour.
    required int color,
    int? parentId,
  }) = _CategoryInfo;
}

/// A store (`stores`).
@freezed
abstract class StoreInfo with _$StoreInfo {
  const factory({required int id, required String name, String? vatNumber}) =
      _StoreInfo;
}
