import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scontrini/features/extraction/domain/paddle_ocr_steps.dart';

/// A probability map [w] × [h] with [value] inside the given rectangles.
Float32List _map(
  int w,
  int h,
  List<(int, int, int, int)> rects, {
  double value = 0.9,
}) {
  final map = Float32List(w * h);
  for (final (x0, y0, x1, y1) in rects) {
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        map[y * w + x] = value;
      }
    }
  }
  return map;
}

void main() {
  group('detectionInput', () {
    test('scales the short side to 736, sides multiples of 32', () {
      final input = detectionInput(img.Image(width: 100, height: 400));
      expect(input.shape, [1, 3, 2944, 736]);
      expect(input.data.length, 3 * 2944 * 736);
    });

    test('large photos keep their size, rounded to 32', () {
      final input = detectionInput(img.Image(width: 1000, height: 1500));
      expect(input.shape, [1, 3, 1504, 992]);
    });

    test('channels are BGR, normalised to -1..1', () {
      final image = img.Image(width: 800, height: 800)
        ..clear(img.ColorRgb8(255, 0, 0));
      final input = detectionInput(image);
      const plane = 800 * 800;
      expect(input.data[0], closeTo(-1, 1e-6)); // blue
      expect(input.data[plane], closeTo(-1, 1e-6)); // green
      expect(input.data[2 * plane], closeTo(1, 1e-6)); // red
    });
  });

  group('boxesFromProbabilities', () {
    test('one text region gives one box, grown and scaled to the image', () {
      final boxes = boxesFromProbabilities(
        _map(100, 50, [(10, 20, 60, 30)]),
        100,
        50,
        width: 200,
        height: 100,
      );
      expect(boxes, hasLength(1));
      final [tl, tr, br, bl] = boxes.single;
      // The region is x 20..120, y 40..60 in image pixels; the box grows
      // around it (unclip) and keeps its corners in order.
      expect(tl.x, lessThan(20));
      expect(tl.y, lessThan(40));
      expect(br.x, greaterThan(118));
      expect(br.y, greaterThan(58));
      expect(tr.x, greaterThan(tl.x));
      expect(bl.y, greaterThan(tl.y));
    });

    test('regions below the box score are dropped', () {
      final boxes = boxesFromProbabilities(
        _map(100, 50, [(10, 20, 60, 30)], value: 0.4),
        100,
        50,
        width: 100,
        height: 50,
      );
      expect(boxes, isEmpty);
    });

    test('specks are dropped', () {
      final boxes = boxesFromProbabilities(
        _map(100, 50, [(10, 10, 12, 12)]),
        100,
        50,
        width: 100,
        height: 50,
      );
      expect(boxes, isEmpty);
    });

    test('lines come top to bottom, left to right on the same line', () {
      final boxes = boxesFromProbabilities(
        _map(200, 100, [
          (120, 10, 180, 20), // top right
          (10, 60, 80, 70), // bottom
          (10, 11, 60, 20), // top left, 1 px lower than top right
        ]),
        200,
        100,
        width: 200,
        height: 100,
      );
      expect(boxes, hasLength(3));
      expect(boxes[0][0].x, lessThan(70));
      expect(boxes[0][0].y, lessThan(30));
      expect(boxes[1][0].x, greaterThan(100));
      expect(boxes[2][0].y, greaterThan(40));
    });

    test('a slanted line keeps its slant', () {
      final map = Float32List(200 * 100);
      for (var x = 20; x < 180; x++) {
        final y0 = 40 + (x - 20) ~/ 8; // falls 20 px over 160
        for (var y = y0; y < y0 + 8; y++) {
          map[y * 200 + x] = 0.9;
        }
      }
      final boxes = boxesFromProbabilities(
        map,
        200,
        100,
        width: 200,
        height: 100,
      );
      expect(boxes, hasLength(1));
      final [tl, tr, _, _] = boxes.single;
      expect(tr.y - tl.y, greaterThan(10));
    });
  });

  group('cropLine', () {
    test('an upright box is cut as is', () {
      final image = img.Image(width: 100, height: 50)
        ..clear(img.ColorRgb8(255, 255, 255));
      img.fillRect(
        image,
        x1: 20,
        y1: 10,
        x2: 29,
        y2: 19,
        color: img.ColorRgb8(0, 0, 0),
      );
      final crop = cropLine(image, [
        (x: 20, y: 10),
        (x: 80, y: 10),
        (x: 80, y: 30),
        (x: 20, y: 30),
      ]);
      expect(crop.width, 60);
      expect(crop.height, 20);
      expect(crop.getPixel(2, 2).r, 0);
      expect(crop.getPixel(30, 15).r, 255);
    });

    test('a box much taller than wide is turned upright', () {
      final crop = cropLine(img.Image(width: 100, height: 100), [
        (x: 10, y: 10),
        (x: 20, y: 10),
        (x: 20, y: 80),
        (x: 10, y: 80),
      ]);
      expect(crop.width, 70);
      expect(crop.height, 10);
    });
  });

  test('recognitionInput pads every line to the widest, 48 px tall', () {
    final input = recognitionInput([
      img.Image(width: 100, height: 20)..clear(img.ColorRgb8(255, 255, 255)),
      img.Image(width: 300, height: 20)..clear(img.ColorRgb8(255, 255, 255)),
    ]);
    expect(input.shape, [2, 3, 48, 720]);
    // The first line is 240 px wide once 48 px tall: white, then padding.
    expect(input.data[239], closeTo(1, 1e-6));
    expect(input.data[240], 0);
    expect(input.data[3 * 48 * 720 + 719], closeTo(1, 1e-6));
  });

  test('recognitionInput is at least 320 px wide', () {
    final input = recognitionInput([img.Image(width: 20, height: 20)]);
    expect(input.shape, [1, 3, 48, 320]);
  });

  group('ctcDecode', () {
    Float32List probabilities(List<int> best, int classes) {
      final p = Float32List(best.length * classes);
      for (final (t, c) in best.indexed) {
        p[t * classes + c] = 0.8;
      }
      return p;
    }

    test('merges repeats, drops blanks, keeps letters split by a blank', () {
      final characters = ['a', 'b', ' '];
      final decoded = ctcDecode(
        probabilities([1, 1, 0, 2, 0, 2, 3, 1], 4),
        1,
        8,
        characters,
      );
      expect(decoded.single.$1, 'abb a');
      expect(decoded.single.$2, closeTo(0.8, 1e-6));
    });

    test('an all-blank line is empty with zero confidence', () {
      final decoded = ctcDecode(probabilities([0, 0, 0], 3), 1, 3, ['a', ' ']);
      expect(decoded.single, ('', 0.0));
    });

    test('decodes each line of a batch', () {
      final p = Float32List.fromList([
        ...probabilities([1, 0], 3),
        ...probabilities([2, 2], 3),
      ]);
      final decoded = ctcDecode(p, 2, 2, ['x', 'y']);
      expect([for (final d in decoded) d.$1], ['x', 'y']);
    });
  });
}
