import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

/// The steps of reading a receipt, in order, for the progress bar.
enum ReadStep { preparing, findingLines, readingLines, parsing }

/// Where reading is: the step, and how much of the whole receipt is done
/// (0..1), or `null` when the reader can't tell (ML Kit).
typedef ReadProgress = ({ReadStep step, double? fraction});

typedef OnReadProgress = void Function(ReadProgress progress);

/// Reads the text of one receipt photo: PaddleOCR or ML Kit.
abstract interface class ImageTextReader {
  /// [onProgress] is called as reading goes on; readers that can't tell
  /// how far along they are report a `null` fraction.
  Future<OcrPage> recognizeFile(String imagePath, {OnReadProgress? onProgress});
}
