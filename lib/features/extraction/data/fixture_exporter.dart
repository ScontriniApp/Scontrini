import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/extraction_result.dart';

/// Debug tool: saves a receipt in the parser fixture format, to be copied
/// into `assets/test_receipts/` with `tool/pull_fixtures.sh`.
///
/// Files go to the app's private `files/fixtures/` folder (not shared
/// storage), readable over USB with `adb run-as` on debug builds only.
class FixtureExporter {
  new(this._baseDirectory);

  /// The app support directory: `/data/data/<app>/files` on Android.
  final Future<Directory> Function() _baseDirectory;

  /// Writes `<name>.txt` (rows), `<name>.ocr.json` (raw text with
  /// positions) and `<name>.draft.json` (current parser output, to be
  /// corrected and renamed `.expected.json`). Returns the file name stem.
  Future<String> export(ExtractionResult result) async {
    final directory = Directory(
      p.join((await _baseDirectory()).path, 'fixtures'),
    );
    await directory.create(recursive: true);
    final name =
        'receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';
    const json = JsonEncoder.withIndent('  ');

    Future<void> write(String suffix, String content) =>
        File(p.join(directory.path, '$name$suffix')).writeAsString(content);

    await write('.txt', '${result.rowsText}\n');
    await write('.ocr.json', json.convert(result.document.toJson()));
    await write('.draft.json', json.convert(result.receipt.toJson()));
    return name;
  }
}
