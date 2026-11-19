import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

/// A lot as the UI sees it: stored fields plus what its ledger derives.
class PantryLot {
  const new({
    required this.id,
    required this.name,
    required this.unit,
    required this.source,
    required this.initialQuantity,
    required this.remainingQuantity,
    required this.status,
    required this.addedAt,
    this.receiptId,
    this.productId,
    this.categoryId,
    this.priceCents,
    this.transactionHash,
  });

  final int id;
  final String name;

  /// `pz`, `kg` or `l`.
  final String unit;
  final PantrySource source;
  final double initialQuantity;
  final double remainingQuantity;
  final PantryLotStatus status;

  /// UTC.
  final DateTime addedAt;
  final int? receiptId;
  final int? productId;
  final int? categoryId;
  final int? priceCents;

  /// Hash of the receipt the lot came from (its tag), when confirmed.
  final String? transactionHash;

  /// Share left, 0–1, for the slider.
  double get remainingFraction => initialQuantity <= 0
      ? 0
      : (remainingQuantity / initialQuantity).clamp(0, 1).toDouble();
}
