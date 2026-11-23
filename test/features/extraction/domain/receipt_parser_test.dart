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
  group('VAT rate printed as a plain number after the price', () {
    test('a VAT column announced in the headings is not read as price', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE PREZZO %Iva',
        'PANINI AL LATTE 2,50 10,00',
        'SAC COMPOSTABILE 0,02 22,00',
        'TOTALE COMPLESSIVO 2,52',
      ]);
      expect([for (final i in receipt.items) i.lineTotalCents], [250, 2]);
      expect(
        [for (final i in receipt.items) i.rawName],
        ['PANINI AL LATTE', 'SAC COMPOSTABILE'],
      );
    });

    test('a leading-zero rate (04,00) is never a price', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE',
        'LATTE 1,85 04,00',
        'TOTALE 1,85',
      ]);
      expect(receipt.items.single.lineTotalCents, 185);
    });

    test('without a VAT column, a 10,00 line total stays a price', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE',
        '4 PASTA 2,50 10,00',
        'TOTALE 10,00',
      ]);
      expect(receipt.items.single.lineTotalCents, 1000);
    });
  });

  group('column layout from the headings', () {
    test('VAT before the price: the rate is not read as the price', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE IVA PREZZO',
        'CAFFE MACINATO 10,00 4,00',
        'ZUCCHERO 4,00 1,20',
        'TOTALE 5,20',
      ]);
      expect(
        [for (final i in receipt.items) i.rawName],
        ['CAFFE MACINATO', 'ZUCCHERO'],
      );
      expect([for (final i in receipt.items) i.lineTotalCents], [400, 120]);
      expect(receipt.isBalanced, isTrue);
    });

    test('VAT after the price: the same row reads the other way', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE PREZZO %IVA',
        'CAFFE MACINATO 10,00 4,00',
        'TOTALE 10,00',
      ]);
      expect(receipt.items.single.lineTotalCents, 1000);
      expect(receipt.items.single.rawName, 'CAFFE MACINATO');
    });

    test('headings split over two rows add up', () {
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE',
        'PREZZO %Iva',
        'PANINI 2,50 10,00',
        'TOTALE 2,50',
      ]);
      expect(receipt.items.single.lineTotalCents, 250);
    });

    test('quantity in its own first column (QTA)', () {
      final receipt = _parser.parseLines([
        'CONAD',
        "QTA' DESCRIZIONE PREZZO TOTALE",
        '2 PANE BAULETTO 1,29 2,58',
        '16 NUTELLA 750G 5,49 87,84',
        '1 BANANE 1,79 1,79',
        'TOTALE COMPLESSIVO 92,21',
      ]);
      expect(
        [for (final i in receipt.items) i.rawName],
        ['PANE BAULETTO', 'NUTELLA 750G', 'BANANE'],
      );
      expect([for (final i in receipt.items) i.quantity], [2, 16, 1]);
      expect(
        [for (final i in receipt.items) i.unitPriceCents],
        [129, 549, 179],
      );
      expect(receipt.isBalanced, isTrue);
    });

    test('a quantity lost by OCR comes from total / unit price', () {
      final receipt = _parser.parseLines([
        'CONAD',
        'QTA* DESCRIZIONE PREZZO TOTALE',
        'PASSATA DI POMODORO 700G 0,99 1,98',
        'PETTO DI POLLO 5,99 5,99',
        'TOTALE COMPLESSIVO 7,97',
      ]);
      expect(
        [for (final i in receipt.items) i.rawName],
        ['PASSATA DI POMODORO 700G', 'PETTO DI POLLO'],
      );
      expect([for (final i in receipt.items) i.quantity], [2, 1]);
      expect(receipt.isBalanced, isTrue);
    });

    test('without headings, the arithmetic finds the VAT column', () {
      // The headings were not read; only the total says that 10,00 is the
      // VAT rate after the price and not the price.
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'PANINI AL LATTE 2,50 10,00',
        'UOVA RUSPANTOVO 2,89 10,00',
        'TOTALE COMPLESSIVO 5,39',
      ]);
      expect([for (final i in receipt.items) i.lineTotalCents], [250, 289]);
      expect([for (final i in receipt.items) i.vatPercent], [10, 10]);
      expect(receipt.isBalanced, isTrue);
    });

    test('misread headings lose to the arithmetic', () {
      // The headings say VAT after the price, but the rows have it before:
      // only the reading without the layout adds up to the total.
      final receipt = _parser.parseLines([
        'NEGOZIO',
        'DESCRIZIONE PREZZO %IVA',
        'PANE 1,20 4,00',
        'TOTALE 4,00',
      ]);
      expect(receipt.items.single.lineTotalCents, 400);
      expect(receipt.isBalanced, isTrue);
    });
  });

  test('a total printed a row off its label is still found', () {
    // Curved photo: the big total digits sit above their label, and the
    // label's row gets the VAT amount instead.
    final receipt = _parser.parseLines([
      'NEGOZIO',
      'DESCRIZIONE PREZZO',
      'PANE 1,20',
      'LATTE 1,80',
      '3,00',
      'TOTALE COMPLESSIVO 0,21',
      'DI CUI IVA 3,00',
    ]);
    expect(receipt.totalCents, 300);
    expect(receipt.warnings, isNot(contains(ParseWarning.totalMismatch)));
  });

  test('an item price is never taken for the total', () {
    final receipt = _parser.parseLines([
      'NEGOZIO',
      'DESCRIZIONE PREZZO',
      'PANE 1,20',
      'TOTALE 4,00',
    ]);
    expect(receipt.totalCents, 400);
    expect(receipt.warnings, contains(ParseWarning.totalMismatch));
  });

  test('a discount summary is neither the total nor a discount', () {
    final receipt = _parser.parseLines([
      'NEGOZIO',
      'DESCRIZIONE',
      'OLIO EVO 11,97',
      'Sconto SPESAMICA -3,48',
      'Totale Sconti Ottenuti -3,48',
      'TOTALE COMPLESSIVO 8,49',
    ]);
    expect(receipt.totalCents, 849);
    expect(receipt.items.single.discountCents, 348);
    expect(receipt.discountCents, 0);
    expect(receipt.isBalanced, isTrue);
  });

  test('the town on the row after the address joins it', () {
    final receipt = _parser.parseLines([
      'CARREFOUR MARKET',
      'Via Roma 12',
      'Milano',
      'P.IVA 02924950963',
    ]);
    expect(receipt.address, 'VIA ROMA 12, MILANO');
  });

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

  test('EUR after the amounts and an OCR × in the quantity row', () {
    final receipt = _parser.parseLines([
      'SCONTRINO 7-52654-712',
      'APPLE MACBOOK PRO 12,99 EUR',
      'CLVR CRE CHRIST PARTY 11,98 EUR',
      '2 × 5,99 EUR',
      'TOTALE 24,97 EUR',
    ]);

    expect(receipt.items.map((i) => i.rawName), [
      'APPLE MACBOOK PRO',
      'CLVR CRE CHRIST PARTY',
    ]);
    expect(receipt.items.last.quantity, 2);
    expect(receipt.items.last.unitPriceCents, 599);
    expect(receipt.totalCents, 2497);
  });

  test('accented letters and zeros inside words are OCR misreadings', () {
    // Real PaddleOCR output on a Carrefour photo, and synthetic receipts.
    final receipt = _parser.parseLines([
      'PASSATA POMODÓRO SIC 2,78',
      'NKN NIKK0R 85MM 1,00',
      'MUTTI POLPA GR500 0,99',
      'TOTALE 4,77',
    ]);

    expect(receipt.items.map((i) => i.rawName), [
      'PASSATA POMODORO SIC',
      'NKN NIKKOR 85MM',
      'MUTTI POLPA GR500',
    ]);
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
