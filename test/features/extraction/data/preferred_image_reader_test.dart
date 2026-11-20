import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/data/preferred_image_reader.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

class _Reader implements ImageTextReader {
  new(this.width, {this.fails = false});

  final double width;
  final bool fails;
  final read = <String>[];

  @override
  Future<OcrPage> recognizeFile(String imagePath) async {
    read.add(imagePath);
    if (fails) throw StateError('out of memory');
    return OcrPage(width: width, height: 1, lines: const []);
  }
}

void main() {
  test('uses GLM-OCR when the model is installed', () async {
    final glm = _Reader(1);
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      glm: Future.value(glm),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 1);
    expect(mlKit.read, isEmpty);
  });

  test('uses ML Kit when the model is not installed', () async {
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(glm: Future.value(), fallback: mlKit);

    expect((await reader.recognizeFile('a.jpg')).width, 2);
  });

  test('falls back to ML Kit when GLM-OCR fails', () async {
    final glm = _Reader(1, fails: true);
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      glm: Future.value(glm),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 2);
    expect(glm.read, ['a.jpg']);
  });
}
