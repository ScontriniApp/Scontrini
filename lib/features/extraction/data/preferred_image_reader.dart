import 'dart:developer' as developer;

import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

/// Reads photos with [preferred] when it is available, with [fallback]
/// otherwise and when [preferred] fails (out of memory, a missing model).
/// Chained, it gives the app's order: GLM-OCR, PaddleOCR, ML Kit.
class PreferredImageReader implements ImageTextReader {
  new({required this.preferred, required this.fallback, this.name = 'OCR'});

  /// Resolves to `null` when the reader isn't installed.
  final Future<ImageTextReader?> preferred;
  final ImageTextReader fallback;

  /// [preferred]'s name, for logs.
  final String name;

  @override
  Future<OcrPage> recognizeFile(String imagePath) async {
    final reader = await preferred;
    if (reader == null) return await fallback.recognizeFile(imagePath);
    try {
      return await reader.recognizeFile(imagePath);
    } on Object catch (error, stack) {
      developer.log(
        '$name failed, reading with the next reader',
        name: 'extraction',
        error: error,
        stackTrace: stack,
      );
      return await fallback.recognizeFile(imagePath);
    }
  }
}
