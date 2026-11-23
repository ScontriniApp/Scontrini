import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/word_spacing.dart';

const _cell = 20.0;

/// Lays out [printed] in a fixed-width font: one 20 px cell per character,
/// narrow letters drawn 4 px wide in the middle of their cell, others 14 px.
/// Words are split wherever [ocrWords] says ML Kit split them.
List<List<OcrGlyph>> _monospace(String printed, List<String> ocrWords) {
  final glyphs = <OcrGlyph>[];
  for (final (i, char) in printed.split('').indexed) {
    if (char == ' ') continue;
    final ink = "IiLl1.,:'".contains(char) ? 4.0 : 14.0;
    final center = i * _cell + _cell / 2;
    glyphs.add(OcrGlyph(char, center - ink / 2, center + ink / 2));
  }
  var next = 0;
  return [
    for (final word in ocrWords)
      [for (var k = 0; k < word.length; k++) glyphs[next++]],
  ];
}

void main() {
  const spacing = WordSpacing();

  test('joins words split around narrow letters', () {
    expect(
      spacing.join(
        _monospace('CODICE A BARRE DI USCITA', [
          'CODI', 'CE', 'A', 'BARRE', 'DI', 'USCI', 'TA', //
        ]),
      ),
      'CODICE A BARRE DI USCITA',
    );
    expect(
      spacing.join(_monospace('DI CUI IVA', ['DI', 'CUI', 'I', 'VA'])),
      'DI CUI IVA',
    );
    expect(
      spacing.join(
        _monospace('Pagamento elettronico', [
          'Pagamento',
          'el',
          'ettroni',
          'co',
        ]),
      ),
      'Pagamento elettronico',
    );
  });

  test('joins an amount split at the comma', () {
    expect(
      spacing.join(_monospace('SEDANO 1,96', ['SEDANO', '1,', '96'])),
      'SEDANO 1,96',
    );
  });

  test('keeps a wide gap as a single space', () {
    expect(
      spacing.join(_monospace('IVA      9,42', ['IVA', '9,42'])),
      'IVA 9,42',
    );
  });

  test('keeps letter-spaced headings spaced', () {
    expect(
      spacing.join(
        _monospace('G R A Z I E', ['G', 'R', 'A', 'Z', 'I', 'E']),
        pagePitch: _cell,
      ),
      'G R A Z I E',
    );
  });

  test('uses the page pitch for lines too short to measure', () {
    final words = _monospace('I VA', ['I', 'VA']);
    expect(spacing.join(words), isNull, reason: 'one sample only');
    expect(spacing.join(words, pagePitch: _cell), 'I VA');
    expect(
      spacing.join(_monospace('IVA', ['I', 'VA']), pagePitch: _cell),
      'IVA',
    );
  });

  test('pagePitch is the median in-word centre distance', () {
    expect(
      spacing.pagePitch([
        _monospace('LATTE INTERO', ['LATTE', 'INTERO']),
      ]),
      _cell,
    );
    expect(spacing.pagePitch([]), isNull);
  });
}
