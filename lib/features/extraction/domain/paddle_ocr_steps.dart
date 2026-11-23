import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// The steps of PP-OCR (PaddleOCR's detection + recognition pipeline)
/// around the two neural networks, ported from RapidOCR so the app reads
/// like the Python benchmark (`tool/bench/paddle_ocr.py`). Pure Dart: the
/// networks themselves run in `PaddleOcr` (onnxruntime).

/// A point in image pixels.
typedef Point = ({double x, double y});

/// A text line found by detection: four corners, top-left, top-right,
/// bottom-right, bottom-left.
typedef Quad = List<Point>;

/// Float32 tensor data with its shape.
typedef Tensor = ({Float32List data, List<int> shape});

/// Detection input: the photo scaled so its short side is at least
/// [limitSide], both sides rounded to a multiple of 32, as BGR channels
/// normalised to -1..1 (NCHW).
Tensor detectionInput(img.Image image, {int limitSide = 736}) {
  final h = image.height;
  final w = image.width;
  var ratio = 1.0;
  if (math.min(h, w) < limitSide) {
    ratio = limitSide / (h < w ? h : w);
  }
  final rh = math.max(32, ((h * ratio).truncate() / 32).round() * 32);
  final rw = math.max(32, ((w * ratio).truncate() / 32).round() * 32);
  final resized = img.copyResize(
    image,
    width: rw,
    height: rh,
    interpolation: img.Interpolation.linear,
  );
  return (data: _chwBgr(resized, rw), shape: [1, 3, rh, rw]);
}

/// Pixels of [image] as BGR planes normalised to -1..1, [width] columns
/// wide (zero padding on the right when wider than the image).
Float32List _chwBgr(img.Image image, int width) {
  final h = image.height;
  final plane = h * width;
  final out = Float32List(3 * plane);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final i = y * width + x;
      out[i] = p.b / 127.5 - 1;
      out[plane + i] = p.g / 127.5 - 1;
      out[2 * plane + i] = p.r / 127.5 - 1;
    }
  }
  return out;
}

/// DB post-processing: text line boxes from the detection network's
/// probability [map] ([mapWidth] × [mapHeight]), in the coordinates of an
/// image [width] × [height]. Same thresholds as RapidOCR.
List<Quad> boxesFromProbabilities(
  Float32List map,
  int mapWidth,
  int mapHeight, {
  required int width,
  required int height,
  double thresh = 0.3,
  double boxThresh = 0.5,
  double unclipRatio = 1.6,
  int maxCandidates = 1000,
}) {
  // Binarise, then dilate with a 2×2 kernel (the pixel, its right, lower
  // and lower-right neighbours, as cv2.dilate anchors it).
  final on = Uint8List(mapWidth * mapHeight);
  for (var i = 0; i < on.length; i++) {
    if (map[i] > thresh) on[i] = 1;
  }
  final mask = Uint8List(on.length);
  for (var y = 0; y < mapHeight; y++) {
    for (var x = 0; x < mapWidth; x++) {
      final i = y * mapWidth + x;
      if (on[i] == 1 ||
          (x > 0 && on[i - 1] == 1) ||
          (y > 0 && on[i - mapWidth] == 1) ||
          (x > 0 && y > 0 && on[i - mapWidth - 1] == 1)) {
        mask[i] = 1;
      }
    }
  }

  final boxes = <(Quad, double)>[];
  for (final border in _componentBorders(mask, mapWidth, mapHeight)) {
    if (boxes.length >= maxCandidates) break;
    final rect = _minAreaRect(border);
    if (math.min(rect.w, rect.h) < 3) continue;
    final corners = _miniBox(rect);
    final score = _meanInside(map, mapWidth, mapHeight, corners);
    if (score < boxThresh) continue;
    // Unclip: grow by area × ratio / perimeter on every side. The minimum
    // rectangle of the rounded offset polygon is the grown rectangle.
    final distance = rect.w * rect.h * unclipRatio / (2 * (rect.w + rect.h));
    final grown = (
      cx: rect.cx,
      cy: rect.cy,
      w: rect.w + 2 * distance,
      h: rect.h + 2 * distance,
      angle: rect.angle,
    );
    if (math.min(grown.w, grown.h) < 5) continue;
    final quad = [
      for (final p in _miniBox(grown))
        (
          x: (p.x / mapWidth * width).roundToDouble().clamp(0.0, width * 1.0),
          y: (p.y / mapHeight * height).roundToDouble().clamp(
            0.0,
            height * 1.0,
          ),
        ),
    ];
    boxes.add((_clockwise(quad, width, height), score));
  }

  return _sorted([
    for (final (quad, _) in boxes)
      if (_dist(quad[0], quad[1]).truncate() > 3 &&
          _dist(quad[0], quad[3]).truncate() > 3)
        quad,
  ]);
}

