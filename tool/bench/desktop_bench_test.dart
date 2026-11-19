// Extraction benchmark on the PC: PDFs (text layer, via the app's own
// PdfTextReader) and saved ML Kit output (`*.ocr.json` from a device run).
// No phone needed. See tool/bench/README.md.
//
//   flutter test tool/bench/desktop_bench_test.dart
//
// Options (all optional), as --dart-define=NAME=value:
//   BENCH_PDFS   folder with the PDFs       (default data/scontrini/scontrini)
//   BENCH_OCR    folder with *.ocr.json     (default data/ocr_cache)
//
// Receipts exported from the app on a phone ("Esporta come test" +
// tool/pull_fixtures.sh) are also replayed from assets/test_receipts/incoming.
//   BENCH_TRUTH  ground truth folder        (default data/ground_truth)
//   BENCH_OUT    where reports are written  (default data/bench_runs)
//   BENCH_ONLY   run only cases whose name contains this text

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

void main() {
  test('extraction benchmark (desktop)', timeout: Timeout.none, () async {
    final cases = [
      ...discoverCases(_pdfs, {InputKind.pdf}),
      ...discoverCases(_ocr, {InputKind.ocrJson}),
      ...discoverCases('assets/test_receipts/incoming', {InputKind.ocrJson}),
    ].where((c) => c.name.contains(_only)).toList();
    if (cases.isEmpty) {
      markTestSkipped('No PDFs in $_pdfs and no *.ocr.json in $_ocr.');
      return;
    }

    // PdfTextReader calls pdfrxFlutterInitialize, which only needs a cache
    // folder from path_provider when none is set.
    Pdfrx.cacheDirectoryPath = Directory.systemTemp.path;
    // ML Kit is only reached for scanned pages, which fail here (no plugin
    // on the PC) and are reported as needing the device.
    final ocr = MlKitOcr();
    final pdfReader = PdfTextReader(ocr, () async => Directory.systemTemp);

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
        InputKind.image => throw UnsupportedError(
          'photos need ML Kit: run tool/bench/run_device.sh',
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

    // One summary per input kind: PDF text layers and replayed photos have
    // very different error profiles.
    for (final kind in InputKind.values) {
      final ofKind = [
        for (final r in results)
          if (r.benchCase.kind == kind) r,
      ];
      if (ofKind.isEmpty) continue;
      stdout.write(
        BenchReport(
          label: 'desktop · ${_kindLabel[kind]}',
          results: ofKind,
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

const _kindLabel = <InputKind, String>{
  InputKind.pdf: 'PDF',
  InputKind.ocrJson: 'photos (saved ML Kit output)',
  InputKind.image: 'photos',
};

String _stamp(DateTime t) =>
    t.toIso8601String().substring(0, 19).replaceAll(':', '-');
