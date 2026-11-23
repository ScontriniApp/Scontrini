import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';

/// Hand-checked answer for one receipt: `<name>.truth.json` plus the optional
/// `<name>.rows.txt`. Format in `tool/bench/README.md`.
class GroundTruth {
  const new({
    required this.name,
    required this.receipt,
    required this.categories,
    this.rows,
    this.ignoredRows = const [],
    this.notes,
  });

  /// Reads `<name>.truth.json` (and `<name>.rows.txt` if present) from [dir].
  /// Returns `null` when there is no answer for [name].
  static GroundTruth? load(String dir, String name) {
    final truthFile = File(p.join(dir, '$name.truth.json'));
    if (!truthFile.existsSync()) return null;
    final json =
        jsonDecode(truthFile.readAsStringSync()) as Map<String, Object?>;
    final items = (json['items'] as List? ?? const [])
        .cast<Map<String, Object?>>();
    final rowsFile = File(p.join(dir, '$name.rows.txt'));
    return GroundTruth(
      name: name,
      receipt: ParsedReceipt.fromJson(json),
      categories: [for (final item in items) item['category'] as String?],
      rows: rowsFile.existsSync()
          ? rowsFile
                .readAsLinesSync()
                .where((line) => line.trim().isNotEmpty)
                .toList()
          : null,
      ignoredRows: (json['ignoredRows'] as List? ?? const []).cast<String>(),
      notes: json['notes'] as String?,
    );
  }

  final String name;

  /// Expected parser output. Fields left out of the JSON take their defaults.
  final ParsedReceipt receipt;

  /// Expected category of each item, in the order of `receipt.items`.
  final List<String?> categories;

  /// Clean transcription of the printed receipt, one row per line.
  final List<String>? rows;

  /// Rows in the item section that are not items.
  final List<String> ignoredRows;

  final String? notes;
}
