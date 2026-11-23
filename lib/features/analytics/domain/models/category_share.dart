import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_share.freezed.dart';

/// What a [CategoryShare] slice stands for.
enum CategoryShareKind {
  /// A real category, named by [CategoryShare.categoryId].
  category,

  /// Items with no category, neither their own nor their product's.
  uncategorised,

  /// The gap between the printed receipt totals and the sum of their items
  /// (OCR errors the user accepted, receipts saved without items). Negative
  /// when the items add up to more than the totals.
  other,
}

/// One slice of spending by category (M3).
@freezed
abstract class CategoryShare with _$CategoryShare {
  const factory({
    required CategoryShareKind kind,

    /// Net amount: item amounts after their own discounts and their part of
    /// any basket coupon. Returns reduce it.
    required int cents,

    /// [cents] ÷ the total of all slices (which equals M1), as a fraction;
    /// 0 when that total is not positive.
    required double share,

    /// Set exactly when [kind] is [CategoryShareKind.category].
    int? categoryId,
  }) = _CategoryShare;
}
