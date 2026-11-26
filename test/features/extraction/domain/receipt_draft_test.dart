import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/domain/receipt_draft.dart';

const _milk = ParsedItem(
  rawName: 'LATTE INTERO',
  unitPriceCents: 129,
  lineTotalCents: 129,
);
const _bread = ParsedItem(
  rawName: 'PANE',
  unitPriceCents: 110,
  lineTotalCents: 110,
);

ReceiptDraft _draft() => ReceiptDraft.fromParsed(
  const ParsedReceipt(
    storeName: 'SUPERMERCATO',
    totalCents: 300,
    items: [_milk, _bread],
    warnings: [ParseWarning.missingDate, ParseWarning.totalMismatch],
  ),
  categoryIds: const [3],
);

void main() {
  test('starts from the parse, categories in row order', () {
    final draft = _draft();
    expect(draft.items.map((i) => i.item.rawName), ['LATTE INTERO', 'PANE']);
    expect(draft.categoryIds, [3, null]);
    expect(draft.receipt.items, [_milk, _bread]);
    expect(draft.receipt.warnings, [
      ParseWarning.missingDate,
      ParseWarning.totalMismatch,
    ]);
  });

  test('header edits recompute the warnings', () {
    var draft = _draft().withDate(DateTime(2026, 11, 24, 10)).withTotal(239);
    expect(draft.receipt.warnings, isEmpty);

    draft = draft.withStore('  ').withTotal(null);
    expect(draft.receipt.storeName, isNull);
    expect(draft.receipt.warnings, [
      ParseWarning.missingStore,
      ParseWarning.missingTotal,
    ]);

    draft = draft.withStore(' COOP ').withTotal(200).withDiscount(39);
    expect(draft.receipt.storeName, 'COOP');
    expect(draft.receipt.computedTotalCents, 200);
    expect(draft.receipt.warnings, isEmpty);
  });

  test('row edits change the sum and keep the categories aligned', () {
    final draft = _draft()
        .removeItem(0)
        .addItem(
          const DraftItem(
            item: ParsedItem(
              rawName: 'MELE',
              unitPriceCents: 199,
              lineTotalCents: 190,
              quantity: 0.955,
              unit: QuantityUnit.kilogram,
            ),
            categoryId: 1,
          ),
        )
        .replaceItem(0, const DraftItem(item: _bread, categoryId: 2));
    expect(draft.categoryIds, [2, 1]);
    expect(draft.receipt.computedTotalCents, 300);
    expect(draft.receipt.warnings, [ParseWarning.missingDate]);

    final undone = draft.insertItem(0, const DraftItem(item: _milk));
    expect(undone.items.map((i) => i.item.rawName), [
      'LATTE INTERO',
      'PANE',
      'MELE',
    ]);
  });

  test('an edited row is flagged when quantity × price is off', () {
    final wrong = _draft().replaceItem(
      0,
      const DraftItem(
        item: ParsedItem(
          rawName: 'YOGURT',
          unitPriceCents: 60,
          lineTotalCents: 150,
          quantity: 2,
        ),
      ),
    );
    expect(wrong.items.first.item.warnings, [ParseWarning.lineTotalMismatch]);

    final fixed = wrong.replaceItem(
      0,
      DraftItem(item: wrong.items.first.item.copyWith(lineTotalCents: 120)),
    );
    expect(fixed.items.first.item.warnings, isEmpty);
  });

  test('a weight rounded to the gram adds up', () {
    bool addsUp(double kg, int pricePerKg, int amount) =>
        ReceiptDraft.lineAddsUp(
          ParsedItem(
            rawName: 'X',
            unitPriceCents: pricePerKg,
            lineTotalCents: amount,
            quantity: kg,
            unit: QuantityUnit.kilogram,
          ),
        );
    expect(addsUp(0.955, 199, 190), isTrue);
    expect(addsUp(0.5, 2990, 1496), isTrue);
    expect(addsUp(0.5, 2990, 1500), isFalse);
  });

  test('rows start unconfirmed; confirmed or corrected rows let it save', () {
    var draft = _draft();
    expect(draft.pendingCount, 2);
    expect(draft.canSave, isFalse);

    draft = draft.withConfirmed(0);
    expect(draft.pendingCount, 1);

    // The review sheet returns corrected rows as confirmed; they stay so.
    draft = draft.replaceItem(
      1,
      const DraftItem(item: _bread, categoryId: 2, confirmed: true),
    );
    expect(draft.items[1].confirmed, isTrue);
    expect(draft.canSave, isTrue);

    // Header edits keep the confirmations.
    expect(draft.withStore('COOP').canSave, isTrue);

    draft = draft.withConfirmed(0, confirmed: false);
    expect(draft.canSave, isFalse);
    expect(draft.removeItem(0).canSave, isTrue);
    expect(draft.removeItem(0).removeItem(0).canSave, isFalse);
  });

  test('confirm all confirms every row', () {
    final draft = _draft().withConfirmed(0).confirmAll();
    expect(draft.items.map((i) => i.confirmed), [true, true]);
    expect(draft.canSave, isTrue);
  });

  test('unconfirm all puts every row back to check', () {
    final draft = _draft().confirmAll().unconfirmAll();
    expect(draft.items.map((i) => i.confirmed), [false, false]);
    expect(draft.pendingCount, 2);
    expect(draft.canSave, isFalse);
  });
}
