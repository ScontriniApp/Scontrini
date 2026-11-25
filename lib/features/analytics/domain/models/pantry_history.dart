import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';

part 'pantry_history.freezed.dart';

/// Every pantry lot with its event log: the read model for pantry
/// statistics (waste, where the spending went). Built by `AnalyticsDao`;
/// derived figures come from `LotLedger`, never from stored counters
/// (docs/pantry_and_stats.md, rule 1).
@freezed
abstract class PantryHistory with _$PantryHistory {
  const factory({required List<PantryHistoryLot> lots}) = _PantryHistory;

  const new _();

  static const empty = PantryHistory(lots: []);

  bool get isEmpty => lots.isEmpty;
}

/// One lot (`pantry_lots`) and its events, oldest first.
@freezed
abstract class PantryHistoryLot with _$PantryHistoryLot {
  const factory({
    required int id,
    required String name,
    required PantrySource source,

    /// Purchased quantity (pieces, kg or l).
    required double initialQuantity,

    /// UTC.
    required DateTime addedAt,

    /// In insertion (id) order, reverts included.
    required List<PantryEvent> events,

    /// Set exactly for [PantrySource.receipt] lots.
    int? receiptId,
    int? productId,
    int? categoryId,

    /// What was paid for the lot after discounts; null for gifts, things
    /// already at home and manual purchases with no price.
    int? priceCents,
  }) = _PantryHistoryLot;
}
