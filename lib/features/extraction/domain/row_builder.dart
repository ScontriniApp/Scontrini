import 'dart:math' as math;

import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/receipt_row.dart';

/// Groups the extractor's lines into printed rows.
///
/// ML Kit tends to return the name column and the price column of a receipt
/// as separate lines, often in separate blocks, so reading them in order
/// would pair names with the wrong prices. This puts lines that share a
/// vertical position back on one row, ordered left to right.
///
/// Photos are rarely perfectly straight: the page skew is estimated as the
/// median line angle, and each line's vertical position is corrected for it
/// before grouping, so a price far to the right still lands on its row.
class RowBuilder {
  const new({this.tolerance = 0.5});

  /// Maximum distance between a line and a row, as a fraction of the median
  /// line height of the page, for the line to join that row.
  final double tolerance;

  List<ReceiptRow> build(OcrDocument document) => [
    for (final (index, page) in document.pages.indexed)
      ..._buildPage(index, page),
  ];

  List<ReceiptRow> _buildPage(int pageIndex, OcrPage page) {
    final lines = page.lines.where((l) => l.text.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const [];

    final slope = math.tan(
      _median([for (final l in lines) l.angle]) * math.pi / 180,
    );
    final maxDistance =
        tolerance * _median([for (final l in lines) l.box.height]);

    // Vertical position of each line projected back to x = 0 along the
    // page skew, so lines on the same row get (nearly) the same value.
    double rowKey(OcrLine line) =>
        line.box.centerY - (line.box.left + line.box.right) / 2 * slope;

    final keyed = [for (final line in lines) (key: rowKey(line), line: line)]
      ..sort((a, b) => a.key.compareTo(b.key));

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

    return [
      for (final group in groups)
        ReceiptRow(
          page: pageIndex,
          cells: [for (final entry in group) entry.line]
            ..sort((a, b) => a.box.left.compareTo(b.box.left)),
        ),
    ];
  }

  static double _median(List<double> values) {
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
