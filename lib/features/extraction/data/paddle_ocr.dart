import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime_v2/onnxruntime_v2.dart';
// The package's own tensor accessors copy element by element into Dart
// lists, far too slow for the recogniser's output (18,710 classes per step).
// ignore: implementation_imports
import 'package:onnxruntime_v2/src/bindings/onnxruntime_bindings_generated.dart'
    as bg;
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/paddle_ocr_steps.dart';

/// One PP-OCR model set: detection and recognition networks (ONNX, as
/// RapidOCR ships them) and the recogniser's characters (the `character`
/// metadata of the recognition model, one per line in the text file).
class PaddleOcrModel {
  const new({
    required this.detection,
    required this.recognition,
    required this.characters,
  });

  /// PP-OCRv6 files of [size] (tiny, small, medium) inside [directory].
  static Future<PaddleOcrModel> fromDirectory(
    String directory, {
    required String size,
  }) async => PaddleOcrModel(
    detection: await File(p.join(directory, 'PP-OCRv6_det_$size.onnx'))
        .readAsBytes(),
    recognition: await File(p.join(directory, 'PP-OCRv6_rec_$size.onnx'))
        .readAsBytes(),
    characters: await File(p.join(directory, characterFileName)).readAsLines(),
  );

  static const characterFileName = 'PP-OCRv6_rec_characters.txt';

  final Uint8List detection;
  final Uint8List recognition;
  final List<String> characters;
}

/// Reads receipt photos with PaddleOCR's PP-OCR networks through
/// onnxruntime, on the device. Same models and steps as the benchmark's
/// Python reader, so the score there is the score here.
///
/// It runs on the calling isolate and takes seconds: the app uses it
/// through `PaddleOcrWorker`.
class PaddleOcr implements ImageTextReader {
  new(this.model, {this.threads});

  final PaddleOcrModel model;

  /// onnxruntime's threads per network; `null` lets it choose.
  final int? threads;

  /// Lines with a lower mean confidence are dropped (as RapidOCR does).
  static const minScore = 0.5;

  /// Photos are scaled down to this longest side first (as RapidOCR does).
  static const maxSide = 2000;

  static const _batch = 6;

  OrtSession? _detection;
  OrtSession? _recognition;
  late List<String> _characters;
  late Uint8List _allowed;

  /// Time spent in each step of the last [recognizeFile], for benchmarks.
  final timings = <String, Duration>{};

  /// Creates the onnxruntime sessions; [recognizeFile] does it if needed.
  void load() {
    if (_detection != null) return;
    OrtEnv.instance.init();
    OrtSessionOptions options() {
      final o = OrtSessionOptions();
      if (threads != null) o.setIntraOpNumThreads(threads!);
      return o;
    }

    _detection = OrtSession.fromBuffer(model.detection, options());
    _recognition = OrtSession.fromBuffer(model.recognition, options());
    _characters = [...model.characters, ' '];
    _allowed = receiptCharacterMask(_characters);
  }

