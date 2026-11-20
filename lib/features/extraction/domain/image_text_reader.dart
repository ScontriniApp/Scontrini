import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

/// Reads the text of one receipt photo: ML Kit or GLM-OCR.
abstract interface class ImageTextReader {
  Future<OcrPage> recognizeFile(String imagePath);
}
