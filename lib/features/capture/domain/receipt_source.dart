import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_source.freezed.dart';

/// A captured receipt, already copied into the app's private storage.
@freezed
sealed class ReceiptSource with _$ReceiptSource {
  /// One or more photos or scans (a long receipt can take several shots),
  /// top to bottom.
  const factory images(List<String> imagePaths) = ImageReceiptSource;

  const factory pdf(String pdfPath) = PdfReceiptSource;

  const new _();

  List<String> get paths => switch (this) {
    ImageReceiptSource(:final imagePaths) => imagePaths,
    PdfReceiptSource(:final pdfPath) => [pdfPath],
  };
}
