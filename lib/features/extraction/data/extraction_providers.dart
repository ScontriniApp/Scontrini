import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/features/extraction/data/device_text_extractor.dart';
import 'package:scontrini/features/extraction/data/fixture_exporter.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/paddle_ocr.dart';
import 'package:scontrini/features/extraction/data/paddle_ocr_worker.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/data/preferred_image_reader.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

final mlKitOcrProvider = Provider<MlKitOcr>((ref) {
  final ocr = MlKitOcr();
  ref.onDispose(ocr.close);
  return ocr;
});

/// PaddleOCR (PP-OCRv6 small, shipped in the APK) on a background isolate:
/// the app's photo reader.
final paddleOcrProvider = Provider<PaddleOcrWorker>((ref) {
  final worker = PaddleOcrWorker(() => paddleModelFromAssets(rootBundle));
  ref.onDispose(worker.close);
  return worker;
});

/// Where the app's PaddleOCR model lives in the assets.
const paddleModelAssets = 'assets/models/paddle';

/// The PP-OCRv6 small model from the app's assets.
Future<PaddleOcrModel> paddleModelFromAssets(AssetBundle bundle) async {
  Future<Uint8List> bytes(String name) async =>
      (await bundle.load('$paddleModelAssets/$name')).buffer.asUint8List();
  return PaddleOcrModel(
    detection: await bytes('PP-OCRv6_det_small.onnx'),
    recognition: await bytes('PP-OCRv6_rec_small.onnx'),
    // One character per line; only the final newline ends no character.
    characters: const LineSplitter().convert(
      await bundle.loadString(
        '$paddleModelAssets/${PaddleOcrModel.characterFileName}',
        cache: false,
      ),
    ),
  );
}

/// Photos: PaddleOCR, and ML Kit if it fails. Benchmark on real photos
/// (Redmi Note 11): PaddleOCR 89% of items in ~9 s, ML Kit 62% in 0.6 s.
/// (GLM-OCR read best but took 5-6 minutes there, so it was removed.)
final textExtractorProvider = Provider<TextExtractor>((ref) {
  final mlKit = ref.watch(mlKitOcrProvider);
  return DeviceTextExtractor(
    PreferredImageReader(
      name: 'PaddleOCR',
      preferred: Future.value(ref.watch(paddleOcrProvider)),
      fallback: mlKit,
    ),
    // Scanned PDF pages stay on ML Kit for now.
    PdfTextReader(mlKit, getTemporaryDirectory),
  );
});

final fixtureExporterProvider = Provider<FixtureExporter>(
  (ref) => FixtureExporter(getApplicationSupportDirectory),
);
