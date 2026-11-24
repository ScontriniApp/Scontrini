import 'package:drift/drift.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/domain/triage_grouping.dart';

/// Reads and changes the pantry, following `docs/pantry_and_stats.md`:
/// lots record what was bought, an append-only event log records what
/// happened to it, and every figure is derived from those facts.
///
/// Deleting a receipt needs nothing here: the foreign keys remove its lots
/// and their events.
class PantryRepository {
  new(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  DateTime get _now => _clock().toUtc();

  /// A slider moved up within this time after a consume corrects that
  /// consume instead of recording a recount (docs/pantry_and_stats.md).
  static const correctionWindow = Duration(minutes: 5);

  /// Lots with their remaining quantity, newest first. Closed lots
  /// (consumed or discarded) are included only when [includeClosed].
  Stream<List<PantryLot>> watchLots({bool includeClosed = false}) {
    final query =
        _db.select(_db.pantryLots).join([
          leftOuterJoin(
            _db.pantryEvents,
            _db.pantryEvents.lotId.equalsExp(_db.pantryLots.id),
          ),
          leftOuterJoin(
            _db.receipts,
            _db.receipts.id.equalsExp(_db.pantryLots.receiptId),
          ),
        ])..orderBy([
          OrderingTerm.desc(_db.pantryLots.addedAt),
          OrderingTerm.desc(_db.pantryLots.id),
          OrderingTerm.asc(_db.pantryEvents.id),
        ]);
    return query.watch().map((rows) {
      final lots = <int, PantryLotRow>{};
      final hashes = <int, String?>{};
      final events = <int, List<PantryEvent>>{};
      for (final row in rows) {
        final lot = row.readTable(_db.pantryLots);
        lots[lot.id] = lot;
        hashes[lot.id] = row.readTableOrNull(_db.receipts)?.transactionHash;
        final event = row.readTableOrNull(_db.pantryEvents);
        final list = events.putIfAbsent(lot.id, () => []);
        if (event != null) list.add(_toEvent(event));
      }
      return [
            for (final lot in lots.values)
              _toLot(lot, LotLedger(events[lot.id]!), hashes[lot.id]),
          ]
          .where((l) => includeClosed || l.status == PantryLotStatus.active)
          .toList();
    });
  }

  Future<PantryLot> lot(int lotId) async {
    final row = await (_db.select(
      _db.pantryLots,
    )..where((l) => l.id.equals(lotId))).getSingle();
    final receiptId = row.receiptId;
    final receipt = receiptId == null
        ? null
        : await (_db.select(
            _db.receipts,
          )..where((r) => r.id.equals(receiptId))).getSingleOrNull();
    return _toLot(row, await _ledger(lotId), receipt?.transactionHash);
  }

  /// Categories for grouping and for the manual-add form, by name.
  Stream<List<PantryCategory>> watchCategories() =>
      (_db.select(
        _db.categories,
      )..orderBy([(c) => OrderingTerm.asc(c.name)])).watch().map(
        (rows) => [
          for (final c in rows)
            PantryCategory(id: c.id, name: c.name, color: c.color),
        ],
      );

  /// Every event of a lot, reverts included, in order.
  Future<List<PantryEvent>> events(int lotId) async {
    final rows =
        await (_db.select(_db.pantryEvents)
              ..where((e) => e.lotId.equals(lotId))
              ..orderBy([(e) => OrderingTerm.asc(e.id)]))
            .get();
    return rows.map(_toEvent).toList();
  }

  /// Swipe cards for a confirmed receipt: rows not yet in the pantry,
  /// grouped by product.
  Future<List<TriageCard>> triageCards(int receiptId) async {
    await _confirmedReceipt(receiptId);
    final query =
        _db.select(_db.receiptItems).join([
            leftOuterJoin(
              _db.products,
              _db.products.id.equalsExp(_db.receiptItems.productId),
            ),
          ])
          ..where(_db.receiptItems.receiptId.equals(receiptId))
          ..orderBy([OrderingTerm.asc(_db.receiptItems.id)]);
    final rows = await query.get();
    return groupForTriage([
      for (final row in rows)
        _triageRow(
          row.readTable(_db.receiptItems),
          row.readTableOrNull(_db.products),
        ),
    ]);
  }

  /// Puts a swiped-right card in the pantry. Quantity and price come from
  /// the receipt rows, not from [card], so the lot always matches the
  /// purchase. [name] and [categoryId] override the card's.
  Future<int> addFromReceipt(
    int receiptId,
    TriageCard card, {
    String? name,
    int? categoryId,
  }) => _db.transaction(() async {
    await _confirmedReceipt(receiptId);
    final ids = card.receiptItemIds;
    if (ids.isEmpty) throw ArgumentError.value(card, 'card', 'has no rows');
    final rows = await (_db.select(
      _db.receiptItems,
    )..where((r) => r.id.isIn(ids))).get();
    if (rows.length != ids.length ||
        rows.any((r) => r.receiptId != receiptId)) {
      throw ArgumentError.value(ids, 'card', 'rows not on receipt $receiptId');
    }
    if (rows.any((r) => r.pantryLotId != null)) {
      throw StateError('Some rows are already in the pantry');
    }
    final quantity = roundQuantity(
      rows.fold<double>(0, (sum, r) => sum + r.quantity),
    );
    final lotId = await _insertLot(
      PantryLotsCompanion.insert(
        receiptId: Value(receiptId),
        productId: Value(card.productId),
        categoryId: Value(categoryId ?? card.categoryId),
        name: name ?? card.name,
        unit: Value(rows.first.unit),
        source: PantrySource.receipt,
        initialQuantity: quantity,
        priceCents: Value(
          rows.fold<int>(
            0,
            (sum, r) => sum + r.lineTotalCents - r.discountCents,
          ),
        ),
        addedAt: _now,
      ),
    );
    await (_db.update(_db.receiptItems)..where((r) => r.id.isIn(ids))).write(
      ReceiptItemsCompanion(pantryLotId: Value(lotId)),
    );
    return lotId;
  });

  /// Puts every product of a confirmed receipt in the pantry, one lot per
  /// [triageCards] card (rows already in the pantry and untracked products
  /// such as bags are left out). Returns how many lots were added.
  Future<int> addAllFromReceipt(int receiptId) => _db.transaction(() async {
    final cards = await triageCards(receiptId);
    for (final card in cards) {
      await addFromReceipt(receiptId, card);
    }
    return cards.length;
  });

  /// Adds a lot by hand. Only [PantrySource.manualPurchase] counts as a
  /// purchase; [PantrySource.receipt] is not allowed here.
  Future<int> addManual({
    required String name,
    required double quantity,
    required PantrySource source,
    String unit = 'pz',
    int? priceCents,
    int? productId,
    int? categoryId,
  }) {
    if (source == PantrySource.receipt) {
      throw ArgumentError.value(source, 'source', 'use addFromReceipt');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be positive');
    }
    return _db.transaction(
      () => _insertLot(
        PantryLotsCompanion.insert(
          productId: Value(productId),
          categoryId: Value(categoryId),
          name: name,
          unit: Value(unit),
          source: source,
          initialQuantity: roundQuantity(quantity),
          priceCents: Value(priceCents),
          addedAt: _now,
        ),
      ),
    );
  }

  /// Uses [amount] of a lot, never more than what is left.
  Future<void> consume(int lotId, double amount) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    return _db.transaction(() async {
      final remaining = (await _ledger(lotId)).remaining;
      final applied = roundQuantity(amount < remaining ? amount : remaining);
      if (applied > 0) {
        await _insertEvent(lotId, PantryEventKind.consume, -applied);
      }
    });
  }

