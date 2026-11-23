import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';

import '../../../tool/bench/src/bench_case.dart';
import '../../../tool/bench/src/keyword_classifier.dart';
import '../../../tool/bench/src/scoring.dart';

ParsedItem _item(String name, int cents, {int discount = 0}) => ParsedItem(
  rawName: name,
  unitPriceCents: cents,
  lineTotalCents: cents,
  discountCents: discount,
);

void main() {
  group('scoreText', () {
    test('counts exact rows, order and similarity', () {
      final score = scoreText(
        ['LATTE *a 1,29', 'SCONTO 10% 0,13-S', 'PANE *a 2,00'],
        ['latte  *a 1,29', 'PANE *a 2,00', 'SCONTO 10% 0,13-S', 'extra'],
      );
      expect(score.found, 3);
      // The discount row moved below the next item.
      expect(score.inOrder, 2);
      expect(score.similarity, 1);
      expect(score.missing, isEmpty);
    });

    test('reports the closest row for a misread one', () {
      final score = scoreText(['TOTALE EURO 22,81'], ['TOTALE EUR0 22.81']);
      expect(score.found, 0);
      expect(score.similarity, closeTo(1 - 2 / 17, 1e-9));
      expect(score.missing.single.closest, 'TOTALE EUR0 22.81');
    });
  });

  group('scoreParse', () {
    final expected = ParsedReceipt(
      storeName: 'ESSELUNGA S.p.A.',
      vatNumber: '04916380159',
      totalCents: 449,
      purchaseDate: DateTime(2026, 2),
      items: [
        _item('LATTE', 129),
        _item('PANE', 200, discount: 20),
        _item('MELE', 140),
      ],
    );

    test('a perfect parse', () {
      final score = scoreParse(
        expected,
        expected.copyWith(storeName: '* ESSELUNGA S.p.A. *'),
      );
      expect(score.perfect, isTrue);
      expect(score.mismatches, isEmpty);
    });

    test('missing, extra and wrong items do not shift the others', () {
      final score = scoreParse(
        expected,
        expected.copyWith(
          vatNumber: null,
          items: [
            _item('SCONTO 10%', 20),
            _item('PANE *a', 200),
            _item('MELE', 140),
          ],
        ),
      );
      expect(score.fields['vatNumber'], FieldResult.missing);
      expect(score.matchedItems, 2);
      expect(score.missingItems, 1);
      expect(score.extraItems, 1);
      expect(score.correctItems, 1);
      expect(score.itemFieldErrors['name'], 1);
      expect(score.itemFieldErrors['discount'], 1);
      expect(score.perfect, isFalse);
      expect(
        score.mismatches,
        containsAll([
          'vatNumber: expected "04916380159", got "-"',
          'missing item "LATTE" 1,29',
          'extra item "SCONTO 10%" 0,20',
        ]),
      );
    });

    test('checks quantity and unit of weighed items', () {
      final weighed = expected.copyWith(
        items: [
          const ParsedItem(
            rawName: 'FOCACCINE',
            quantity: 0.18,
            unit: QuantityUnit.kilogram,
            unitPriceCents: 1439,
            lineTotalCents: 253,
          ),
        ],
      );
      final score = scoreParse(
        weighed,
        weighed.copyWith(items: [_item('FOCACCINE', 253)]),
      );
      expect(score.itemFieldErrors['quantity'], 1);
      expect(score.itemFieldErrors['unit'], 1);
      expect(score.itemFieldErrors['unitPrice'], 1);
    });
  });

  test('matchItems keeps repeated products in order', () {
    final items = [_item('YOGURT', 79), _item('YOGURT', 79)];
    expect(matchItems(items, items), [0, 1]);
  });

  test('keywordCategory matches at the start of a word', () {
    expect(keywordCategory('CAROTE NATUR.'), 'Frutta e verdura');
    expect(keywordCategory('ESSEL.LATTE FR.PS 500'), 'Latticini e uova');
    expect(keywordCategory('GRANBISCOTTO BIP'), isNull);
  });

  test('discoverCases groups photo pages and pairs names', () {
    final dir = Directory.systemTemp.createTempSync('bench_cases');
    addTearDown(() => dir.deleteSync(recursive: true));
    for (final name in [
      'a.pdf',
      'b.p2.JPG',
      'b.p1.jpg',
      'c.png',
      'd.ocr.json',
      'notes.txt',
    ]) {
      File(p.join(dir.path, name)).writeAsStringSync('');
    }
    final cases = discoverCases(dir.path, InputKind.values.toSet());
    expect(
      [for (final c in cases) '${c.name}:${c.kind.name}'],
      ['a:pdf', 'b:image', 'c:image', 'd:ocrJson'],
    );
    expect(cases[1].files.map(p.basename), ['b.p1.jpg', 'b.p2.JPG']);
  });
}
