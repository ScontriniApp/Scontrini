import 'dart:math' as math;
import 'dart:typed_data';

/// One crease in a sheet of paper: a straight line through [x], [y] in
/// direction [angle], raised (ridge, [slope] > 0) or sunk (valley) with a
/// tent profile [halfWidth] wide on each side, fading out [reach] away from
/// the point along the line ([double.infinity] = across the whole sheet).
class Fold {
  const new({
    required this.x,
    required this.y,
    required this.angle,
    required this.slope,
    required this.halfWidth,
    this.reach = double.infinity,
  });

  final double x;
  final double y;
  final double angle;

  /// Steepness of the two faces (height per unit of distance), signed.
  final double slope;
  final double halfWidth;
  final double reach;

  /// Rounding of the crease line, as a fraction of [halfWidth].
  static const _round = 0.05;

  /// Height this fold adds at ([px], [py]).
  double heightAt(double px, double py) {
    final dx = px - x;
    final dy = py - y;
    final c = math.cos(angle);
    final s = math.sin(angle);
    // Distance across the crease, and along it.
    final across = (-dx * s + dy * c) / halfWidth;
    final t = across.abs();
    if (t >= 1) return 0;
    var fade = 1 - _smoothstep(0.55, 1, t);
    if (reach.isFinite) {
      final along = (dx * c + dy * s).abs() / reach;
      if (along >= 1) return 0;
      fade *= 1 - _smoothstep(0.5, 1, along);
    }
    final rounded = math.sqrt(t * t + _round * _round) - _round;
    return slope * halfWidth * (1 - rounded) * fade;
  }
}

double _smoothstep(double a, double b, double v) {
  final t = ((v - a) / (b - a)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

/// A crumpled-then-flattened sheet as a height field: the sum of [folds].
///
/// The sheet is [width] × [length] logical pixels, sampled on a
/// [columns] × [rows] grid. The same seed and size always give the same
/// surface, so a receipt keeps its creases.
class FoldSurface {
  new _({
    required this.width,
    required this.length,
    required this.columns,
    required this.rows,
    required this.folds,
    required this.heights,
  });

  /// Creases of a [width] × [length] sheet from [seed]: [creases] scales the
  /// long folds across the sheet (folded to fit a pocket), [crumple] the
  /// short random ones (balled up). [texel] is the grid step in logical px;
  /// it grows for huge sheets so the grid stays within [maxRows].
  factory generate({
    required double width,
    required double length,
    required int seed,
    double creases = 1,
    double crumple = 1,
    double texel = 3,
    int maxColumns = 512,
    int maxRows = 4096,
  }) {
    assert(width > 0 && length > 0, 'empty sheet');
    final random = math.Random(seed);
    double between(double a, double b) => a + random.nextDouble() * (b - a);
    double sign() => random.nextBool() ? 1 : -1;

    final folds = <Fold>[];
    // Long folds, roughly across the sheet, spread along its length.
    final expected = creases * length / (width * 0.8);
    final long = (expected + random.nextDouble()).floor();
    for (var i = 0; i < long; i++) {
      folds.add(
        Fold(
          x: width * between(0.3, 0.7),
          y: length * (i + between(0.2, 0.8)) / long,
          angle: between(-0.12, 0.12),
          slope: sign() * between(0.10, 0.22),
          halfWidth: width * between(0.35, 0.7),
        ),
      );
    }
    // Short crumple creases in any direction.
    final short = (crumple * 6 * length / width).round();
    for (var i = 0; i < short; i++) {
      folds.add(
        Fold(
          x: width * random.nextDouble(),
          y: length * random.nextDouble(),
          angle: between(0, math.pi),
          slope: sign() * between(0.08, 0.25),
          halfWidth: width * between(0.08, 0.25),
          reach: width * between(0.15, 0.5),
        ),
      );
    }

    return FoldSurface.fromFolds(
      folds,
      width: width,
      length: length,
      texel: texel,
      maxColumns: maxColumns,
      maxRows: maxRows,
    );
  }

  /// The sheet shaped by exactly [folds].
  factory fromFolds(
    List<Fold> folds, {
    required double width,
    required double length,
    double texel = 3,
    int maxColumns = 512,
    int maxRows = 4096,
  }) {
    final columns = (width / texel).ceil().clamp(2, maxColumns);
    final rows = (length / texel).ceil().clamp(2, maxRows);
    final heights = Float32List(columns * rows);
    final stepX = width / columns;
    final stepY = length / rows;
    for (var r = 0; r < rows; r++) {
      final py = (r + 0.5) * stepY;
      for (var c = 0; c < columns; c++) {
        final px = (c + 0.5) * stepX;
        var h = 0.0;
        for (final fold in folds) {
          h += fold.heightAt(px, py);
        }
        heights[r * columns + c] = h;
      }
    }
    return FoldSurface._(
      width: width,
      length: length,
      columns: columns,
      rows: rows,
      folds: List.unmodifiable(folds),
      heights: heights,
    );
  }

  final double width;
  final double length;
  final int columns;
  final int rows;
  final List<Fold> folds;

  /// Height of each grid cell centre in logical px, row by row.
  final Float32List heights;

  double get stepX => width / columns;
  double get stepY => length / rows;

  double heightOf(int column, int row) =>
      heights[row.clamp(0, rows - 1) * columns + column.clamp(0, columns - 1)];

  /// Largest absolute height, at least a hair so dividing by it is safe.
  double get maxHeight {
    var max = 1e-6;
    for (final h in heights) {
      if (h.abs() > max) max = h.abs();
    }
    return max;
  }

  /// Slope (dh/dx, dh/dy) at a grid cell, by central differences.
  (double, double) gradientOf(int column, int row) {
    final gx =
        (heightOf(column + 1, row) - heightOf(column - 1, row)) / (2 * stepX);
    final gy =
        (heightOf(column, row + 1) - heightOf(column, row - 1)) / (2 * stepY);
    return (gx, gy);
  }

  /// Unit surface normal (x right, y down, z towards the viewer).
  (double, double, double) normalOf(int column, int row) {
    final (gx, gy) = gradientOf(column, row);
    final length = math.sqrt(gx * gx + gy * gy + 1);
    return (-gx / length, -gy / length, 1 / length);
  }

  /// The map the shader reads, RGBA bytes row by row: R and G the slope
  /// (dh/dx, dh/dy, -1..1 → 0..255, 128 = flat), B the height scaled by
  /// [maxHeight] (128 = the flat sheet), A opaque (so nothing is
  /// premultiplied away).
  Uint8List toRgba() {
    final bytes = Uint8List(columns * rows * 4);
    final scale = maxHeight;
    int encode(double v) => ((v.clamp(-1.0, 1.0) * 0.5 + 0.5) * 255).round();
    var i = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final (gx, gy) = gradientOf(c, r);
        bytes[i++] = encode(gx);
        bytes[i++] = encode(gy);
        bytes[i++] = encode(heightOf(c, r) / scale);
        bytes[i++] = 255;
      }
    }
    return bytes;
  }
}
