import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';

/// Reads what the export file holds: every row of every confirmed receipt
/// (the same receipts the history and statistics show), oldest first.
class ExportRepository {
  new(this._db, this._pantry);

  final AppDatabase _db;
  final PantryRepository _pantry;

  Future<List<ExportRow>> rows() async {
    final query =
        _db.select(_db.receiptItems).join([
            innerJoin(
              _db.receipts,
              _db.receipts.id.equalsExp(_db.receiptItems.receiptId),
            ),
            leftOuterJoin(
              _db.stores,
              _db.stores.id.equalsExp(_db.receipts.storeId),
            ),
            leftOuterJoin(
              _db.products,
              _db.products.id.equalsExp(_db.receiptItems.productId),
            ),
            leftOuterJoin(
              _db.categories,
              _db.categories.id.equalsExp(_db.receiptItems.categoryId),
            ),
          ])
          ..where(_db.receipts.status.equalsValue(ReceiptStatus.confirmed))
          ..orderBy([
            OrderingTerm.asc(_db.receipts.purchaseDate),
            OrderingTerm.asc(_db.receipts.id),
            OrderingTerm.asc(_db.receiptItems.id),
          ]);
    final lots = {
      for (final lot in await _pantry.watchLots(includeClosed: true).first)
        lot.id: lot,
    };
    final lotsSeen = <int>{};

    return [for (final row in await query.get()) _row(row, lots, lotsSeen)];
  }

  ExportRow _row(TypedResult row, Map<int, PantryLot> lots, Set<int> lotsSeen) {
    final item = row.readTable(_db.receiptItems);
    final receipt = row.readTable(_db.receipts);
    final store = row.readTableOrNull(_db.stores);
    final lot = item.pantryLotId == null ? null : lots[item.pantryLotId];
    // A lot shared by several rows reports what is left once.
    final remaining = lot != null && lotsSeen.add(lot.id)
        ? lot.remainingQuantity
        : null;
    return ExportRow(
      receiptId: receipt.id,
      purchasedAt: receipt.purchaseDate.toLocal(),
      storeName: store?.name,
      vatNumber: store?.vatNumber,
      receiptTotalCents: receipt.totalCents,
      receiptDiscountCents: receipt.discountCents,
      origin: origin(receipt.sourcePath, receipt.rawOcrText),
      rawName: item.rawName,
      productName: row.readTableOrNull(_db.products)?.canonicalName,
      categoryName: row.readTableOrNull(_db.categories)?.name,
      quantity: item.quantity,
      unit: item.unit,
      unitPriceCents: item.unitPriceCents,
      lineTotalCents: item.lineTotalCents,
      discountCents: item.discountCents,
      pantryState: lot == null
          ? null
          : switch (lot.status) {
              PantryLotStatus.active => ExportPantryState.active,
              PantryLotStatus.consumed => ExportPantryState.consumed,
              PantryLotStatus.discarded => ExportPantryState.discarded,
            },
      remaining: remaining,
    );
  }

  /// A receipt with no capture and no OCR text was typed in by hand.
  static ReceiptOrigin origin(String? sourcePath, String? rawOcrText) {
    if (sourcePath == null) {
      return rawOcrText == null ? ReceiptOrigin.manual : ReceiptOrigin.photo;
    }
    return sourcePath.toLowerCase().endsWith('.pdf')
        ? ReceiptOrigin.pdf
        : ReceiptOrigin.photo;
  }
}
