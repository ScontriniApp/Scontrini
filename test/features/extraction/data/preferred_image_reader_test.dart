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
  Future<OcrPage> recognizeFile(
    String imagePath, {
    OnReadProgress? onProgress,
  }) async {
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
      preferred: Future.value(glm),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 1);
    expect(mlKit.read, isEmpty);
  });

  test('uses ML Kit when the model is not installed', () async {
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      preferred: Future.value(),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 2);
  });

  test('falls back to ML Kit when GLM-OCR fails', () async {
    final glm = _Reader(1, fails: true);
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      preferred: Future.value(glm),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 2);
    expect(glm.read, ['a.jpg']);
  });

  test('chains: GLM-OCR, then PaddleOCR, then ML Kit', () async {
    final glm = _Reader(1, fails: true);
    final paddle = _Reader(2, fails: true);
    final mlKit = _Reader(3);
    final reader = PreferredImageReader(
      preferred: Future.value(glm),
      fallback: PreferredImageReader(
        preferred: Future.value(paddle),
        fallback: mlKit,
      ),
    );

    expect((await reader.recognizeFile('a.jpg')).width, 3);
    expect(glm.read, ['a.jpg']);
    expect(paddle.read, ['a.jpg']);
  });

  test('without GLM-OCR, PaddleOCR reads before ML Kit', () async {
    final paddle = _Reader(2);
    final mlKit = _Reader(3);
    final reader = PreferredImageReader(
      preferred: Future.value(),
      fallback: PreferredImageReader(
        preferred: Future.value(paddle),
        fallback: mlKit,
      ),
    );

    expect((await reader.recognizeFile('a.jpg')).width, 2);
    expect(mlKit.read, isEmpty);
  });
}
