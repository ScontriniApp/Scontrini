import 'dart:developer' as developer;

import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

/// Reads photos with GLM-OCR when its model files are on the device, with
/// ML Kit otherwise (and if GLM-OCR fails, e.g. out of memory).
///
/// GLM-OCR reads real receipt photos far better (benchmark: 115/119 items
/// vs 33/88 for ML Kit), but its 1.4 GB model is not in the APK.
class PreferredImageReader implements ImageTextReader {
  new({required this.glm, required this.fallback});

  /// Resolves to `null` when the model isn't installed.
  final Future<ImageTextReader?> glm;
  final ImageTextReader fallback;

  @override
  Future<OcrPage> recognizeFile(String imagePath) async {
    final model = await glm;
    if (model == null) return await fallback.recognizeFile(imagePath);
    try {
      return await model.recognizeFile(imagePath);
    } on Object catch (error, stack) {
      developer.log(
        'GLM-OCR failed, reading with ML Kit',
        name: 'extraction',
        error: error,
        stackTrace: stack,
      );
      return await fallback.recognizeFile(imagePath);
    }
  }
}
