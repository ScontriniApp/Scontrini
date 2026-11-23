// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OcrLine _$OcrLineFromJson(Map<String, dynamic> json) => _OcrLine(
  text: json['text'] as String,
  box: TextBox.fromJson(json['box'] as Map<String, dynamic>),
  angle: (json['angle'] as num?)?.toDouble() ?? 0,
  confidence: (json['confidence'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OcrLineToJson(_OcrLine instance) => <String, dynamic>{
  'text': instance.text,
  'box': instance.box.toJson(),
  'angle': instance.angle,
  'confidence': instance.confidence,
};
