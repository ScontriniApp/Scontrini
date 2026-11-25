import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/models/shopping_suggestion.dart';
import 'package:scontrini/features/analytics/domain/price_metrics.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

/// The next-shopping list: products that are finished, about to run out,
/// or due going by how often they are bought. Pure functions over the
/// purchase history and the pantry.
///
/// For each product bought at least twice:
/// 1. If the pantry has been kept up for it (a use or a discard in the last
///    [trustDays] days), the pantry decides: suggested when nothing is
///    left, or when what is left lasts [horizonDays] days or less at the
///    pace it was used over the last [trustDays] days. Stock that lasts
///    longer keeps it off the list, whatever the calendar says.
/// 2. Otherwise, with at least [minPurchases] purchase days, the typical
///    gap (median) decides: suggested when the last purchase plus the gap
///    is within [horizonDays] days.
///
/// A product not bought for more than [stoppedFactor] times its gap is
/// taken as no longer bought and left out.
///
/// A lot never moved (no use, discard or recount) and older than twice the
/// gap ([staleDays] when there is no gap) is taken as used without being
/// recorded: it does not count as stock, or a yogurt forgotten in the
/// pantry log months ago would keep yogurt off the list forever.
abstract final class ShoppingSuggestions {
  /// History the DAO should load for [forToday].
  static const historyDays = 180;

  /// How far back pantry movements make the pantry trusted, and the window
  /// the usage pace is measured over.
  static const trustDays = 60;

  /// Suggest what is needed within this many days.
  static const horizonDays = 3;

  /// Purchase days needed to trust the typical gap.
  static const minPurchases = 3;

  static const stoppedFactor = 3;

  /// Age after which an untouched lot stops counting as stock, when the
  /// product has no typical gap.
  static const staleDays = 30;

  /// What the DAO must load for [forToday].
  static DateRange window(DateTime today) =>
      DateRange.lastDays(historyDays, now: today);

  /// Overdue first, then by due day, then by name.
  static List<ShoppingSuggestion> forToday(
    PurchaseHistory purchases,
    PantryHistory pantry,
    DateTime today,
  ) {
    final day = DateRange.day(today).start;
    final horizon = _addDays(day, horizonDays);
    final trustFrom = _addDays(day, -trustDays);

    // Purchase days per product, oldest first.
    final purchaseDays = <int, List<DateTime>>{};
    final lastPurchase = <int, DateTime>{};
    for (final p in PriceMetrics.pricePoints(purchases, window(today))) {
      final d = DateRange.day(p.purchaseDate).start;
      final days = purchaseDays[p.productId] ??= [];
      if (days.isEmpty || days.last != d) days.add(d);
      lastPurchase[p.productId] = p.purchaseDate;
    }

    final lotsByProduct = <int, List<PantryHistoryLot>>{};
    for (final lot in pantry.lots) {
      final id = lot.productId;
      if (id != null) (lotsByProduct[id] ??= []).add(lot);
    }

    final suggestions = <ShoppingSuggestion>[];
    for (final MapEntry(key: productId, value: days) in purchaseDays.entries) {
      if (days.length < 2) continue;
      final interval = days.length >= minPurchases ? _medianGap(days) : null;
      if (interval != null &&
          _daysBetween(days.last, day) > stoppedFactor * interval) {
        continue;
      }

      final name =
          purchases.products[productId]?.name ??
          lotsByProduct[productId]?.first.name ??
          '#$productId';
      ShoppingSuggestion suggest(
        ShoppingReason reason,
        DateTime due, {
        double? remaining,
        String? unit,
      }) => ShoppingSuggestion(
        productId: productId,
        name: name,
        reason: reason,
        dueDay: due,
        lastPurchase: lastPurchase[productId]!,
        intervalDays: interval,
        remaining: remaining,
        unit: unit,
      );

      final staleBefore = _addDays(
        day,
        -(interval == null ? staleDays : 2 * interval),
      );
      final pantryView = _PantryView(
        lotsByProduct[productId] ?? const [],
        staleBefore: staleBefore,
      );
      if (pantryView.movedSince(trustFrom)) {
        final left = pantryView.remaining;
        if (left <= 0) {
          suggestions.add(suggest(ShoppingReason.finished, day));
          continue;
        }
        final perDay = pantryView.usePerDay(trustFrom, day);
        if (perDay == null) continue;
        // Tolerance so 1 ÷ (1/3) is 3 days, not 4.
        final daysLeft = (left / perDay - 1e-9).ceil();
        if (daysLeft <= horizonDays) {
          suggestions.add(
            suggest(
              ShoppingReason.runningLow,
              _addDays(day, daysLeft),
              remaining: left,
              unit: pantryView.unit,
            ),
          );
        }
        continue;
      }

      if (interval == null) continue;
      final due = _addDays(days.last, interval);
      if (!due.isAfter(horizon)) {
        suggestions.add(suggest(ShoppingReason.usualInterval, due));
      }
    }

    return suggestions..sort((a, b) {
      final byDue = a.dueDay.compareTo(b.dueDay);
      return byDue != 0 ? byDue : a.name.compareTo(b.name);
    });
  }

