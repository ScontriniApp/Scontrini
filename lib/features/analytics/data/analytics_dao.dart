import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/product_unit.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

/// Loads the [PurchaseHistory] that analytics and insights work on. The only
/// analytics code that touches Drift; everything above it is pure Dart.
///
/// Only confirmed receipts are read. Callers pass the whole window their
/// metrics need, not just the visible range: the previous period for M1/M8
/// (`range.extendBack(range.days)`), 90 days for M6, three months for the
/// category-spike rule.
class AnalyticsDao {
  new(this._db);

  final AppDatabase _db;

  /// [loadHistory] for [range], again every time a receipt, item, product,
  /// category or store changes, so confirming, editing or deleting a receipt
  /// updates every screen.
  Stream<PurchaseHistory> watchHistory(DateRange range) => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          _db.receipts,
          _db.receiptItems,
          _db.products,
          _db.categories,
          _db.stores,
        },
      )
      .watch()
      .asyncMap((_) => loadHistory(range));

  /// Confirmed receipts whose purchase day (local time) is in [range],
  /// oldest first, with their items and the products, categories and stores
  /// they reference. Read in one transaction, so it is consistent.
  Future<PurchaseHistory> loadHistory(DateRange range) =>
      _db.transaction(() async {
        final receiptRows =
            await (_db.select(_db.receipts)
                  ..where((r) => _confirmedIn(r, range))
                  ..orderBy([
                    (r) => OrderingTerm.asc(r.purchaseDate),
                    (r) => OrderingTerm.asc(r.id),
                  ]))
                .get();

        final itemRows =
            await (_db.select(_db.receiptItems).join([
                    innerJoin(
                      _db.receipts,
                      _db.receipts.id.equalsExp(_db.receiptItems.receiptId),
                      useColumns: false,
                    ),
                    leftOuterJoin(
                      _db.products,
                      _db.products.id.equalsExp(_db.receiptItems.productId),
                    ),
                  ])
                  ..where(_confirmedIn(_db.receipts, range))
                  ..orderBy([OrderingTerm.asc(_db.receiptItems.id)]))
                .get();

        final storeIds = {...receiptRows.map((r) => r.storeId).nonNulls};
        final storeRows = storeIds.isEmpty
            ? const <Store>[]
            : await (_db.select(
                _db.stores,
              )..where((s) => s.id.isIn(storeIds))).get();
        final categoryRows = await _db.select(_db.categories).get();

        final products = <int, ProductInfo>{};
        final itemsByReceipt = <int, List<PurchaseItem>>{};
        for (final row in itemRows) {
          final item = row.readTable(_db.receiptItems);
          final product = row.readTableOrNull(_db.products);
          if (product != null) {
            products[product.id] = ProductInfo(
              id: product.id,
              name: product.canonicalName,
              categoryId: product.categoryId,
              unit: ProductUnit.fromDb(product.unit),
            );
          }
          (itemsByReceipt[item.receiptId] ??= []).add(
            PurchaseItem(
              id: item.id,
              rawName: item.rawName,
              unitPriceCents: item.unitPriceCents,
              lineTotalCents: item.lineTotalCents,
              quantity: item.quantity,
              discountCents: item.discountCents,
              productId: item.productId,
              categoryId: item.categoryId ?? product?.categoryId,
              // The unit printed on the row (`receipt_items.unit`, v2); the
              // product's only for a value the row can't hold.
              unit:
                  ProductUnit.fromDb(item.unit) ??
                  ProductUnit.fromDb(product?.unit),
            ),
          );
        }

        return PurchaseHistory(
          receipts: [
            for (final r in receiptRows)
              PurchaseReceipt(
                id: r.id,
                purchaseDate: r.purchaseDate.toUtc(),
                totalCents: r.totalCents,
                discountCents: r.discountCents,
                storeId: r.storeId,
                items: itemsByReceipt[r.id] ?? const [],
              ),
          ],
          products: products,
          categories: {
            for (final c in categoryRows)
              c.id: CategoryInfo(
                id: c.id,
                name: c.name,
                icon: c.icon,
                color: c.color,
                parentId: c.parentId,
              ),
          },
          stores: {
            for (final s in storeRows)
              s.id: StoreInfo(id: s.id, name: s.name, vatNumber: s.vatNumber),
          },
        );
      });

  /// Confirmed, and bought on a local day in [range]. The range ends are
  /// local midnights; Drift compares them as instants.
  Expression<bool> _confirmedIn($ReceiptsTable r, DateRange range) =>
      r.status.equalsValue(ReceiptStatus.confirmed) &
      r.purchaseDate.isBiggerOrEqualValue(range.start) &
      r.purchaseDate.isSmallerThanValue(range.end);
}
