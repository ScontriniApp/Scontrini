import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';

part 'ocr_page.freezed.dart';
part 'ocr_page.g.dart';

/// Text extracted from one image or one PDF page.
@freezed
abstract class OcrPage with _$OcrPage {
  const factory({
    required double width,
    required double height,
    required List<OcrLine> lines,
  }) = _OcrPage;

  factory fromJson(Map<String, Object?> json) => _$OcrPageFromJson(json);
}