/// Border pixels of each 8-connected component of [mask].
List<List<Point>> _componentBorders(Uint8List mask, int w, int h) {
  final label = Int32List(mask.length);
  final borders = <List<Point>>[];
  final stack = <int>[];
  for (var start = 0; start < mask.length; start++) {
    if (mask[start] == 0 || label[start] != 0) continue;
    final id = borders.length + 1;
    final border = <Point>[];
    label[start] = id;
    stack.add(start);
    while (stack.isNotEmpty) {
      final i = stack.removeLast();
      final x = i % w;
      final y = i ~/ w;
      var edge = false;
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          final nx = x + dx;
          final ny = y + dy;
          if (nx < 0 || ny < 0 || nx >= w || ny >= h) {
            edge = true;
            continue;
          }
          final n = ny * w + nx;
          if (mask[n] == 0) {
            if (dx == 0 || dy == 0) edge = true;
            continue;
          }
          if (label[n] == 0) {
            label[n] = id;
            stack.add(n);
          }
        }
      }
      if (edge) border.add((x: x.toDouble(), y: y.toDouble()));
    }
    borders.add(border);
  }
  return borders;
}

typedef _Rect = ({double cx, double cy, double w, double h, double angle});

/// Smallest rectangle around [points] (rotating calipers on the hull).
_Rect _minAreaRect(List<Point> points) {
  final hull = _convexHull(points);
  if (hull.length == 1) {
    return (cx: hull[0].x, cy: hull[0].y, w: 0, h: 0, angle: 0);
  }
  _Rect? best;
  var bestArea = double.infinity;
  for (var i = 0; i < hull.length; i++) {
    final a = hull[i];
    final b = hull[(i + 1) % hull.length];
    final len = _dist(a, b);
    if (len == 0) continue;
    final ux = (b.x - a.x) / len;
    final uy = (b.y - a.y) / len;
    var minU = double.infinity;
    var maxU = -double.infinity;
    var minV = double.infinity;
    var maxV = -double.infinity;
    for (final p in hull) {
      final u = p.x * ux + p.y * uy;
      final v = -p.x * uy + p.y * ux;
      minU = math.min(minU, u);
      maxU = math.max(maxU, u);
      minV = math.min(minV, v);
      maxV = math.max(maxV, v);
    }
    final area = (maxU - minU) * (maxV - minV);
    if (area < bestArea) {
      bestArea = area;
      final cu = (minU + maxU) / 2;
      final cv = (minV + maxV) / 2;
      best = (
        cx: cu * ux - cv * uy,
        cy: cu * uy + cv * ux,
        w: maxU - minU,
        h: maxV - minV,
        angle: math.atan2(uy, ux),
      );
    }
  }
  return best!;
}

List<Point> _convexHull(List<Point> points) {
  final p = [...points]
    ..sort((a, b) => a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y));
  if (p.length < 3) return p;
  double cross(Point o, Point a, Point b) =>
      (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
  final lower = <Point>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <Point>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [...lower..removeLast(), ...upper..removeLast()];
}

/// The rectangle's corners ordered as RapidOCR's get_mini_boxes does.
Quad _miniBox(_Rect r) {
  final c = math.cos(r.angle);
  final s = math.sin(r.angle);
  final hw = r.w / 2;
  final hh = r.h / 2;
  final points = [
    for (final (u, v) in [(-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)])
      (x: r.cx + u * c - v * s, y: r.cy + u * s + v * c),
  ]..sort((a, b) => a.x.compareTo(b.x));
  final (i1, i4) = points[1].y > points[0].y ? (0, 1) : (1, 0);
  final (i2, i3) = points[3].y > points[2].y ? (2, 3) : (3, 2);
  return [points[i1], points[i2], points[i3], points[i4]];
}

