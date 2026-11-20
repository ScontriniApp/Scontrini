// Extraction benchmark on the PC, no phone needed. See tool/bench/README.md.
//
//   flutter test tool/bench/desktop_bench_test.dart
//
// Reads:
//   - PDFs, with the app's own PdfTextReader (text layer);
//   - saved ML Kit output (*.ocr.json) from device runs, and receipts
//     exported from the app on a phone ("Esporta come test" +
//     tool/pull_fixtures.sh, in assets/test_receipts/incoming);
//   - saved GLM-OCR output (data/ocr_cache/glm/*.ocr.json), and with
//     BENCH_GLM=true it reads the photos not read yet with GLM-OCR through
//     LM Studio (`lms load glm-ocr`, `lms server start`) and saves them.
//
// Options (all optional), as --dart-define=NAME=value:
//   BENCH_PDFS    folder with the PDFs        (default data/scontrini/scontrini)
//   BENCH_OCR     folder with ML Kit output   (default data/ocr_cache)
//   BENCH_PHOTOS  photo folders, comma-separated, for GLM-OCR
//                 (default data/scontrini_foto_reali,data/foto_render)
//   BENCH_GLM     true: read new photos with GLM-OCR; `refresh`: read all again
//   BENCH_GLM_MAX_SIDE  longest image side sent to GLM-OCR (default 4096)
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
import 'src/glm_ocr_reader.dart';
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
const _photos = String.fromEnvironment(
  'BENCH_PHOTOS',
  defaultValue: 'data/scontrini_foto_reali,data/foto_render',
);
const _glm = String.fromEnvironment('BENCH_GLM');
const _glmMaxSide = int.fromEnvironment(
  'BENCH_GLM_MAX_SIDE',
  defaultValue: 4096,
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
const _glmGroup = 'photos · GLM-OCR';

void main() {
  test('extraction benchmark (desktop)', timeout: Timeout.none, () async {
    final glmCache = p.join(_ocr, 'glm');
    final glmCached = {
      for (final c in discoverCases(glmCache, {InputKind.ocrJson})) c.name: c,
    };
    final glmToRead = [
      if (_glm == 'true' || _glm == 'refresh')
        for (final dir in _photos.split(','))
          for (final c in discoverCases(dir.trim(), {InputKind.image}))
            if (_glm == 'refresh' || !glmCached.containsKey(c.name)) c,
    ];
    final glmNames = {for (final c in glmToRead) c.name};

    final cases = [
      for (final c in discoverCases(_pdfs, {InputKind.pdf}))
        c.withGroup(_pdfGroup),
      for (final c in discoverCases(_ocr, {InputKind.ocrJson}))
        c.withGroup(_mlKitGroup),
      for (final c in discoverCases('assets/test_receipts/incoming', {
        InputKind.ocrJson,
      }))
        c.withGroup(_mlKitGroup),
      for (final c in glmCached.values)
        if (!glmNames.contains(c.name)) c.withGroup(_glmGroup),
      for (final c in glmToRead) c.withGroup(_glmGroup),
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
    final glm = GlmOcrReader(maxSide: _glmMaxSide);
    final glmUsage = <String, GlmUsage>{};

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
        InputKind.image => await _readWithGlm(glm, c, glmCache, glmUsage),
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
    if (glmUsage.isNotEmpty) stdout.write(_usageSummary(glmUsage));
    stdout
      ..writeln()
      ..writeln('Full report: ${file.path}');
  });
}

Future<OcrDocument> _readWithGlm(
  GlmOcrReader glm,
  BenchCase c,
  String cacheDir,
  Map<String, GlmUsage> usage,
) async {
  final (document, cost) = await glm.read(c.files);
  usage[c.name] = cost;
  // Saved like ML Kit's output, so later runs replay it without the model.
  final file = File(p.join(cacheDir, '${c.name}.ocr.json'));
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(document.toJson()));
  return document;
}

String _usageSummary(Map<String, GlmUsage> usage) {
  final b = StringBuffer()
    ..writeln()
    ..writeln('GLM-OCR COST (this PC; on a phone the time grows with the')
    ..writeln('generated tokens)');
  for (final MapEntry(:key, :value) in usage.entries) {
    b.writeln(
      '  ${key.padRight(32)}'
      '${'${value.promptTokens}'.padLeft(6)} image+prompt tokens'
      '${'${value.completionTokens}'.padLeft(6)} generated'
      '${(value.milliseconds / 1000).toStringAsFixed(1).padLeft(7)} s',
    );
  }
  return b.toString();
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
