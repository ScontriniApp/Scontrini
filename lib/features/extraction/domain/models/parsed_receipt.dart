import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';

part 'parsed_receipt.freezed.dart';
part 'parsed_receipt.g.dart';

/// Result of parsing one receipt. Every header field is nullable because OCR
/// can miss it; the review screen asks the user to fill in what is missing.
@freezed
abstract class ParsedReceipt with _$ParsedReceipt {
  const factory({
    required List<ParsedItem> items,
    String? storeName,

    /// Italian VAT number (P.IVA), 11 digits.
    String? vatNumber,
    String? address,

    /// Date and time as printed, in local time. Convert to UTC when saving.
    DateTime? purchaseDate,

    /// Printed grand total.
    int? totalCents,

    /// Discounts not tied to a single item (e.g. a coupon on the subtotal),
    /// as a positive amount.
    @Default(0) int discountCents,
    @Default(<ParseWarning>[]) List<ParseWarning> warnings,

    /// Rows inside the item section that the parser could not interpret.
    /// Shown in the review screen in case they hide a missed item.
    @Default(<String>[]) List<String> unparsedLines,
  }) = _ParsedReceipt;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$ParsedReceiptFromJson(json);

  /// Sum of the items after their own discounts and the receipt discount.
  int get computedTotalCents =>
      items.fold(0, (sum, item) => sum + item.netCents) - discountCents;

  /// Whether the items add up to the printed total. `false` when the total
  /// is missing.
  bool get isBalanced => totalCents == computedTotalCents;
}
