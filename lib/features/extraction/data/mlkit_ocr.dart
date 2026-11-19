import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';

/// On-device OCR with ML Kit (Latin script). Nothing leaves the phone.
class MlKitOcr {
  final _recognizer = TextRecognizer();

  Future<OcrPage> recognizeFile(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    final lines = [
      for (final block in result.blocks)
        for (final line in block.lines)
          OcrLine(
            text: line.text,
            angle: line.angle ?? 0,
            box: TextBox(
              left: line.boundingBox.left,
              top: line.boundingBox.top,
              right: line.boundingBox.right,
              bottom: line.boundingBox.bottom,
            ),
          ),
    ];
    // ML Kit reports coordinates in the upright (EXIF-rotated) image, so the
    // file's own width/height may be swapped. The text extent is enough:
    // nothing downstream needs the exact page size.
    return OcrPage(
      width: lines.fold(0, (w, l) => l.box.right > w ? l.box.right : w),
      height: lines.fold(0, (h, l) => l.box.bottom > h ? l.box.bottom : h),
      lines: lines,
    );
  }

  Future<void> close() => _recognizer.close();
}
