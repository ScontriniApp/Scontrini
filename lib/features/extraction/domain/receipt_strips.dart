import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Cuts a receipt image into horizontal strips, each cut in the blank space
/// between two printed rows, so a strip never splits a row.
///
/// Why: GLM-OCR's image encoder costs more than linearly with the image size
/// (phone, one whole receipt: 25 s, 56 s, 302 s as images grew), so several
/// strips read one after the other cost less than the whole image, and the
/// first strip's rows are ready long before the last one is read.
class ReceiptStrips {
  const new({this.maxStripHeight = 1100, this.search = 0.25});

  /// No strip is taller than this, in pixels of the prepared image.
  final int maxStripHeight;

  /// How far from the ideal cut to look for blank space, as a fraction of
  /// the strip height.
  final double search;

  /// The rows `[top, bottom)` of each strip, top to bottom, covering the
  /// whole image without overlap. One strip if the image is short enough.
  List<(int, int)> cut(img.Image gray) {
    final height = gray.height;
    final count = (height / maxStripHeight).ceil();
    if (count <= 1) return [(0, height)];

    final ink = _rowInk(gray);
    final stripHeight = height / count;
    final window = (stripHeight * search).round();
    final cuts = <int>[0];
    for (var i = 1; i < count; i++) {
      final ideal = (stripHeight * i).round();
      final from = math.max(cuts.last + 1, ideal - window);
      final to = math.min(height - 1, ideal + window);
      cuts.add(_blankestRow(ink, from, to, ideal));
    }
    cuts.add(height);
    return [for (var i = 0; i < count; i++) (cuts[i], cuts[i + 1])];
  }

  /// Copies of the strips of [gray].
  List<img.Image> split(img.Image gray) => [
    for (final (top, bottom) in cut(gray))
      img.copyCrop(gray, x: 0, y: top, width: gray.width, height: bottom - top),
  ];

  /// Dark pixels per row: text rows have many, the gaps between them few.
  /// "Dark" is relative to the row's own brightness band, so shadows and
  /// uneven light across the photo don't count as text.
  static List<int> _rowInk(img.Image gray) {
    final ink = List.filled(gray.height, 0);
    for (var y = 0; y < gray.height; y++) {
      var sum = 0.0;
      for (var x = 0; x < gray.width; x++) {
        sum += gray.getPixel(x, y).luminance;
      }
      final threshold = 0.75 * sum / gray.width;
      var dark = 0;
      for (var x = 0; x < gray.width; x++) {
        if (gray.getPixel(x, y).luminance < threshold) dark++;
      }
      ink[y] = dark;
    }
    return ink;
  }

  /// The row with the least ink in `[from, to]`, the middle of the blank
  /// band it belongs to (so the cut keeps a margin on both sides), and the
  /// one nearest [ideal] among equals.
  static int _blankestRow(List<int> ink, int from, int to, int ideal) {
    var best = ideal.clamp(from, to);
    for (var y = from; y <= to; y++) {
      final better =
          ink[y] < ink[best] ||
          (ink[y] == ink[best] && (y - ideal).abs() < (best - ideal).abs());
      if (better) best = y;
    }
    var top = best;
    var bottom = best;
    while (top > from && ink[top - 1] <= ink[best]) {
      top--;
    }
    while (bottom < to && ink[bottom + 1] <= ink[best]) {
      bottom++;
    }
    return (top + bottom) ~/ 2;
  }
}
