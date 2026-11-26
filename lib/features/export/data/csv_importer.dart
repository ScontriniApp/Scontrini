import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/product_matcher.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';

/// What a CSV import did.
class CsvImportResult {
  const new({
    required this.receipts,
    required this.duplicates,
    required this.lots,
  });

  /// Receipts added to the history.
  final int receipts;

  /// Receipts already stored (same transaction hash), left as they are.
  final int duplicates;

  /// Pantry lots restored.
  final int lots;
}

/// Reads back a file written by the export ([PurchaseCsv]): every receipt
/// it holds is saved as confirmed, and its pantry lots are restored.
///
/// - Rows are grouped into receipts by `scontrino_id` (the id in the
///   exporting app, not reused here).
/// - Categories are matched by name; a row whose product name differs from
///   its printed name gets an alias, so it groups under the same product.
/// - A receipt already stored (same store, minute and total) is skipped,
///   so importing the same file twice adds nothing.
/// - Pantry: the file holds each lot's final state, not its history, so
///   the movements are recorded at import time: an active lot is used down
///   to what was left, a finished one fully used, a thrown-away one thrown
///   away whole (how much was eaten first isn't in the file).
/// - The origin is kept for the export (photo, PDF, by hand), but the
///   captured files aren't in the CSV.
class CsvImporter {
  new(this._db, this._receipts, this._pantry);

  final AppDatabase _db;
  final ReceiptRepository _receipts;
  final PantryRepository _pantry;

  /// Placeholder capture paths that keep a receipt's origin
  /// (`ExportRepository.origin`): no file is stored at them.
  static const photoPlaceholder = 'csv-import.jpg';
  static const pdfPlaceholder = 'csv-import.pdf';

  /// Imports [rows] (from [PurchaseCsv.decode]); all or nothing.
  Future<CsvImportResult> import(List<ExportRow> rows) =>
      _db.transaction(() async {
        final receipts = <int, List<ExportRow>>{};
        for (final row in rows) {
          receipts.putIfAbsent(row.receiptId, () => []).add(row);
        }
        final categories = {
          for (final c in await _db.select(_db.categories).get())
            ProductMatcher.normalise(c.name): c.id,
        };
        var saved = 0;
        var duplicates = 0;
        var lots = 0;
        for (final group in receipts.values) {
          final lotsAdded = await _importReceipt(group, categories);
          if (lotsAdded == null) {
            duplicates++;
          } else {
            saved++;
            lots += lotsAdded;
          }
        }
        return CsvImportResult(
          receipts: saved,
          duplicates: duplicates,
          lots: lots,
        );
      });

  /// Saves one receipt and restores its lots; returns how many lots, or
  /// `null` when the receipt was already stored.
  Future<int?> _importReceipt(
    List<ExportRow> rows,
    Map<String, int> categories,
  ) async {
    final head = rows.first;
    final hash = transactionHash(
      purchaseDate: head.purchasedAt,
      totalCents: head.receiptTotalCents,
      vatNumber: head.vatNumber,
      storeName: head.storeName,
    );
    final existing = await (_db.select(
      _db.receipts,
    )..where((r) => r.transactionHash.equals(hash))).getSingleOrNull();
    if (existing != null) return null;

    await _aliasProducts(rows);
    final receiptId = await _receipts.saveConfirmed(
      ParsedReceipt(
        items: [
          for (final r in rows)
            ParsedItem(
              rawName: r.rawName,
              unitPriceCents: r.unitPriceCents,
              lineTotalCents: r.lineTotalCents,
              quantity: r.quantity,
              unit: _unit(r.unit),
              discountCents: r.discountCents,
            ),
        ],
        storeName: head.storeName,
        vatNumber: head.vatNumber,
        purchaseDate: head.purchasedAt,
        totalCents: head.receiptTotalCents,
        discountCents: head.receiptDiscountCents,
      ),
      categoryIds: [
        for (final r in rows)
          if (r.categoryName case final name?)
            categories[ProductMatcher.normalise(name)]
          else
            null,
      ],
      sourcePath: switch (head.origin) {
        ReceiptOrigin.photo => photoPlaceholder,
        ReceiptOrigin.pdf => pdfPlaceholder,
        ReceiptOrigin.manual => null,
      },
    );
    return await _restorePantry(receiptId, rows);
  }

  /// A row printed as one name but counted under another product (an alias
  /// in the exporting app) gets the same alias here.
  Future<void> _aliasProducts(List<ExportRow> rows) async {
    final linker = await _db.productLinker();
    final aliased = <String>{};
    for (final r in rows) {
      final product = r.productName;
      final raw = ProductMatcher.normalise(r.rawName);
      if (product == null ||
          ProductMatcher.normalise(product) == raw ||
          aliased.contains(raw) ||
          linker.match(r.rawName) != null) {
        continue;
      }
      final target = await linker.link(product, unit: r.unit);
      if (target == null) continue;
      await _db
          .into(_db.productAliases)
          .insert(
            ProductAliasesCompanion.insert(
              rawName: r.rawName.trim(),
              productId: target.id,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      aliased.add(raw);
    }
  }

  /// Puts back the lots of rows that were in the pantry, grouped the way
  /// the app groups them, each in its exported state.
  Future<int> _restorePantry(int receiptId, List<ExportRow> rows) async {
    if (rows.every((r) => r.pantryState == null)) return 0;
    final itemIds =
        await (_db.select(_db.receiptItems)
              ..where((i) => i.receiptId.equals(receiptId))
              ..orderBy([(i) => OrderingTerm.asc(i.id)]))
            .map((i) => i.id)
            .get();
    final rowOf = {for (final (i, id) in itemIds.indexed) id: rows[i]};

    var added = 0;
    for (final card in await _pantry.triageCards(receiptId)) {
      final cardRows = [for (final id in card.receiptItemIds) rowOf[id]!];
      final exported = cardRows.where((r) => r.pantryState != null).toList();
      if (exported.isEmpty) continue;
      final lotId = await _pantry.addFromReceipt(receiptId, card);
      added++;
      switch (exported.first.pantryState!) {
        case ExportPantryState.active:
          final left = exported.map((r) => r.remaining).nonNulls.firstOrNull;
          if (left != null) await _pantry.setRemaining(lotId, left);
        case ExportPantryState.consumed:
          await _pantry.setRemaining(lotId, 0);
        case ExportPantryState.discarded:
          await _pantry.discard(lotId, PantryEventReason.other);
      }
    }
    return added;
  }

  static QuantityUnit _unit(String code) => switch (code) {
    'kg' => QuantityUnit.kilogram,
    'l' => QuantityUnit.litre,
    _ => QuantityUnit.piece,
  };
}
