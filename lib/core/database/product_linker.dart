import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/product_matcher.dart';

/// Links printed names to products in the database: the [ProductMatcher]
/// over the stored products and aliases, kept up to date as [link] creates
/// new products. One per save (or backfill); get it from
/// `AppDatabase.productLinker`.
class ProductLinker {
  new _(this._db, this._matcher, this._categories);

  static Future<ProductLinker> load(AppDatabase db) async {
    final products = await db.select(db.products).get();
    final aliases = await db.select(db.productAliases).get();
    return ProductLinker._(
      db,
      ProductMatcher(
        products: [
          for (final p in products)
            MatchableProduct(id: p.id, canonicalName: p.canonicalName),
        ],
        aliases: {for (final a in aliases) a.rawName: a.productId},
      ),
      {for (final p in products) p.id: p.categoryId},
    );
  }

  final AppDatabase _db;
  final ProductMatcher _matcher;

  /// Product id → category id.
  final Map<int, int?> _categories;

  /// The product labelled [rawName], if there is one.
  int? match(String rawName) => _matcher.match(rawName);

  /// The category of product [productId] (chosen when it was created or
  /// in an earlier review).
  int? categoryOf(int? productId) => _categories[productId];

  /// The product labelled [rawName], else a new one named after it (as
  /// printed, trimmed) with [unit] and [categoryId]. `null` for a name with
  /// no letters or digits.
  Future<({int id, int? categoryId})?> link(
    String rawName, {
    String? unit,
    int? categoryId,
  }) async {
    final match = _matcher.match(rawName);
    if (match != null) return (id: match, categoryId: _categories[match]);
    if (ProductMatcher.normalise(rawName).isEmpty) return null;

    final name = rawName.trim();
    final id = await _db
        .into(_db.products)
        .insert(
          ProductsCompanion.insert(
            canonicalName: name,
            categoryId: Value(categoryId),
            unit: Value(unit),
          ),
        );
    _matcher.add(MatchableProduct(id: id, canonicalName: name));
    _categories[id] = categoryId;
    return (id: id, categoryId: categoryId);
  }
}
