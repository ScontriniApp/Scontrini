import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';

part 'receipt_row.freezed.dart';

/// One printed row of a receipt, rebuilt from the extractor's lines.
@freezed
abstract class ReceiptRow with _$ReceiptRow {
  const factory({
    /// Index of the page in the `OcrDocument`.
    required int page,

    /// Lines on this row, left to right. Usually the product name and the
    /// price, which ML Kit returns separately.
    required List<OcrLine> cells,
  }) = _ReceiptRow;

  const new _();

  /// Cells joined with a single space.
  String get text => cells.map((cell) => cell.text).join(' ');
}
