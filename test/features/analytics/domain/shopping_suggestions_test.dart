import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/models/shopping_suggestion.dart';
import 'package:scontrini/features/analytics/domain/shopping_suggestions.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';

import 'history_fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 25, 12);
  const milk = 1;
  const coffee = 2;

  PurchaseHistory bought(Map<int, List<DateTime>> days) =>
      history([
        for (final MapEntry(key: product, value: dates) in days.entries)
          for (final d in dates)
            receipt(d, 100, items: [item(100, productId: product)]),
      ]).copyWith(
        products: const {
          milk: ProductInfo(id: milk, name: 'Latte'),
          coffee: ProductInfo(id: coffee, name: 'Caffè'),
        },
      );

  var nextId = 1;
  PantryEvent ev(PantryEventKind kind, double delta, DateTime localAt) =>
      PantryEvent(
        id: nextId++,
        lotId: 0,
        kind: kind,
        delta: delta,
        at: localAt.toUtc(),
      );

  /// A lot of [product] added on [added] with [quantity], then [moves]
  /// (consume deltas, local times).
  PantryHistoryLot lot(
    int product,
    DateTime added,
    double quantity, [
    List<(double, DateTime)> moves = const [],
  ]) => PantryHistoryLot(
    id: nextId++,
    name: 'lot',
    source: PantrySource.receipt,
    initialQuantity: quantity,
    addedAt: added.toUtc(),
    productId: product,
    events: [
      ev(PantryEventKind.stockIn, quantity, added),
      for (final (delta, at) in moves) ev(PantryEventKind.consume, delta, at),
    ],
  );

  List<DateTime> weekly(int count, {required DateTime last}) => [
    for (var i = count - 1; i >= 0; i--)
      DateTime(last.year, last.month, last.day - 7 * i, 10),
  ];

  test('a product finished in the pantry is on the list for today', () {
    final purchases = bought({milk: weekly(4, last: DateTime(2026, 11, 21))});
    final pantry = PantryHistory(
      lots: [
        lot(milk, DateTime(2026, 11, 21, 10), 1, [
          (-1, DateTime(2026, 11, 23, 9)),
        ]),
      ],
    );
    final s = ShoppingSuggestions.forToday(purchases, pantry, today).single;
    expect(s.name, 'Latte');
    expect(s.reason, ShoppingReason.finished);
    expect(s.dueDay, DateTime(2026, 11, 25));
    expect(s.intervalDays, 7);
  });

  test('stock that runs out within three days at the recent pace is '
      'running low; more stock keeps it off the list', () {
    final purchases = bought({
      milk: [DateTime(2026, 10, 26, 10), DateTime(2026, 11, 20, 10)],
    });
    // Ten used in 30 days (one every 3 days), 1 left: runs out in 3 days.
    PantryHistory pantry(double left) => PantryHistory(
      lots: [
        lot(milk, DateTime(2026, 10, 26, 10), 10 + left, [
          (-10, DateTime(2026, 11, 20, 9)),
        ]),
      ],
    );
    final low = ShoppingSuggestions.forToday(purchases, pantry(1), today);
    expect(low.single.reason, ShoppingReason.runningLow);
    expect(low.single.remaining, 1);
    expect(low.single.dueDay, DateTime(2026, 11, 28));

    expect(ShoppingSuggestions.forToday(purchases, pantry(5), today), isEmpty);
  });

  test('without pantry movements the usual gap decides', () {
    final purchases = bought({
      // Every 7 days, last 6 days ago: due tomorrow.
      milk: weekly(4, last: DateTime(2026, 11, 19)),
      // Every 14 days, last 2 days ago: not due.
      coffee: [
        DateTime(2026, 10, 26, 10),
        DateTime(2026, 11, 9, 10),
        DateTime(2026, 11, 23, 10),
      ],
    });
    final s = ShoppingSuggestions.forToday(
      purchases,
      PantryHistory.empty,
      today,
    ).single;
    expect(s.name, 'Latte');
    expect(s.reason, ShoppingReason.usualInterval);
    expect(s.dueDay, DateTime(2026, 11, 26));
  });

  test('an old lot nobody updated does not count as stock', () {
    final purchases = bought({milk: weekly(4, last: DateTime(2026, 11, 21))});
    final pantry = PantryHistory(
      lots: [
        // Forgotten: added two months ago, never moved.
        lot(milk, DateTime(2026, 9, 20, 10), 1),
        lot(milk, DateTime(2026, 11, 21, 10), 1, [
          (-1, DateTime(2026, 11, 23, 9)),
        ]),
      ],
    );
    expect(
      ShoppingSuggestions.forToday(purchases, pantry, today).single.reason,
      ShoppingReason.finished,
    );
  });

  test('bought once, or no longer bought, stays off the list', () {
    final purchases = bought({
      coffee: [DateTime(2026, 11, 20, 10)],
      // Weekly until August: more than three gaps ago.
      milk: weekly(5, last: DateTime(2026, 8, 30)),
    });
    expect(
      ShoppingSuggestions.forToday(purchases, PantryHistory.empty, today),
      isEmpty,
    );
  });

  test('overdue first, then by due day', () {
    final purchases = bought({
      milk: weekly(4, last: DateTime(2026, 11, 15)),
      coffee: weekly(4, last: DateTime(2026, 11, 20)),
    });
    final list = ShoppingSuggestions.forToday(
      purchases,
      PantryHistory.empty,
      today,
    );
    expect(list.map((s) => s.name), ['Latte', 'Caffè']);
    expect(list.first.dueDay, DateTime(2026, 11, 22));
  });
}
