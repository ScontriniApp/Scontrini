import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

/// [TextExtractor] for photos (PaddleOCR or ML Kit) and PDFs
/// (pdfrx).
class DeviceTextExtractor implements TextExtractor {
  new(this._images, this._pdf);

  final ImageTextReader _images;
  final PdfTextReader _pdf;

  @override
  Future<OcrDocument> extract(
    ReceiptSource source, {
    OnReadProgress? onProgress,
  }) async {
    switch (source) {
      case ImageReceiptSource(:final imagePaths):
        // A receipt in several photos: each photo is its share of the bar.
        final pages = <OcrPage>[];
        for (final (i, path) in imagePaths.indexed) {
          pages.add(
            await _images.recognizeFile(
              path,
              onProgress: onProgress == null
                  ? null
                  : (p) => onProgress((
                      step: p.step,
                      fraction: p.fraction == null
                          ? null
                          : (i + p.fraction!) / imagePaths.length,
                    )),
            ),
          );
        }
        return OcrDocument(source: TextSource.ocr, pages: pages);
      case PdfReceiptSource(:final pdfPath):
        onProgress?.call((step: ReadStep.readingLines, fraction: null));
        return await _pdf.read(pdfPath);
    }
  }
}
