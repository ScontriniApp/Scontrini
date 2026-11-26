import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/export/data/csv_importer.dart';
import 'package:scontrini/features/export/data/export_repository.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';

final exportRepositoryProvider = Provider<ExportRepository>(
  (ref) => ExportRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(pantryRepositoryProvider),
  ),
);

/// Saves [bytes] where the user picks (Android's "save as" dialog), named
/// [fileName] by default. `false` when the user cancels. Overridden in tests.
typedef FileSaver = Future<bool> Function({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
});

final fileSaverProvider = Provider<FileSaver>(
  (ref) =>
      ({required fileName, required bytes, required mimeType}) async =>
          await FilePicker.saveFile(
            fileName: fileName,
            bytes: bytes,
            mimeType: mimeType,
          ) !=
          null,
);

final csvImporterProvider = Provider<CsvImporter>(
  (ref) => CsvImporter(
    ref.watch(appDatabaseProvider),
    ref.watch(receiptRepositoryProvider),
    ref.watch(pantryRepositoryProvider),
  ),
);

/// Lets the user pick a file and returns its text; `null` when cancelled.
/// Overridden in tests.
typedef TextFilePicker = Future<String?> Function();

final textFilePickerProvider = Provider<TextFilePicker>(
  (ref) => () async {
    // Any type: Android file managers label CSV files inconsistently
    // (text/csv, text/comma-separated-values, octet-stream), so a CSV
    // filter can grey out the very file. The decoder rejects other files.
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    await FilePicker.clearTemporaryFiles();
    return utf8.decode(bytes, allowMalformed: true);
  },
);
