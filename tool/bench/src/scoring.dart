import 'dart:math' as math;

import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:string_similarity/string_similarity.dart';

/// Upper case, punctuation turned into spaces, spaces collapsed. Used to
/// compare names and addresses without caring about `*`, `.` or spacing.
String normalizeName(String text) =>
    text.toUpperCase().replaceAll(RegExp('[^A-Z0-9À-Ý%]+'), ' ').trim();

/// Upper case with whitespace collapsed: the strict comparison for rows.
String normalizeRow(String text) =>
    text.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();

/// Levenshtein edit distance.
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }
  return previous[b.length];
}

/// 1 for identical strings, 0 for nothing in common.
double editSimilarity(String a, String b) {
  final longest = math.max(a.length, b.length);
  return longest == 0 ? 1 : 1 - levenshtein(a, b) / longest;
}

/// Length of the longest common subsequence of two row lists.
int _lcs(List<String> a, List<String> b) {
  var previous = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0);
    for (var j = 1; j <= b.length; j++) {
      current[j] = a[i - 1] == b[j - 1]
          ? previous[j - 1] + 1
          : math.max(previous[j], current[j - 1]);
    }
    previous = current;
  }
  return previous[b.length];
}

// ---------------------------------------------------------------------------
// Step 1: text extraction.

/// How well the extracted rows reproduce the clean transcription.
class TextScore {
  const new({
    required this.truthRows,
    required this.found,
    required this.inOrder,
    required this.similarity,
    required this.missing,
  });

  /// Rows in `<name>.rows.txt`.
  final int truthRows;

  /// Truth rows that appear exactly (case and spacing aside) in the output.
  final int found;

  /// Longest run of truth rows found in the same order: rows on the wrong
  /// line (e.g. a discount next to the wrong item) lower this.
  final int inOrder;

  /// Mean, over truth rows, of the best character similarity to any
  /// extracted row (1 = perfect).
  final double similarity;

  /// Truth rows not found exactly, with the closest extracted row.
  final List<({String expected, String closest})> missing;

  Map<String, Object?> toJson() => {
    'truthRows': truthRows,
    'found': found,
    'inOrder': inOrder,
    'similarity': similarity,
    'missing': [
      for (final m in missing) {'expected': m.expected, 'closest': m.closest},
    ],
  };
}

TextScore scoreText(List<String> truthRows, List<String> extractedRows) {
  final truth = truthRows.map(normalizeRow).toList();
  final extracted = extractedRows.map(normalizeRow).toList();
  final available = <String, int>{};
  for (final row in extracted) {
    available[row] = (available[row] ?? 0) + 1;
  }

  var found = 0;
  var similaritySum = 0.0;
  final missing = <({String expected, String closest})>[];
  for (final row in truth) {
    final left = available[row] ?? 0;
    if (left > 0) {
      available[row] = left - 1;
      found++;
      similaritySum += 1;
      continue;
    }
    var best = 0.0;
    var closest = '';
    for (final candidate in extracted) {
      final s = editSimilarity(row, candidate);
      if (s > best) {
        best = s;
        closest = candidate;
      }
    }
    similaritySum += best;
    missing.add((expected: row, closest: closest));
  }

  return TextScore(
    truthRows: truth.length,
    found: found,
    inOrder: _lcs(truth, extracted),
    similarity: truth.isEmpty ? 1 : similaritySum / truth.length,
    missing: missing,
  );
}

// ---------------------------------------------------------------------------
// Step 2: parsing.

/// Outcome of comparing one value with the expected one.
enum FieldResult {
  correct,
  wrong,

  /// Expected a value, got none.
  missing,
}

/// Header fields compared for every receipt, in report order.
const headerFields = [
  'storeName',
  'vatNumber',
  'address',
  'purchaseDate',
  'totalCents',
  'discountCents',
];

/// Item fields checked on matched items, in report order.
const itemFields = [
  'name',
  'lineTotal',
  'discount',
  'quantity',
  'unit',
  'unitPrice',
];

/// Comparison of a parsed receipt with its ground truth.
class ParseScore {
  const new({
    required this.fields,
    required this.expectedItems,
    required this.parsedItems,
    required this.matchedItems,
    required this.correctItems,
    required this.itemFieldErrors,
    required this.balanced,
    required this.mismatches,
  });