/// Mean of [map] over the pixels inside [quad] (RapidOCR's "fast" score).
double _meanInside(Float32List map, int w, int h, Quad quad) {
  final xs = quad.map((p) => p.x);
  final ys = quad.map((p) => p.y);
  final x0 = xs.reduce(math.min).floor().clamp(0, w - 1);
  final x1 = xs.reduce(math.max).ceil().clamp(0, w - 1);
  final y0 = ys.reduce(math.min).floor().clamp(0, h - 1);
  final y1 = ys.reduce(math.max).ceil().clamp(0, h - 1);
  final corners = [
    for (final p in quad)
      (x: p.x.truncateToDouble(), y: p.y.truncateToDouble()),
  ];
  var sum = 0.0;
  var count = 0;
  for (var y = y0; y <= y1; y++) {
    for (var x = x0; x <= x1; x++) {
      if (_inside(corners, x.toDouble(), y.toDouble())) {
        sum += map[y * w + x];
        count++;
      }
    }
  }
  return count == 0 ? 0 : sum / count;
}

/// Whether (x, y) is inside or on the convex quadrilateral [q].
bool _inside(Quad q, double x, double y) {
  var sign = 0;
  for (var i = 0; i < 4; i++) {
    final a = q[i];
    final b = q[(i + 1) % 4];
    final cross = (b.x - a.x) * (y - a.y) - (b.y - a.y) * (x - a.x);
    if (cross.abs() < 1e-9) continue;
    final s = cross > 0 ? 1 : -1;
    if (sign == 0) {
      sign = s;
    } else if (s != sign) {
      return false;
    }
  }
  return true;
}

/// Corners as top-left, top-right, bottom-right, bottom-left, clipped to
/// the image and truncated to whole pixels.
Quad _clockwise(Quad quad, int width, int height) {
  final byX = [...quad]..sort((a, b) => a.x.compareTo(b.x));
  final left = byX.sublist(0, 2)..sort((a, b) => a.y.compareTo(b.y));
  final right = byX.sublist(2)..sort((a, b) => a.y.compareTo(b.y));
  Point clip(Point p) => (
    x: p.x.clamp(0, width - 1).truncateToDouble(),
    y: p.y.clamp(0, height - 1).truncateToDouble(),
  );
  return [clip(left[0]), clip(right[0]), clip(right[1]), clip(left[1])];
}

/// Top to bottom, left to right within boxes less than 10 px apart.
List<Quad> _sorted(List<Quad> boxes) {
  final byY = [...boxes]..sort((a, b) => a[0].y.compareTo(b[0].y));
  final lineIds = <int>[];
  for (var i = 0; i < byY.length; i++) {
    lineIds.add(
      i == 0 ? 0 : lineIds.last + (byY[i][0].y - byY[i - 1][0].y >= 10 ? 1 : 0),
    );
  }
  final order = List<int>.generate(byY.length, (i) => i)
    ..sort((a, b) {
      final line = lineIds[a].compareTo(lineIds[b]);
      return line != 0 ? line : byY[a][0].x.compareTo(byY[b][0].x);
    });
  return [for (final i in order) byY[i]];
}

double _dist(Point a, Point b) =>
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));

/// The text line inside [quad], straightened: as wide as its longer
/// horizontal side, as tall as its longer vertical one; turned upright when
/// much taller than wide.
img.Image cropLine(img.Image image, Quad quad) {
  final w = math.max(_dist(quad[0], quad[1]), _dist(quad[2], quad[3])).toInt();
  final h = math.max(_dist(quad[0], quad[3]), _dist(quad[1], quad[2])).toInt();
  final out = img.Image(width: math.max(w, 1), height: math.max(h, 1));
  final project = _perspective(quad, w.toDouble(), h.toDouble());
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final (sx, sy) = project(x.toDouble(), y.toDouble());
      out.setPixel(
        x,
        y,
        image.getPixelInterpolate(
          sx.clamp(0, image.width - 1),
          sy.clamp(0, image.height - 1),
        ),
      );
    }
  }
  return out.height / out.width >= 1.5 ? img.copyRotate(out, angle: -90) : out;
}

