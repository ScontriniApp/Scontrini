/// Guesses a product's category from its name as printed on a receipt,
/// with keywords (see `default_categories.dart`).
///
/// A keyword matches at the start of a word of the upper-case name, so a
/// stem catches the abbreviations receipts print (`MOZZ` → `MOZZ.TRIS`,
/// `MOZZARELLA`). When several keywords match, the one that comes first in
/// the name wins (Italian product names start with the product: `PETTO DI
/// POLLO A FETTE`, `PANINI AL LATTE`); at the same position the longer,
/// more specific one wins (`PATATINE DA FORNO` over `PATAT`).
class CategoryClassifier<C> {
  /// [keywords] maps each keyword to its category.
  new(Map<String, C> keywords)
    : _keywords = [
        for (final MapEntry(:key, :value) in keywords.entries)
          // A trailing space is part of the keyword: `SH ` is shampoo,
          // not the start of `SHIN RAMYUN`.
          if (key.trim().isNotEmpty)
            (
              RegExp('(?:^|[^A-Z])(${RegExp.escape(key.toUpperCase())})'),
              key.length,
              value,
            ),
      ];

  final List<(RegExp, int, C)> _keywords;

  /// The category of [name], or `null` when no keyword matches.
  C? classify(String name) {
    final upper = name.toUpperCase();
    C? best;
    var bestAt = 1 << 30;
    var bestLength = 0;
    for (final (pattern, length, category) in _keywords) {
      final match = pattern.firstMatch(upper);
      if (match == null) continue;
      final at = match.start + match.group(0)!.length - length;
      if (at < bestAt || (at == bestAt && length > bestLength)) {
        best = category;
        bestAt = at;
        bestLength = length;
      }
    }
    return best;
  }
}
