/// Where the text of an `OcrDocument` came from.
enum TextSource {
  /// On-device OCR of a photo, a scan or a rendered PDF page.
  ocr,

  /// The embedded text layer of a digital PDF (no OCR errors).
  pdfTextLayer,
}
