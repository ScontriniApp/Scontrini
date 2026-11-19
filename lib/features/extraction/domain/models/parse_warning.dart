/// Something the parser could not read or verify. The review screen uses
/// these to point the user at the fields that most likely need fixing.
enum ParseWarning {
  // Receipt level.
  missingStore,
  missingDate,
  missingTotal,

  /// Items minus discounts do not add up to the printed total.
  totalMismatch,

  // Item level.

  /// Quantity × unit price does not match the line total.
  lineTotalMismatch,
}
