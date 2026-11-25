import 'package:flutter/foundation.dart' show debugPrint;

import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

/// Reads photos with [preferred] when it is available, with [fallback]
/// otherwise and when [preferred] fails (out of memory, a missing model).
/// The app's order: PaddleOCR, then ML Kit.
class PreferredImageReader implements ImageTextReader {
  new({required this.preferred, required this.fallback, this.name = 'OCR'});

  /// Resolves to `null` when the reader isn't installed.
  final Future<ImageTextReader?> preferred;
  final ImageTextReader fallback;

  /// [preferred]'s name, for logs.
  final String name;

  @override
  Future<OcrPage> recognizeFile(
    String imagePath, {
    OnReadProgress? onProgress,
  }) async {
    final reader = await preferred;
    if (reader == null) {
      return await fallback.recognizeFile(imagePath, onProgress: onProgress);
    }
    try {
      return await reader.recognizeFile(imagePath, onProgress: onProgress);
    } on Object catch (error, stack) {
      // debugPrint, not developer.log: this fallback is silent for the user,
      // and developer.log never reaches logcat in release builds, where a
      // broken reader (e.g. native classes stripped by R8) would otherwise
      // go unnoticed. `adb logcat | grep flutter` shows it.
      debugPrint('$name failed, reading with the next reader: $error\n$stack');
      return await fallback.recognizeFile(imagePath, onProgress: onProgress);
    }
  }
}
