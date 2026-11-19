import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

/// A row of a confirmed receipt, as the pantry triage needs it.
class TriageRow {
  const new({
    required this.receiptItemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.netCents,
    this.productId,
    this.categoryId,
    this.inPantry = false,
    this.trackInPantry = true,
  });

  final int receiptItemId;

  /// Canonical product name when matched, otherwise the printed name.
  final String name;
  final double quantity;
  final String unit;

  /// Paid after the row's own discount.
  final int netCents;
  final int? productId;
  final int? categoryId;

  /// Already linked to a pantry lot.
  final bool inPantry;

  /// False for products the user never wants in the pantry.
  final bool trackInPantry;
}

/// One swipe card: every row of the same product on one receipt, summed.
/// A receipt is one purchase occasion, so repeated rows are one purchase.
class TriageCard {
  const new({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.priceCents,
    required this.receiptItemIds,
    this.productId,
    this.categoryId,
  });

  final String name;
  final String unit;
  final double quantity;
  final int priceCents;
  final List<int> receiptItemIds;
  final int? productId;
  final int? categoryId;
}

/// Upper-case, single-spaced, trimmed: `latte  ps 1l` → `LATTE PS 1L`.
String normaliseItemName(String name) =>
    name.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

/// Groups [rows] into cards, in order of first appearance. Rows of the same
/// product (same matched product, or same normalised name when unmatched)
/// and unit are merged. Rows already in the pantry or not tracked are left
/// out.
List<TriageCard> groupForTriage(Iterable<TriageRow> rows) {
  final groups = <String, List<TriageRow>>{};
  for (final row in rows) {
    if (row.inPantry || !row.trackInPantry) continue;
    final product = row.productId != null
        ? 'p:${row.productId}'
        : 'n:${normaliseItemName(row.name)}';
    groups.putIfAbsent('$product|${row.unit}', () => []).add(row);
  }
  return [
    for (final group in groups.values)
      TriageCard(
        name: group.first.name,
        unit: group.first.unit,
        quantity: roundQuantity(
          group.fold<double>(0, (sum, r) => sum + r.quantity),
        ),
        priceCents: group.fold<int>(0, (sum, r) => sum + r.netCents),
        receiptItemIds: [for (final r in group) r.receiptItemId],
        productId: group.first.productId,
        categoryId: group
            .map((r) => r.categoryId)
            .firstWhere((id) => id != null, orElse: () => null),
      ),
  ];
}
