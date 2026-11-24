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
  test('uses the preferred reader when it is available', () async {
    final paddle = _Reader(1);
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      preferred: Future.value(paddle),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 1);
    expect(mlKit.read, isEmpty);
  });

  test('uses the fallback when the preferred reader is missing', () async {
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      preferred: Future.value(),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 2);
  });

  test('falls back to ML Kit when PaddleOCR fails', () async {
    final paddle = _Reader(1, fails: true);
    final mlKit = _Reader(2);
    final reader = PreferredImageReader(
      preferred: Future.value(paddle),
      fallback: mlKit,
    );

    expect((await reader.recognizeFile('a.jpg')).width, 2);
    expect(paddle.read, ['a.jpg']);
  });

  test('chains: each reader falls back to the next', () async {
    final first = _Reader(1, fails: true);
    final second = _Reader(2, fails: true);
    final last = _Reader(3);
    final reader = PreferredImageReader(
      preferred: Future.value(first),
      fallback: PreferredImageReader(
        preferred: Future.value(second),
        fallback: last,
      ),
    );

    expect((await reader.recognizeFile('a.jpg')).width, 3);
    expect(first.read, ['a.jpg']);
    expect(second.read, ['a.jpg']);
  });
}
