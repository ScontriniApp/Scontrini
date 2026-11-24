import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/receipts/domain/product_matcher.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';

/// Stores receipts: [saveConfirmed] is what the review screen's "confirm"
/// calls, once the user has corrected what was read.
class ReceiptRepository {
  new(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Saves [receipt] as confirmed, with its store, rows and transaction
  /// hash, and returns its id. The same receipt saved again (same hash)
  /// returns the existing id instead of a duplicate.
  ///
  /// A receipt whose date wasn't read is dated now (the capture). A total
  /// that wasn't read is the rows' sum. Rows get the categories in
  /// [categoryIds] (same order, as chosen in the review; `null` means
  /// uncategorised). Without [categoryIds] they get one from the keywords
  /// table (`CategoryClassifier`), else their product's.
  ///
  /// Every row is linked to a product (`ProductMatcher`): the one with the
  /// same label (canonical name or alias), or else a new product named after
  /// the row, with the row's category and unit. Different labels are never
  /// merged.
  Future<int> saveConfirmed(
    ParsedReceipt receipt, {
    List<int?>? categoryIds,
    String? sourcePath,
    String? rawOcrText,
  }) => _db.transaction(() async {
    final purchaseDate = receipt.purchaseDate ?? _clock();
    final total = receipt.totalCents ?? receipt.computedTotalCents;
    final hash = transactionHash(
      purchaseDate: purchaseDate,
      totalCents: total,
      vatNumber: receipt.vatNumber,
      storeName: receipt.storeName,
    );
    final existing = await (_db.select(
      _db.receipts,
    )..where((r) => r.transactionHash.equals(hash))).getSingleOrNull();
    if (existing != null) return existing.id;

    final receiptId = await _db
        .into(_db.receipts)
        .insert(
          ReceiptsCompanion.insert(
            storeId: Value(await _storeId(receipt)),
            purchaseDate: purchaseDate.toUtc(),
            totalCents: total,
            discountCents: Value(receipt.discountCents),
            sourcePath: Value(sourcePath),
            rawOcrText: Value(rawOcrText),
            status: ReceiptStatus.confirmed,
            transactionHash: Value(hash),
          ),
        );
    final classifier = await _db.categoryClassifier();
    final products = await _ProductLinker.load(_db);
    for (final (i, item) in receipt.items.indexed) {
      final unit = unitCode(item.unit);
      final chosen = categoryIds != null;
      final category = chosen
          ? (i < categoryIds.length ? categoryIds[i] : null)
          : classifier.classify(item.rawName);
      final product = await products.link(
        item.rawName,
        unit: unit,
        categoryId: category,
      );
      await _db
          .into(_db.receiptItems)
          .insert(
            ReceiptItemsCompanion.insert(
              receiptId: receiptId,
              productId: Value(product.id),
              rawName: item.rawName,
              quantity: Value(item.quantity),
              unit: Value(unit),
              unitPriceCents: item.unitPriceCents,
              lineTotalCents: item.lineTotalCents,
              discountCents: Value(item.discountCents),
              categoryId: Value(
                chosen ? category : category ?? product.categoryId,
              ),
            ),
          );
    }
    return receiptId;
  });

  /// The category of each name: the product's with that label (chosen in
  /// an earlier review), else the keywords table's. What the review screen
  /// shows before the user changes it.
  Future<List<int?>> guessCategories(List<String> names) async {
    final classifier = await _db.categoryClassifier();
    final products = await _db.select(_db.products).get();
    final aliases = await _db.select(_db.productAliases).get();
    final matcher = ProductMatcher(
      products: [
        for (final p in products)
          MatchableProduct(id: p.id, canonicalName: p.canonicalName),
      ],
      aliases: {for (final a in aliases) a.rawName: a.productId},
    );
    final categoryOf = {for (final p in products) p.id: p.categoryId};
    return [
      for (final name in names)
        categoryOf[matcher.match(name)] ?? classifier.classify(name),
    ];
  }

  /// The `receipt_items.unit` code of [unit].
  static String unitCode(QuantityUnit unit) => switch (unit) {
    QuantityUnit.piece => 'pz',
    QuantityUnit.kilogram => 'kg',
    QuantityUnit.litre => 'l',
  };

  /// The store with the receipt's VAT number, else its name; created when
  /// new. `null` when the receipt names no store.
  Future<int?> _storeId(ParsedReceipt receipt) async {
    final vat = receipt.vatNumber;
    final name = receipt.storeName;
    if (vat == null && name == null) return null;
    final found =
        await (_db.select(_db.stores)..where(
              (s) =>
                  vat != null ? s.vatNumber.equals(vat) : s.name.equals(name!),
            ))
            .getSingleOrNull();
    if (found != null) return found.id;
    return await _db
        .into(_db.stores)
        .insert(
          StoresCompanion.insert(
            name: name ?? vat!,
            vatNumber: Value(vat),
            address: Value(receipt.address),
          ),
        );
  }
}

/// Links receipt rows to products within one save: the matcher over the
/// stored products and aliases, kept up to date as rows add new ones.
class _ProductLinker {
  new _(this._db, this._matcher, this._categories);

  static Future<_ProductLinker> load(AppDatabase db) async {
    final products = await db.select(db.products).get();
    final aliases = await db.select(db.productAliases).get();
    return _ProductLinker._(
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

  /// The product labelled [rawName], or a new one with [unit] and
  /// [categoryId].
  Future<({int id, int? categoryId})> link(
    String rawName, {
    required String unit,
    required int? categoryId,
  }) async {
    final match = _matcher.match(rawName);
    if (match != null) return (id: match, categoryId: _categories[match]);

    final name = ProductMatcher.normalise(rawName);
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
