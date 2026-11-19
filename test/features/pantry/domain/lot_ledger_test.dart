import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';
import 'package:scontrini/features/pantry/domain/triage_grouping.dart';

PantryEvent _e(
  int id,
  PantryEventKind kind,
  double delta, {
  PantryEventReason? reason,
  int? reverts,
}) => PantryEvent(
  id: id,
  lotId: 1,
  kind: kind,
  delta: delta,
  reason: reason,
  revertsEventId: reverts,
  at: DateTime.utc(2026),
);

void main() {
  group('LotLedger', () {
    test('reverted events and reverts do not count', () {
      final ledger = LotLedger([
        _e(1, PantryEventKind.stockIn, 2),
        _e(2, PantryEventKind.consume, -1),
        _e(3, PantryEventKind.revert, 1, reverts: 2),
        _e(4, PantryEventKind.consume, -0.5),
      ]);

      expect(ledger.remaining, 1.5);
      expect(ledger.consumed, 0.5);
      expect(ledger.effectiveEvents.map((e) => e.id), [1, 4]);
      expect(ledger.undoTarget?.id, 4);
    });

    test('rounds floating-point crumbs', () {
      final ledger = LotLedger([
        _e(1, PantryEventKind.stockIn, 0.3),
        _e(2, PantryEventKind.consume, -0.1),
        _e(3, PantryEventKind.consume, -0.2),
      ]);
      expect(ledger.remaining, 0);
      expect(ledger.status, PantryLotStatus.consumed);
    });

    test('corrections and stock-ins are not undoable', () {
      expect(LotLedger([_e(1, PantryEventKind.stockIn, 1)]).undoTarget, isNull);
      expect(
        LotLedger([
          _e(1, PantryEventKind.stockIn, 1),
          _e(
            2,
            PantryEventKind.adjust,
            1,
            reason: PantryEventReason.correction,
          ),
        ]).undoTarget,
        isNull,
      );
    });
  });

  group('groupForTriage', () {
    TriageRow row(
      int id,
      String name, {
      int? productId,
      String unit = 'pz',
      double quantity = 1,
    }) => TriageRow(
      receiptItemId: id,
      name: name,
      quantity: quantity,
      unit: unit,
      netCents: 100,
      productId: productId,
    );

    test('groups by matched product, then by normalised name and unit', () {
      final cards = groupForTriage([
        row(1, 'MELE', unit: 'kg', quantity: 0.8),
        row(2, 'Latte', productId: 7),
        row(3, 'LATTE INTERO', productId: 7),
        row(4, ' mele ', unit: 'kg', quantity: 0.45),
        row(5, 'MELE'),
      ]);

      expect(cards, hasLength(3));
      expect(cards[0].receiptItemIds, [1, 4]);
      expect(cards[0].quantity, 1.25);
      expect(cards[1].receiptItemIds, [2, 3]);
      expect(cards[2].receiptItemIds, [5]);
    });
  });
}
