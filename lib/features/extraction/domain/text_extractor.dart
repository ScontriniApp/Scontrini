import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';

/// Phase 2a: gets the text, with positions, out of a captured receipt.
abstract interface class TextExtractor {
  /// [onProgress] reports how far along the whole receipt is.
  Future<OcrDocument> extract(
    ReceiptSource source, {
    OnReadProgress? onProgress,
  });
}
