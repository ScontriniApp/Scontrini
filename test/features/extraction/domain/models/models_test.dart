import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';

void main() {
  group('TextBox.verticalOverlap', () {
    const name = TextBox(left: 10, top: 100, right: 200, bottom: 120);

    test('is 1 for a box on the same row', () {
      const price = TextBox(left: 400, top: 102, right: 450, bottom: 118);
      expect(name.verticalOverlap(price), 1);
    });

    test('is partial for a slightly skewed row', () {
      const price = TextBox(left: 400, top: 110, right: 450, bottom: 130);
      expect(name.verticalOverlap(price), closeTo(0.5, 1e-9));
    });

    test('is 0 for the next row', () {
      const next = TextBox(left: 10, top: 125, right: 200, bottom: 145);
      expect(name.verticalOverlap(next), 0);
    });
  });

  group('ParsedReceipt totals', () {
    const items = [
      ParsedItem(
        rawName: 'LATTE INTERO',
        unitPriceCents: 129,
        lineTotalCents: 129,
      ),
      ParsedItem(
        rawName: 'BANANE',
        quantity: 0.456,
        unit: QuantityUnit.kilogram,
        unitPriceCents: 199,
        lineTotalCents: 91,
      ),
      ParsedItem(
        rawName: 'PASTA',
        quantity: 2,
        unitPriceCents: 89,
        lineTotalCents: 178,
        discountCents: 50,
      ),
    ];

    test('subtracts item and receipt discounts', () {
      const receipt = ParsedReceipt(
        items: items,
        discountCents: 20,
        totalCents: 328,
      );
      expect(receipt.computedTotalCents, 129 + 91 + 128 - 20);
      expect(receipt.isBalanced, isTrue);
    });

    test('is not balanced when the total is missing', () {
      const receipt = ParsedReceipt(items: items);
      expect(receipt.isBalanced, isFalse);
    });
  });

  test('ParsedReceipt survives a JSON round trip', () {
    final receipt = ParsedReceipt(
      storeName: 'SUPERMERCATO ESEMPIO',
      vatNumber: '12345678901',
      purchaseDate: DateTime(2026, 11, 19, 18, 42),
      totalCents: 129,
      items: const [
        ParsedItem(
          rawName: 'BANANE',
          quantity: 0.5,
          unit: QuantityUnit.kilogram,
          unitPriceCents: 199,
          lineTotalCents: 100,
          warnings: [ParseWarning.lineTotalMismatch],
        ),
      ],
      warnings: const [ParseWarning.totalMismatch],
      unparsedLines: const ['???'],
    );

    final json =
        jsonDecode(jsonEncode(receipt.toJson())) as Map<String, Object?>;
    expect(ParsedReceipt.fromJson(json), receipt);
    final item = (json['items']! as List).single as Map<String, Object?>;
    expect(item['unit'], 'kg');
  });

  test('OcrDocument survives a JSON round trip and joins plain text', () {
    const document = OcrDocument(
      source: TextSource.ocr,
      pages: [
        OcrPage(
          width: 1080,
          height: 2400,
          lines: [
            OcrLine(
              text: 'LATTE INTERO',
              box: TextBox(left: 10, top: 100, right: 200, bottom: 120),
            ),
            OcrLine(
              text: '1,29 B',
              box: TextBox(left: 400, top: 101, right: 470, bottom: 119),
            ),
          ],
        ),
      ],
    );

    final json =
        jsonDecode(jsonEncode(document.toJson())) as Map<String, Object?>;
    expect(OcrDocument.fromJson(json), document);
    expect(document.plainText, 'LATTE INTERO\n1,29 B');
  });
}
