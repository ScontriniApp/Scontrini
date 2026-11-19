import 'dart:convert';

import 'bench_runner.dart';
import 'scoring.dart';

/// Totals of a run, the console summary and the JSON report.
class BenchReport {
  new({
    required this.label,
    required this.results,
    required this.startedAt,
    this.classifierName,
  });

  /// Where the run happened, e.g. `pdf-desktop` or `device`.
  final String label;
  final List<CaseResult> results;
  final DateTime startedAt;
  final String? classifierName;

  List<CaseResult> get _scored =>
      results.where((r) => r.parse != null).toList();

  Map<String, Object?> toJson() => {
    'label': label,
    'startedAt': startedAt.toIso8601String(),
    'classifier': classifierName,
    'summary': _summaryJson(),
    'cases': [for (final r in results) r.toJson()],
  };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> _summaryJson() {
    final scored = _scored;
    return {
      'cases': results.length,
      'withTruth': results.where((r) => r.hasTruth).length,
      'errors': results.where((r) => r.error != null).length,
      'text': _textTotals(),
      'parse': _parseTotals([for (final r in scored) r.parse!]),
      'cleanParse': _parseTotals([
        for (final r in scored)
          if (r.cleanParse != null) r.cleanParse!,
      ]),
      'categories': _categoryTotals(),
    };
  }

  Map<String, num> _textTotals() {
    final scores = [
      for (final r in results)
        if (r.text != null) r.text!,
    ];
    return {
      'receipts': scores.length,
      'truthRows': scores.fold<int>(0, (s, t) => s + t.truthRows),
      'found': scores.fold<int>(0, (s, t) => s + t.found),
      'inOrder': scores.fold<int>(0, (s, t) => s + t.inOrder),
      'similarity': scores.isEmpty
          ? 0
          : scores.fold<double>(0, (s, t) => s + t.similarity) / scores.length,
    };
  }

  static Map<String, Object?> _parseTotals(List<ParseScore> scores) => {
    'receipts': scores.length,
    'fields': {
      for (final f in headerFields)
        f: scores.where((s) => s.fields[f] == FieldResult.correct).length,
    },
    'expectedItems': scores.fold<int>(0, (s, p) => s + p.expectedItems),
    'parsedItems': scores.fold<int>(0, (s, p) => s + p.parsedItems),
    'matchedItems': scores.fold<int>(0, (s, p) => s + p.matchedItems),
    'correctItems': scores.fold<int>(0, (s, p) => s + p.correctItems),
    'itemFieldErrors': {
      for (final f in itemFields)
        f: scores.fold<int>(0, (s, p) => s + p.itemFieldErrors[f]!),
    },
    'balanced': scores.where((s) => s.balanced).length,
    'perfect': scores.where((s) => s.perfect).length,
  };

  Map<String, int> _categoryTotals() {
    final scores = [
      for (final r in results)
        if (r.categories != null) r.categories!,
    ];
    return {
      'total': scores.fold<int>(0, (s, c) => s + c.total),
      'answered': scores.fold<int>(0, (s, c) => s + c.answered),
      'correct': scores.fold<int>(0, (s, c) => s + c.correct),
    };
  }

