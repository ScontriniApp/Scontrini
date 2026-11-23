// Prints what the pipeline makes of saved OCR output: the printed rows and
// the parsed receipt. For looking at one receipt while fixing the parser:
//   flutter test tool/bench/show_receipt_test.dart \
//     --dart-define=OCR=data/ocr_cache/paddle_dart-v6-small/redmi_1.ocr.json

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

const _ocr = String.fromEnvironment('OCR');

void main() {
  test('show receipt', skip: _ocr.isEmpty, () {
    final document = OcrDocument.fromJson(
      jsonDecode(File(_ocr).readAsStringSync()) as Map<String, Object?>,
    );
    final rows = [for (final r in const RowBuilder().build(document)) r.text];
    final receipt = const ReceiptParser().parseLines(rows);
    final out = StringBuffer()..writeln('--- rows');
    rows.forEach(out.writeln);
    out
      ..writeln('--- receipt')
      ..writeln(
        '${receipt.storeName} | ${receipt.vatNumber} | ${receipt.address} | '
        '${receipt.purchaseDate} | total ${receipt.totalCents} | '
        'discount ${receipt.discountCents}',
      );
    for (final i in receipt.items) {
      out.writeln(
        '  ${i.rawName.padRight(28)} q ${i.quantity} ${i.unit.name} '
        'unit ${i.unitPriceCents} line ${i.lineTotalCents} '
        'disc ${i.discountCents} vat ${i.vatPercent}',
      );
    }
    out
      ..writeln('items sum ${receipt.computedTotalCents}')
      ..writeln('warnings ${receipt.warnings}')
      ..writeln('unparsed ${receipt.unparsedLines}');
    // ignore: avoid_print, the point of the tool
    print(out);
  });
}
