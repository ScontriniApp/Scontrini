import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';

/// Stores receipts. For now only [saveConfirmed], used by the extraction
/// screen's "confirm and sort" until the review screen (where the user
/// corrects the fields first) takes over.
class ReceiptRepository {
  new(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Saves [receipt] as confirmed, with its store, rows and transaction
  /// hash, and returns its id. The same receipt saved again (same hash)
  /// returns the existing id instead of a duplicate.
  ///
  /// A receipt whose date wasn't read is dated now (the capture). A total
  /// that wasn't read is the rows' sum. Rows get a category from the
  /// keywords table (`CategoryClassifier`).
  Future<int> saveConfirmed(
    ParsedReceipt receipt, {
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
    for (final item in receipt.items) {
      await _db
          .into(_db.receiptItems)
          .insert(
            ReceiptItemsCompanion.insert(
              receiptId: receiptId,
              rawName: item.rawName,
              quantity: Value(item.quantity),
              unit: Value(unitCode(item.unit)),
              unitPriceCents: item.unitPriceCents,
              lineTotalCents: item.lineTotalCents,
              discountCents: Value(item.discountCents),
              categoryId: Value(classifier.classify(item.rawName)),
            ),
          );
    }
    return receiptId;
  });

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
