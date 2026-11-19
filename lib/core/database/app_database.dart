import 'package:drift/drift.dart';
import 'package:scontrini/core/database/default_categories.dart';
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
        await m.createTable(pantryLots);
        await m.createTable(pantryEvents);
        await m.addColumn(products, products.trackInPantry);
        await m.addColumn(receiptItems, receiptItems.unit);
        await m.addColumn(receiptItems, receiptItems.pantryLotId);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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
