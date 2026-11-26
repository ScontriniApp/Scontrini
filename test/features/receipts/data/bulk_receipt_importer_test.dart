import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';
import 'package:scontrini/features/receipts/data/bulk_receipt_importer.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

/// Returns the text of a fixture per path, one line per row; a path with
/// no fixture throws, like an unreadable PDF.
class _FakeExtractor implements TextExtractor {
  _FakeExtractor(this.texts);

  final Map<String, String> texts;

  @override
  Future<OcrDocument> extract(
    ReceiptSource source, {
    OnReadProgress? onProgress,
  }) async {
    final text = texts[source.paths.single];
    if (text == null) throw const FormatException('unreadable');
    final lines = text.split('\n');
    return OcrDocument(
      source: TextSource.pdfTextLayer,
      pages: [
        OcrPage(
          width: 600,
          height: lines.length * 20.0,
          lines: [
            for (final (i, line) in lines.indexed)
              OcrLine(
                text: line,
                box: TextBox(
                  left: 0,
                  top: i * 20.0,
                  right: line.length * 10.0,
                  bottom: i * 20.0 + 14,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

void main() {
  late AppDatabase db;
  late String fixture;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fixture = File(
      'assets/test_receipts/esselunga_vat_codes_weight.txt',
    ).readAsStringSync();
  });
  tearDown(() => db.close());

  test('saves new receipts, skips duplicates and unreadable files, '
      'leaves the pantry empty', () async {
    final importer = BulkReceiptImporter(
      _FakeExtractor({
        'a.pdf': fixture,
        'a (1).pdf': fixture,
        'no_date.pdf': 'CARREFOUR\nPANE 1,00\nTOTALE 1,00',
      }),
      ReceiptRepository(db),
    );
    final progress = <int>[];

    final result = await importer.import(
      [
        for (final path in ['a.pdf', 'a (1).pdf', 'no_date.pdf', 'bad.pdf'])
          ReceiptSource.pdf(path),
      ],
      onProgress: (done, total) {
        expect(total, 4);
        progress.add(done);
      },
    );

    expect(result.saved, 1);
    expect(result.duplicates, 1);
    expect(result.failed, ['no_date.pdf', 'bad.pdf']);
    expect(progress, [1, 2, 3, 4]);

    final receipts = await db.select(db.receipts).get();
    expect(receipts, hasLength(1));
    expect(receipts.single.status, ReceiptStatus.confirmed);
    expect(receipts.single.sourcePath, 'a.pdf');
    expect(receipts.single.rawOcrText, isNotEmpty);
    expect(await db.select(db.receiptItems).get(), isNotEmpty);
    expect(await db.select(db.pantryLots).get(), isEmpty);
  });
}
