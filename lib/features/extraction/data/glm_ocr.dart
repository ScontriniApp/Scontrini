import 'dart:async';
import 'dart:io';

import 'package:llamadart/llamadart.dart';
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/model_text_page.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/ocr_image_preparation.dart';

/// The two GGUF files of GLM-OCR (ggml-org/GLM-OCR-GGUF, Q8_0): the
/// language model and the vision projector.
class GlmOcrModelFiles {
  const new({required this.model, required this.projector});

  /// Files named as published, inside [directory].
  factory inDirectory(String directory) => GlmOcrModelFiles(
    model: p.join(directory, modelFileName),
    projector: p.join(directory, projectorFileName),
  );

  static const modelFileName = 'GLM-OCR-Q8_0.gguf';
  static const projectorFileName = 'mmproj-GLM-OCR-Q8_0.gguf';

  /// Folder of the app's support directory that holds the files.
  static const folder = 'models/glm-ocr';

  final String model;
  final String projector;

  bool get exist => File(model).existsSync() && File(projector).existsSync();
}

/// Reads receipt photos with GLM-OCR, a 0.9B vision-language OCR model,
/// run on the device by llama.cpp (through `llamadart`). Nothing leaves the
/// phone. The same code runs on the PC in the benchmark.
///
/// The model takes about 1.5 GB of RAM, so it is loaded on the first photo
/// and unloaded [idleTimeout] after the last one (or by [close]).
class GlmOcr implements ImageTextReader {
  new(
    this.files, {
    this.preparation = const OcrImagePreparation(),
    this.params = defaultParams,
    this.idleTimeout = const Duration(minutes: 2),
  });

  /// CPU, with room for a tall receipt's image tokens in one batch (the
  /// projector's output must fit a single micro-batch).
  static const defaultParams = ModelParams(
    contextSize: 8192,
    batchSize: 4096,
    microBatchSize: 4096,
    gpuLayers: 0,
  );

  /// The model's own prompt for plain text output; no system message, the
  /// model was not trained with one.
  static const prompt = 'Text Recognition:';

  final GlmOcrModelFiles files;
  final OcrImagePreparation preparation;
  final ModelParams params;
  final Duration idleTimeout;

  Future<LlamaEngine>? _engine;
  Timer? _idle;

  /// Starts loading the model now (for example while the user is still
  /// taking the photo), so the first [recognizeFile] doesn't wait for it.
  Future<void> warmUp() => _load();

  @override
  Future<OcrPage> recognizeFile(String imagePath) async {
    _idle?.cancel();
    _running++;
    try {
      final image = preparation.prepare(await File(imagePath).readAsBytes());
      final engine = await _load();
      final text = await engine.create([
        LlamaChatMessage.withContent(
          role: LlamaChatRole.user,
          content: [
            LlamaImageContent(bytes: image),
            const LlamaTextContent(prompt),
          ],
        ),
      ], params: const GenerationParams(temp: 0)).text();
      return modelTextToPage(text);
    } finally {
      if (--_running == 0) _idle = Timer(idleTimeout, close);
    }
  }

  /// Photos being read now: the model is never unloaded under them.
  var _running = 0;

  Future<LlamaEngine> _load() => _engine ??=
      LlamaEngine.load(
        LlamaModel(
          ModelSource.path(files.model),
          projector: ModelSource.path(files.projector),
        ),
        params: params,
      ).onError<Object>((error, stack) {
        _engine = null; // let the next photo try again
        Error.throwWithStackTrace(error, stack);
      });

  /// Frees the model's memory; the next photo loads it again.
  Future<void> close() async {
    _idle?.cancel();
    final engine = _engine;
    _engine = null;
    if (engine != null) await (await engine).dispose();
  }
}
