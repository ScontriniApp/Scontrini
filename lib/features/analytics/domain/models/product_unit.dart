/// Unit of measure of a canonical product, as stored in `products.unit`.
enum ProductUnit {
  piece('pz'),
  kilogram('kg'),
  litre('l');

  new(this.dbValue);

  /// Value stored in the database.
  final String dbValue;

  /// Whether quantities are weights or volumes rather than pieces.
  bool get isMeasured => this != piece;

  /// Reads `products.unit`; returns `null` for a missing or unknown value.
  static ProductUnit? fromDb(String? value) {
    for (final unit in values) {
      if (unit.dbValue == value) return unit;
    }
    return null;
  }
}
