import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _databaseFileName = 'scontrini.sqlite';

/// Opens the app database encrypted with [key].
///
/// The app bundles SQLite3MultipleCiphers (see `hooks.user_defines` in
/// `pubspec.yaml`); `PRAGMA key` must be the first statement on the
/// connection. The database runs in a background isolate.
QueryExecutor openEncryptedConnection(String key) {
  assert(RegExp(r'^[0-9a-f]+$').hasMatch(key), 'key must be lowercase hex');

  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _databaseFileName));

    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        final cipher = db.select('PRAGMA cipher');
        if (cipher.isEmpty) {
          throw StateError(
            'SQLite was built without encryption support. '
            'Check hooks.user_defines.sqlite3.source in pubspec.yaml.',
          );
        }
        db.execute("PRAGMA key = '$key'");
      },
    );
  });
}
