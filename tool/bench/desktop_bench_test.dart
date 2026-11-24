// Extraction benchmark on the PC, no phone needed. See tool/bench/README.md.
//
//   flutter test tool/bench/desktop_bench_test.dart
//
// Reads:
//   - PDFs, with the app's own PdfTextReader (text layer);
//   - saved ML Kit output (*.ocr.json) from device runs, and receipts
//     exported from the app on a phone ("Esporta come test" +
//     tool/pull_fixtures.sh, in assets/test_receipts/incoming);
//   - saved PaddleOCR output from tool/bench/paddle_ocr.py.
//
// Options (all optional), as --dart-define=NAME=value:
//   BENCH_PDFS    folder with the PDFs        (default data/scontrini/scontrini)
//   BENCH_OCR     folder with ML Kit output   (default data/ocr_cache)
//   BENCH_TRUTH   ground truth folder         (default data/ground_truth)
//   BENCH_OUT     where reports are written   (default data/bench_runs)
//   BENCH_ONLY    run only cases whose name contains this text

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';

import 'src/bench_case.dart';
import 'src/bench_runner.dart';
import 'src/keyword_classifier.dart';
import 'src/report.dart';

const _pdfs = String.fromEnvironment(
  'BENCH_PDFS',
  defaultValue: 'data/scontrini/scontrini',
);
const _ocr = String.fromEnvironment(
  'BENCH_OCR',
  defaultValue: 'data/ocr_cache',
);
const _truth = String.fromEnvironment(
  'BENCH_TRUTH',
  defaultValue: 'data/ground_truth',
);
const _out = String.fromEnvironment(
  'BENCH_OUT',
  defaultValue: 'data/bench_runs',
);
const _only = String.fromEnvironment('BENCH_ONLY');

const _pdfGroup = 'PDF';
const _mlKitGroup = 'photos · ML Kit (saved)';

void main() {
  test('extraction benchmark (desktop)', timeout: Timeout.none, () async {
    final cases = [
      for (final c in discoverCases(_pdfs, {InputKind.pdf}))
        c.withGroup(_pdfGroup),
      for (final c in discoverCases(_ocr, {InputKind.ocrJson}))
        c.withGroup(_mlKitGroup),
      for (final c in discoverCases('assets/test_receipts/incoming', {
        InputKind.ocrJson,
      }))
        c.withGroup(_mlKitGroup),
      // PaddleOCR output from tool/bench/paddle_ocr.py, one folder per model.
      for (final dir in _paddleCaches(_ocr))
        for (final c in discoverCases(dir.path, {InputKind.ocrJson}))
          c.withGroup('photos · PaddleOCR ${_paddleModel(dir)}'),
    ].where((c) => c.name.contains(_only)).toList();
    if (cases.isEmpty) {
      markTestSkipped('Nothing to run: no PDFs, photos or saved OCR output.');
      return;
    }

    // PdfTextReader calls pdfrxFlutterInitialize, which only needs a cache
    // folder from path_provider when none is set.
    Pdfrx.cacheDirectoryPath = Directory.systemTemp.path;
    // ML Kit is only reached for scanned pages, which fail here (no plugin
    // on the PC) and are reported as needing the device.
    final pdfReader = PdfTextReader(
      MlKitOcr(),
      () async => Directory.systemTemp,
    );

    final startedAt = DateTime.now();
    final results = await runBench(
      cases: cases,
      truthDir: _truth,
      classifier: keywordCategory,
      extract: (c) async => switch (c.kind) {
        InputKind.pdf => await _onDesktop(() => pdfReader.read(c.files.single)),
        InputKind.ocrJson => OcrDocument.fromJson(
          jsonDecode(File(c.files.single).readAsStringSync())
              as Map<String, Object?>,
        ),
        // Photos need an OCR engine: run them on the phone.
        InputKind.image => throw StateError(
          'photo: run tool/bench/run_device.sh',
        ),
      },
    );

    final report = BenchReport(
      label: 'desktop',
      results: results,
      startedAt: startedAt,
      classifierName: 'keyword baseline',
    );
    final file = File(p.join(_out, '${_stamp(startedAt)}_desktop.json'));
    await file.parent.create(recursive: true);
    await file.writeAsString(report.toJsonString());

    // One summary per group: PDF text layers and each OCR engine have very
    // different error profiles.
    final groups = <String, List<CaseResult>>{};
    for (final r in results) {
      (groups[r.benchCase.groupLabel] ??= []).add(r);
    }
    for (final MapEntry(:key, :value) in groups.entries) {
      stdout.write(
        BenchReport(
          label: 'desktop · $key',
          results: value,
          startedAt: startedAt,
          classifierName: report.classifierName,
        ).summary(),
      );
    }
    stdout
      ..writeln()
      ..writeln('Full report: ${file.path}');
  });
}

Future<OcrDocument> _onDesktop(Future<OcrDocument> Function() read) async {
  try {
    return await read();
  } on Object catch (error) {
    if ('$error'.contains('MissingPluginException')) {
      throw StateError(
        'scanned PDF: needs ML Kit, run tool/bench/run_device.sh',
      );
    }
    rethrow;
  }
}

/// `<ocr cache>/paddle_<model>/` folders written by paddle_ocr.py.
List<Directory> _paddleCaches(String ocrDir) {
  final root = Directory(ocrDir);
  if (!root.existsSync()) return const [];
  return root
      .listSync()
      .whereType<Directory>()
      .where((d) => p.basename(d.path).startsWith('paddle_'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String _paddleModel(Directory dir) =>
    p.basename(dir.path).substring('paddle_'.length);

String _stamp(DateTime t) =>
    t.toIso8601String().substring(0, 19).replaceAll(':', '-');
