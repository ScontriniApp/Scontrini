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

  test('bundled SQLite supports encryption', () async {
    final row = await db.customSelect('PRAGMA cipher').getSingleOrNull();
    expect(row, isNotNull);
  });
}
