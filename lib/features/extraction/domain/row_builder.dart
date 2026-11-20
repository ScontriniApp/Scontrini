import 'dart:math' as math;

import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/receipt_row.dart';

/// Groups the extractor's lines into printed rows.
///
/// OCR engines return the name column and the price column of a receipt as
/// separate boxes, so reading them in order would pair names with the wrong
/// prices. This puts boxes that share a printed row back together, ordered
/// left to right.
///
/// Photos are rarely flat and straight, so the row direction is estimated
/// from the geometry itself, not from the boxes' own angles (short boxes like
/// `2,38` or `X` report 0° whatever the page does):
/// - the slope is the one that lines up boxes of different columns best,
///   searched between -[maxSkewDegrees] and +[maxSkewDegrees];
/// - it is estimated again in bands down the page and interpolated, so a
///   curved receipt (slope changing from top to bottom) still lines up;
/// - two boxes share a row when they are closer than a fraction of the row
///   pitch (the distance between printed rows), not of the text height:
///   on tight receipts the text is taller than half the pitch;
/// - short boxes outside the band of the receipt (text printed on the table
///   or mat under it) are dropped.
class RowBuilder {
  const new({this.tolerance = 0.5, this.maxSkewDegrees = 8});

  /// Maximum distance between a box and a row, as a fraction of the row
  /// pitch (capped at the same fraction of the text height).
  final double tolerance;

  /// Largest page slope searched, in degrees.
  final double maxSkewDegrees;

  List<ReceiptRow> build(OcrDocument document) => [
    for (final (index, page) in document.pages.indexed)
      ..._buildPage(index, page),
  ];

