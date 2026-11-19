import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';

part 'ocr_document.freezed.dart';
part 'ocr_document.g.dart';

/// Output of the text extraction step and input of the parser.
///
/// Its JSON form is what gets stored in `receipts.raw_ocr_text` and used for
/// test fixtures, so a receipt can be parsed again later with the geometry
/// intact.
@freezed
abstract class OcrDocument with _$OcrDocument {
  const factory({required TextSource source, required List<OcrPage> pages}) =
      _OcrDocument;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$OcrDocumentFromJson(json);

  /// All text in extraction order, one line per `OcrLine`. For display and
  /// debugging only: the parser works on rebuilt rows, not on this.
  String get plainText => [
    for (final page in pages)
      for (final line in page.lines) line.text,
  ].join('\n');
}