/// Maps a point of the w × h crop back into the photo (the inverse of the
/// perspective transform from [quad] to the crop's corners).
(double, double) Function(double, double) _perspective(
  Quad quad,
  double w,
  double h,
) {
  // Homography from the unit square to the quad (Heckbert), scaled to w×h.
  final (x0, y0) = (quad[0].x, quad[0].y);
  final (x1, y1) = (quad[1].x, quad[1].y);
  final (x2, y2) = (quad[2].x, quad[2].y);
  final (x3, y3) = (quad[3].x, quad[3].y);
  final dx1 = x1 - x2;
  final dx2 = x3 - x2;
  final dy1 = y1 - y2;
  final dy2 = y3 - y2;
  final sx = x0 - x1 + x2 - x3;
  final sy = y0 - y1 + y2 - y3;
  double g;
  double hh;
  if (sx.abs() < 1e-9 && sy.abs() < 1e-9) {
    g = 0;
    hh = 0;
  } else {
    final den = dx1 * dy2 - dx2 * dy1;
    g = (sx * dy2 - dx2 * sy) / den;
    hh = (dx1 * sy - sx * dy1) / den;
  }
  final a = x1 - x0 + g * x1;
  final b = x3 - x0 + hh * x3;
  final d = y1 - y0 + g * y1;
  final e = y3 - y0 + hh * y3;
  return (x, y) {
    final u = w == 0 ? 0.0 : x / w;
    final v = h == 0 ? 0.0 : y / h;
    final z = g * u + hh * v + 1;
    return ((a * u + b * v + x0) / z, (d * u + e * v + y0) / z);
  };
}

/// Recognition input for a batch of line [crops]: 48 px tall, as wide as
/// the widest line's aspect ratio (at least 320), right-padded with zeros.
Tensor recognitionInput(List<img.Image> crops) {
  const height = 48;
  var maxRatio = 320 / height;
  for (final c in crops) {
    maxRatio = math.max(maxRatio, c.width / c.height);
  }
  final width = (height * maxRatio).truncate();
  final plane = height * width;
  final data = Float32List(crops.length * 3 * plane);
  for (final (n, crop) in crops.indexed) {
    final resizedWidth = math.min(
      width,
      (height * crop.width / crop.height).ceil(),
    );
    final resized = img.copyResize(
      crop,
      width: resizedWidth,
      height: height,
      interpolation: img.Interpolation.linear,
    );
    data.setRange(n * 3 * plane, (n + 1) * 3 * plane, _chwBgr(resized, width));
  }
  return (data: data, shape: [crops.length, 3, height, width]);
}

/// Whether [character] can appear on an Italian receipt: ASCII, Latin-1
/// (accented letters, °, ×), Latin Extended-A and €. The recogniser knows
/// 18,708 characters of many scripts; on a receipt a Chinese or Cyrillic
/// one is a printed symbol the model has no class for, so decoding drops
/// it (taking the next best letter instead invented letters: "WGRANMIX").
bool isReceiptCharacter(String character) => character.runes.every(
  (r) => (r >= 0x20 && r <= 0x7E) || (r >= 0xA0 && r <= 0x17F) || r == 0x20AC,
);

/// CTC greedy decoding of the recognition output ([batch] × [steps] ×
/// classes): the best class per step, repeats merged, blanks (class 0)
/// dropped. [characters] are the model's classes 1..n-1 (the last one is
/// a space). Steps whose best class has a 0 [allowed] entry are dropped
/// (see [isReceiptCharacter]). Returns each line's text and mean confidence.
List<(String, double)> ctcDecode(
  Float32List probabilities,
  int batch,
  int steps,
  List<String> characters, {
  Uint8List? allowed,
}) {
  final classes = characters.length + 1;
  final results = <(String, double)>[];
  for (var b = 0; b < batch; b++) {
    final text = StringBuffer();
    var sum = 0.0;
    var count = 0;
    var previous = -1;
    for (var t = 0; t < steps; t++) {
      final offset = (b * steps + t) * classes;
      var best = 0;
      var bestP = probabilities[offset];
      for (var c = 1; c < classes; c++) {
        final p = probabilities[offset + c];
        if (p > bestP) {
          bestP = p;
          best = c;
        }
      }
      // A step whose best class is not a receipt character is dropped:
      // the model saw a printed symbol (a flag, a logo), not a letter.
      final skip = allowed != null && allowed[best] == 0;
      if (best != 0 && best != previous && !skip) {
        text.write(characters[best - 1]);
        sum += bestP;
        count++;
      }
      previous = best;
    }
    results.add((text.toString(), count == 0 ? 0 : sum / count));
  }
  return results;
}

/// [ctcDecode]'s `allowed` mask for [characters]: 1 for the blank and for
/// every receipt character.
Uint8List receiptCharacterMask(List<String> characters) {
  final mask = Uint8List(characters.length + 1)..[0] = 1;
  for (final (i, c) in characters.indexed) {
    if (isReceiptCharacter(c)) mask[i + 1] = 1;
  }
  return mask;
}
