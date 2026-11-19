// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedItem _$ParsedItemFromJson(Map<String, dynamic> json) => _ParsedItem(
  rawName: json['rawName'] as String,
  unitPriceCents: (json['unitPriceCents'] as num).toInt(),
  lineTotalCents: (json['lineTotalCents'] as num).toInt(),
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
  unit:
      $enumDecodeNullable(_$QuantityUnitEnumMap, json['unit']) ??
      QuantityUnit.piece,
  discountCents: (json['discountCents'] as num?)?.toInt() ?? 0,
  warnings:
      (json['warnings'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ParseWarningEnumMap, e))
          .toList() ??
      const <ParseWarning>[],
);

Map<String, dynamic> _$ParsedItemToJson(
  _ParsedItem instance,
) => <String, dynamic>{
  'rawName': instance.rawName,
  'unitPriceCents': instance.unitPriceCents,
  'lineTotalCents': instance.lineTotalCents,
  'quantity': instance.quantity,
  'unit': _$QuantityUnitEnumMap[instance.unit]!,
  'discountCents': instance.discountCents,
  'warnings': instance.warnings.map((e) => _$ParseWarningEnumMap[e]!).toList(),
};

const _$QuantityUnitEnumMap = {
  QuantityUnit.piece: 'pz',
  QuantityUnit.kilogram: 'kg',
  QuantityUnit.litre: 'l',
};

const _$ParseWarningEnumMap = {
  ParseWarning.missingStore: 'missingStore',
  ParseWarning.missingDate: 'missingDate',
  ParseWarning.missingTotal: 'missingTotal',
  ParseWarning.totalMismatch: 'totalMismatch',
  ParseWarning.lineTotalMismatch: 'lineTotalMismatch',
};