  final Map<String, FieldResult> fields;
  final int expectedItems;
  final int parsedItems;

  /// Expected items paired with a parsed item (by name and price).
  final int matchedItems;

  /// Matched items with every field right.
  final int correctItems;

  /// Per item field (see [itemFields]), how many matched items got it wrong.
  final Map<String, int> itemFieldErrors;

  /// Whether the parsed items add up to the parsed total.
  final bool balanced;

  /// Human-readable list of every difference.
  final List<String> mismatches;

  int get missingItems => expectedItems - matchedItems;
  int get extraItems => parsedItems - matchedItems;

  bool get perfect =>
      fields.values.every((r) => r == FieldResult.correct) &&
      correctItems == expectedItems &&
      extraItems == 0;

  Map<String, Object?> toJson() => {
    'fields': {for (final e in fields.entries) e.key: e.value.name},
    'expectedItems': expectedItems,
    'parsedItems': parsedItems,
    'matchedItems': matchedItems,
    'correctItems': correctItems,
    'itemFieldErrors': itemFieldErrors,
    'balanced': balanced,
    'perfect': perfect,
    'mismatches': mismatches,
  };
}

String _cents(int? cents) => cents == null
    ? '-'
    : '${cents < 0 ? '-' : ''}${cents.abs() ~/ 100},'
          '${(cents.abs() % 100).toString().padLeft(2, '0')}';

FieldResult _compare(Object? expected, Object? actual) {
  if (expected == actual) return FieldResult.correct;
  if (actual == null) return FieldResult.missing;
  return FieldResult.wrong;
}

ParseScore scoreParse(ParsedReceipt expected, ParsedReceipt actual) {
  final mismatches = <String>[];

  String? name(String? s) => s == null ? null : normalizeName(s);
  final fields = <String, FieldResult>{
    'storeName': _compare(name(expected.storeName), name(actual.storeName)),
    'vatNumber': _compare(expected.vatNumber, actual.vatNumber),
    'address': _compare(name(expected.address), name(actual.address)),
    'purchaseDate': _compare(expected.purchaseDate, actual.purchaseDate),
    'totalCents': _compare(expected.totalCents, actual.totalCents),
    'discountCents': _compare(expected.discountCents, actual.discountCents),
  };
  final shown = <String, (Object?, Object?)>{
    'storeName': (expected.storeName, actual.storeName),
    'vatNumber': (expected.vatNumber, actual.vatNumber),
    'address': (expected.address, actual.address),
    'purchaseDate': (expected.purchaseDate, actual.purchaseDate),
    'totalCents': (_cents(expected.totalCents), _cents(actual.totalCents)),
    'discountCents': (
      _cents(expected.discountCents),
      _cents(actual.discountCents),
    ),
  };
  for (final MapEntry(:key, :value) in fields.entries) {
    if (value == FieldResult.correct) continue;
    final (want, got) = shown[key]!;
    mismatches.add('$key: expected "$want", got "${got ?? '-'}"');
  }

  final pairs = matchItems(expected.items, actual.items);
  final matchedActual = <int>{};
  final itemFieldErrors = {for (final f in itemFields) f: 0};
  var correctItems = 0;

  for (final (i, want) in expected.items.indexed) {
    final j = pairs[i];
    if (j == null) {
      mismatches.add(
        'missing item "${want.rawName}" ${_cents(want.lineTotalCents)}',
      );
      continue;
    }
    matchedActual.add(j);
    final got = actual.items[j];
    // Keys are the names in [itemFields].
    final errors = <String, String>{
      if (normalizeName(want.rawName) != normalizeName(got.rawName))
        'name': 'name "${got.rawName}"',
      if (want.lineTotalCents != got.lineTotalCents)
        'lineTotal':
            'line total ${_cents(got.lineTotalCents)} '
            '(expected ${_cents(want.lineTotalCents)})',
      if (want.discountCents != got.discountCents)
        'discount':
            'discount ${_cents(got.discountCents)} '
            '(expected ${_cents(want.discountCents)})',
      if ((want.quantity - got.quantity).abs() > 0.0005)
        'quantity': 'quantity ${got.quantity} (expected ${want.quantity})',
      if (want.unit != got.unit)
        'unit': 'unit ${got.unit.name} (expected ${want.unit.name})',
      if (want.unitPriceCents != got.unitPriceCents)
        'unitPrice':
            'unit price ${_cents(got.unitPriceCents)} '
            '(expected ${_cents(want.unitPriceCents)})',
    };
    if (errors.isEmpty) {
      correctItems++;
    } else {
      for (final field in errors.keys) {
        itemFieldErrors[field] = itemFieldErrors[field]! + 1;
      }
      mismatches.add('item "${want.rawName}": ${errors.values.join(', ')}');
    }
  }
  for (final (j, got) in actual.items.indexed) {
    if (!matchedActual.contains(j)) {
      mismatches.add(
        'extra item "${got.rawName}" ${_cents(got.lineTotalCents)}',
      );
    }
  }

  return ParseScore(
    fields: fields,
    expectedItems: expected.items.length,
    parsedItems: actual.items.length,
    matchedItems: matchedActual.length,
    correctItems: correctItems,
    itemFieldErrors: itemFieldErrors,
    balanced: actual.totalCents != null && actual.isBalanced,
    mismatches: mismatches,
  );
}

