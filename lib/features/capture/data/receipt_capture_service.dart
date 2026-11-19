import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scontrini/features/capture/data/receipt_file_store.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';

/// Phase 1: gets a receipt from the camera scanner, the gallery or a PDF.
///
/// Every method returns `null` when the user cancels.
class ReceiptCaptureService {
  new(this._store, {ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ReceiptFileStore _store;
  final ImagePicker _imagePicker;

  /// Long receipts may need several shots; more than this is unlikely.
  static const maxPages = 5;

  /// Document scanner: crops, straightens and cleans up the photo, which
  /// helps OCR a lot. On Android it is Google's ML Kit scanner, so no camera
  /// permission is needed.
  Future<ReceiptSource?> scan() async {
    final result = await CunningDocumentScanner.scanDocuments(
      noOfPages: maxPages,
    );
    if (result == null || result.images.isEmpty) return null;
    final kept = await _store.keepAll(result.images);
    await CunningDocumentScanner.cleanCache();
    return ReceiptSource.images(kept);
  }

  Future<ReceiptSource?> pickImages() async {
    final files = await _imagePicker.pickMultiImage(limit: maxPages);
    if (files.isEmpty) return null;
    return ReceiptSource.images(
      await _store.keepAll([for (final f in files) f.path]),
    );
  }

  Future<ReceiptSource?> pickPdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = file?.path;
    if (path == null) return null;
    final kept = await _store.keepAll([path]);
    await FilePicker.clearTemporaryFiles();
    return ReceiptSource.pdf(kept.single);
  }
}