  /// Slider release: going down is consumption, going up is a recount
  /// (not consumption). Going up within [correctionWindow] of a consume
  /// corrects that consume instead: it is reverted and the net amount is
  /// recorded, so a slip of the finger never counts as consumption.
  /// [target] is clamped to 0…initial quantity.
  Future<void> setRemaining(int lotId, double target) =>
      _db.transaction(() async {
        final lot = await _lotRow(lotId);
        final clamped = roundQuantity(
          target.clamp(0, lot.initialQuantity).toDouble(),
        );
        var ledger = await _ledger(lotId);
        if (clamped > ledger.remaining) {
          final last = ledger.effectiveEvents.lastOrNull;
          if (last != null &&
              last.kind == PantryEventKind.consume &&
              _now.difference(last.at) <= correctionWindow) {
            await _insertEvent(
              lotId,
              PantryEventKind.revert,
              -last.delta,
              revertsEventId: last.id,
            );
            ledger = await _ledger(lotId);
          }
        }
        final diff = roundQuantity(clamped - ledger.remaining);
        if (diff < 0) {
          await _insertEvent(lotId, PantryEventKind.consume, diff);
        } else if (diff > 0) {
          await _insertEvent(
            lotId,
            PantryEventKind.adjust,
            diff,
            reason: PantryEventReason.recount,
          );
        }
      });

  /// Throws away what is left. Does nothing if the lot is already empty.
  Future<void> discard(int lotId, PantryEventReason reason) {
    const allowed = {
      PantryEventReason.expired,
      PantryEventReason.spoiled,
      PantryEventReason.other,
    };
    if (!allowed.contains(reason)) {
      throw ArgumentError.value(reason, 'reason', 'not a discard reason');
    }
    return _db.transaction(() async {
      final remaining = (await _ledger(lotId)).remaining;
      if (remaining > 0) {
        await _insertEvent(
          lotId,
          PantryEventKind.discard,
          -remaining,
          reason: reason,
        );
      }
    });
  }

