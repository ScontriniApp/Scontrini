import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

import 'bench_case.dart';
import 'ground_truth.dart';
import 'scoring.dart';

/// Gets the text out of one case: the platform-specific part of a run.
typedef CaseExtractor = Future<OcrDocument> Function(BenchCase benchCase);

/// Everything measured for one receipt.
class CaseResult {
  const new({
    required this.benchCase,
    required this.hasTruth,
    this.error,
    this.document,
    this.rows = const [],
    this.parsed,
    this.extractMs = 0,
    this.parseMs = 0,
    this.text,
    this.parse,
    this.cleanParse,
    this.categories,
  });

  final BenchCase benchCase;
  final bool hasTruth;

  /// Set when extraction or parsing threw; the other fields are then empty.
  final String? error;

  final OcrDocument? document;
  final List<String> rows;
  final ParsedReceipt? parsed;
  final int extractMs;
  final int parseMs;

  /// Step 1: extracted rows against `<name>.rows.txt`.
  final TextScore? text;

  /// Step 2 on the real pipeline output.
  final ParseScore? parse;

  /// Step 2 with the parser fed the clean rows: parser errors only.
  final ParseScore? cleanParse;

  /// Step 3 on the ground-truth item names.
  final CategoryScore? categories;

  Map<String, Object?> toJson() => {
    'name': benchCase.name,
    'kind': benchCase.kind.name,
    'group': benchCase.groupLabel,
    'hasTruth': hasTruth,
    'error': ?error,
    'textSource': ?document?.source.name,
    'extractMs': extractMs,
    'parseMs': parseMs,
    'text': ?text?.toJson(),
    'parse': ?parse?.toJson(),
    'cleanParse': ?cleanParse?.toJson(),
    'categories': ?categories?.toJson(),
    'rows': rows,
    'parsed': ?parsed?.toJson(),
  };
}

/// Runs every case through extraction → rows → parser and scores it against
/// the ground truth in [truthDir]. Cases without ground truth are still run,
/// so their output can be reviewed and turned into new answers.
Future<List<CaseResult>> runBench({
  required List<BenchCase> cases,
  required String truthDir,
  required CaseExtractor extract,
  CategoryClassifier? classifier,
  void Function(CaseResult result)? onResult,
}) async {
  const rowBuilder = RowBuilder();
  const parser = ReceiptParser();
  final results = <CaseResult>[];

  for (final benchCase in cases) {
    final truth = GroundTruth.load(truthDir, benchCase.name);
    CaseResult result;
    try {
      final extractWatch = Stopwatch()..start();
      final document = await extract(benchCase);
      extractWatch.stop();

      final parseWatch = Stopwatch()..start();
      final rows = [for (final row in rowBuilder.build(document)) row.text];
      final parsed = parser.parseLines(rows);
      parseWatch.stop();

      final truthRows = truth?.rows;
      result = CaseResult(
        benchCase: benchCase,
        hasTruth: truth != null,
        document: document,
        rows: rows,
        parsed: parsed,
        extractMs: extractWatch.elapsedMilliseconds,
        parseMs: parseWatch.elapsedMilliseconds,
        text: truthRows == null ? null : scoreText(truthRows, rows),
        parse: truth == null ? null : scoreParse(truth.receipt, parsed),
        cleanParse: truthRows == null
            ? null
            : scoreParse(truth!.receipt, parser.parseLines(truthRows)),
        categories: truth == null || classifier == null
            ? null
            : scoreCategories(
                truth.receipt.items,
                truth.categories,
                classifier,
              ),
      );
    } on Object catch (error) {
      result = CaseResult(
        benchCase: benchCase,
        hasTruth: truth != null,
        error: '$error',
      );
    }
    results.add(result);
    onResult?.call(result);
  }
  return results;
}
