import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scontrini/features/extraction/domain/ocr_image_preparation.dart';

void main() {
  const prep = OcrImagePreparation();

  group('scale', () {
    test('a small web photo is enlarged to the target width', () {
      expect(prep.scaleFor(447, 447), closeTo(1200 / 447, 1e-9));
    });

    test('a phone photo is shrunk to the target width', () {
      expect(prep.scaleFor(3000, 4000), closeTo(0.4, 1e-9));
    });

    test('a photo near the target size is left alone', () {
      // Real Carrefour photos, read perfectly as they are.
      expect(prep.scaleFor(1080, 1920), 1);
    });

    test('a long receipt is never enlarged past the longest side', () {
      // 591 px wide renders: 1200 px wide would be 7370 px tall.
      expect(prep.scaleFor(591, 3629), 1);
      expect(prep.scaleFor(400, 3000), closeTo(4096 / 3000, 1e-9));
    });

    test('a long side over the limit is always shrunk', () {
      expect(prep.scaleFor(1100, 5000), closeTo(4096 / 5000, 1e-9));
    });
  });

  test('prepare returns a grayscale PNG at the new size', () {
    final photo = img.Image(width: 3000, height: 4000)
      ..clear(img.ColorRgb8(200, 30, 30));
    final prepared = img.decodePng(prep.prepare(img.encodeJpg(photo)))!;

    expect((prepared.width, prepared.height), (1200, 1600));
    final pixel = prepared.getPixel(10, 10);
    expect(pixel.r, pixel.g);
    expect(pixel.g, pixel.b);
  });

  test('prepare rejects bytes that are not an image', () {
    expect(
      () => prep.prepare(img.Image(width: 1, height: 1).toUint8List()),
      throwsFormatException,
    );
  });
}
