import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';

const _parser = ReceiptParser();

void main() {
  group('dates', () {
    DateTime? dateOf(String row) =>
        _parser.parseLines(['NEGOZIO', row]).purchaseDate;

    test('reads common formats', () {
      expect(dateOf('19/11/2026 18:42'), DateTime(2026, 11, 19, 18, 42));
      expect(dateOf('19-11-26 ORE 08.05'), DateTime(2026, 11, 19, 8, 5));
      expect(dateOf('DATA 1.3.2026'), DateTime(2026, 3));
    });

    test('reads a time after "Ora:" with OCR spaces', () {
      expect(
        dateOf('Data: 08/10/26 Ora: 11: 17'),
        DateTime(2026, 10, 8, 11, 17),
      );
    });

    test('prefers a later date that has a time', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'EMESSO IL 08/10/2026',
        '000000101 001 00001 08/10/2026 11:17',
      ]);
      expect(receipt.purchaseDate, DateTime(2026, 10, 8, 11, 17));
    });

    test('ignores an impossible time but keeps the date', () {
      expect(dateOf('08/10/2026 14.83'), DateTime(2026, 10, 8));
    });

    test('rejects impossible dates', () {
      expect(dateOf('31/02/2026'), isNull);
      expect(dateOf('12/13/2026'), isNull);
    });
  });

  test('reads VAT numbers in their common spellings', () {
    String? vatOf(String row) => _parser.parseLines(['NEGOZIO', row]).vatNumber;
    expect(vatOf('P.I. 02036440275'), '02036440275');
    expect(vatOf('P.IVA 02036440275'), '02036440275');
    expect(vatOf('P.I.V.A. IT02036440275'), '02036440275');
    expect(vatOf("PIU' AMENO 02036440275"), isNull);
  });

  test('reads a VAT number split by OCR spaces', () {
    final receipt = _parser.parseLines([
      'NEGOZIO',
      'PARTITA IVA: 012 345 678 90',
    ]);
    expect(receipt.vatNumber, '01234567890');
  });

  test('joins amounts split by OCR', () {
    final receipt = _parser.parseLines(['LATTE 1 ,29', 'TOTALE 1, 29']);
    expect(receipt.items.single.lineTotalCents, 129);
    expect(receipt.totalCents, 129);
  });

  test('reads the total from the next row when it is on its own', () {
    final receipt = _parser.parseLines(['LATTE 1,29', 'TOTALE', '1,29']);
    expect(receipt.totalCents, 129);
    expect(receipt.isBalanced, isTrue);
  });

  test('flags a total that does not match the items', () {
    final receipt = _parser.parseLines([
      'LATTE 1,29',
      'PANE 1,10',
      'TOTALE 3,00',
    ]);
    expect(receipt.warnings, contains(ParseWarning.totalMismatch));
  });

  test('a discount before any subtotal goes to the item above it', () {
    final receipt = _parser.parseLines([
      'LATTE 1,29',
      'SCONTO 0,30',
      'TOTALE 0,99',
    ]);
    expect(receipt.items.single.discountCents, 30);
    expect(receipt.discountCents, 0);
    expect(receipt.isBalanced, isTrue);
  });

  test('a weighed item without a unit is read as kilograms', () {
    final receipt = _parser.parseLines(['MELE 1,50', '0,750 X 2,00']);
    final item = receipt.items.single;
    expect(item.quantity, 0.75);
    expect(item.unit, QuantityUnit.kilogram);
    expect(item.warnings, isEmpty);
  });

  test('never throws on garbage', () {
    final receipt = _parser.parseLines(['', '%%%', '12', '-,--', 'X X 1,2,3']);
    expect(receipt.items, isEmpty);
  });

  test('parses an OcrDocument through the row builder', () {
    OcrLine line(String text, double left, double top) => OcrLine(
      text: text,
      box: TextBox(
        left: left,
        top: top,
        right: left + text.length * 18,
        bottom: top + 30,
      ),
    );
    // Name column first, price column second, as ML Kit returns them.
    const document = OcrDocument(source: TextSource.ocr, pages: []);
    final receipt = _parser.parse(
      document.copyWith(
        pages: [
          OcrPage(
            width: 1080,
            height: 2400,
            lines: [
              line('LATTE INTERO', 20, 100),
              line('TOTALE', 20, 140),
              line('1,29', 800, 101),
              line('1,29', 800, 141),
            ],
          ),
        ],
      ),
    );

    expect(receipt.items.single.rawName, 'LATTE INTERO');
    expect(receipt.totalCents, 129);
  });
}
