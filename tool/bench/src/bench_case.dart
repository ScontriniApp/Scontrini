import 'dart:io';

import 'package:path/path.dart' as p;

/// What a benchmark case is read from.
enum InputKind {
  /// A PDF: text layer, or ML Kit on rendered pages when scanned.
  pdf,

  /// One or more photos: ML Kit (device only).
  image,

  /// A saved `OcrDocument` (`<name>.ocr.json`) from an earlier device run.
  /// Replays ML Kit's output on the PC without the phone.
  ocrJson,
}

/// One receipt to run through the pipeline.
class BenchCase {
  const new(this.name, this.kind, this.files, {this.group});

  /// File name without extension (and without the `.pN` page suffix). The
  /// ground truth is looked up by this name.
  final String name;
  final InputKind kind;

  /// Input files; several only for multi-page photos, in page order.
  final List<String> files;

  /// Label used to group cases in the summary, e.g. which OCR engine produced
  /// the text. Defaults to the input kind.
  final String? group;

  String get groupLabel => group ?? kind.name;

  BenchCase withGroup(String group) =>
      BenchCase(name, kind, files, group: group);
}

final _imageRe = RegExp(
  r'^(.+?)(?:\.p(\d+))?\.(jpe?g|png|webp|bmp)$',
  caseSensitive: false,
);

/// Finds the cases in [dir] whose kind is in [kinds].
///
/// Photos are `<name>.jpg`, or `<name>.p1.jpg`, `<name>.p2.jpg`, ... for a
/// receipt photographed in several parts. Results are sorted by name.
List<BenchCase> discoverCases(String dir, Set<InputKind> kinds) {
  final directory = Directory(dir);
  if (!directory.existsSync()) return const [];
  final pdfs = <BenchCase>[];
  final ocr = <BenchCase>[];
  final pages = <String, List<(int, String)>>{};

  for (final file in directory.listSync().whereType<File>()) {
    final base = p.basename(file.path);
    final lower = base.toLowerCase();
    if (lower.endsWith('.pdf')) {
      pdfs.add(
        BenchCase(p.basenameWithoutExtension(base), InputKind.pdf, [file.path]),
      );
    } else if (lower.endsWith('.ocr.json')) {
      ocr.add(
        BenchCase(
          base.substring(0, base.length - '.ocr.json'.length),
          InputKind.ocrJson,
          [file.path],
        ),
      );
    } else if (_imageRe.firstMatch(base) case final m?) {
      (pages[m[1]!] ??= []).add((int.tryParse(m[2] ?? '') ?? 0, file.path));
    }
  }

  final images = [
    for (final MapEntry(:key, :value) in pages.entries)
      BenchCase(key, InputKind.image, [
        for (final (_, path) in value..sort((a, b) => a.$1.compareTo(b.$1)))
          path,
      ]),
  ];

  return [
    if (kinds.contains(InputKind.pdf)) ...pdfs,
    if (kinds.contains(InputKind.image)) ...images,
    if (kinds.contains(InputKind.ocrJson)) ...ocr,
  ]..sort((a, b) => a.name.compareTo(b.name));
}