  /// Console summary: one block per step, then the worst receipts.
  String summary({int worst = 8}) {
    final b = StringBuffer();
    final scored = _scored;
    final errors = results.where((r) => r.error != null).toList();
    b
      ..writeln()
      ..writeln(
        '=== Benchmark "$label" · ${results.length} receipts, '
        '${results.where((r) => r.hasTruth).length} with answers, '
        '${errors.length} errors ===',
      );

    final text = _textTotals();
    if (text['receipts'] != 0) {
      final rows = text['truthRows']! as int;
      b
        ..writeln()
        ..writeln('STEP 1 · text extraction (${text['receipts']} receipts)')
        ..writeln(
          _line('rows found exactly', _pct(text['found']! as int, rows)),
        )
        ..writeln(
          _line('rows in the right order', _pct(text['inOrder']! as int, rows)),
        )
        ..writeln(
          _line(
            'character similarity',
            '${((text['similarity']! as double) * 100).toStringAsFixed(1)}%',
          ),
        );
    }

    if (scored.isNotEmpty) {
      final real = [for (final r in scored) r.parse!];
      final clean = [
        for (final r in scored)
          if (r.cleanParse != null) r.cleanParse!,
      ];
      final n = real.length;
      final m = clean.length;
      String both(
        int Function(List<ParseScore>) count,
        int Function(List<ParseScore>) of,
      ) =>
          '${_pct(count(real), of(real)).padRight(18)}'
          '${clean.isEmpty ? '' : _pct(count(clean), of(clean))}';
      int field(List<ParseScore> s, String f) =>
          s.where((p) => p.fields[f] == FieldResult.correct).length;
      int sum(List<ParseScore> s, int Function(ParseScore) f) =>
          s.fold(0, (acc, p) => acc + f(p));

      b
        ..writeln()
        ..writeln('STEP 2 · parsing ($n receipts)')
        ..writeln(
          _line('', '${'pipeline'.padRight(18)}${m == 0 ? '' : 'clean rows'}'),
        );
      for (final f in headerFields) {
        b.writeln(_line(f, both((s) => field(s, f), (s) => s.length)));
      }
      b
        ..writeln(
          _line(
            'items found',
            both(
              (s) => sum(s, (p) => p.matchedItems),
              (s) => sum(s, (p) => p.expectedItems),
            ),
          ),
        )
        ..writeln(
          _line(
            'items invented',
            both(
              (s) => sum(s, (p) => p.extraItems),
              (s) => sum(s, (p) => p.parsedItems),
            ),
          ),
        )
        ..writeln(
          _line(
            'items fully correct',
            both(
              (s) => sum(s, (p) => p.correctItems),
              (s) => sum(s, (p) => p.expectedItems),
            ),
          ),
        );
      for (final f in itemFields) {
        b.writeln(
          _line(
            '  wrong $f',
            both(
              (s) => sum(s, (p) => p.itemFieldErrors[f]!),
              (s) => sum(s, (p) => p.matchedItems),
            ),
          ),
        );
      }
      b
        ..writeln(
          _line(
            'balanced (items = total)',
            both((s) => s.where((p) => p.balanced).length, (s) => s.length),
          ),
        )
        ..writeln(
          _line(
            'perfect receipts',
            both((s) => s.where((p) => p.perfect).length, (s) => s.length),
          ),
        );
    }

    final categories = _categoryTotals();
    if (categories['total']! > 0) {
      final total = categories['total']!;
      b
        ..writeln()
        ..writeln(
          'STEP 3 · categories (${classifierName ?? 'classifier'}, '
          'on the expected names)',
        )
        ..writeln(_line('answered', _pct(categories['answered']!, total)))
        ..writeln(_line('correct', _pct(categories['correct']!, total)));
    }

    final timed = results.where((r) => r.error == null).toList();
    if (timed.isNotEmpty) {
      final extract = timed.fold(0, (s, r) => s + r.extractMs) / timed.length;
      final parse = timed.fold(0, (s, r) => s + r.parseMs) / timed.length;
      b
        ..writeln()
        ..writeln(
          'TIME · extraction ${extract.toStringAsFixed(0)} ms, '
          'rows + parsing ${parse.toStringAsFixed(1)} ms per receipt',
        );
    }

    final ranked = [...scored]
      ..sort(
        (a, b) =>
            b.parse!.mismatches.length.compareTo(a.parse!.mismatches.length),
      );
    final bad = ranked.where((r) => r.parse!.mismatches.isNotEmpty).take(worst);
    if (bad.isNotEmpty) {
      b
        ..writeln()
        ..writeln('WORST RECEIPTS (pipeline)');
      for (final r in bad) {
        final mismatches = r.parse!.mismatches;
        b.writeln('  ${r.benchCase.name} · ${mismatches.length} differences');
        for (final m in mismatches.take(4)) {
          b.writeln('      $m');
        }
      }
    }
    for (final r in errors) {
      b.writeln('  ERROR ${r.benchCase.name}: ${r.error}');
    }
    final noTruth = results.where((r) => !r.hasTruth && r.error == null);
    if (noTruth.isNotEmpty) {
      b
        ..writeln()
        ..writeln(
          'NO ANSWER YET (parser output saved in the report): '
          '${noTruth.map((r) => r.benchCase.name).join(', ')}',
        );
    }
    return b.toString();
  }

  static String _line(String label, String value) =>
      '  ${label.padRight(26)}$value';

  static String _pct(int count, int of) => of == 0
      ? '$count/0'
      : '$count/$of (${(count * 100 / of).toStringAsFixed(1)}%)';
}
