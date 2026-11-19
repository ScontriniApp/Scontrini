import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

/// [TextExtractor] backed by ML Kit (images) and pdfrx (PDFs).
class DeviceTextExtractor implements TextExtractor {
  new(this._ocr, this._pdf);

  final MlKitOcr _ocr;
  final PdfTextReader _pdf;

  @override
  Future<OcrDocument> extract(ReceiptSource source) async => switch (source) {
    ImageReceiptSource(:final imagePaths) => OcrDocument(
      source: TextSource.ocr,
      pages: [for (final path in imagePaths) await _ocr.recognizeFile(path)],
    ),
    PdfReceiptSource(:final pdfPath) => await _pdf.read(pdfPath),
  };
}