  @override
  Future<OcrPage> recognizeFile(
    String imagePath, {
    OnReadProgress? onProgress,
  }) async {
    onProgress?.call((step: ReadStep.preparing, fraction: 0));
    timings.clear();
    final watch = Stopwatch()..start();
    void lap(String step) {
      timings[step] = watch.elapsed;
      watch.reset();
    }

    load();
    var image = img.decodeImage(await File(imagePath).readAsBytes());
    if (image == null) throw FormatException('not an image: $imagePath');
    image = img.bakeOrientation(image);
    final width = image.width;
    final height = image.height;
    final scale = math.max(width, height) > maxSide
        ? maxSide / math.max(width, height)
        : 1.0;
    if (scale < 1) {
      image = img.copyResize(
        image,
        width: (width * scale).round(),
        height: (height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }
    if (image.numChannels != 3) {
      image = image.convert(numChannels: 3);
    }
    lap('decode');
    onProgress?.call((step: ReadStep.findingLines, fraction: 0.05));

    final input = detectionInput(image);
    final map = _run(_detection!, input);
    lap('detection');
    final quads = boxesFromProbabilities(
      map.data,
      map.shape[3],
      map.shape[2],
      width: image.width,
      height: image.height,
    );
    lap('boxes');

    final crops = [for (final q in quads) cropLine(image, q)];
    lap('crops');
    // Detection is about a quarter of the time, recognition the rest.
    onProgress?.call((step: ReadStep.readingLines, fraction: 0.3));
    final texts = recognizeCrops(
      crops,
      onBatch: onProgress == null
          ? null
          : (done, total) => onProgress((
              step: ReadStep.readingLines,
              fraction: 0.3 + 0.7 * done / total,
            )),
    );
    lap('recognition');

    return OcrPage(
      width: width.toDouble(),
      height: height.toDouble(),
      lines: [
        for (final (i, quad) in quads.indexed)
          if (texts[i].$2 >= minScore && texts[i].$1.trim().isNotEmpty)
            _line(texts[i].$1, texts[i].$2, quad, 1 / scale),
      ],
    );
  }

  /// Text and confidence of each line image (see [cropLine]), recognised in
  /// batches of similar width as RapidOCR does: less padding to read.
  /// [onBatch] gets the lines read so far after each batch.
  List<(String, double)> recognizeCrops(
    List<img.Image> crops, {
    void Function(int done, int total)? onBatch,
  }) {
    load();
    final texts = List<(String, double)>.filled(crops.length, ('', 0));
    final order = List<int>.generate(crops.length, (i) => i)
      ..sort(
        (a, b) => (crops[a].width / crops[a].height).compareTo(
          crops[b].width / crops[b].height,
        ),
      );
    final prepare = Stopwatch();
    final run = Stopwatch();
    final decode = Stopwatch();
    for (var start = 0; start < order.length; start += _batch) {
      final batch = order.sublist(
        start,
        math.min(start + _batch, order.length),
      );
      prepare.start();
      final input = recognitionInput([for (final i in batch) crops[i]]);
      prepare.stop();
      run.start();
      final output = _run(_recognition!, input);
      run.stop();
      decode.start();
      final decoded = ctcDecode(
        output.data,
        output.shape[0],
        output.shape[1],
        _characters,
        allowed: _allowed,
      );
      decode.stop();
      for (final (k, i) in batch.indexed) {
        texts[i] = decoded[k];
      }
      onBatch?.call(start + batch.length, crops.length);
    }
    timings
      ..['rec-input'] = prepare.elapsed
      ..['rec-network'] = run.elapsed
      ..['rec-decode'] = decode.elapsed;
    return texts;
  }

  /// A line as the benchmark's Python reader writes it: the box keeps the
  /// real text height (left and right edges of the slanted quad) around
  /// the quad's centre, so RowBuilder doesn't merge rows.
  static OcrLine _line(String text, double confidence, Quad q, double scale) {
    double dist(Point a, Point b) =>
        math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
    final xs = [for (final c in q) c.x * scale];
    final cy = q.fold<double>(0, (sum, c) => sum + c.y) / 4 * scale;
    final h = (dist(q[0], q[3]) + dist(q[1], q[2])) / 2 * scale;
    return OcrLine(
      text: text,
      box: TextBox(
        left: xs.reduce(math.min),
        top: cy - h / 2,
        right: xs.reduce(math.max),
        bottom: cy + h / 2,
      ),
      angle: math.atan2(q[1].y - q[0].y, q[1].x - q[0].x) * 180 / math.pi,
      confidence: confidence,
    );
  }

  /// Runs [session] on one float input; returns its first output.
  static Tensor _run(OrtSession session, Tensor input) {
    final tensor = _floatTensor(input);
    final runOptions = OrtRunOptions();
    try {
      final outputs = session.run(runOptions, {
        session.inputNames.first: tensor,
      });
      try {
        return _readFloats(outputs.first!);
      } finally {
        for (final o in outputs) {
          o?.release();
        }
      }
    } finally {
      tensor.release();
      runOptions.release();
    }
  }

  static bg.OrtApi get _api => OrtEnv.instance.ortApiPtr.ref;

  static OrtValueTensor _floatTensor(Tensor t) {
    final n = t.data.length;
    final data = calloc<ffi.Float>(n)..asTypedList(n).setAll(0, t.data);
    final shape = calloc<ffi.Int64>(t.shape.length)
      ..asTypedList(t.shape.length).setAll(0, t.shape);
    final info = calloc<ffi.Pointer<bg.OrtMemoryInfo>>();
    final value = calloc<ffi.Pointer<bg.OrtValue>>();
    try {
      _check(
        _api.CreateCpuMemoryInfo.asFunction<
          bg.OrtStatusPtr Function(
            int,
            int,
            ffi.Pointer<ffi.Pointer<bg.OrtMemoryInfo>>,
          )
        >()(
          bg.OrtAllocatorType.OrtArenaAllocator,
          bg.OrtMemType.OrtMemTypeDefault,
          info,
        ),
      );
      _check(
        _api.CreateTensorWithDataAsOrtValue.asFunction<
          bg.OrtStatusPtr Function(
            ffi.Pointer<bg.OrtMemoryInfo>,
            ffi.Pointer<ffi.Void>,
            int,
            ffi.Pointer<ffi.Int64>,
            int,
            int,
            ffi.Pointer<ffi.Pointer<bg.OrtValue>>,
          )
        >()(
          info.value,
          data.cast(),
          n * 4,
          shape,
          t.shape.length,
          ONNXTensorElementDataType.float.value,
          value,
        ),
      );
      _api.ReleaseMemoryInfo.asFunction<
        void Function(ffi.Pointer<bg.OrtMemoryInfo>)
      >()(info.value);
      return OrtValueTensor(value.value, data.cast());
    } finally {
      calloc
        ..free(shape)
        ..free(info)
        ..free(value);
    }
  }

  static Tensor _readFloats(OrtValue value) {
    final infoPtr = calloc<ffi.Pointer<bg.OrtTensorTypeAndShapeInfo>>();
    final count = calloc<ffi.Size>();
    final dataPtr = calloc<ffi.Pointer<ffi.Void>>();
    try {
      _check(
        _api.GetTensorTypeAndShape.asFunction<
          bg.OrtStatusPtr Function(
            ffi.Pointer<bg.OrtValue>,
            ffi.Pointer<ffi.Pointer<bg.OrtTensorTypeAndShapeInfo>>,
          )
        >()(value.ptr, infoPtr),
      );
      final info = infoPtr.value;
      _check(
        _api.GetDimensionsCount.asFunction<
          bg.OrtStatusPtr Function(
            ffi.Pointer<bg.OrtTensorTypeAndShapeInfo>,
            ffi.Pointer<ffi.Size>,
          )
        >()(info, count),
      );
      final dims = count.value;
      final shapePtr = calloc<ffi.Int64>(dims);
      _check(
        _api.GetDimensions.asFunction<
          bg.OrtStatusPtr Function(
            ffi.Pointer<bg.OrtTensorTypeAndShapeInfo>,
            ffi.Pointer<ffi.Int64>,
            int,
          )
        >()(info, shapePtr, dims),
      );
      final shape = List<int>.of(shapePtr.asTypedList(dims));
      calloc.free(shapePtr);
      _api.ReleaseTensorTypeAndShapeInfo.asFunction<
        void Function(ffi.Pointer<bg.OrtTensorTypeAndShapeInfo>)
      >()(info);
      _check(
        _api.GetTensorMutableData.asFunction<
          bg.OrtStatusPtr Function(
            ffi.Pointer<bg.OrtValue>,
            ffi.Pointer<ffi.Pointer<ffi.Void>>,
          )
        >()(value.ptr, dataPtr),
      );
      final n = shape.fold(1, (a, b) => a * b);
      return (
        data: Float32List.fromList(
          dataPtr.value.cast<ffi.Float>().asTypedList(n),
        ),
        shape: shape,
      );
    } finally {
      calloc
        ..free(infoPtr)
        ..free(count)
        ..free(dataPtr);
    }
  }

  static void _check(bg.OrtStatusPtr status) =>
      OrtStatus.checkOrtStatus(status);

  Future<void> close() async {
    await _detection?.release();
    await _recognition?.release();
    _detection = null;
    _recognition = null;
  }
}
