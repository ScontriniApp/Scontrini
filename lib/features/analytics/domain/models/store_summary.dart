import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_summary.freezed.dart';

/// Spending at one store in a period (M4).
@freezed
abstract class StoreSummary with _$StoreSummary {
  const factory({
    /// Sum of the printed receipt totals.
    required int totalCents,

    /// Number of receipts (visits).
    required int receiptCount,

    /// `null` for receipts whose store was never recognised.
    int? storeId,
  }) = _StoreSummary;

  const new _();

  /// Average receipt total, rounded to the nearest cent.
  int get averageBasketCents =>
      receiptCount == 0 ? 0 : (totalCents / receiptCount).round();
}
