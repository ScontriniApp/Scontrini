import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';

/// Runs every `<name>.txt` + `<name>.expected.json` pair in
/// `assets/test_receipts/`. See the README there for the format.
void main() {
  final fixtures =
      Directory('assets/test_receipts')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.txt'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('fixtures folder is not empty', () => expect(fixtures, isNotEmpty));

  for (final file in fixtures) {
    final name = file.uri.pathSegments.last.replaceAll('.txt', '');
    test(name, () {
      final expectedFile = File(file.path.replaceAll('.txt', '.expected.json'));
      final expected = ParsedReceipt.fromJson(
        jsonDecode(expectedFile.readAsStringSync()) as Map<String, Object?>,
      );

      final actual = const ReceiptParser().parseLines(file.readAsLinesSync());

      expect(actual, expected);
    });
  }
}
