import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/pantry_event.dart';

/// Whether a lot is still in the pantry, and how it left.
enum PantryLotStatus { active, consumed, discarded }

/// Rounds a quantity to 3 decimals (grams / millilitres), so repeated slider
/// moves do not leave floating-point crumbs like 0.30000000000000004.
double roundQuantity(double value) => (value * 1000).round() / 1000;

/// Everything derived from one lot's event log. Nothing here is stored:
/// the log is the only source of truth, so a revert or a deleted lot can
/// never leave a stale counter behind.
class LotLedger {
  /// [events] must all belong to the same lot, in insertion (id) order.
  factory(List<PantryEvent> events) {
    final reverted = {
      for (final e in events)
        if (e.kind == PantryEventKind.revert && e.revertsEventId != null)
          e.revertsEventId!,
    };
    final effective = [
      for (final e in events)
        if (e.kind != PantryEventKind.revert && !reverted.contains(e.id)) e,
    ];
    final total = events.fold<double>(0, (sum, e) => sum + e.delta);
    return LotLedger._(effective, roundQuantity(total < 0 ? 0 : total));
  }

  new _(this.effectiveEvents, this.remaining);

  /// Events that still count: no reverts, and nothing that was reverted.
  final List<PantryEvent> effectiveEvents;

  /// What is left in the pantry, never negative.
  final double remaining;

  /// Total used, from effective consume events.
  double get consumed => _sumOf(PantryEventKind.consume);

  /// Total thrown away, from effective discard events.
  double get discarded => _sumOf(PantryEventKind.discard);

  PantryLotStatus get status {
    if (remaining > 0) return PantryLotStatus.active;
    final last = effectiveEvents.isEmpty ? null : effectiveEvents.last;
    return last?.kind == PantryEventKind.discard
        ? PantryLotStatus.discarded
        : PantryLotStatus.consumed;
  }

  /// The event an undo would cancel: the latest effective event, if it is a
  /// user movement. Stock-ins and receipt corrections are not undoable here
  /// (they follow the receipt), and undo works as a stack so the remaining
  /// quantity always returns to a state that really existed.
  PantryEvent? get undoTarget {
    if (effectiveEvents.isEmpty) return null;
    final last = effectiveEvents.last;
    return switch (last.kind) {
      PantryEventKind.consume || PantryEventKind.discard => last,
      PantryEventKind.adjust when last.reason != PantryEventReason.correction =>
        last,
      _ => null,
    };
  }

  double _sumOf(PantryEventKind kind) => roundQuantity(
    -effectiveEvents
        .where((e) => e.kind == kind)
        .fold<double>(0, (sum, e) => sum + e.delta),
  );
}