/// Pairs each expected item with at most one parsed item.
///
/// Items are matched on name similarity, helped by an equal line total, so a
/// single missed row does not shift every later item. Among equally good
/// pairs the one closest in position wins (repeated products stay in order).
/// Returns, for each expected index, the parsed index or `null`.
List<int?> matchItems(List<ParsedItem> expected, List<ParsedItem> actual) {
  final candidates = <(double, int, int)>[];
  for (final (i, want) in expected.indexed) {
    final wantName = normalizeName(want.rawName);
    for (final (j, got) in actual.indexed) {
      final similarity = StringSimilarity.compareTwoStrings(
        wantName,
        normalizeName(got.rawName),
      );
      final samePrice = want.lineTotalCents == got.lineTotalCents;
      if (similarity < 0.5 && !(samePrice && similarity >= 0.25)) continue;
      final positionPenalty =
          (i / math.max(1, expected.length) - j / math.max(1, actual.length))
              .abs() *
          0.01;
      candidates.add((
        similarity + (samePrice ? 0.5 : 0) - positionPenalty,
        i,
        j,
      ));
    }
  }
  candidates.sort((a, b) => b.$1.compareTo(a.$1));

  final result = List<int?>.filled(expected.length, null);
  final used = <int>{};
  for (final (_, i, j) in candidates) {
    if (result[i] != null || used.contains(j)) continue;
    result[i] = j;
    used.add(j);
  }
  return result;
}

// ---------------------------------------------------------------------------
// Step 3: categories.

/// Assigns a category name to a raw item name, or `null` if it can't tell.
typedef CategoryClassifier = String? Function(String rawName);

/// Accuracy of a classifier on the expected item names of one receipt.
///
/// Runs on the ground-truth names, so it measures the classifier alone,
/// independently of the parser.
class CategoryScore {
  const new({
    required this.total,
    required this.answered,
    required this.correct,
    required this.errors,
  });

  final int total;

  /// Items for which the classifier gave a category.
  final int answered;
  final int correct;

  /// `name: expected → predicted` for every wrong or missing answer.
  final List<String> errors;

  Map<String, Object?> toJson() => {
    'total': total,
    'answered': answered,
    'correct': correct,
    'errors': errors,
  };
}

CategoryScore scoreCategories(
  List<ParsedItem> items,
  List<String?> expected,
  CategoryClassifier classify,
) {
  var total = 0;
  var answered = 0;
  var correct = 0;
  final errors = <String>[];
  for (final (i, item) in items.indexed) {
    final want = i < expected.length ? expected[i] : null;
    if (want == null) continue;
    total++;
    final got = classify(item.rawName);
    if (got != null) answered++;
    if (got == want) {
      correct++;
    } else {
      errors.add('${item.rawName}: $want → ${got ?? '-'}');
    }
  }
  return CategoryScore(
    total: total,
    answered: answered,
    correct: correct,
    errors: errors,
  );
}
