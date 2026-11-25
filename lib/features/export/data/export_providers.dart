import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/export/data/export_repository.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';

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