  /// Median of the gaps between consecutive [days], rounded, at least 1.
  static int _medianGap(List<DateTime> days) {
    final gaps = [
      for (var i = 1; i < days.length; i++) _daysBetween(days[i - 1], days[i]),
    ]..sort();
    final mid = gaps.length ~/ 2;
    final median = gaps.length.isOdd
        ? gaps[mid].toDouble()
        : (gaps[mid - 1] + gaps[mid]) / 2;
    return median.round().clamp(1, 1 << 30);
  }

  /// Calendar days from [a] to [b] (local midnights), DST-safe.
  static int _daysBetween(DateTime a, DateTime b) => DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  static DateTime _addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);
}

/// One product's lots, as their ledgers see them.
class _PantryView {
  new(List<PantryHistoryLot> lots, {required this.staleBefore})
    : _lots = [for (final l in lots) (lot: l, ledger: LotLedger(l.events))];

  final List<({PantryHistoryLot lot, LotLedger ledger})> _lots;

  /// Untouched lots added before this day are not counted as stock.
  final DateTime staleBefore;

  Iterable<({PantryHistoryLot lot, LotLedger ledger})> get _stock =>
      _lots.where(
        (l) =>
            l.ledger.remaining > 0 &&
            !(_untouched(l.ledger) &&
                l.lot.addedAt.toLocal().isBefore(staleBefore)),
      );

  double get remaining =>
      roundQuantity(_stock.fold(0, (sum, l) => sum + l.ledger.remaining));

  /// The unit of the lots counted as stock.
  String? get unit => _stock.firstOrNull?.lot.unit;

  static bool _untouched(LotLedger ledger) => ledger.effectiveEvents.every(
    (e) =>
        e.kind == PantryEventKind.stockIn ||
        (e.kind == PantryEventKind.adjust &&
            e.reason == PantryEventReason.correction),
  );

  /// Whether anything was used or thrown away since [from].
  bool movedSince(DateTime from) => _lots.any(
    (l) => l.ledger.effectiveEvents.any(
      (e) =>
          (e.kind == PantryEventKind.consume ||
              e.kind == PantryEventKind.discard) &&
          !e.at.toLocal().isBefore(from),
    ),
  );

  /// Quantity used per day from [from] to [today], or from the first lot
  /// when the product is newer than that; null when nothing was used or the
  /// stretch is under a week.
  double? usePerDay(DateTime from, DateTime today) {
    var used = 0.0;
    DateTime? first;
    for (final l in _lots) {
      for (final e in l.ledger.effectiveEvents) {
        if (e.kind == PantryEventKind.consume &&
            !e.at.toLocal().isBefore(from)) {
          used -= e.delta;
        }
      }
      final added = l.lot.addedAt.toLocal();
      if (first == null || added.isBefore(first)) first = added;
    }
    final begin = first != null && first.isAfter(from) ? first : from;
    final days = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(begin.year, begin.month, begin.day)).inDays;
    if (used <= 0 || days < 7) return null;
    return used / days;
  }
}
