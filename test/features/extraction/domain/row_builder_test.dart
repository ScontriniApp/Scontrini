import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

const _lineHeight = 30.0;
const _rowPitch = 40.0;

/// A line of text on printed row [row], starting at [left], on a page
/// rotated clockwise by [angle] degrees around the origin.
OcrLine _line(String text, int row, double left, {double angle = 0}) {
  final width = text.length * 18.0;
  final top = 100 + row * _rowPitch;
  final slope = math.tan(angle * math.pi / 180);
  final shift = (left + width / 2) * slope;
  return OcrLine(
    text: text,
    angle: angle,
    box: TextBox(
      left: left,
      top: top + shift,
      right: left + width,
      bottom: top + _lineHeight + shift,
    ),
  );
}

OcrDocument _doc(List<List<OcrLine>> pages) => OcrDocument(
  source: TextSource.ocr,
  pages: [
    for (final lines in pages) OcrPage(width: 1080, height: 2400, lines: lines),
  ],
);

List<String> _texts(OcrDocument doc) => [
  for (final row in const RowBuilder().build(doc)) row.text,
];

void main() {
  test('joins the name column and the price column row by row', () {
    // ML Kit order: the whole name block first, then the price block.
    final doc = _doc([
      [
        _line('LATTE INTERO', 0, 20),
        _line('BANANE', 1, 20),
        _line('PASTA', 2, 20),
        _line('1,29 B', 0, 800),
        _line('0,91 A', 1, 800),
        _line('1,78 B', 2, 800),
      ],
    ]);

    expect(_texts(doc), [
      'LATTE INTERO 1,29 B',
      'BANANE 0,91 A',
      'PASTA 1,78 B',
    ]);
  });

  test('keeps rows apart when the price is slightly offset', () {
    final doc = _doc([
      [
        _line('LATTE INTERO', 0, 20),
        _line('BANANE', 1, 20),
        _line('1,29 B', 0, 800).copyWith(
          box: const TextBox(left: 800, top: 108, right: 908, bottom: 138),
        ),
        _line('0,91 A', 1, 800),
      ],
    ]);

    expect(_texts(doc), ['LATTE INTERO 1,29 B', 'BANANE 0,91 A']);
  });

  test('corrects page skew using the line angle', () {
    // 3° over ~900 px moves the price ~47 px down: more than a row pitch.
    const angle = 3.0;
    final doc = _doc([
      [
        _line('LATTE INTERO', 0, 20, angle: angle),
        _line('BANANE', 1, 20, angle: angle),
        _line('PASTA', 2, 20, angle: angle),
        _line('1,29 B', 0, 800, angle: angle),
        _line('0,91 A', 1, 800, angle: angle),
        _line('1,78 B', 2, 800, angle: angle),
      ],
    ]);

    expect(_texts(doc), [
      'LATTE INTERO 1,29 B',
      'BANANE 0,91 A',
      'PASTA 1,78 B',
    ]);
  });

  test('orders cells left to right and keeps single-cell rows', () {
    final doc = _doc([
      [
        _line('SUPERMERCATO', 0, 300),
        _line('B', 1, 900),
        _line('2 x 0,89', 1, 60),
        _line('1,78', 1, 700),
      ],
    ]);

    expect(_texts(doc), ['SUPERMERCATO', '2 x 0,89 1,78 B']);
  });

  test('numbers rows per page and skips blank lines', () {
    final doc = _doc([
      [_line('TOTALE', 0, 20), _line('   ', 0, 400)],
      [_line('GRAZIE', 0, 20)],
      [],
    ]);

    final rows = const RowBuilder().build(doc);
    expect(
      [for (final r in rows) (r.page, r.text)],
      [(0, 'TOTALE'), (1, 'GRAZIE')],
    );
  });

  /// Twelve rows of name + price + VAT, each box reporting angle 0 (as
  /// short OCR boxes do), but placed on a page whose rows slope by
  /// [slopeAt] (degrees, as a function of the row).
  List<OcrLine> receiptRows(double Function(int row) slopeAt) => [
    for (var row = 0; row < 12; row++)
      for (final (text, left) in [
        ('PRODOTTO $row', 20.0),
        ('${row + 1},50', 640.0),
        ('04,00', 820.0),
      ])
        () {
          final line = _line(text, row, left);
          final shift =
              (line.box.left + line.box.width / 2) *
              math.tan(slopeAt(row) * math.pi / 180);
          return line.copyWith(
            box: TextBox(
              left: line.box.left,
              top: line.box.top + shift,
              right: line.box.right,
              bottom: line.box.bottom + shift,
            ),
          );
        }(),
  ];

  List<String> expectedRows() => [
    for (var row = 0; row < 12; row++) 'PRODOTTO $row ${row + 1},50 04,00',
  ];

  test('finds a page rotation that the box angles do not report', () {
    // 3° over ~800 px: the price column sits more than half a row lower.
    expect(_texts(_doc([receiptRows((_) => 3)])), expectedRows());
  });

  test('follows a curved receipt whose slope changes down the page', () {
    expect(
      _texts(_doc([receiptRows((row) => -1.5 + row * 0.25)])),
      expectedRows(),
    );
  });

  test('drops short text printed on the mat beside the receipt', () {
    final lines = [
      ...receiptRows((_) => 0),
      const OcrLine(
        text: 'UT',
        box: TextBox(left: -200, top: 140, right: -120, bottom: 170),
      ),
    ];
    expect(_texts(_doc([lines])), expectedRows());
  });
}
