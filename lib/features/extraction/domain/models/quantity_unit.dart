import 'package:json_annotation/json_annotation.dart';

/// Unit of an item's quantity. JSON values match `products.unit`.
enum QuantityUnit {
  @JsonValue('pz')
  piece,
  @JsonValue('kg')
  kilogram,
  @JsonValue('l')
  litre,
}
