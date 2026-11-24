/// A product the matcher can link receipt rows to.
class MatchableProduct {
  const new({required this.id, required this.canonicalName});

  final int id;
  final String canonicalName;
}

/// Links a raw name printed on a receipt to a canonical product, so the
/// same product bought on different receipts counts as one in price trends
/// and frequency (M5–M7).
///
/// Pure Dart: the repository loads the products and aliases, asks for a
/// match, and creates a product (then [add]s it) when there is none.
///
/// Only the same label matches: a name joins a product when its normalised
/// form (case and spacing ignored) is the product's canonical name or one
/// of its aliases. Different labels stay different products, however close
/// they look; only the user merges them (by adding an alias).
class ProductMatcher {
  new({
    Iterable<MatchableProduct> products = const [],
    Map<String, int> aliases = const {},
  }) {
    products.forEach(add);
    aliases.forEach(addAlias);
  }

  final _productIds = <int>{};

  /// Normalised name → product id: aliases and canonical names.
  final _names = <String, int>{};

  /// Upper-case, single-spaced and trimmed: `latte  ps 1l` → `LATTE PS 1L`.
  static String normalise(String name) =>
      name.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Makes [product] matchable by its canonical name.
  void add(MatchableProduct product) {
    _productIds.add(product.id);
    _names.putIfAbsent(normalise(product.canonicalName), () => product.id);
  }

  /// Makes [rawName] match [productId]. Ignored for an unknown product.
  void addAlias(String rawName, int productId) {
    if (!_productIds.contains(productId)) return;
    _names.putIfAbsent(normalise(rawName), () => productId);
  }

  /// The id of the product labelled [rawName], or `null` when none is.
  int? match(String rawName) {
    final name = normalise(rawName);
    return name.isEmpty ? null : _names[name];
  }
}
