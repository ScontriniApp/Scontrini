import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

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

/// Where one load of GLM-OCR runs: a name for logs and the benchmark, and
/// the llama.cpp parameters.
typedef GlmOcrPlacement = ({String name, ModelParams params});

/// Reads receipt photos with GLM-OCR, a 0.9B vision-language OCR model,
/// run on the device by llama.cpp (through `llamadart`). Nothing leaves the
/// phone. The same code runs on the PC in the benchmark.
///
/// The model takes about 1.5 GB of RAM, so it is loaded on the first photo
/// and unloaded [idleTimeout] after the last one (or by [close]).
///
/// It is loaded at the first of [placements] that works: the image encoder
/// on the GPU when there is one (5-7x faster on an integrated GPU, and it is
/// most of the time on a CPU), otherwise everything on the CPU. A placement
/// that fails to load, or fails while reading, is skipped from then on.
class GlmOcr implements ImageTextReader {
  new(
    this.files, {
    this.preparation = const OcrImagePreparation(),
    this.strips,
    List<GlmOcrPlacement>? placements,
    this.idleTimeout = const Duration(minutes: 2),
  }) : placements = placements ?? defaultPlacements;

  /// How tall photos are cut before reading; `null` reads them whole.
  final ReceiptStrips? strips;

  /// Placements tried in order, see the class comment.
  final List<GlmOcrPlacement> placements;

  /// Image encoder on the GPU (Vulkan; on Android also OpenCL, the backend
  /// Qualcomm maintains for Adreno), then the CPU.
  static List<GlmOcrPlacement> get defaultPlacements => [
    (name: 'gpu-vulkan', params: gpuProjectorParams(GpuBackend.vulkan)),
    if (Platform.isAndroid)
      (name: 'gpu-opencl', params: gpuProjectorParams(GpuBackend.opencl)),
    (name: 'cpu', params: cpuParams),
  ];

  /// Everything on the CPU, with room for a tall receipt's image tokens in
  /// one batch (the projector's output must fit a single micro-batch).
  ///
  /// llama.cpp's automatic thread count is 4: text generation uses all
  /// cores but two (6 on an 8-core phone, leaving the small cores to the
  /// UI), at most 8. The image encoder stays at 4: llamadart doesn't pass
  /// the thread count on to it.
  static ModelParams get cpuParams => ModelParams(
    contextSize: 8192,
    batchSize: 4096,
    microBatchSize: 4096,
    device: ComputeDevice.cpu,
    numberOfThreads: threads,
    numberOfThreadsBatch: threads,
  );

  /// The image encoder on the GPU [backend], device [gpu], and the text on
  /// the CPU: llamadart puts the projector on a GPU only when at least one
  /// model layer is there, so exactly one is. With the whole model on an
  /// integrated GPU, text generation was slower than on the CPU.
  static ModelParams gpuProjectorParams(GpuBackend backend, {int gpu = 0}) =>
      cpuParams.copyWith(
        device: ComputeDevice.auto,
        preferredBackend: backend,
        gpuLayers: 1,
        mainGpu: gpu,
        splitMode: ModelSplitMode.none,
      );

  /// Threads for [cpuParams].
  static int get threads => (Platform.numberOfProcessors - 2).clamp(1, 8);

  /// The model's own prompt for plain text output; no system message, the
  /// model was not trained with one.
  static const prompt = 'Text Recognition:';

  final GlmOcrModelFiles files;
  final OcrImagePreparation preparation;
  final Duration idleTimeout;

  Future<LlamaEngine>? _engine;
  Timer? _idle;

  /// Index in [placements] of the next placement to try.
  var _placement = 0;

  /// The placement the model is loaded with, or will be tried next.
  String get placement => placements[_placement].name;

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
  Future<OcrPage> recognizeFile(
    String imagePath, {
    OnReadProgress? onProgress,
  }) async => modelTextToPage(
    (await readStrips(imagePath, onProgress: onProgress).toList()).join('\n'),
  );

  /// The text of each strip of the photo (see [strips]), top to bottom, as
  /// soon as it is read: the first rows can be shown, or triaged, while the
  /// rest of the receipt is still being read.
  Stream<String> readStrips(
    String imagePath, {
    OnReadProgress? onProgress,
  }) async* {
    _idle?.cancel();
    _running++;
    try {
      onProgress?.call((step: ReadStep.preparing, fraction: 0));
      final image = preparation.prepareImage(
        await File(imagePath).readAsBytes(),
      );
      final parts = strips?.split(image) ?? [image];
      for (final (i, strip) in parts.indexed) {
        onProgress?.call((
          step: ReadStep.readingLines,
          fraction: 0.05 + 0.95 * i / parts.length,
        ));
        yield await _read(img.encodePng(strip));
      }
    } finally {
      if (--_running == 0) _idle = Timer(idleTimeout, close);
    }
  }

  /// Reads one image; if the placement fails while reading (a GPU driver
  /// error), moves on to the next one and reads it again.
  Future<String> _read(Uint8List png) async {
    while (true) {
      final engine = await _load();
      try {
        return await engine.create([
          LlamaChatMessage.withContent(
            role: LlamaChatRole.user,
            content: [
              LlamaImageContent(bytes: png),
              const LlamaTextContent(prompt),
            ],
          ),
        ], params: const GenerationParams(temp: 0)).text();
      } on Object catch (error, stack) {
        if (_placement == placements.length - 1) rethrow;
        _log('GLM-OCR failed on $placement, trying the next', error, stack);
        await _unload();
        _placement++;
      }
    }
  }

  /// Photos being read now: the model is never unloaded under them.
  var _running = 0;

  Future<LlamaEngine> _load() => _engine ??= _loadFirstWorking();

  Future<LlamaEngine> _loadFirstWorking() async {
    while (true) {
      try {
        return await LlamaEngine.load(
          LlamaModel(
            ModelSource.path(files.model),
            projector: ModelSource.path(files.projector),
          ),
          params: placements[_placement].params,
        );
      } on Object catch (error, stack) {
        if (_placement == placements.length - 1) {
          _engine = null; // let the next photo try again
          rethrow;
        }
        _log('GLM-OCR could not load on $placement', error, stack);
        _placement++;
      }
    }
  }

  static void _log(String message, Object error, StackTrace stack) => developer
      .log(message, name: 'extraction', error: error, stackTrace: stack);

  /// Frees the model's memory; the next photo loads it again (with the
  /// placement that last worked).
  Future<void> close() async {
    _idle?.cancel();
    await _unload();
  }

  Future<void> _unload() async {
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      try {
        await (await engine).dispose();
      } on Object catch (_) {
        // A load that failed has nothing to free.
      }
    }
  }
}
