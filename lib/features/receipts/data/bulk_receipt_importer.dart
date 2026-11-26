import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

/// What a bulk import did with each file.
class BulkImportResult {
  const new({
    required this.saved,
    required this.duplicates,
    required this.failed,
  });

  /// Receipts added to the history.
  final int saved;

  /// Receipts already in the history (same transaction hash), left alone.
  final int duplicates;

  /// Files that couldn't be read, or had no date or no items.
  final List<String> failed;
}

/// Debug tool: reads many receipts (PDFs) at once and saves them as
/// confirmed **without the review screen**, so a backlog of old receipts
/// can reach the history and statistics in seconds. Parser mistakes go in
/// unchecked.
///
/// Imported receipts are not put in the pantry: they are usually months
/// old, and full lots of long-eaten food would fill the pantry tab.
class BulkReceiptImporter {
  new(this._extractor, this._receipts);

  final TextExtractor _extractor;
  final ReceiptRepository _receipts;

  /// Imports [sources] in order. [onProgress] gets how many are done.
  Future<BulkImportResult> import(
    List<ReceiptSource> sources, {
    void Function(int done, int total)? onProgress,
  }) async {
    var saved = 0;
    var duplicates = 0;
    final failed = <String>[];
    for (final (i, source) in sources.indexed) {
      final name = source.paths.first;
      try {
        final document = await _extractor.extract(source);
        final rows = const RowBuilder().build(document);
        final receipt = const ReceiptParser().parseLines([
          for (final row in rows) row.text,
        ]);
        // Without a date the receipt would be dated today, which is wrong
        // for a backlog; without items there is nothing to save.
        if (receipt.purchaseDate == null || receipt.items.isEmpty) {
          failed.add(name);
        } else {
          final before = await _receipts.count();
          await _receipts.saveConfirmed(
            receipt,
            sourcePath: name,
            rawOcrText: [for (final row in rows) row.text].join('\n'),
          );
          if (await _receipts.count() > before) {
            saved++;
          } else {
            duplicates++;
          }
        }
      } on Object {
        failed.add(name);
      }
      onProgress?.call(i + 1, sources.length);
    }
    return BulkImportResult(
      saved: saved,
      duplicates: duplicates,
      failed: failed,
    );
  }
}
