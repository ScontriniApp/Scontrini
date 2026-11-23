import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';

part 'ocr_line.freezed.dart';
part 'ocr_line.g.dart';

/// One run of text as returned by the text extractor (an ML Kit line, or a
/// PDF text fragment), with its position on the page.
///
/// ML Kit often returns the name column and the price column of a receipt as
/// separate lines, so these are not yet printed rows: the row builder groups
/// them by vertical position first.
@freezed
abstract class OcrLine with _$OcrLine {
  const factory({
    required String text,
    required TextBox box,

    /// Rotation of the text in degrees, clockwise in image coordinates
    /// (y pointing down), as reported by ML Kit. 0 for PDF text.
    @Default(0) double angle,

    /// How sure the reader is of [text], 0..1 (PaddleOCR's mean character
    /// probability); `null` when the reader doesn't say (ML Kit, PDF text).
    double? confidence,
  }) = _OcrLine;

  factory fromJson(Map<String, Object?> json) => _$OcrLineFromJson(json);
}
