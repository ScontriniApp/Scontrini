import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/default_categories.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seeds default categories and keywords on create', () async {
    final categories = await db.select(db.categories).get();
    expect(categories, hasLength(defaultCategories.length));

    final keywords = await db.select(db.categoryKeywords).get();
    expect(keywords, isNotEmpty);
  });

  test('keywords are brought back in line with the seed on open', () async {
    final pasta = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Pane e pasta'))).getSingle();
    // An old install: a stale keyword and a missing one.
    await db
        .into(db.categoryKeywords)
        .insert(
          CategoryKeywordsCompanion.insert(
            keyword: 'OBSOLETO',
            categoryId: pasta.id,
          ),
        );
    await (db.delete(
      db.categoryKeywords,
    )..where((k) => k.keyword.equals('MOZZ'))).go();

    await db.syncCategoryKeywords();

    final keywords = {
      for (final k in await db.select(db.categoryKeywords).get()) k.keyword,
    };
    expect(keywords, {for (final c in defaultCategories) ...c.keywords});
  });

  test('rows and lots saved without a category get one on open', () async {
    final receiptId = await db
        .into(db.receipts)
        .insert(
          ReceiptsCompanion.insert(
            purchaseDate: DateTime.utc(2026, 11, 23),
            totalCents: 300,
            status: ReceiptStatus.confirmed,
          ),
        );
    Future<int> row(String name) => db
        .into(db.receiptItems)
        .insert(
          ReceiptItemsCompanion.insert(
            receiptId: receiptId,
            rawName: name,
            unitPriceCents: 100,
            lineTotalCents: 100,
          ),
        );
    final mozzarella = await row('MOZZ.TRIS SANTA LUCI');
    final unknown = await row('ARTICOLO 123');
    final lot = await db
        .into(db.pantryLots)
        .insert(
          PantryLotsCompanion.insert(
            receiptId: Value(receiptId),
            name: 'MOZZ.TRIS SANTA LUCI',
            source: PantrySource.receipt,
            initialQuantity: 1,
            addedAt: DateTime.utc(2026, 11, 23),
          ),
        );

    await db.categorizeUnclassified();

    final dairy = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Latticini e uova'))).getSingle();
    Future<int?> rowCategory(int id) async => (await (db.select(
      db.receiptItems,
    )..where((r) => r.id.equals(id))).getSingle()).categoryId;
    expect(await rowCategory(mozzarella), dairy.id);
    expect(await rowCategory(unknown), isNull);
    final savedLot = await (db.select(
      db.pantryLots,
    )..where((l) => l.id.equals(lot))).getSingle();
    expect(savedLot.categoryId, dairy.id);
  });

  test('deleting a receipt cascades to its items', () async {
    final receiptId = await db
        .into(db.receipts)
        .insert(
          ReceiptsCompanion.insert(
            purchaseDate: DateTime.utc(2026, 11, 18),
            totalCents: 129,
            status: ReceiptStatus.confirmed,
          ),
        );
    await db
        .into(db.receiptItems)
        .insert(
          ReceiptItemsCompanion.insert(
            receiptId: receiptId,
            rawName: 'LATTE PS 1L',
            unitPriceCents: 129,
            lineTotalCents: 129,
          ),
        );

    await (db.delete(db.receipts)..where((r) => r.id.equals(receiptId))).go();

    expect(await db.select(db.receiptItems).get(), isEmpty);
  });

  test('the same transaction hash cannot be confirmed twice', () async {
    ReceiptsCompanion receipt(String? hash) => ReceiptsCompanion.insert(
      purchaseDate: DateTime.utc(2026, 11, 18),
      totalCents: 129,
      status: hash == null ? ReceiptStatus.draft : ReceiptStatus.confirmed,
      transactionHash: Value(hash),
    );
    await db.into(db.receipts).insert(receipt(null));
    await db.into(db.receipts).insert(receipt(null));
    await db.into(db.receipts).insert(receipt('abc'));

    expect(
      () => db.into(db.receipts).insert(receipt('abc')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('bundled SQLite supports encryption', () async {
    final row = await db.customSelect('PRAGMA cipher').getSingleOrNull();
    expect(row, isNotNull);
  });
}
