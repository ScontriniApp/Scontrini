// Extraction benchmark on a phone or emulator: photos and PDFs go through
// exactly the app's pipeline (DeviceTextExtractor → ML Kit / pdfrx →
// RowBuilder → ReceiptParser). Don't run it directly: use
// tool/bench/run_device.sh, which pushes the receipts and pulls the report.
//
// Skipped unless --dart-define=BENCH=true, so `flutter test integration_test`
// is not affected.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/device_text_extractor.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';

import '../../tool/bench/src/bench_case.dart';
import '../../tool/bench/src/bench_runner.dart';
import '../../tool/bench/src/keyword_classifier.dart';
import '../../tool/bench/src/report.dart';

const _enabled = bool.fromEnvironment('BENCH');

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
      final ocrOut = Directory(p.join(out.path, 'ocr'));
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
      final extractor = DeviceTextExtractor(
        ocr,
        PdfTextReader(ocr, getTemporaryDirectory),
      );
      final startedAt = DateTime.now();

      final results = await tester.runAsync(
        () => runBench(
          cases: cases,
          truthDir: p.join(root, 'truth'),
          classifier: keywordCategory,
          extract: (c) => extractor.extract(switch (c.kind) {
            InputKind.pdf => ReceiptSource.pdf(c.files.single),
            _ => ReceiptSource.images(c.files),
          }),
          onResult: (r) {
            // Saved ML Kit output lets the PC replay these receipts later.
            if (r.document case final document?
                when r.benchCase.kind == InputKind.image) {
              File(p.join(ocrOut.path, '${r.benchCase.name}.ocr.json'))
                  .writeAsStringSync(jsonEncode(document.toJson()));
            }
            // ignore: avoid_print, progress in the flutter test output
            print('${r.benchCase.name}: ${r.error ?? _differences(r)}');
          },
        ),
      );
      await ocr.close();

      final report = BenchReport(
        label: 'device',
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
