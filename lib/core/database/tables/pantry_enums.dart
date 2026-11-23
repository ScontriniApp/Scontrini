// Pantry enums, kept free of imports so the pantry domain layer can use
// them without depending on drift. Stored by name: never rename a value
// without a migration.

/// Where a pantry lot came from. Only [receipt] lots are linked to a receipt;
/// only [receipt] and [manualPurchase] lots are purchases.
enum PantrySource { receipt, manualPurchase, initialStock, gift }

/// What a pantry event did. See `docs/pantry_and_stats.md`.
enum PantryEventKind {
  /// The lot entered the pantry with its initial quantity.
  stockIn,

  /// Part of the lot was used.
  consume,

  /// What was left was thrown away (waste).
  discard,

  /// The remaining quantity was fixed: neither consumption nor waste.
  adjust,

  /// Cancels an earlier event (`pantry_events.reverts_event_id`).
  revert,
}

/// Why a [PantryEventKind.discard] or [PantryEventKind.adjust] happened.
enum PantryEventReason {
  expired,
  spoiled,
  other,

  /// The user re-counted what is left (slider moved up).
  recount,

  /// The purchased quantity on the receipt was corrected.
  correction,
}
