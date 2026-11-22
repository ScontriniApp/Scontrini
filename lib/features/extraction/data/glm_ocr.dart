import 'dart:async';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:llamadart/llamadart.dart';
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/model_text_page.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/ocr_image_preparation.dart';
import 'package:scontrini/features/extraction/domain/receipt_strips.dart';

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
    this.strips,
    ModelParams? params,
    this.idleTimeout = const Duration(minutes: 2),
  }) : params = params ?? defaultParams;

  /// How tall photos are cut before reading; `null` reads them whole.
  final ReceiptStrips? strips;

  /// CPU, with room for a tall receipt's image tokens in one batch (the
  /// projector's output must fit a single micro-batch).
  ///
  /// llama.cpp's automatic thread count is 4. Reading is mostly generating
  /// text, which scales with the cores: use all but two (6 on an 8-core
  /// phone, leaving the small cores to the UI), at most 8.
  static ModelParams get defaultParams => ModelParams(
    contextSize: 8192,
    batchSize: 4096,
    microBatchSize: 4096,
    device: ComputeDevice.cpu,
    numberOfThreads: threads,
    numberOfThreadsBatch: threads,
  );

  /// Threads for [defaultParams].
  static int get threads => (Platform.numberOfProcessors - 2).clamp(1, 8);

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
  /// Unloaded again after [idleTimeout] if no photo comes.
  Future<void> warmUp() async {
    await _load();
    if (_running == 0) {
      _idle?.cancel();
      _idle = Timer(idleTimeout, close);
    }
  }

  @override
  Future<OcrPage> recognizeFile(String imagePath) async =>
      modelTextToPage((await readStrips(imagePath).toList()).join('\n'));

  /// The text of each strip of the photo (see [strips]), top to bottom, as
  /// soon as it is read: the first rows can be shown, or triaged, while the
  /// rest of the receipt is still being read.
  Stream<String> readStrips(String imagePath) async* {
    _idle?.cancel();
    _running++;
    try {
      final image = preparation.prepareImage(
        await File(imagePath).readAsBytes(),
      );
      final engine = await _load();
      for (final strip in strips?.split(image) ?? [image]) {
        yield await engine.create([
          LlamaChatMessage.withContent(
            role: LlamaChatRole.user,
            content: [
              LlamaImageContent(bytes: img.encodePng(strip)),
              const LlamaTextContent(prompt),
            ],
          ),
        ], params: const GenerationParams(temp: 0)).text();
      }
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
