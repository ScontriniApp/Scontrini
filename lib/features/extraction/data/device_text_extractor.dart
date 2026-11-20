import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

/// [TextExtractor] for photos (GLM-OCR or ML Kit) and PDFs (pdfrx).
class DeviceTextExtractor implements TextExtractor {
  new(this._images, this._pdf);

  final ImageTextReader _images;
  final PdfTextReader _pdf;

  @override
  Future<OcrDocument> extract(ReceiptSource source) async => switch (source) {
    ImageReceiptSource(:final imagePaths) => OcrDocument(
      source: TextSource.ocr,
      pages: [for (final path in imagePaths) await _images.recognizeFile(path)],
    ),
    PdfReceiptSource(:final pdfPath) => await _pdf.read(pdfPath),
  };
}
