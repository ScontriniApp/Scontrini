import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';

part 'parsed_item.freezed.dart';
part 'parsed_item.g.dart';

/// One product line read from a receipt, before matching to a canonical
/// product or category.
@freezed
abstract class ParsedItem with _$ParsedItem {
  const factory({
    /// Name exactly as printed.
    required String rawName,
    required int unitPriceCents,

    /// Amount printed on the line, before [discountCents].
    required int lineTotalCents,

    /// Pieces, or kg/l for weighed items.
    @Default(1) double quantity,
    @Default(QuantityUnit.piece) QuantityUnit unit,

    /// Discounts printed right after this item, as a positive amount.
    @Default(0) int discountCents,

    /// VAT rate printed for this item, in percent (4, 5, 10, 22), or 0 when
    /// it is not subject to VAT (e.g. `*NS` newspapers). `null` when the
    /// receipt doesn't say.
    int? vatPercent,
    @Default(<ParseWarning>[]) List<ParseWarning> warnings,
  }) = _ParsedItem;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$ParsedItemFromJson(json);

  /// What was actually paid for this item.
  int get netCents => lineTotalCents - discountCents;
}
