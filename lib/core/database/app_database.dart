import 'package:drift/drift.dart';
import 'package:scontrini/core/database/default_categories.dart';
import 'package:scontrini/core/database/tables/tables.dart';

export 'package:scontrini/core/database/tables/tables.dart' show ReceiptStatus;

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
  ],
)
class AppDatabase extends _$AppDatabase {
  new(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedCategories();
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
