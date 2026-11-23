import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scontrini/features/extraction/domain/receipt_strips.dart';

/// A white page with [rows] printed rows: dark text 30 px tall every 45 px,
/// starting at 20 px. Returns the image and the rows' `[top, bottom)`.
(img.Image, List<(int, int)>) page(int rows, {int width = 600}) {
  final image = img.Image(width: width, height: 40 + rows * 45)
    ..clear(img.ColorRgb8(235, 235, 235));
  final text = <(int, int)>[];
  for (var r = 0; r < rows; r++) {
    final top = 20 + r * 45;
    text.add((top, top + 30));
    // Characters: dark blocks with spaces, as text looks in a row profile.
    for (var x = 20; x < width - 20; x += 24) {
      img.fillRect(
        image,
        x1: x,
        y1: top,
        x2: x + 14,
        y2: top + 29,
        color: img.ColorRgb8(30, 30, 30),
      );
    }
  }
  return (image, text);
}

void main() {
  test('a short image is one strip', () {
    final (image, _) = page(10);
    expect(const ReceiptStrips().cut(image), [(0, image.height)]);
  });

  test('strips cover the image, are short enough, never cut a row', () {
    final (image, rows) = page(80); // 3640 px
    final strips = const ReceiptStrips(maxStripHeight: 1000).cut(image);

    expect(strips.length, 4);
    expect(strips.first.$1, 0);
    expect(strips.last.$2, image.height);
    for (var i = 1; i < strips.length; i++) {
      expect(strips[i].$1, strips[i - 1].$2, reason: 'no gap, no overlap');
    }
    for (final (top, bottom) in strips) {
      expect(bottom - top, lessThanOrEqualTo(1000 * 1.25));
      for (final (rowTop, rowBottom) in rows) {
        expect(
          top <= rowTop || top >= rowBottom,
          isTrue,
          reason: 'cut at $top splits the row $rowTop..$rowBottom',
        );
      }
    }
  });

  test('a shadow across the page is not taken for text', () {
    final (image, rows) = page(60);
    // Darker right half, as when the phone shades the paper.
    img.fillRect(
      image,
      x1: 300,
      y1: 0,
      x2: 599,
      y2: image.height - 1,
      color: img.ColorRgba8(0, 0, 0, 90),
    );
    for (final (top, _) in const ReceiptStrips(
      maxStripHeight: 900,
    ).cut(image)) {
      for (final (rowTop, rowBottom) in rows) {
        expect(top <= rowTop || top >= rowBottom, isTrue);
      }
    }
  });

  test('split crops the strips at full width', () {
    final (image, _) = page(50);
    final parts = const ReceiptStrips(maxStripHeight: 1000).split(image);

    expect(parts.length, 3);
    expect(parts.every((s) => s.width == image.width), isTrue);
    expect(parts.fold(0, (h, s) => h + s.height), image.height);
  });
}
