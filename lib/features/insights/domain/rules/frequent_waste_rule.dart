import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/valued_lot.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

/// A product that is often partly thrown away: of its lots added in the
/// last [days] days and already closed (finished or thrown away), at least
/// [minShare] had something thrown away.
///
/// Only closed lots count, so a lot still in the fridge is neither a success
/// nor a waste yet. Lots with no price (gifts, things already at home) count
/// towards the share but add nothing to the euros.
class FrequentWasteRule implements InsightRule {
  const new({
    this.days = 90,
    this.minClosedLots = 3,
    this.minWastedLots = 2,
    this.minShare = 1 / 3,
    this.minWastedCents = 100,
  });

  final int days;
  final int minClosedLots;
  final int minWastedLots;
  final double minShare;
  final int minWastedCents;

  @override
  List<Insight> evaluate(InsightInput input) {
    final window = DateRange.lastDays(days, now: input.today);
    final tallies = <String, _Tally>{};

    for (final history in input.pantry.lots) {
      if (!window.contains(history.addedAt)) continue;
      final lot = ValuedLot(history);
      if (lot.ledger.status == PantryLotStatus.active) continue;

      final key = history.productId != null
          ? 'p:${history.productId}'
          : 'n:${history.name.trim().toUpperCase()}';
      final tally = tallies[key] ??= _Tally(
        name: input.purchases.products[history.productId]?.name ?? history.name,
        productId: history.productId,
      );
      tally.closed++;
      if (lot.ledger.discarded > 0) {
        tally.wasted++;
        tally.cents += lot.valueOf(lot.ledger.discarded);
      }
    }

    return [
      for (final t in tallies.values)
        if (t.closed >= minClosedLots &&
            t.wasted >= minWastedLots &&
            t.wasted >= t.closed * minShare &&
            t.cents >= minWastedCents)
          Insight.frequentWaste(
            productName: t.name,
            productId: t.productId,
            wastedLots: t.wasted,
            closedLots: t.closed,
            wastedCents: t.cents,
            days: days,
          ),
    ];
  }
}

class _Tally {
  new({required this.name, this.productId});

  final String name;
  final int? productId;
  int closed = 0;
  int wasted = 0;
  int cents = 0;
}
