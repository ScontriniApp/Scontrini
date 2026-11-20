import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/word_spacing.dart';

/// On-device OCR with ML Kit (Latin script). Nothing leaves the phone.
class MlKitOcr implements ImageTextReader {
  new({this.spacing = const WordSpacing()});

  final WordSpacing spacing;
  final _recognizer = TextRecognizer();

  @override
  Future<OcrPage> recognizeFile(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    final mlLines = [for (final block in result.blocks) ...block.lines];
    final glyphs = [for (final line in mlLines) _glyphs(line)];
    final pagePitch = spacing.pagePitch(glyphs.nonNulls);

    final lines = [
      for (final (i, line) in mlLines.indexed)
        OcrLine(
          // Fall back to ML Kit's own spacing if character boxes are missing.
          text:
              switch (glyphs[i]) {
                final words? => spacing.join(words, pagePitch: pagePitch),
                null => null,
              } ??
              line.text,
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

  /// Character boxes of each word, or `null` if ML Kit gave none (iOS may
  /// not report symbols for every element).
  static List<List<OcrGlyph>>? _glyphs(TextLine line) {
    final words = <List<OcrGlyph>>[];
    for (final element in line.elements) {
      if (element.symbols.isEmpty) return null;
      words.add([
        for (final s in element.symbols)
          OcrGlyph(s.text, s.boundingBox.left, s.boundingBox.right),
      ]);
    }
    return words;
  }

  Future<void> close() => _recognizer.close();
}
