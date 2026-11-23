// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedReceipt _$ParsedReceiptFromJson(Map<String, dynamic> json) =>
    _ParsedReceipt(
      items: (json['items'] as List<dynamic>)
          .map((e) => ParsedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      storeName: json['storeName'] as String?,
      vatNumber: json['vatNumber'] as String?,
      address: json['address'] as String?,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      totalCents: (json['totalCents'] as num?)?.toInt(),
      discountCents: (json['discountCents'] as num?)?.toInt() ?? 0,
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ParseWarningEnumMap, e))
              .toList() ??
          const <ParseWarning>[],
      unparsedLines:
          (json['unparsedLines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ParsedReceiptToJson(
  _ParsedReceipt instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'storeName': instance.storeName,
  'vatNumber': instance.vatNumber,
  'address': instance.address,
  'purchaseDate': instance.purchaseDate?.toIso8601String(),
  'totalCents': instance.totalCents,
  'discountCents': instance.discountCents,
  'warnings': instance.warnings.map((e) => _$ParseWarningEnumMap[e]!).toList(),
  'unparsedLines': instance.unparsedLines,
};

const _$ParseWarningEnumMap = {
  ParseWarning.missingStore: 'missingStore',
  ParseWarning.missingDate: 'missingDate',
  ParseWarning.missingTotal: 'missingTotal',
  ParseWarning.totalMismatch: 'totalMismatch',
  ParseWarning.lineTotalMismatch: 'lineTotalMismatch',
};
