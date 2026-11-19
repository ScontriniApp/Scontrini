// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OcrDocument _$OcrDocumentFromJson(Map<String, dynamic> json) => _OcrDocument(
  source: $enumDecode(_$TextSourceEnumMap, json['source']),
  pages: (json['pages'] as List<dynamic>)
      .map((e) => OcrPage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OcrDocumentToJson(_OcrDocument instance) =>
    <String, dynamic>{
      'source': _$TextSourceEnumMap[instance.source]!,
      'pages': instance.pages.map((e) => e.toJson()).toList(),
    };

const _$TextSourceEnumMap = {
  TextSource.ocr: 'ocr',
  TextSource.pdfTextLayer: 'pdfTextLayer',
};
