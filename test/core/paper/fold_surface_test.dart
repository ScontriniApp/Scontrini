import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/paper/fold_surface.dart';

void main() {
  group('Fold', () {
    const ridge = Fold(x: 50, y: 100, angle: 0, slope: 0.2, halfWidth: 40);

    test('peaks on its line and falls to zero at its half width', () {
      final top = ridge.heightAt(50, 100);
      expect(top, greaterThan(0));
      expect(ridge.heightAt(50, 120), lessThan(top));
      expect(ridge.heightAt(50, 140), 0);
      expect(ridge.heightAt(50, 60), 0);
      // Same on both sides, anywhere along a full-length fold.
      expect(ridge.heightAt(50, 90), closeTo(ridge.heightAt(50, 110), 1e-9));
      expect(ridge.heightAt(9000, 110), closeTo(ridge.heightAt(50, 110), 1e-9));
    });

    test('a sharp crease keeps its slope right up to the line', () {
      double slopeNearLine(double round) {
        final fold = Fold(
          x: 0,
          y: 100,
          angle: 0,
          slope: 0.3,
          halfWidth: 40,
          round: round,
        );
        return (fold.heightAt(0, 100) - fold.heightAt(0, 101)) / 1;
      }

      // Knife edge: about the face slope one pixel from the crease.
      expect(slopeNearLine(0.004), greaterThan(0.25));
      // Rounded: much flatter there.
      expect(slopeNearLine(0.12), lessThan(0.1));
    });

    test('a valley sinks, a short crease ends after its reach', () {
      const valley = Fold(
        x: 50,
        y: 100,
        angle: 0,
        slope: -0.2,
        halfWidth: 40,
        reach: 30,
      );
      expect(valley.heightAt(50, 100), lessThan(0));
      expect(valley.heightAt(50 + 30, 100), 0);
    });
  });

  group('FoldSurface', () {
    test('the same seed and size give the same sheet', () {
      FoldSurface make(int seed) =>
          FoldSurface.generate(width: 300, length: 900, seed: seed);
      expect(make(4).heights, make(4).heights);
      expect(make(4).heights, isNot(make(5).heights));
    });

    test('no folds is a flat sheet, encoded as mid grey', () {
      final flat = FoldSurface.generate(
        width: 120,
        length: 60,
        seed: 1,
        creases: 0,
        crumple: 0,
      );
      expect(flat.folds, isEmpty);
      expect(flat.normalOf(3, 3), (0.0, 0.0, 1.0));
      final bytes = flat.toRgba();
      expect(bytes.length, flat.columns * flat.rows * 4);
      expect(bytes.sublist(0, 4), [128, 128, 128, 255]);
    });

    test('normals lean away from a ridge, and the map says so', () {
      final sheet = FoldSurface.fromFolds(
        const [Fold(x: 60, y: 60, angle: 0, slope: 0.2, halfWidth: 30)],
        width: 120,
        length: 120,
        texel: 2,
      );
      const column = 30;
      // Below the ridge (y grows downwards) the sheet slopes down.
      const below = 37; // y ≈ 75
      const above = 22; // y ≈ 45
      expect(sheet.normalOf(column, below).$2, greaterThan(0.1));
      expect(sheet.normalOf(column, above).$2, lessThan(-0.1));
      final bytes = sheet.toRgba();
      int green(int row) => bytes[(row * sheet.columns + column) * 4 + 1];
      expect(green(below), lessThan(128));
      expect(green(above), greaterThan(128));
      // The highest point is on the ridge, encoded near white.
      final ridgeRow = (60 / sheet.stepY).floor();
      expect(
        bytes[(ridgeRow * sheet.columns + column) * 4 + 2],
        greaterThan(240),
      );
    });

    test('creases scale with the length of the sheet', () {
      final short = FoldSurface.generate(width: 300, length: 300, seed: 2);
      final long = FoldSurface.generate(width: 300, length: 3000, seed: 2);
      expect(long.folds.length, greaterThan(short.folds.length * 3));
    });

    test('huge sheets keep the grid within its limits', () {
      final huge = FoldSurface.generate(
        width: 400,
        length: 40000,
        seed: 3,
        crumple: 0,
        maxRows: 1024,
      );
      expect(huge.rows, 1024);
      expect(huge.stepY, closeTo(40000 / 1024, 1e-9));
    });
  });
}
