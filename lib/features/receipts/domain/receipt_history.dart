/// One confirmed receipt in the history list.
class ReceiptSummary {
  const new({
    required this.id,
    required this.purchaseDate,
    required this.totalCents,
    required this.itemCount,
    required this.manual,
    this.storeName,
    this.transactionHash,
  });

  final int id;

  /// Local time.
  final DateTime purchaseDate;
  final int totalCents;
  final int itemCount;

  /// Typed in by hand (no photo, no PDF, no OCR text).
  final bool manual;
  final String? storeName;
  final String? transactionHash;
}

/// One row of a receipt, as the detail screen shows it.
class ReceiptLine {
  const new({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPriceCents,
    required this.lineTotalCents,
    required this.discountCents,
    this.categoryId,
  });

  final int id;
  final String name;
  final double quantity;

  /// `pz`, `kg` or `l`.
  final String unit;
  final int unitPriceCents;
  final int lineTotalCents;
  final int discountCents;
  final int? categoryId;

  int get netCents => lineTotalCents - discountCents;
}

/// A receipt with its rows.
class ReceiptDetail {
  const new({
    required this.summary,
    required this.lines,
    required this.discountCents,
  });

  final ReceiptSummary summary;
  final List<ReceiptLine> lines;

  /// Discounts on the whole receipt.
  final int discountCents;
}
