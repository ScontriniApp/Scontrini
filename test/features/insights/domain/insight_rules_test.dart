import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/insights/domain/insight.dart';
import 'package:scontrini/features/insights/domain/insight_engine.dart';
import 'package:scontrini/features/insights/domain/insight_rule.dart';
import 'package:scontrini/features/insights/domain/rules/category_spike_rule.dart';
import 'package:scontrini/features/insights/domain/rules/frequent_waste_rule.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';

import '../../analytics/domain/history_fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 20, 12);
  const drinks = 5;
  const meat = 2;

  PurchaseHistory named(List<PurchaseReceipt> receipts) => history(receipts)
      .copyWith(
        categories: const {
          drinks: CategoryInfo(
            id: drinks,
            name: 'Bevande',
            icon: 'x',
            color: 0,
          ),
          meat: CategoryInfo(id: meat, name: 'Carne', icon: 'x', color: 0),
        },
        products: const {1: ProductInfo(id: 1, name: 'Mele')},
      );

  /// One receipt on [day] of [month] (2026) with [drinksCents] of drinks
  /// and 50,00 € of meat.
  PurchaseReceipt shop(int month, int day, int drinksCents) => receipt(
    DateTime(2026, month, day, 10),
    drinksCents + 5000,
    items: [
      item(drinksCents, categoryId: drinks),
      item(5000, categoryId: meat),
    ],
  );

  InsightInput input(
    PurchaseHistory purchases, {
    PantryHistory pantry = PantryHistory.empty,
    DateTime? on,
  }) => InsightInput(purchases: purchases, pantry: pantry, today: on ?? today);

  group('CategorySpikeRule', () {
    test('fires when this month is well above the same days of earlier '
        'months', () {
      final h = named([
        shop(8, 10, 1000),
        shop(9, 10, 1200),
        shop(10, 10, 800),
        // Outside 1–20 of October: not part of the usual.
        shop(10, 25, 9000),
        shop(11, 10, 3500),
      ]);
      final i = const CategorySpikeRule().evaluate(input(h)).single;
      expect(
        i,
        const Insight.categorySpike(
          categoryId: drinks,
          categoryName: 'Bevande',
          cents: 3500,
          usualCents: 1000,
          monthsCompared: 3,
        ),
      );
      expect(i.monthlyImpactCents, 2500);
    });

    test('stays quiet below the ratio, below 10 € extra, early in the '
        'month, or with fewer than two months to compare', () {
      const rule = CategorySpikeRule();
      // +20 %: below 1.3×.
      expect(
        rule.evaluate(
          input(
            named([shop(9, 10, 1000), shop(10, 10, 1000), shop(11, 10, 1200)]),
          ),
        ),
        isEmpty,
      );
      // Doubled, but only 3 € more.
      expect(
        rule.evaluate(
          input(
            named([shop(9, 10, 300), shop(10, 10, 300), shop(11, 10, 600)]),
          ),
        ),
        isEmpty,
      );
      // Before the 7th.
      expect(
        rule.evaluate(
          input(
            named([shop(9, 2, 1000), shop(10, 2, 1000), shop(11, 2, 5000)]),
            on: DateTime(2026, 11, 5, 12),
          ),
        ),
        isEmpty,
      );
      // One earlier month only.
      expect(
        rule.evaluate(input(named([shop(10, 10, 1000), shop(11, 10, 5000)]))),
        isEmpty,
      );
    });

    test('a month with no receipts is not a usual month', () {
      final h = named([
        // August, then nothing in September (holiday).
        shop(8, 10, 1000),
        shop(10, 10, 1000),
        shop(11, 10, 3000),
      ]);
      final i =
          const CategorySpikeRule().evaluate(input(h)).single
              as CategorySpikeInsight;
      expect(i.usualCents, 1000);
      expect(i.monthsCompared, 2);
    });
  });

  group('FrequentWasteRule', () {
    var nextId = 1;
    PantryEvent ev(PantryEventKind kind, double delta, DateTime at) =>
        PantryEvent(
          id: nextId++,
          lotId: 0,
          kind: kind,
          delta: delta,
          at: at.toUtc(),
        );

    /// A lot of apples (1 kg, 3,00 €) added on [added]; [wasted] throws
    /// half away, otherwise all is used; [open] leaves it in the pantry.
    PantryHistoryLot apples(
      DateTime added, {
      bool wasted = false,
      bool open = false,
      int? productId = 1,
      int? price = 300,
    }) {
      final later = added.add(const Duration(days: 3));
      return PantryHistoryLot(
        id: nextId++,
        name: 'MELE',
        source: PantrySource.receipt,
        initialQuantity: 1,
        addedAt: added.toUtc(),
        productId: productId,
        priceCents: price,
        events: [
          ev(PantryEventKind.stockIn, 1, added),
          if (!open) ...[
            ev(PantryEventKind.consume, -0.5, later),
            ev(
              wasted ? PantryEventKind.discard : PantryEventKind.consume,
              -0.5,
              later,
            ),
          ],
        ],
      );
    }

    test('fires when a third or more of the closed lots had waste', () {
      final pantry = PantryHistory(
        lots: [
          apples(DateTime(2026, 9), wasted: true),
          apples(DateTime(2026, 9, 20), wasted: true),
          apples(DateTime(2026, 10, 10)),
          apples(DateTime(2026, 11)),
          apples(DateTime(2026, 11, 18), open: true),
          // Before the 90 days: not counted.
          apples(DateTime(2026, 7), wasted: true),
        ],
      );
      final i = const FrequentWasteRule()
          .evaluate(input(named(const []), pantry: pantry))
          .single;
      expect(
        i,
        const Insight.frequentWaste(
          productName: 'Mele',
          productId: 1,
          wastedLots: 2,
          closedLots: 4,
          wastedCents: 300,
          days: 90,
        ),
      );
      expect(i.monthlyImpactCents, 100);
    });

    test('stays quiet with too few closed lots, too little waste, or '
        'under 1 €', () {
      const rule = FrequentWasteRule();
      PantryHistory p(List<PantryHistoryLot> lots) => PantryHistory(lots: lots);
      // Two closed lots only.
      expect(
        rule.evaluate(
          input(
            named(const []),
            pantry: p([
              apples(DateTime(2026, 10), wasted: true),
              apples(DateTime(2026, 10, 8), wasted: true),
            ]),
          ),
        ),
        isEmpty,
      );
      // One waste in seven.
      expect(
        rule.evaluate(
          input(
            named(const []),
            pantry: p([
              apples(DateTime(2026, 9), wasted: true),
              for (var d = 1; d <= 6; d++) apples(DateTime(2026, 10, d)),
            ]),
          ),
        ),
        isEmpty,
      );
      // Cheap: 0,40 € thrown away.
      expect(
        rule.evaluate(
          input(
            named(const []),
            pantry: p([
              for (var d = 1; d <= 4; d++)
                apples(DateTime(2026, 10, d), wasted: d.isOdd, price: 40),
            ]),
          ),
        ),
        isEmpty,
      );
    });
  });

  test('the engine ranks by euros a month at stake', () {
    final h = named([
      shop(9, 10, 1000),
      shop(10, 10, 1000),
      shop(11, 10, 3000),
    ]);
    final pantry = PantryHistory(
      lots: [
        for (var d = 1; d <= 3; d++)
          PantryHistoryLot(
            id: 100 + d,
            name: 'MELE',
            source: PantrySource.receipt,
            initialQuantity: 1,
            addedAt: DateTime(2026, 10, d).toUtc(),
            productId: 1,
            priceCents: 300,
            events: [
              PantryEvent(
                id: 200 + d,
                lotId: 100 + d,
                kind: PantryEventKind.stockIn,
                delta: 1,
                at: DateTime(2026, 10, d).toUtc(),
              ),
              PantryEvent(
                id: 300 + d,
                lotId: 100 + d,
                kind: PantryEventKind.discard,
                delta: -1,
                at: DateTime(2026, 10, d + 2).toUtc(),
              ),
            ],
          ),
      ],
    );
    final ranked = evaluateInsights(input(h, pantry: pantry));
    // Spike: 20,00 € extra; waste: 9,00 € over 90 days = 3,00 € a month.
    expect(ranked.map((i) => i.runtimeType), [
      CategorySpikeInsight,
      FrequentWasteInsight,
    ]);
  });
}
