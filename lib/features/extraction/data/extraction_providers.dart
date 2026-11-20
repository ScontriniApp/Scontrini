import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/features/extraction/data/device_text_extractor.dart';
import 'package:scontrini/features/extraction/data/fixture_exporter.dart';
import 'package:scontrini/features/extraction/data/glm_ocr.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/data/preferred_image_reader.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

final mlKitOcrProvider = Provider<MlKitOcr>((ref) {
  final ocr = MlKitOcr();
  ref.onDispose(ocr.close);
  return ocr;
});

/// GLM-OCR if its model files are in `<app support>/models/glm-ocr/`,
/// otherwise `null`. Loading the model itself waits for the first photo.
final glmOcrProvider = Provider<Future<GlmOcr?>>((ref) {
  final glm = () async {
    final support = await getApplicationSupportDirectory();
    final files = GlmOcrModelFiles.inDirectory(
      p.join(support.path, GlmOcrModelFiles.folder),
    );
    return files.exist ? GlmOcr(files) : null;
  }();
  ref.onDispose(() async => await (await glm)?.close());
  return glm;
});

final textExtractorProvider = Provider<TextExtractor>((ref) {
  final mlKit = ref.watch(mlKitOcrProvider);
  return DeviceTextExtractor(
    PreferredImageReader(glm: ref.watch(glmOcrProvider), fallback: mlKit),
    // Scanned PDF pages stay on ML Kit for now.
    PdfTextReader(mlKit, getTemporaryDirectory),
  );
});

final fixtureExporterProvider = Provider<FixtureExporter>(
  (ref) => FixtureExporter(getApplicationSupportDirectory),
);
