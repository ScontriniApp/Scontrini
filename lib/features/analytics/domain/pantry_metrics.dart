import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_overview.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/proportional_split.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

/// Pantry statistics for the analytics tab, as pure functions over the
/// [PantryHistory] and the [PurchaseHistory] (docs/pantry_and_stats.md,
/// "Global").
///
/// A lot's price is spread over what its ledger says happened to it:
/// consumed, discarded, and what is left. Reverted events never count. A
/// recount that raised the quantity makes the lot's parts larger than what
/// was bought, so shares are taken of the parts' sum, not of the purchased
/// quantity, and always add up to the price.
abstract final class PantryMetrics {
  static PantryOverview overview(
    PurchaseHistory purchases,
    PantryHistory pantry,
    AnalyticsPeriod period,
    DateTime today,
  ) {
    final range = period.toDate(today);
    final compared = period.comparison(today);
    final lots = [for (final lot in pantry.lots) _Lot(lot)];

    final reasons = <PantryEventReason, int>{};
    final byCategory = <int?, int>{};
    final byProduct = <String, ({String name, int? id, int cents, int lots})>{};
    var wasted = 0;
    var used = 0;
    var unpriced = 0;

    for (final lot in lots) {
      final discards = lot.quantities(PantryEventKind.discard, range);
      final consumed = lot.quantities(PantryEventKind.consume, range);
      if (discards.isEmpty && consumed.isEmpty) continue;
      if (lot.history.priceCents == null) {
        if (discards.isNotEmpty) unpriced++;
        continue;
      }
      used += consumed.fold(0, (sum, e) => sum + lot.valueOf(e.quantity));
      if (discards.isEmpty) continue;

      var lotCents = 0;
      for (final d in discards) {
        final cents = lot.valueOf(d.quantity);
        final reason = d.reason ?? PantryEventReason.other;
        reasons[reason] = (reasons[reason] ?? 0) + cents;
        lotCents += cents;
      }
      wasted += lotCents;
      final categoryId = lot.history.categoryId;
      byCategory[categoryId] = (byCategory[categoryId] ?? 0) + lotCents;

      final productId = lot.history.productId;
      final name =
          (productId == null ? null : purchases.products[productId])?.name;
      final key = productId != null
          ? 'p:$productId'
          : 'n:${lot.history.name.trim().toUpperCase()}';
      final seen = byProduct[key];
      byProduct[key] = (
        name: seen?.name ?? name ?? lot.history.name,
        id: productId,
        cents: (seen?.cents ?? 0) + lotCents,
        lots: (seen?.lots ?? 0) + 1,
      );
    }

    final previousWasted = lots.fold(
      0,
      (sum, lot) =>
          sum +
          (lot.history.priceCents == null
              ? 0
              : lot
                    .quantities(PantryEventKind.discard, compared)
                    .fold(0, (s, e) => s + lot.valueOf(e.quantity))),
    );

    final categoryIds = purchases.categories.keys.toList()..sort();
    return PantryOverview(
      hasPantry: pantry.lots.isNotEmpty,
      wasted: PeriodAmount(cents: wasted, previousCents: previousWasted),
      wasteRate: wasted + used <= 0 ? null : wasted / (wasted + used),
      unpricedDiscards: unpriced,
      reasons: [
        for (final MapEntry(:key, :value) in reasons.entries)
          if (value > 0) WasteByReason(reason: key, cents: value),
      ]..sort((a, b) => b.cents.compareTo(a.cents)),
      categories: [
        for (final MapEntry(:key, :value) in byCategory.entries)
          if (value > 0)
            WasteByCategory(
              cents: value,
              category: key == null ? null : purchases.categories[key],
              colorSlot: key == null ? null : categoryIds.indexOf(key),
            ),
      ]..sort((a, b) => b.cents.compareTo(a.cents)),
      products: [
        for (final p in byProduct.values)
          if (p.cents > 0)
            WastedProduct(
              name: p.name,
              cents: p.cents,
              lotCount: p.lots,
              productId: p.id,
            ),
      ]..sort((a, b) => b.cents.compareTo(a.cents)),
      fate: _fate(purchases, lots, range),
    );
  }

  static SpendingFate _fate(
    PurchaseHistory purchases,
    List<_Lot> lots,
    DateRange range,
  ) {
    final receipts = purchases.receiptsIn(range).toList();
    final ids = {for (final r in receipts) r.id};
    final total = receipts.fold(0, (sum, r) => sum + r.totalCents);

    var used = 0;
    var wasted = 0;
    var left = 0;
    var count = 0;
    var untouched = 0;
    for (final lot in lots) {
      if (!ids.contains(lot.history.receiptId)) continue;
      count++;
      if (lot.untouched) untouched++;
      final price = lot.history.priceCents ?? 0;
      final parts = lot.split(price);
      used += parts[0];
      wasted += parts[1];
      left += parts[2];
    }
    final tracked = used + wasted + left;
    return SpendingFate(
      totalCents: tracked > total ? tracked : total,
      usedCents: used,
      wastedCents: wasted,
      inPantryCents: left,
      notInPantryCents: tracked > total ? 0 : total - tracked,
      lotCount: count,
      untouchedLotCount: untouched,
    );
  }
}

/// A lot with its ledger worked out once.
class _Lot {
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
