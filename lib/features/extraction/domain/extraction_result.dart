import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/receipt_row.dart';

/// Everything produced from one captured receipt: the raw text, the rebuilt
/// rows and the parsed result.
class ExtractionResult {
  const new({
    required this.document,
    required this.rows,
    required this.receipt,
  });

  final OcrDocument document;
  final List<ReceiptRow> rows;
  final ParsedReceipt receipt;

  /// The rows as plain text, one per line: the format of the parser
  /// fixtures in `assets/test_receipts/`.
  String get rowsText => [for (final row in rows) row.text].join('\n');
}
