import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';

/// Stores and reads receipts. [saveConfirmed] is used by the extraction
/// screen's "confirm and sort" (until the review screen, where the user
/// corrects the fields first, takes over) and by the manual receipt form;
/// [watchHistory] and [watchReceipt] feed the history tab.
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
  /// keywords table (`CategoryClassifier`), unless [categoryIds] (one entry
  /// per item, `null` = classify) says otherwise, and the product of their
  /// name (`AppDatabase.productIdFor`), which per-product statistics group by.
  Future<int> saveConfirmed(
    ParsedReceipt receipt, {
    String? sourcePath,
    String? rawOcrText,
    List<int?>? categoryIds,
  }) => _db.transaction(() async {
    if (categoryIds != null && categoryIds.length != receipt.items.length) {
      throw ArgumentError.value(categoryIds, 'categoryIds', 'one per item');
    }
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
    for (final (index, item) in receipt.items.indexed) {
      final categoryId =
          categoryIds?[index] ?? classifier.classify(item.rawName);
      final unit = unitCode(item.unit);
      await _db
          .into(_db.receiptItems)
          .insert(
            ReceiptItemsCompanion.insert(
              receiptId: receiptId,
              rawName: item.rawName,
              quantity: Value(item.quantity),
              unit: Value(unit),
              unitPriceCents: item.unitPriceCents,
              lineTotalCents: item.lineTotalCents,
              discountCents: Value(item.discountCents),
              categoryId: Value(categoryId),
              productId: Value(
                await _db.productIdFor(
                  item.rawName,
                  categoryId: categoryId,
                  unit: unit,
                ),
              ),
            ),
          );
    }
    return receiptId;
  });

  /// Confirmed receipts, newest first.
  Stream<List<ReceiptSummary>> watchHistory() {
    final count = _db.receiptItems.id.count();
    final query =
        _db.select(_db.receipts).join([
            leftOuterJoin(
              _db.stores,
              _db.stores.id.equalsExp(_db.receipts.storeId),
            ),
            leftOuterJoin(
              _db.receiptItems,
              _db.receiptItems.receiptId.equalsExp(_db.receipts.id),
            ),
          ])
          ..addColumns([count])
          ..where(_db.receipts.status.equalsValue(ReceiptStatus.confirmed))
          ..groupBy([_db.receipts.id])
          ..orderBy([
            OrderingTerm.desc(_db.receipts.purchaseDate),
            OrderingTerm.desc(_db.receipts.id),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          _summary(
            row.readTable(_db.receipts),
            row.readTableOrNull(_db.stores),
            row.read(count) ?? 0,
          ),
      ],
    );
  }

  /// One receipt with its rows in printed order; `null` once deleted.
  /// Reloads on any change to receipts, rows or stores (SQLite's cascade
  /// deletes are not reported per table, so one table is not enough).
  Stream<ReceiptDetail?> watchReceipt(int id) => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {_db.receipts, _db.receiptItems, _db.stores},
      )
      .watch()
      .asyncMap((_) => receipt(id));

  /// One receipt with its rows in printed order; `null` if there is none.
  Future<ReceiptDetail?> receipt(int id) async {
    final found = await (_db.select(_db.receipts).join([
      leftOuterJoin(_db.stores, _db.stores.id.equalsExp(_db.receipts.storeId)),
    ])..where(_db.receipts.id.equals(id))).getSingleOrNull();
    if (found == null) return null;
    final rows =
        await (_db.select(_db.receiptItems)
              ..where((r) => r.receiptId.equals(id))
              ..orderBy([(r) => OrderingTerm.asc(r.id)]))
            .get();
    final receipt = found.readTable(_db.receipts);
    return ReceiptDetail(
      summary: _summary(
        receipt,
        found.readTableOrNull(_db.stores),
        rows.length,
      ),
      discountCents: receipt.discountCents,
      lines: [
        for (final r in rows)
          ReceiptLine(
            id: r.id,
            name: r.rawName,
            quantity: r.quantity,
            unit: r.unit,
            unitPriceCents: r.unitPriceCents,
            lineTotalCents: r.lineTotalCents,
            discountCents: r.discountCents,
            categoryId: r.categoryId,
          ),
      ],
    );
  }

  /// Deletes a receipt; its rows, pantry lots and their events go with it.
  Future<void> delete(int id) =>
      (_db.delete(_db.receipts)..where((r) => r.id.equals(id))).go();

  static ReceiptSummary _summary(Receipt r, Store? store, int itemCount) =>
      ReceiptSummary(
        id: r.id,
        storeName: store?.name,
        purchaseDate: r.purchaseDate.toLocal(),
        totalCents: r.totalCents,
        itemCount: itemCount,
        manual: r.sourcePath == null && r.rawOcrText == null,
        transactionHash: r.transactionHash,
      );

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
