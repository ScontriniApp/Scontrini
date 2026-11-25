import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/pantry_history.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';
import 'package:scontrini/features/analytics/domain/pantry_metrics.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';

import 'history_fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 24, 12);
  final november = AnalyticsPeriod.of(PeriodKind.month, today);

  var nextEventId = 1;
  PantryEvent ev(
    PantryEventKind kind,
    double delta,
    DateTime localAt, {
    PantryEventReason? reason,
    int? reverts,
  }) => PantryEvent(
    id: nextEventId++,
    lotId: 0,
    kind: kind,
    delta: delta,
    at: localAt.toUtc(),
    reason: reason,
    revertsEventId: reverts,
  );

  var nextLotId = 1;
  PantryHistoryLot lot({
    required double quantity,
    required List<PantryEvent> events,
    int? priceCents,
    int? receiptId,
    int? productId,
    int? categoryId,
    String name = 'LOT',
    PantrySource source = PantrySource.receipt,
  }) => PantryHistoryLot(
    id: nextLotId++,
    name: name,
    source: source,
    initialQuantity: quantity,
    addedAt: DateTime(2026, 10).toUtc(),
    events: [
      ev(PantryEventKind.stockIn, quantity, DateTime(2026, 10)),
      ...events,
    ],
    receiptId: receiptId,
    productId: productId,
    categoryId: categoryId,
    priceCents: priceCents,
  );

  test('waste is valued at its share of the lot price, by discard day', () {
    final pantry = PantryHistory(
      lots: [
        // Half used, half thrown away in November: 1,00 € wasted.
        lot(
          quantity: 2,
          priceCents: 200,
          productId: 1,
          categoryId: 5,
          events: [
            ev(PantryEventKind.consume, -1, DateTime(2026, 11, 2)),
            ev(
              PantryEventKind.discard,
              -1,
              DateTime(2026, 11, 9),
              reason: PantryEventReason.spoiled,
            ),
          ],
        ),
        // Thrown away in October, inside the compared days.
        lot(
          quantity: 1,
          priceCents: 300,
          productId: 2,
          events: [
            ev(
              PantryEventKind.discard,
              -1,
              DateTime(2026, 10, 10),
              reason: PantryEventReason.expired,
            ),
          ],
        ),
      ],
    );
    const purchases = PurchaseHistory(
      receipts: [],
      products: {1: ProductInfo(id: 1, name: 'Latte')},
      categories: {
        5: CategoryInfo(id: 5, name: 'Latticini', icon: 'x', color: 0),
      },
    );
    final o = PantryMetrics.overview(purchases, pantry, november, today);

    expect(o.hasPantry, isTrue);
    expect(o.wasted.cents, 100);
    expect(o.wasted.previousCents, 300);
    // 1,00 € used, 1,00 € wasted in November.
    expect(o.wasteRate, 0.5);
    expect(o.reasons.single.reason, PantryEventReason.spoiled);
    expect(o.categories.single.category?.name, 'Latticini');
    expect(o.products.single.name, 'Latte');
    expect(o.products.single.lotCount, 1);
  });

  test('a reverted discard does not count', () {
    final discard = ev(
      PantryEventKind.discard,
      -1,
      DateTime(2026, 11, 3),
      reason: PantryEventReason.other,
    );
    final pantry = PantryHistory(
      lots: [
        lot(
          quantity: 1,
          priceCents: 500,
          events: [
            discard,
            ev(
              PantryEventKind.revert,
              1,
              DateTime(2026, 11, 3),
              reverts: discard.id,
            ),
          ],
        ),
      ],
    );
    final o = PantryMetrics.overview(
      PurchaseHistory.empty,
      pantry,
      november,
      today,
    );
    expect(o.wasted.cents, 0);
    expect(o.wasteRate, isNull);
    expect(o.products, isEmpty);
  });

  test('a lot without a price is counted, not valued', () {
    final pantry = PantryHistory(
      lots: [
        lot(
          quantity: 1,
          source: PantrySource.gift,
          events: [ev(PantryEventKind.discard, -1, DateTime(2026, 11, 3))],
        ),
      ],
    );
    final o = PantryMetrics.overview(
      PurchaseHistory.empty,
      pantry,
      november,
      today,
    );
    expect(o.wasted.cents, 0);
    expect(o.unpricedDiscards, 1);
  });

  test("the period's spending splits into used, wasted, left and not in "
      'the pantry, exactly', () {
    final r = receipt(DateTime(2026, 11, 5), 1000);
    final pantry = PantryHistory(
      lots: [
        // 1/3 used, 1/3 wasted, 1/3 left of 1,00 €.
        lot(
          quantity: 3,
          priceCents: 100,
          receiptId: r.id,
          events: [
            ev(PantryEventKind.consume, -1, DateTime(2026, 11, 6)),
            ev(PantryEventKind.discard, -1, DateTime(2026, 11, 7)),
          ],
        ),
        // Never moved: all still in the pantry.
        lot(quantity: 1, priceCents: 600, receiptId: r.id, events: const []),
        // From another receipt: not part of this period's spending.
        lot(quantity: 1, priceCents: 999, receiptId: 9999, events: const []),
      ],
    );
    final fate = PantryMetrics.overview(
      history([r]),
      pantry,
      november,
      today,
    ).fate;

    expect(fate.totalCents, 1000);
    expect(fate.usedCents + fate.wastedCents + fate.inPantryCents, 700);
    // Ties in the split go to the earlier part.
    expect(fate.usedCents, 34);
    expect(fate.wastedCents, 33);
    expect(fate.inPantryCents, 633);
    expect(fate.notInPantryCents, 300);
    expect(fate.lotCount, 2);
    expect(fate.untouchedLotCount, 1);
  });

  test('a recount up makes the parts larger, shares still add up', () {
    final r = receipt(DateTime(2026, 11, 5), 400);
    final pantry = PantryHistory(
      lots: [
        lot(
          quantity: 1,
          priceCents: 400,
          receiptId: r.id,
          events: [
            ev(PantryEventKind.consume, -1, DateTime(2026, 11, 6)),
            // Found another one: 1 used, 1 left.
            ev(
              PantryEventKind.adjust,
              1,
              DateTime(2026, 11, 7),
              reason: PantryEventReason.recount,
            ),
          ],
        ),
      ],
    );
    final fate = PantryMetrics.overview(
      history([r]),
      pantry,
      november,
      today,
    ).fate;
    expect(fate.usedCents, 200);
    expect(fate.inPantryCents, 200);
    expect(fate.notInPantryCents, 0);
    expect(fate.untouchedLotCount, 0);
  });

  test('no receipts in the period: the fate is empty', () {
    final o = PantryMetrics.overview(
      PurchaseHistory.empty,
      PantryHistory.empty,
      november,
      today,
    );
    expect(o.hasPantry, isFalse);
    expect(o.fate.isEmpty, isTrue);
  });
}