  List<ReceiptRow> _buildPage(int pageIndex, OcrPage page) {
    var lines = page.lines.where((l) => l.text.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const [];

    final height = _median([for (final l in lines) l.box.height]);
    lines = _dropOutsideReceipt(lines, height);
    final xRef = _median([for (final l in lines) _centerX(l)]);

    List<({double key, OcrLine line})> keyedBy(
      double Function(double) slopeAt,
    ) => [
      for (final l in lines)
        (
          key: l.box.centerY - (_centerX(l) - xRef) * slopeAt(l.box.centerY),
          line: l,
        ),
    ]..sort((a, b) => a.key.compareTo(b.key));

    // 1. Page slope; a first grouping with it gives the row pitch.
    final global = _pageSlope(lines, height, xRef);
    final pitch = _rowPitch(
      _group(keyedBy((_) => global), tolerance * height),
      height,
    );

    // 2. Slope refined in bands, for curved paper.
    final slopeAt = _slopeField(lines, height, xRef, global, pitch);
    final keyed = keyedBy(slopeAt);

    // 3. Rows: closer than a fraction of the pitch.
    final maxDistance = tolerance * math.min(height, pitch);
    final groups = _group(keyed, maxDistance);

    return [
      for (final group in groups)
        ReceiptRow(
          page: pageIndex,
          cells: [for (final entry in group) entry.line]
            ..sort((a, b) => a.box.left.compareTo(b.box.left)),
        ),
    ];
  }

  static double _centerX(OcrLine l) => (l.box.left + l.box.right) / 2;

  static List<List<({double key, OcrLine line})>> _group(
    List<({double key, OcrLine line})> keyed,
    double maxDistance,
  ) {
    final groups = <List<({double key, OcrLine line})>>[];
    var rowMean = 0.0;
    for (final entry in keyed) {
      if (groups.isEmpty || entry.key - rowMean > maxDistance) {
        groups.add([entry]);
        rowMean = entry.key;
      } else {
        final group = groups.last..add(entry);
        rowMean += (entry.key - rowMean) / group.length;
      }
    }
    return groups;
  }

  /// Typical distance between consecutive rows; the text height when there
  /// are too few rows to tell.
  static double _rowPitch(
    List<List<({double key, OcrLine line})>> groups,
    double height,
  ) {
    final means = [
      for (final g in groups) g.fold<double>(0, (s, e) => s + e.key) / g.length,
    ];
    final gaps = [
      for (var i = 1; i < means.length; i++)
        if (means[i] - means[i - 1] < 3 * height) means[i] - means[i - 1],
    ];
    if (gaps.length < 4) return height;
    return _median(gaps);
  }

  /// Drops short boxes lying outside the horizontal band of the receipt:
  /// text on the mat or table around it (`UT`, `VC`, `M`).
  static List<OcrLine> _dropOutsideReceipt(List<OcrLine> lines, double height) {
    if (lines.length < 12) return lines;
    final lefts = [for (final l in lines) l.box.left]..sort();
    final rights = [for (final l in lines) l.box.right]..sort();
    final low = lefts[(lefts.length * 0.05).floor()] - height / 2;
    final high =
        rights[(rights.length * 0.95).floor().clamp(0, rights.length - 1)] +
        height / 2;
    // The centre decides: mat text often touches the edge of the receipt.
    return [
      for (final l in lines)
        if (l.text.replaceAll(RegExp(r'\s'), '').length > 3 ||
            (_centerX(l) > low && _centerX(l) < high))
          l,
    ];
  }

  static final double _step = math.tan(0.25 * math.pi / 180);

  /// Best slope for the whole page.
  double _pageSlope(List<OcrLine> lines, double height, double xRef) {
    final maxSlope = math.tan(maxSkewDegrees * math.pi / 180);
    return _bestSlope(
          lines,
          height,
          xRef,
          -maxSlope,
          maxSlope,
          _step,
          center: 0,
          penalty: 0.15 / maxSlope,
        ) ??
        0;
  }

  /// Slope of the printed rows as a function of the vertical position: the
  /// page slope [global], refined in bands down the page.
  ///
  /// A band may differ from the page by at most what moves the farthest
  /// column by half a row ([pitch]): beyond that, a curve and a column
  /// shifted by a whole row look the same, and the shift would win.
  double Function(double y) _slopeField(
    List<OcrLine> lines,
    double height,
    double xRef,
    double global,
    double pitch,
  ) {
    final step = _step;
    final reach = lines.fold<double>(
      0,
      (m, l) => math.max(m, (_centerX(l) - xRef).abs()),
    );
    final maxDeviation = reach == 0 ? 0.0 : 0.5 * pitch / reach;
    final steps = (maxDeviation / step).floor();
    if (steps == 0) return (_) => global;

    // Bands of about 8 rows, moving by 3 rows.
    final ys = [for (final l in lines) l.box.centerY]..sort();
    final top = ys.first;
    final bottom = ys.last;
    final half = 4 * height;
    final samples = <(double, double)>[];
    for (var y = top; y <= bottom; y += 1.5 * height) {
      final band = [
        for (final l in lines)
          if ((l.box.centerY - y).abs() <= half) l,
      ];
      final local = _bestSlope(
        band,
        height,
        xRef,
        global - steps * step,
        global + steps * step,
        step,
        minPairs: 3,
        center: global,
        penalty: 0.3 / (steps * step),
      );
      samples.add((y, local ?? global));
    }
    if (samples.isEmpty) return (_) => global;

    return (y) {
      if (y <= samples.first.$1) return samples.first.$2;
      if (y >= samples.last.$1) return samples.last.$2;
      for (var i = 1; i < samples.length; i++) {
        final (y1, s1) = samples[i];
        if (y <= y1) {
          final (y0, s0) = samples[i - 1];
          return s0 + (s1 - s0) * (y - y0) / (y1 - y0);
        }
      }
      return global;
    };
  }

  /// The slope in [from]..[to] that puts the most pairs of boxes from
  /// different columns on the same line. `null` if fewer than [minPairs]
  /// such pairs line up at any slope (nothing to measure).
  ///
  /// A slope that shifts one column by exactly one row lines up almost as
  /// many pairs as the right one, so each slope's score is reduced by
  /// [penalty] per unit of distance from [center] (0 for the whole page,
  /// the page slope for a band): near-ties go to the expected slope, a clear
  /// skew still wins.
  static double? _bestSlope(
    List<OcrLine> lines,
    double height,
    double xRef,
    double from,
    double to,
    double step, {
    required double center,
    required double penalty,
    int minPairs = 1,
  }) {
    final cx = [for (final l in lines) _centerX(l)];
    final cy = [for (final l in lines) l.box.centerY];
    final near = height / 4;
    double? best;
    var bestScore = 0.0;
    for (var s = from; s <= to + step / 2; s += step) {
      var score = 0.0;
      for (var i = 0; i < lines.length; i++) {
        final ki = cy[i] - (cx[i] - xRef) * s;
        for (var j = i + 1; j < lines.length; j++) {
          // Only boxes far apart horizontally say anything about the slope.
          if ((cx[i] - cx[j]).abs() < 2 * height) continue;
          final d = (ki - (cy[j] - (cx[j] - xRef) * s)).abs();
          if (d < near) score += 1 - d / near;
        }
      }
      score *= math.max(0, 1 - penalty * (s - center).abs());
      if (score > bestScore + 1e-9) {
        bestScore = score;
        best = s;
      }
    }
    return bestScore >= minPairs * 0.5 ? best : null;
  }

  static double _median(List<double> values) {
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
