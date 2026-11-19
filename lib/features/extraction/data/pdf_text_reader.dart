import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';

/// Reads a PDF receipt.
///
/// Digital receipts (from a store app or e-mail) have a text layer, which is
/// exact and is used directly. Scanned PDFs have none, so those pages are
/// rendered and sent through OCR.
class PdfTextReader {
  new(this._ocr, this._temporaryDirectory);

  final MlKitOcr _ocr;
  final Future<Directory> Function() _temporaryDirectory;

  /// Below this many non-space characters a page counts as scanned.
  static const _minTextLayerChars = 20;
  static const _renderDpi = 300;

  /// Keeps very long receipts within memory limits (about 100 MB of pixels).
  static const _maxRenderSide = 6000;

  Future<OcrDocument> read(String path) async {
    await pdfrxFlutterInitialize();
    final document = await PdfDocument.openFile(path);
    try {
      var usedOcr = false;
      final pages = <OcrPage>[];
      for (final page in document.pages) {
        final text = await page.loadStructuredText();
        if (text.fullText.replaceAll(RegExp(r'\s'), '').length >=
            _minTextLayerChars) {
          pages.add(_fromTextLayer(page, text));
        } else {
          pages.add(await _ocrPage(page));
          usedOcr = true;
        }
      }
      return OcrDocument(
        source: usedOcr ? TextSource.ocr : TextSource.pdfTextLayer,
        pages: pages,
      );
    } finally {
      await document.dispose();
    }
  }

  /// Splits the page text at line breaks and boxes each run with the union
  /// of its characters' rectangles, flipped to a top-left origin.
  static OcrPage _fromTextLayer(PdfPage page, PdfPageText text) {
    final lines = <OcrLine>[];
    final buffer = StringBuffer();
    double? left;
    double? top;
    double? right;
    double? bottom;

    void flush() {
      final run = buffer.toString().trim();
      if (run.isNotEmpty && left != null) {
        lines.add(
          OcrLine(
            text: run,
            box: TextBox(
              left: left!,
              top: page.height - top!,
              right: right!,
              bottom: page.height - bottom!,
            ),
          ),
        );
      }
      buffer.clear();
      left = top = right = bottom = null;
    }

    for (var i = 0; i < text.fullText.length; i++) {
      final char = text.fullText[i];
      if (char == '\n' || char == '\r') {
        flush();
        continue;
      }
      buffer.write(char);
      final rect = i < text.charRects.length ? text.charRects[i] : null;
      if (rect == null || rect.isEmpty) continue;
      left = left == null || rect.left < left! ? rect.left : left;
      right = right == null || rect.right > right! ? rect.right : right;
      top = top == null || rect.top > top! ? rect.top : top;
      bottom = bottom == null || rect.bottom < bottom! ? rect.bottom : bottom;
    }
    flush();

    return OcrPage(width: page.width, height: page.height, lines: lines);
  }

  Future<OcrPage> _ocrPage(PdfPage page) async {
    var scale = _renderDpi / 72;
    final longest =
        (page.width > page.height ? page.width : page.height) * scale;
    if (longest > _maxRenderSide) scale *= _maxRenderSide / longest;
    final width = (page.width * scale).round();
    final height = (page.height * scale).round();

    final image = await page.render(
      width: width,
      height: height,
      fullWidth: width.toDouble(),
      fullHeight: height.toDouble(),
      backgroundColor: 0xFFFFFFFF,
    );
    if (image == null) {
      throw StateError('Could not render page ${page.pageNumber}');
    }
    final pixels = Uint8List.fromList(image.pixels);
    image.dispose();

    final png = await Isolate.run(() => _encodePng(pixels, width, height));
    final file = File(
      p.join(
        (await _temporaryDirectory()).path,
        'pdf_page_${DateTime.now().microsecondsSinceEpoch}.png',
      ),
    );
    try {
      await file.writeAsBytes(png);
      return await _ocr.recognizeFile(file.path);
    } finally {
      // The rendered page is an unencrypted copy of the receipt.
      if (file.existsSync()) await file.delete();
    }
  }
}

Uint8List _encodePng(Uint8List bgra, int width, int height) => img.encodePng(
  img.Image.fromBytes(
    width: width,
    height: height,
    bytes: bgra.buffer,
    numChannels: 4,
    order: img.ChannelOrder.bgra,
  ),
  level: 1,
);
