import 'package:scontrini/core/database/tables/pantry_enums.dart';

/// One movement in a lot's append-only log.
class PantryEvent {
  const new({
    required this.id,
    required this.lotId,
    required this.kind,
    required this.delta,
    required this.at,
    this.reason,
    this.revertsEventId,
  });

  final int id;
  final int lotId;
  final PantryEventKind kind;
  final PantryEventReason? reason;

  /// Change applied to the remaining quantity (negative for consume and
  /// discard).
  final double delta;

  /// Set on [PantryEventKind.revert] events.
  final int? revertsEventId;

  /// UTC.
  final DateTime at;
}
