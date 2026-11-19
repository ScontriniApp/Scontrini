import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/features/extraction/data/device_text_extractor.dart';
import 'package:scontrini/features/extraction/data/fixture_exporter.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

final mlKitOcrProvider = Provider<MlKitOcr>((ref) {
  final ocr = MlKitOcr();
  ref.onDispose(ocr.close);
  return ocr;
});

final textExtractorProvider = Provider<TextExtractor>((ref) {
  final ocr = ref.watch(mlKitOcrProvider);
  return DeviceTextExtractor(ocr, PdfTextReader(ocr, getTemporaryDirectory));
});

final fixtureExporterProvider = Provider<FixtureExporter>(
  (ref) => FixtureExporter(getApplicationSupportDirectory),
);
