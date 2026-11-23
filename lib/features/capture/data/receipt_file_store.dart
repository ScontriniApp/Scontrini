import 'dart:io';

import 'package:path/path.dart' as p;

/// Copies captured files into a private `receipts/` folder, so they survive
/// plugin cache cleanup and can be shown again from the receipt history.
class ReceiptFileStore {
  new(this._baseDirectory);

  /// Resolved lazily (path_provider is async), usually the app documents
  /// directory.
  final Future<Directory> Function() _baseDirectory;

  Future<List<String>> keepAll(List<String> paths) async {
    final directory = Directory(
      p.join((await _baseDirectory()).path, 'receipts'),
    );
    await directory.create(recursive: true);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return [
      for (final (i, path) in paths.indexed)
        (await File(path).copy(
          p.join(
            directory.path,
            '${stamp}_$i${p.extension(path).toLowerCase()}',
          ),
        )).path,
    ];
  }
}