  /// Cancels the latest consume, discard or recount of a lot. Returns false
  /// when there is nothing to undo.
  Future<bool> undoLast(int lotId) => _db.transaction(() async {
    final target = (await _ledger(lotId)).undoTarget;
    if (target == null) return false;
    await _insertEvent(
      lotId,
      PantryEventKind.revert,
      -target.delta,
      revertsEventId: target.id,
    );
    return true;
  });

  /// Corrects the purchased quantity of a receipt row. This edits the
  /// purchase (no new purchase is created) and, if the row is in the
  /// pantry, moves the lot's initial and remaining quantity by the same
  /// difference. Consumption already recorded is not touched; the
  /// remaining quantity stops at 0.
  Future<void> correctItemQuantity(int receiptItemId, double newQuantity) {
    if (newQuantity <= 0) {
      throw ArgumentError.value(newQuantity, 'newQuantity', 'must be positive');
    }
    return _db.transaction(() async {
      final item = await (_db.select(
        _db.receiptItems,
      )..where((r) => r.id.equals(receiptItemId))).getSingle();
      final quantity = roundQuantity(newQuantity);
      final diff = roundQuantity(quantity - item.quantity);
      if (diff == 0) return;
      await (_db.update(_db.receiptItems)
            ..where((r) => r.id.equals(receiptItemId)))
          .write(ReceiptItemsCompanion(quantity: Value(quantity)));

      final lotId = item.pantryLotId;
      if (lotId == null) return;
      final lot = await _lotRow(lotId);
      final initial = roundQuantity(lot.initialQuantity + diff);
      await (_db.update(
        _db.pantryLots,
      )..where((l) => l.id.equals(lotId))).write(
        PantryLotsCompanion(initialQuantity: Value(initial < 0 ? 0 : initial)),
      );
      final remaining = (await _ledger(lotId)).remaining;
      final applied = roundQuantity(diff < -remaining ? -remaining : diff);
      if (applied != 0) {
        await _insertEvent(
          lotId,
          PantryEventKind.adjust,
          applied,
          reason: PantryEventReason.correction,
        );
      }
    });
  }

  /// Removes a lot and its events. Receipt rows in it become available to
  /// the triage again; the purchase itself is untouched.
  Future<void> deleteLot(int lotId) =>
      (_db.delete(_db.pantryLots)..where((l) => l.id.equals(lotId))).go();

  Future<int> _insertLot(PantryLotsCompanion lot) async {
    final id = await _db.into(_db.pantryLots).insert(lot);
    await _insertEvent(id, PantryEventKind.stockIn, lot.initialQuantity.value);
    return id;
  }

  Future<void> _insertEvent(
    int lotId,
    PantryEventKind kind,
    double delta, {
    PantryEventReason? reason,
    int? revertsEventId,
  }) => _db
      .into(_db.pantryEvents)
      .insert(
        PantryEventsCompanion.insert(
          lotId: lotId,
          kind: kind,
          reason: Value(reason),
          delta: roundQuantity(delta),
          revertsEventId: Value(revertsEventId),
          at: _now,
        ),
      );

  Future<Receipt> _confirmedReceipt(int receiptId) async {
    final receipt = await (_db.select(
      _db.receipts,
    )..where((r) => r.id.equals(receiptId))).getSingle();
    if (receipt.status != ReceiptStatus.confirmed) {
      throw StateError('Receipt $receiptId is not confirmed');
    }
    return receipt;
  }

  Future<PantryLotRow> _lotRow(int lotId) => (_db.select(
    _db.pantryLots,
  )..where((l) => l.id.equals(lotId))).getSingle();

  Future<LotLedger> _ledger(int lotId) async => LotLedger(await events(lotId));

  TriageRow _triageRow(ReceiptItem item, Product? product) => TriageRow(
    receiptItemId: item.id,
    name: product?.canonicalName ?? item.rawName,
    quantity: item.quantity,
    unit: item.unit,
    netCents: item.lineTotalCents - item.discountCents,
    productId: item.productId,
    categoryId: item.categoryId ?? product?.categoryId,
    inPantry: item.pantryLotId != null,
    trackInPantry: product?.trackInPantry ?? true,
  );

  static PantryEvent _toEvent(PantryEventRow row) => PantryEvent(
    id: row.id,
    lotId: row.lotId,
    kind: row.kind,
    reason: row.reason,
    delta: row.delta,
    revertsEventId: row.revertsEventId,
    at: row.at,
  );

  static PantryLot _toLot(
    PantryLotRow row,
    LotLedger ledger,
    String? transactionHash,
  ) => PantryLot(
    id: row.id,
    name: row.name,
    unit: row.unit,
    source: row.source,
    initialQuantity: row.initialQuantity,
    remainingQuantity: ledger.remaining,
    status: ledger.status,
    addedAt: row.addedAt,
    receiptId: row.receiptId,
    productId: row.productId,
    categoryId: row.categoryId,
    priceCents: row.priceCents,
    transactionHash: transactionHash,
  );
}
