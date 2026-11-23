import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

part 'dashboard_summary.freezed.dart';

/// What the dashboard shows for the current month.
@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory({
    /// The calendar month containing today.
    required DateRange month,

    /// The days of [month] up to and including today.
    required DateRange monthToDate,

    /// Printed totals of the confirmed receipts in [monthToDate] (M1).
    required int monthToDateCents,
    required int receiptCount,

    /// Category slices of [monthToDate], largest first, the rest last.
    required List<DashboardSlice> slices,

    /// Whether any confirmed receipt was loaded at all (this month or the
    /// three before). False means a new user: the dashboard shows its empty
    /// state.
    required bool hasHistory,

    /// Average spent in the same days (1 to today's day) of the previous
    /// months that had receipts, up to three; null when none had.
    int? usualCents,
  }) = _DashboardSummary;

  const new _();

  /// Change of [monthToDateCents] against [usualCents], in percent.
  double? get changePercent {
    final usual = usualCents;
    if (usual == null || usual <= 0) return null;
    return (monthToDateCents - usual) * 100 / usual;
  }
}

/// One slice of the dashboard's category pie.
@freezed
abstract class DashboardSlice with _$DashboardSlice {
  const factory({
    /// Amount of the slice, always positive.
    required int cents,

    /// [cents] ÷ the sum of all slices.
    required double share,

    /// The category; null for the slice that groups the rest (smaller
    /// categories, uncategorised items and the gap to the receipt totals).
    CategoryInfo? category,

    /// Position of [category] among all categories by id, so a category
    /// keeps its colour whatever its rank this month. Null for the rest.
    int? colorSlot,

    /// The items behind the slice, newest first.
    @Default(<CategoryPurchase>[]) List<CategoryPurchase> purchases,
  }) = _DashboardSlice;

  const new _();

  /// Part of [cents] no listed item accounts for: basket coupons spread over
  /// the items (negative) and, in the rest slice, the gap between receipt
  /// totals and their items.
  int get unassignedCents =>
      cents - purchases.fold(0, (sum, p) => sum + p.netCents);
}

/// One item bought, as listed under a dashboard category.
@freezed
abstract class CategoryPurchase with _$CategoryPurchase {
  const factory({
    required int itemId,

    /// The product's name, or the name printed on the receipt when the item
    /// is matched to no product.
    required String name,

    /// Name as printed on the receipt.
    required String rawName,

    /// When the receipt was bought (UTC).
    required DateTime purchaseDate,

    /// Price paid, after the item's own discount.
    required int netCents,

    /// Price before the item's discount.
    required int fullCents,
    required double quantity,
    ProductUnit? unit,
    String? storeName,

    /// The item's category; set in the rest slice, where categories mix.
    /// Null there for an uncategorised item.
    String? categoryName,
  }) = _CategoryPurchase;

  const new _();

  bool get isDiscounted => netCents < fullCents;
}
