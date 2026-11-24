import 'package:drift/drift.dart';
import 'package:scontrini/core/database/category_classifier.dart';
import 'package:scontrini/core/database/default_categories.dart';
import 'package:scontrini/core/database/product_linker.dart';
import 'package:scontrini/core/database/tables/tables.dart';

export 'package:scontrini/core/database/tables/tables.dart'
    show PantryEventKind, PantryEventReason, PantrySource, ReceiptStatus;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Stores,
    Categories,
    Products,
    ProductAliases,
    CategoryKeywords,
    Receipts,
    ReceiptItems,
    PantryLots,
    PantryEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  new(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedCategories();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Pantry: lots, their event log, and the links to receipts/products.
        // Receipts: transaction hash. SQLite cannot add a UNIQUE column, so
        // the receipts table is rebuilt.
        await m.alterTable(
          TableMigration(receipts, newColumns: [receipts.transactionHash]),
        );
        await m.createTable(pantryLots);
        await m.createTable(pantryEvents);
        await m.addColumn(products, products.trackInPantry);
        await m.addColumn(receiptItems, receiptItems.unit);
        await m.addColumn(receiptItems, receiptItems.pantryLotId);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await syncCategoryKeywords();
      await categorizeUnclassified();
      await linkProducts();
    },
  );

  /// Makes `category_keywords` match [defaultCategories] (keywords added,
  /// moved or removed in an update reach existing installs), adding any
  /// seed category that is missing. User corrections will live in
  /// `product_aliases`, never in this table.
  Future<void> syncCategoryKeywords() => transaction(() async {
    final ids = {for (final c in await select(categories).get()) c.name: c.id};
    for (final seed in defaultCategories) {
      ids[seed.name] ??= await into(categories).insert(
        CategoriesCompanion.insert(
          name: seed.name,
          icon: Value(seed.icon),
          color: Value(seed.color),
        ),
      );
    }
    await delete(categoryKeywords).go();
    await batch(
      (b) => b.insertAll(categoryKeywords, [
        for (final seed in defaultCategories)
          for (final keyword in seed.keywords)
            CategoryKeywordsCompanion.insert(
              keyword: keyword,
              categoryId: ids[seed.name]!,
            ),
      ]),
    );
  });

  /// The keyword classifier over the current `category_keywords`.
  Future<CategoryClassifier<int>> categoryClassifier() async =>
      CategoryClassifier({
        for (final k in await select(categoryKeywords).get())
          k.keyword: k.categoryId,
      });

  /// Gives a category to receipt rows and pantry lots that have none
  /// (saved before the keywords knew them).
  Future<void> categorizeUnclassified() => transaction(() async {
    final classifier = await categoryClassifier();
    final rows = await (select(
      receiptItems,
    )..where((r) => r.categoryId.isNull())).get();
    for (final row in rows) {
      final category = classifier.classify(row.rawName);
      if (category == null) continue;
      await (update(receiptItems)..where((r) => r.id.equals(row.id))).write(
        ReceiptItemsCompanion(categoryId: Value(category)),
      );
    }
    final lots = await (select(
      pantryLots,
    )..where((l) => l.categoryId.isNull())).get();
    for (final lot in lots) {
      final category = classifier.classify(lot.name);
      if (category == null) continue;
      await (update(pantryLots)..where((l) => l.id.equals(lot.id))).write(
        PantryLotsCompanion(categoryId: Value(category)),
      );
    }
  });

  /// Links printed names to products (see [ProductLinker]).
  Future<ProductLinker> productLinker() => ProductLinker.load(this);

  /// Links receipt rows and pantry lots saved without a product (before
  /// products were linked on save): rows by their printed name, lots
  /// through their receipt rows, else by their name.
  Future<void> linkProducts() => transaction(() async {
    final linker = await productLinker();
    final rows =
        await (select(receiptItems)
              ..where((r) => r.productId.isNull())
              ..orderBy([(r) => OrderingTerm.asc(r.id)]))
            .get();
    for (final row in rows) {
      final id = (await linker.link(
        row.rawName,
        categoryId: row.categoryId,
        unit: row.unit,
      ))?.id;
      if (id == null) continue;
      await (update(receiptItems)..where((r) => r.id.equals(row.id))).write(
        ReceiptItemsCompanion(productId: Value(id)),
      );
    }
    final lots = await (select(
      pantryLots,
    )..where((l) => l.productId.isNull())).get();
    for (final lot in lots) {
      final row =
          await (select(receiptItems)
                ..where(
                  (r) => r.pantryLotId.equals(lot.id) & r.productId.isNotNull(),
                )
                ..limit(1))
              .getSingleOrNull();
      final id =
          row?.productId ??
          (await linker.link(
            lot.name,
            categoryId: lot.categoryId,
            unit: lot.unit,
          ))?.id;
      if (id == null) continue;
      await (update(pantryLots)..where((l) => l.id.equals(lot.id))).write(
        PantryLotsCompanion(productId: Value(id)),
      );
    }
  });

  Future<void> _seedCategories() async {
    for (final seed in defaultCategories) {
      final id = await into(categories).insert(
        CategoriesCompanion.insert(
          name: seed.name,
          icon: Value(seed.icon),
          color: Value(seed.color),
        ),
      );
      await batch(
        (b) => b.insertAll(categoryKeywords, [
          for (final keyword in seed.keywords)
            CategoryKeywordsCompanion.insert(keyword: keyword, categoryId: id),
        ]),
      );
    }
  }
}
