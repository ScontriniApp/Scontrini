# Pantry and statistics: design rules

Status: agreed on 2026-11-19/20. Schema v2, `PantryRepository` and the pantry tab
implement rules 1–7 (`lib/features/pantry/`). Rule 8 has its unique column and hash function; the
receipt save step (not built yet) must compute the hash and handle the collision.
This document fixes **what** gets recorded and **when statistics may change**, before the schema
and the UI are written. The goal: a correction is never counted as a purchase, and statistics
change only when a real-world fact changes.

## Flow

```
parsing → receipt review → confirm ──→ analytics (purchases)
                                  └──→ pantry triage (swipe) → pantry
```

- Triage happens **after** the receipt is confirmed. Swiping left means "not in the pantry", never
  "remove from the receipt": the purchase still counts.
- Edits made on a triage card before it is accepted are draft edits: they create no event.

## Model

- **Every item has an origin**: a receipt (photo + label) or a manual entry. Nothing exists without one.
- **Receipt tag** = the receipt's **transaction hash** (`receipts.transaction_hash`), shown as its
  first 8 hex characters (`#a3f91c02`) on every pantry lot from that receipt. Manual lots show their
  source instead ("Already at home", "Gift", "Bought, no receipt").
  - SHA-256 of the receipt's identity: store (VAT number, else normalised name), date/time to the
    minute in UTC, total in cents, and later the printed document number
    (`transactionHash()` in `lib/features/receipts/domain/transaction_hash.dart`).
  - Computed at **confirmation**, from the reviewed fields; drafts have none. Recomputed when one of
    those fields is corrected. Links between rows, lots and receipts use the internal id, so a
    changed hash breaks nothing.
- **Lot** (`pantry_lots`) = what one origin put in the pantry for one product. It stores the
  purchased (`initial`) quantity; the remaining quantity is derived from its events. Two milks from receipt A and one from
  receipt B are two lots; the UI may group them as "Milk: 3".
- **Purchase** = a row of a confirmed receipt, or a manual entry marked "bought".
- **Purchase occasion** = one origin (one receipt, or one manual purchase) containing the product.
  Repeated rows of the same product on one receipt are one occasion; their quantities are summed and
  they become **one triage card** and **one lot**. The `receipt_items` rows stay as printed.

## Rules

1. **Statistics are derived, never stored as counters.** Every figure is a query over the current
   facts. Correcting a fact makes the next query right. Any cache must be disposable and rebuildable.
2. **Facts live in separate places.**

   | Fact | Where | Can it change? |
   |---|---|---|
   | Purchase | `receipt_items` of a `confirmed` receipt; manual purchases | Yes: a correction *edits the row*, it never adds one |
   | Pantry movement | `pantry_events`, append-only | No: it can only be voided |
   | Correction | Edit of a purchase, or a `void` / `adjust` event | — |

3. **Only confirmed receipts count.** Drafts do not exist for statistics or the pantry.
4. **Quantity correction = `adjust` with the difference applied to both initial and remaining.**
   Example: receipt read as milk ×2, one consumed (1 of 2 left), receipt corrected to ×3 → lot is
   2 of 3. Recorded consumption stays at 1. If the correction goes below what was already consumed,
   remaining becomes 0 and the lot is exhausted.
5. **Manual add asks "bought / already at home / gift".** Only "bought" counts as a purchase
   (price optional). "Already at home" is the default while first filling the pantry.
6. **Deleting a receipt deletes everything that came from it**, in cascade:
   - its rows, so its purchases leave every statistic;
   - its lots in the pantry (set to 0 and removed), whatever was left in them;
   - the consume / discard / adjust events of those lots, so their consumption and waste leave the
     history too.

   Lots from other origins are untouched. Example: milk ×2 on the deleted receipt, 1 still in the
   pantry → that lot goes to 0 and disappears; milk from other receipts stays.
7. **Quantities are never negative.** Every operation (consume, adjust, delete) clamps at 0.
8. **No duplicate receipts.** `transaction_hash` is unique, so confirming the same receipt twice
   fails. On a collision the app asks "is this the same receipt?"; if the user says no, the hash is
   recomputed with `attempt: 1` (2, …).

## Pantry events

| Event | Cause / source | Counts as purchase? | Counts as consumption / waste? |
|---|---|---|---|
| `stock_in` | `receipt` (from triage) | No: the purchase is the receipt row | — |
| `stock_in` | `manual_purchase` | Yes | — |
| `stock_in` | `initial_stock`, `gift` | No | — |
| `consume` | slider moved down | — | Consumption |
| `discard` | `expired`, `spoiled`, `other` | — | Waste (the quantity left) |
| `adjust` (`recount`) | slider moved up | — | No |
| `adjust` (`correction`) | purchased quantity corrected on the receipt | — | No |
| `revert` | cancels event X (undo) | — | Removes X from all figures |

- Every event stores the `delta` it actually applied to the remaining quantity, already clamped,
  so remaining = sum of deltas and is never negative. A `revert` carries the opposite delta.
- Undo is a stack: only the latest effective consume / discard / recount can be reverted, so the lot
  always returns to a state that really existed. Stock-ins and corrections follow the receipt and
  are not undoable.
- The slider writes one event when released, not while dragging. Moving it back up within
  5 minutes of a consume corrects that consume (revert + the net consume) instead of recording a
  recount, so a slip of the finger never counts as consumption.
- Every consume, finish and discard in the UI shows a snackbar with **Undo**.

## Statistics

**Per product, from purchases** (confirmed receipts + manual purchases):
- number of purchase occasions; last purchase;
- average interval between occasions, and the estimated next purchase;
- average quantity per occasion;
- unit price: trend, min/max, per store; €/kg or €/l for weighed items. Receipt rows only: manual
  purchases without a price are left out;
- total spend and share of discounts;
- stores where it is bought.

**Per product, from the pantry** (events not voided):
- current stock;
- average life of a lot (stock-in → exhausted);
- consumption rate (units/week) and estimated run-out date;
- waste rate (discarded vs consumed) and euros wasted (discarded fraction × lot purchase price);
- over-buying: occasions where stock was still > 0.

**Global**: current pantry value, monthly waste in euros, most-wasted categories.
Waste in euros, most-wasted categories and products, and where a period's spending went (used,
thrown away, still at home, not in the pantry) are on the analytics tab's "Dispensa" sub-tab
(`PantryMetrics`, 2026-11-25). A discarded share of a lot is worth that share of its price, taken
of consumed + discarded + left. Current pantry value is still to do.

## Grouping

Statistics group by `productId` (canonical product via `product_aliases`). Until the matcher exists,
`productId` may be null and grouping falls back to the normalised raw name. Merging two products
later needs no migration of statistics, because they are derived (rule 1).
