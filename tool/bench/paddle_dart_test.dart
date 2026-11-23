// Reads the bench photos with the app's PaddleOcr (Dart + onnxruntime) on
// the PC and saves the text where desktop_bench_test.dart scores it, as the
// group "photos · PaddleOCR dart-<size>". It must score like the Python
// reader (paddle_ocr.py) on the same models: that checks the Dart port.
//
// On Windows the models need onnxruntime >= 1.16 (ONNX IR 10): the DLL in
// the onnxruntime_v2 package and Windows' own (System32) are older, so the
// test loads the Python venv's by full path first (ORT_DLL), and the
// package's DynamicLibrary.open('onnxruntime.dll') gets that one:
//   flutter test tool/bench/paddle_dart_test.dart --dart-define=PADDLE=true
// Defines: PADDLE_MODELS (default data/modelli/paddle), PADDLE_SIZE
// (medium), PADDLE_PHOTOS (comma-separated folders).

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/data/paddle_ocr.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';

import 'src/bench_case.dart';

const _enabled = bool.fromEnvironment('PADDLE');
const _models = String.fromEnvironment(
  'PADDLE_MODELS',
  defaultValue: 'data/modelli/paddle',
);
const _size = String.fromEnvironment('PADDLE_SIZE', defaultValue: 'medium');
const _ortDll = String.fromEnvironment(
  'ORT_DLL',
  defaultValue:
      '.tooling/paddle-venv/Lib/site-packages/onnxruntime/capi/onnxruntime.dll',
);
const _photos = String.fromEnvironment(
  'PADDLE_PHOTOS',
  defaultValue: 'data/scontrini_foto_reali,data/foto_render',
);

void main() {
  test('PaddleOCR (Dart) on the bench photos', skip: !_enabled, () async {
    if (Platform.isWindows) DynamicLibrary.open(File(_ortDll).absolute.path);
    final ocr = PaddleOcr(
      await PaddleOcrModel.fromDirectory(_models, size: _size),
    );
    final out = Directory('data/ocr_cache/paddle_dart-v6-$_size');
    await out.create(recursive: true);
    for (final folder in _photos.split(',')) {
      if (!Directory(folder).existsSync()) continue;
      for (final c in discoverCases(folder, {InputKind.image})) {
        final watch = Stopwatch()..start();
        final pages = [for (final f in c.files) await ocr.recognizeFile(f)];
        final document = OcrDocument(source: TextSource.ocr, pages: pages);
        File(p.join(out.path, '${c.name}.ocr.json'))
            .writeAsStringSync(jsonEncode(document.toJson()));
        final steps = ocr.timings.entries
            .map((e) => '${e.key} ${e.value.inMilliseconds}')
            .join(', ');
        // Progress in the flutter test output.
        // ignore: avoid_print
        print(
          '${c.name.padRight(32)} ${pages.first.lines.length} lines '
          '${watch.elapsedMilliseconds} ms ($steps)',
        );
      }
    }
    await ocr.close();
  }, timeout: Timeout.none);
}
