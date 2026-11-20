import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Prepares a receipt photo for GLM-OCR: grayscale, and scaled so the
/// text is neither too small to read nor needlessly large.
///
/// Measured on the benchmark (2026-11-20): the model misreads
/// rows under ~18 px tall and reads ~22 px rows as well as 44 px ones,
/// while its cost grows with the pixel count (image tokens: 2702 at
/// 1080×1920, 657 at half that size). Upscaling small web photos raised
/// the score from 105 to 115 of 119 items; grayscale alone helped a little;
/// contrast stretching (CLAHE) and binarization made it worse.
///
/// Without a text detector, the width stands in for the text size: a
/// receipt photographed whole fills the width, so [targetWidth] puts its
/// rows at about 40 px.
class OcrImagePreparation {
  const new({
    this.targetWidth = 1200,
    this.maxSide = 4096,
    this.tolerance = 1.3,
  });

  /// Width the photo is scaled to.
  final int targetWidth;

  /// Longest side after scaling: the model's own limit.
  final int maxSide;

  /// Photos within this factor of [targetWidth] are left at their size:
  /// resampling for a small change only blurs.
  final double tolerance;

  /// Factor the photo is scaled by (1 when left alone).
  double scaleFor(int width, int height) {
    final wanted = math.min(
      targetWidth / width,
      maxSide / math.max(width, height),
    );
    final small = wanted > 1 / tolerance && wanted < tolerance;
    return small && math.max(width, height) <= maxSide ? 1 : wanted;
  }

  /// Grayscale, scaled, PNG-encoded copy of [bytes] (any format the
  /// `image` package decodes). Throws [FormatException] if it can't decode.
  Uint8List prepare(Uint8List bytes) {
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
    return img.encodePng(img.grayscale(sized));
  }
}
