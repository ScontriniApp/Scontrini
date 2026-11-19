// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OcrLine _$OcrLineFromJson(Map<String, dynamic> json) => _OcrLine(
  text: json['text'] as String,
  box: TextBox.fromJson(json['box'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OcrLineToJson(_OcrLine instance) => <String, dynamic>{
  'text': instance.text,
  'box': instance.box.toJson(),
};
