import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Prepares a receipt photo for GLM-OCR: grayscale, and scaled so the
/// text is neither too small to read nor needlessly large.
///
/// The cost of GLM-OCR grows with the pixel count (one image token per
/// 28×28 px; encoding them is most of the time on a phone), so sharp photos
/// are shrunk as far as they still read perfectly, and small blurry ones
/// are enlarged, which helps the model. Measured on the benchmark
/// (benchmark, 2026-11-22), with the width standing in for the text size
/// (a receipt photographed whole fills the width):
/// - Phone photos (1080 px wide) read 31/31 items at 1200, 1000,
///   800, 650 and 540 px wide; at 432 px they fall to 10/31. 650 px costs
///   1008 image tokens instead of 2691.
/// - Small web photos (413–600 px) read best enlarged to 1000 px:
///   116/119 items on the 10 real photos, 113 when left at 650–800 px.
/// - Grayscale helped a little; contrast stretching (CLAHE) and
///   binarization made it worse.
class OcrImagePreparation {
  const new({
    this.minWidth = 700,
    this.enlargeTo = 1000,
    this.maxWidth = 1000,
    this.shrinkTo = 700,
    this.maxSide = 4096,
    this.tolerance = 1.3,
  });

  /// Photos narrower than this are small (web, screenshots) and blurry...
  final int minWidth;

  /// ...and are enlarged to this width.
  final int enlargeTo;

  /// Photos wider than this are sharp camera photos...
  final int maxWidth;

  /// ...and are shrunk to this width. Between [minWidth] and [maxWidth]
  /// photos keep their size.
  final int shrinkTo;

  /// Longest side after scaling: the model's own limit.
  final int maxSide;

  /// Photos needing less than this factor are left at their size:
  /// resampling for a small change only blurs.
  final double tolerance;

  /// Factor the photo is scaled by (1 when left alone).
  double scaleFor(int width, int height) {
    final target = width < minWidth
        ? enlargeTo
        : width > maxWidth
        ? shrinkTo
        : width;
    final wanted = math.min(target / width, maxSide / math.max(width, height));
    final small = wanted > 1 / tolerance && wanted < tolerance;
    return small && math.max(width, height) <= maxSide ? 1 : wanted;
  }

  /// Grayscale, scaled, PNG-encoded copy of [bytes] (any format the
  /// `image` package decodes). Throws [FormatException] if it can't decode.
  Uint8List prepare(Uint8List bytes) => img.encodePng(prepareImage(bytes));

  /// Same as [prepare], before encoding.
  img.Image prepareImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('cannot decode the image');
    }
    final upright = img.bakeOrientation(decoded);
    final scale = scaleFor(upright.width, upright.height);
    final sized = scale == 1
        ? upright
        : img.copyResize(
            upright,
            width: (upright.width * scale).round(),
            height: (upright.height * scale).round(),
            interpolation: scale > 1
                ? img.Interpolation.cubic
                : img.Interpolation.average,
          );
    return img.grayscale(sized);
  }
}
