import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

/// Helpers for building small in-code [PurchaseHistory] fixtures.
///
/// Dates are given in local time and stored as UTC, like the database does.

var _nextId = 1;

PurchaseReceipt receipt(
  DateTime localDate,
  int totalCents, {
  int discountCents = 0,
  int? storeId,
  List<PurchaseItem> items = const [],
}) => PurchaseReceipt(
  id: _nextId++,
  purchaseDate: localDate.toUtc(),
  totalCents: totalCents,
  discountCents: discountCents,
  storeId: storeId,
  items: items,
);

PurchaseItem item(
  int lineTotalCents, {
  int discountCents = 0,
  double quantity = 1,
  int? productId,
  int? categoryId,
  String rawName = 'ITEM',
}) => PurchaseItem(
  id: _nextId++,
  rawName: rawName,
  unitPriceCents: (lineTotalCents / quantity).round(),
  lineTotalCents: lineTotalCents,
  quantity: quantity,
  discountCents: discountCents,
  productId: productId,
  categoryId: categoryId,
);

PurchaseHistory history(List<PurchaseReceipt> receipts) => PurchaseHistory(
  receipts: [...receipts]
    ..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate)),
);
