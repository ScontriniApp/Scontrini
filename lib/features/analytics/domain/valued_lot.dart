import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/proportional_split.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

/// A pantry lot with its ledger worked out once, and its price spread over
/// what happened to it: consumed, discarded and left. Shares are taken of
/// those parts' sum, not of the purchased quantity, so a recount up never
/// makes them exceed the price. Shared by the pantry statistics and the
/// waste insight.
class ValuedLot {
  new(this.history) : ledger = LotLedger(history.events);

  final PantryHistoryLot history;
  final LotLedger ledger;

  /// Consumed + discarded + left: what the lot's price is spread over.
  double get _parts => ledger.consumed + ledger.discarded + ledger.remaining;

  /// Never used, thrown away or re-counted.
  bool get untouched => ledger.effectiveEvents.every(
    (e) =>
        e.kind == PantryEventKind.stockIn ||
        (e.kind == PantryEventKind.adjust &&
            e.reason == PantryEventReason.correction),
  );

  /// The effective [kind] events in [range], with the quantity they took.
  List<({double quantity, PantryEventReason? reason})> quantities(
    PantryEventKind kind,
    DateRange range,
  ) => [
    for (final e in ledger.effectiveEvents)
      if (e.kind == kind && range.contains(e.at))
        (quantity: -e.delta, reason: e.reason),
  ];

  /// What [quantity] of this lot cost, in whole cents.
  int valueOf(double quantity) {
    final price = history.priceCents;
    final parts = _parts;
    if (price == null || parts <= 0) return 0;
    return (price * quantity / parts).round();
  }

  /// [price] split into used, thrown away and left, exactly.
  List<int> split(int price) {
    // Grams or millilitres, so the weights are whole numbers.
    final weights = [
      (ledger.consumed * 1000).round(),
      (ledger.discarded * 1000).round(),
      (ledger.remaining * 1000).round(),
    ];
    if (price <= 0 || weights.every((w) => w == 0)) return [0, 0, 0];
    return splitProportionally(price, weights);
  }
}
