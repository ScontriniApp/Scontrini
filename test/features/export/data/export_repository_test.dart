import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/export/data/export_repository.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

void main() {
  late AppDatabase db;
  late ReceiptRepository receipts;
  late PantryRepository pantry;
  late ExportRepository export;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    receipts = ReceiptRepository(db);
    pantry = PantryRepository(db);
    export = ExportRepository(db, pantry);
  });
  tearDown(() => db.close());

  test(
    'every row of confirmed receipts, oldest first, with pantry state',
    () async {
      // Newer, scanned PDF: milk printed twice (one lot), apples, a bag.
      final scanned = await receipts.saveConfirmed(
        ParsedReceipt(
          storeName: 'CARREFOUR MARKET',
          vatNumber: '02924950963',
          purchaseDate: DateTime(2026, 11, 23, 18, 30),
          totalCents: 368,
          items: const [
            ParsedItem(
              rawName: 'LATTE INTERO',
              unitPriceCents: 129,
              lineTotalCents: 129,
            ),
            ParsedItem(
              rawName: 'LATTE INTERO',
              unitPriceCents: 129,
              lineTotalCents: 129,
            ),
            ParsedItem(
              rawName: 'MELE GOLDEN',
              unitPriceCents: 200,
              lineTotalCents: 100,
              quantity: 0.5,
              unit: QuantityUnit.kilogram,
              discountCents: 10,
            ),
            ParsedItem(
              rawName: 'SHOPPER',
              unitPriceCents: 10,
              lineTotalCents: 10,
            ),
          ],
        ),
        sourcePath: '/receipts/carrefour.PDF',
        rawOcrText: 'LATTE INTERO 1,29',
      );
      // Older, typed in by hand, never put in the pantry.
      await receipts.saveConfirmed(
        ParsedReceipt(
          purchaseDate: DateTime(2026, 11, 20, 9, 5),
          items: const [
            ParsedItem(
              rawName: 'Pane',
              unitPriceCents: 150,
              lineTotalCents: 150,
            ),
          ],
        ),
      );
      // A draft never reaches the export.
      await db
          .into(db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              purchaseDate: DateTime.utc(2026, 11, 25),
              totalCents: 1,
              status: ReceiptStatus.draft,
            ),
          );

      await pantry.addAllFromReceipt(scanned);
      final lots = await pantry.watchLots().first;
      final milk = lots.singleWhere((l) => l.name == 'LATTE INTERO');
      final apples = lots.singleWhere((l) => l.name == 'MELE GOLDEN');
      await pantry.consume(milk.id, 2);
      await pantry.consume(apples.id, 0.2);

      final rows = await export.rows();
      expect(rows.map((r) => (r.rawName, r.origin)), [
        ('Pane', ReceiptOrigin.manual),
        ('LATTE INTERO', ReceiptOrigin.pdf),
        ('LATTE INTERO', ReceiptOrigin.pdf),
        ('MELE GOLDEN', ReceiptOrigin.pdf),
        ('SHOPPER', ReceiptOrigin.pdf),
      ]);

      final bread = rows[0];
      expect(bread.purchasedAt, DateTime(2026, 11, 20, 9, 5));
      expect(
        (bread.storeName, bread.pantryState, bread.remaining),
        (null, null, null),
      );

      // The two milk rows share one lot: its state on both, what is left once.
      expect(rows[1].pantryState, ExportPantryState.consumed);
      expect(rows[2].pantryState, ExportPantryState.consumed);
      expect((rows[1].remaining, rows[2].remaining), (0.0, null));

      final apple = rows[3];
      expect(apple.storeName, 'CARREFOUR MARKET');
      expect(apple.vatNumber, '02924950963');
      expect(apple.productName, 'MELE GOLDEN');
      expect(apple.categoryName, 'Frutta e verdura');
      expect((apple.quantity, apple.unit, apple.paidCents), (0.5, 'kg', 90));
      expect(apple.pantryState, ExportPantryState.active);
      expect(apple.remaining, closeTo(0.3, 1e-9));

    },
  );

  test('origin: no capture and no text is by hand, .pdf is a PDF', () {
    expect(ExportRepository.origin(null, null), ReceiptOrigin.manual);
    expect(ExportRepository.origin('/r/1.jpg', 'x'), ReceiptOrigin.photo);
    expect(ExportRepository.origin('/r/1.Pdf', 'x'), ReceiptOrigin.pdf);
  });
}
