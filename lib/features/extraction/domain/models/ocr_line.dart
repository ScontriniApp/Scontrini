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
  const factory({required String text, required TextBox box}) = _OcrLine;

  factory fromJson(Map<String, Object?> json) => _$OcrLineFromJson(json);
}
