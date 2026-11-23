import 'dart:async';
import 'dart:isolate';

import 'package:scontrini/features/extraction/data/paddle_ocr.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';

/// [PaddleOcr] on a background isolate: reading a photo takes seconds of
/// CPU (about 9 s on a Snapdragon 680) and must not freeze the UI.
///
/// The isolate is started on the first photo (or [warmUp]) with the model
/// loaded once, and stopped [idleTimeout] after the last photo, freeing the
/// networks' memory.
class PaddleOcrWorker implements ImageTextReader {
  new(
    this._loadModel, {
    this.threads,
    this.idleTimeout = const Duration(minutes: 2),
  });

  final Future<PaddleOcrModel> Function() _loadModel;
  final int? threads;
  final Duration idleTimeout;

  Future<SendPort>? _worker;
  Isolate? _isolate;
  Timer? _idle;
  var _running = 0;

  /// Step timings of the last photo (see [PaddleOcr.timings]).
  Map<String, Duration> lastTimings = const {};

  /// Starts the isolate and loads the model now, so the first photo
  /// doesn't wait for it.
  Future<void> warmUp() async {
    await _start();
    if (_running == 0) _scheduleStop();
  }

  @override
  Future<OcrPage> recognizeFile(String imagePath) async {
    _idle?.cancel();
    _running++;
    try {
      final worker = await _start();
      final reply = ReceivePort();
      worker.send((imagePath, reply.sendPort));
      final answer = await reply.first;
      reply.close();
      return switch (answer) {
        (final Map<String, Object?> page, final Map<String, int> timings) =>
          _done(page, timings),
        final String error => throw StateError('PaddleOCR: $error'),
        _ => throw StateError('PaddleOCR: unexpected reply $answer'),
      };
    } finally {
      if (--_running == 0) _scheduleStop();
    }
  }

  OcrPage _done(Map<String, Object?> page, Map<String, int> timings) {
    lastTimings = {
      for (final MapEntry(:key, :value) in timings.entries)
        key: Duration(microseconds: value),
    };
    return OcrPage.fromJson(page);
  }

  void _scheduleStop() {
    _idle?.cancel();
    _idle = Timer(idleTimeout, close);
  }

  Future<SendPort> _start() => _worker ??= () async {
    final model = await _loadModel();
    final ready = ReceivePort();
    final errors = ReceivePort();
    _isolate = await Isolate.spawn(
      _main,
      (
        ready.sendPort,
        TransferableTypedData.fromList([model.detection]),
        TransferableTypedData.fromList([model.recognition]),
        model.characters,
        threads,
      ),
      onError: errors.sendPort,
      debugName: 'PaddleOCR',
    );
    final first = await Future.any([ready.first, errors.first]);
    ready.close();
    errors.close();
    if (first is SendPort) return first;
    _worker = null;
    _isolate?.kill();
    _isolate = null;
    throw StateError('PaddleOCR did not start: $first');
  }();

  /// Stops the isolate; the next photo starts it again.
  Future<void> close() async {
    _idle?.cancel();
    final worker = _worker;
    _worker = null;
    if (worker == null) return;
    try {
      final done = ReceivePort();
      (await worker).send(done.sendPort);
      await done.first.timeout(const Duration(seconds: 5));
      done.close();
    } on Object catch (_) {
      _isolate?.kill(priority: Isolate.immediate);
    }
    _isolate = null;
  }
}

/// The isolate: loads the networks, then answers `(path, reply)` with
/// `(page JSON, step timings)` or an error message, until it gets a bare
/// [SendPort], which it answers after freeing the sessions.
Future<void> _main(
  (SendPort, TransferableTypedData, TransferableTypedData, List<String>, int?)
  args,
) async {
  final (ready, detection, recognition, characters, threads) = args;
  final ocr = PaddleOcr(
    PaddleOcrModel(
      detection: detection.materialize().asUint8List(),
      recognition: recognition.materialize().asUint8List(),
      characters: characters,
    ),
    threads: threads,
  )..load();
  final requests = ReceivePort();
  ready.send(requests.sendPort);
  await for (final message in requests) {
    switch (message) {
      case (final String path, final SendPort reply):
        try {
          final page = await ocr.recognizeFile(path);
          reply.send((
            page.toJson(),
            {
              for (final MapEntry(:key, :value) in ocr.timings.entries)
                key: value.inMicroseconds,
            },
          ));
        } on Object catch (error) {
          reply.send('$error');
        }
      case final SendPort done:
        await ocr.close();
        requests.close();
        done.send(true);
    }
  }
}
