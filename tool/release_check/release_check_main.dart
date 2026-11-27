// Debug vs release check: the same probes in both build modes, so whatever
// a release build changes (R8 shrinking the plugins' Java/Kotlin code,
// asserts stripped, AOT) shows up as a difference. Don't run it directly:
// tool/release_check/run.sh builds it twice, runs it on a phone, compares.
//
// In:  <external files>/release_check/input/ (photos, PDFs, one scanned PDF)
//      and truth/ (ground truth, optional).
// Out: <external files>/release_check/out_<debug|release>/*.json + done.
//
// Every probe catches its own errors and records them, so one broken plugin
// doesn't hide the others.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/device_text_extractor.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/data/mlkit_ocr.dart';
import 'package:scontrini/features/extraction/data/paddle_ocr_worker.dart';
import 'package:scontrini/features/extraction/data/pdf_text_reader.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:sqlite3/sqlite3.dart';

import '../bench/src/bench_case.dart';
import '../bench/src/bench_runner.dart';
import '../bench/src/keyword_classifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = ValueNotifier('release check: starting');
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: status,
          builder: (_, text, _) => Text(text),
        ),
      ),
    ),
  );

  final root = p.join(
    (await getExternalStorageDirectory())!.path,
    'release_check',
  );
  const mode = kReleaseMode ? 'release' : 'debug';
  final out = Directory(p.join(root, 'out_$mode'));
  if (out.existsSync()) out.deleteSync(recursive: true);
  out.createSync(recursive: true);
  void write(String name, Object? json) =>
      File(p.join(out.path, name))
          .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(json));

  // 1. Native pieces without UI.
  final native = <String, Object?>{};
  Future<void> probe(String name, Future<Object?> Function() body) async {
    status.value = '$mode: $name';
    try {
      native[name] = await body();
    } on Object catch (e, stack) {
      native[name] = 'ERROR $e $stack';
    }
  }

  await probe('secureStorage', _secureStorage);
  await probe('pathProvider', _pathProvider);
  await probe('encryptedSqlite', _encryptedSqlite);
  write('native.json', native);

  // 2. The extraction pipeline: every reader on its own (no fallback, so a
  // broken reader is an error here, not a silent switch to another one).
  final cases = discoverCases(p.join(root, 'input'), {
    InputKind.pdf,
    InputKind.image,
  });
  final mlkit = MlKitOcr();
  final paddle = PaddleOcrWorker(() => paddleModelFromAssets(rootBundle));
  final pdfReader = PdfTextReader(mlkit, getTemporaryDirectory);

  Future<void> pass(
    String name,
    ImageTextReader reader,
    List<BenchCase> selected,
  ) async {
    status.value = '$mode: $name';
    final extractor = DeviceTextExtractor(reader, pdfReader);
    final results = await runBench(
      cases: selected,
      truthDir: p.join(root, 'truth'),
      classifier: keywordCategory,
      extract: (c) => extractor.extract(switch (c.kind) {
        InputKind.pdf => ReceiptSource.pdf(c.files.single),
        _ => ReceiptSource.images(c.files),
      }),
    );
    write('$name.json', [
      for (final r in results)
        {
          // Timings differ between modes by design.
          ...r.toJson()
            ..remove('extractMs')
            ..remove('parseMs'),
          'document': r.document?.toJson(),
        },
    ]);
  }

  final photos = cases.where((c) => c.kind != InputKind.pdf).toList();
  final pdfs = cases.where((c) => c.kind == InputKind.pdf).toList();
  try {
    await pass('paddle', paddle, photos);
    await pass('mlkit', mlkit, photos);
    await pass('pdf', mlkit, pdfs);
    File(p.join(out.path, 'done')).writeAsStringSync('ok');
    status.value = '$mode: done';
  } on Object catch (e, stack) {
    File(p.join(out.path, 'done')).writeAsStringSync('error: $e\n$stack');
    status.value = '$mode: error $e';
  } finally {
    await mlkit.close();
    await paddle.close();
  }
}

/// Write, read back and delete a value: the database key lives here.
Future<Object?> _secureStorage() async {
  const storage = FlutterSecureStorage();
  const key = 'release_check_probe';
  final value = Random.secure().nextInt(1 << 30).toString();
  await storage.write(key: key, value: value);
  final back = await storage.read(key: key);
  await storage.delete(key: key);
  return {'roundTrip': back == value, 'deleted': await storage.read(key: key)};
}

Future<Object?> _pathProvider() async => {
  'documents': (await getApplicationDocumentsDirectory()).existsSync(),
  'temporary': (await getTemporaryDirectory()).existsSync(),
  'support': (await getApplicationSupportDirectory()).existsSync(),
};

/// SQLite3MultipleCiphers: a keyed file is unreadable without the key, and
/// drift opens it in a background isolate the way the app does.
Future<Object?> _encryptedSqlite() async {
  final temp = (await getTemporaryDirectory()).path;
  final file = File(p.join(temp, 'release_check.db'));
  if (file.existsSync()) file.deleteSync();
  const key = 'abcdef0123456789';

  final db = sqlite3.open(file.path);
  final cipher = db.select('PRAGMA cipher').firstOrNull?.values.first;
  db
    ..execute("PRAGMA key = '$key'")
    ..execute('CREATE TABLE t (v TEXT)')
    ..execute("INSERT INTO t VALUES ('ok')")
    ..close();
  final header = String.fromCharCodes(file.readAsBytesSync().take(15));

  final again = sqlite3.open(file.path)..execute("PRAGMA key = '$key'");
  final row = again.select('SELECT v FROM t').single['v'];
  again.close();

  String wrongKey;
  try {
    final wrong = sqlite3.open(file.path)..execute("PRAGMA key = 'nope'");
    try {
      wrong.select('SELECT v FROM t');
      wrongKey = 'OPENED WITH A WRONG KEY';
    } finally {
      wrong.close();
    }
  } on Object {
    wrongKey = 'refused';
  }
  file.deleteSync();

  final driftFile = File(p.join(temp, 'release_check_drift.db'));
  if (driftFile.existsSync()) driftFile.deleteSync();
  final drift = AppDatabase(
    NativeDatabase.createInBackground(
      driftFile,
      setup: (db) => db.execute("PRAGMA key = '$key'"),
    ),
  );
  final categories = await drift
      .customSelect('SELECT count(*) AS n FROM categories')
      .getSingle();
  await drift.close();
  driftFile.deleteSync();

  return {
    'cipher': cipher,
    'plainHeader': header.startsWith('SQLite format'),
    'row': row,
    'wrongKey': wrongKey,
    'seededCategories': categories.data['n'],
  };
}
