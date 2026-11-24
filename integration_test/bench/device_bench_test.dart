// Extraction benchmark on a phone or emulator: photos and PDFs go through
// exactly the app's pipeline (DeviceTextExtractor → ML Kit / pdfrx →
// RowBuilder → ReceiptParser). Don't run it directly: use
// tool/bench/run_device.sh, which pushes the receipts and pulls the report.
//
// Skipped unless --dart-define=BENCH=true, so `flutter test integration_test`
// is not affected.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/device_text_extractor.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/paddle_ocr.dart';
import 'package:scontrini/features/extraction/data/paddle_ocr_worker.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';

import '../../tool/bench/src/bench_case.dart';
import '../../tool/bench/src/bench_runner.dart';
import '../../tool/bench/src/keyword_classifier.dart';
import '../../tool/bench/src/report.dart';

const _enabled = bool.fromEnvironment('BENCH');
// PaddleOCR (PP-OCRv6 via onnxruntime) with the models run_device.sh
// --paddle pushed into <external files>/paddle-model/.
const _paddle = bool.fromEnvironment('BENCH_PADDLE');
const _paddleSize = String.fromEnvironment(
  'BENCH_PADDLE_SIZE',
  defaultValue: 'small',
);
const _paddleThreads = String.fromEnvironment('BENCH_PADDLE_THREADS');

/// "decode 20, detection 359, ..." from PaddleOcr's step timings.
String _steps(Map<String, Duration> timings) =>
    timings.entries.map((e) => '${e.key} ${e.value.inMilliseconds}').join(', ');

/// Peak and current memory of this process (MB), from /proc/self/status.
String _memory() {
  final status = File('/proc/self/status').readAsLinesSync();
  String mb(String key) {
    final line = status.firstWhere((l) => l.startsWith(key), orElse: () => '');
    final kb = int.tryParse(RegExp(r'\d+').stringMatch(line) ?? '');
    return kb == null ? '?' : '${kb ~/ 1024}';
  }

  return 'RSS ${mb('VmRSS')} MB, peak ${mb('VmHWM')} MB';
}

String _differences(CaseResult r) =>
    '${r.parse?.mismatches.length ?? '?'} differences';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'extraction benchmark (device)',
    skip: !_enabled,
    timeout: Timeout.none,
    (tester) async {
      // Handshake with run_device.sh: installing the test app can wipe the
      // app's folders, so the receipts are pushed only after this writes
      // `ready`, and the run starts when the script writes `go`.
      // In: <external files>/bench/{input,truth}. Out: <...>/bench/out.
      final root = p.join((await getExternalStorageDirectory())!.path, 'bench');
      final rootDir = Directory(root);
      if (rootDir.existsSync()) await rootDir.delete(recursive: true);
      final out = Directory(p.join(root, 'out'));
      final ocrOut = Directory(
        p.join(out.path, _paddle ? 'ocr_paddle' : 'ocr'),
      );
      await ocrOut.create(recursive: true);
      await Directory(p.join(root, 'input')).create();
      await Directory(p.join(root, 'truth')).create();
      await File(p.join(root, 'ready')).create();
      await tester.runAsync(() async {
        final go = File(p.join(root, 'go'));
        final deadline = DateTime.now().add(const Duration(minutes: 10));
        while (!go.existsSync()) {
          if (DateTime.now().isAfter(deadline)) {
            fail('run_device.sh never wrote $root/go');
          }
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      });

      final cases = discoverCases(p.join(root, 'input'), {
        InputKind.pdf,
        InputKind.image,
      });
      expect(cases, isNotEmpty, reason: 'nothing in $root/input');

      final ocr = MlKitOcr();
      // small: the app's own model, from the assets; other sizes: the
      // files run_device.sh pushed.
      final paddleDir = p.join(
        (await getExternalStorageDirectory())!.path,
        'paddle-model',
      );
      final paddle = _paddle
          ? PaddleOcrWorker(
              () => _paddleSize == 'small'
                  ? paddleModelFromAssets(rootBundle)
                  : PaddleOcrModel.fromDirectory(paddleDir, size: _paddleSize),
              threads: int.tryParse(_paddleThreads),
            )
          : null;
      final extractor = DeviceTextExtractor(
        paddle ?? ocr,
        PdfTextReader(ocr, getTemporaryDirectory),
      );
      final times = <String, Duration>{};
      final startedAt = DateTime.now();

      final results = await tester.runAsync(
        () => runBench(
          cases: cases,
          truthDir: p.join(root, 'truth'),
          classifier: keywordCategory,
          extract: (c) async {
            final watch = Stopwatch()..start();
            try {
              return await extractor.extract(switch (c.kind) {
                InputKind.pdf => ReceiptSource.pdf(c.files.single),
                _ => ReceiptSource.images(c.files),
              });
            } finally {
              times[c.name] = watch.elapsed;
            }
          },
          onResult: (r) {
            // Saved ML Kit output lets the PC replay these receipts later.
            if (r.document case final document?
                when r.benchCase.kind == InputKind.image) {
              File(p.join(ocrOut.path, '${r.benchCase.name}.ocr.json'))
                  .writeAsStringSync(jsonEncode(document.toJson()));
            }
            final seconds = (times[r.benchCase.name]!.inMilliseconds / 1000)
                .toStringAsFixed(1);
            final steps = paddle == null
                ? ''
                : ' (${_steps(paddle.lastTimings)} ms)';
            // ignore: avoid_print, progress in the flutter test output
            print(
              '${r.benchCase.name}: ${r.error ?? _differences(r)}, '
              '$seconds s$steps, '
              '${_memory()}',
            );
          },
        ),
      );
      await ocr.close();
      await paddle?.close();

      final report = BenchReport(
        label: paddle != null ? 'device · PaddleOCR v6-$_paddleSize' : 'device',
        results: results!,
        startedAt: startedAt,
        classifierName: 'keyword baseline',
      );
      File(p.join(out.path, 'report.json'))
          .writeAsStringSync(report.toJsonString());
      // ignore: avoid_print, the summary is the point of the run
      print(report.summary());
    },
  );
}
