// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OcrPage _$OcrPageFromJson(Map<String, dynamic> json) => _OcrPage(
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OcrLine.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OcrPageToJson(_OcrPage instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};
