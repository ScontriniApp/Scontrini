// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OcrLine {

 String get text; TextBox get box;/// Rotation of the text in degrees, clockwise in image coordinates
/// (y pointing down), as reported by ML Kit. 0 for PDF text.
 double get angle;/// How sure the reader is of [text], 0..1 (PaddleOCR's mean character
/// probability); `null` when the reader doesn't say (ML Kit, PDF text).
 double? get confidence;
/// Create a copy of OcrLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrLineCopyWith<OcrLine> get copyWith => _$OcrLineCopyWithImpl<OcrLine>(this as OcrLine, _$identity);

  /// Serializes this OcrLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OcrLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrLine&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.box, _this.box) || other.box == _this.box)&&(identical(other.angle, _this.angle) || other.angle == _this.angle)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OcrLine;
  return Object.hash(runtimeType,_this.text,_this.box,_this.angle,_this.confidence);
}

@override
String toString() {
  final _this = this as OcrLine;
  return 'OcrLine(text: ${_this.text}, box: ${_this.box}, angle: ${_this.angle}, confidence: ${_this.confidence})';
}


}

/// @nodoc
abstract mixin class $OcrLineCopyWith<$Res>  {
  factory $OcrLineCopyWith(OcrLine value, $Res Function(OcrLine) _then) = _$OcrLineCopyWithImpl;
@useResult
$Res call({
 String text, TextBox box, double angle, double? confidence
});


$TextBoxCopyWith<$Res> get box;

}
/// @nodoc
class _$OcrLineCopyWithImpl<$Res>
    implements $OcrLineCopyWith<$Res> {
  _$OcrLineCopyWithImpl(this._self, this._then);

  final OcrLine _self;
  final $Res Function(OcrLine) _then;

/// Create a copy of OcrLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? box = null,Object? angle = null,Object? confidence = freezed,}) {
  return _then(OcrLine(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as TextBox,angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of OcrLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextBoxCopyWith<$Res> get box {
  
  return $TextBoxCopyWith<$Res>(_self.box, (value) {
    return _then(_self.copyWith(box: value));
  });
}
}


/// Adds pattern-matching-related methods to [OcrLine].
extension OcrLinePatterns on OcrLine {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrLine() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrLine value)  $default,){
final _that = this;
switch (_that) {
case _OcrLine():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrLine value)?  $default,){
final _that = this;
switch (_that) {
case _OcrLine() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  TextBox box,  double angle,  double? confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrLine() when $default != null:
return $default(_that.text,_that.box,_that.angle,_that.confidence);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  TextBox box,  double angle,  double? confidence)  $default,) {final _that = this;
switch (_that) {
case _OcrLine():
return $default(_that.text,_that.box,_that.angle,_that.confidence);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  TextBox box,  double angle,  double? confidence)?  $default,) {final _that = this;
switch (_that) {
case _OcrLine() when $default != null:
return $default(_that.text,_that.box,_that.angle,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OcrLine implements OcrLine {
  const _OcrLine({required this.text, required this.box, this.angle = 0, this.confidence});
  factory _OcrLine.fromJson(Map<String, dynamic> json) => _$OcrLineFromJson(json);

@override final  String text;
@override final  TextBox box;
/// Rotation of the text in degrees, clockwise in image coordinates
/// (y pointing down), as reported by ML Kit. 0 for PDF text.
@override@JsonKey() final  double angle;
/// How sure the reader is of [text], 0..1 (PaddleOCR's mean character
/// probability); `null` when the reader doesn't say (ML Kit, PDF text).
@override final  double? confidence;

/// Create a copy of OcrLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrLineCopyWith<_OcrLine> get copyWith => __$OcrLineCopyWithImpl<_OcrLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OcrLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrLine&&(identical(other.text, text) || other.text == text)&&(identical(other.box, box) || other.box == box)&&(identical(other.angle, angle) || other.angle == angle)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,box,angle,confidence);
}

@override
String toString() {
    return 'OcrLine(text: $text, box: $box, angle: $angle, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$OcrLineCopyWith<$Res> implements $OcrLineCopyWith<$Res> {
  factory _$OcrLineCopyWith(_OcrLine value, $Res Function(_OcrLine) _then) = __$OcrLineCopyWithImpl;
@override @useResult
$Res call({
 String text, TextBox box, double angle, double? confidence
});


@override $TextBoxCopyWith<$Res> get box;

}
/// @nodoc
class __$OcrLineCopyWithImpl<$Res>
    implements _$OcrLineCopyWith<$Res> {
  __$OcrLineCopyWithImpl(this._self, this._then);

  final _OcrLine _self;
  final $Res Function(_OcrLine) _then;

/// Create a copy of OcrLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? box = null,Object? angle = null,Object? confidence = freezed,}) {
  return _then(_OcrLine(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as TextBox,angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of OcrLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextBoxCopyWith<$Res> get box {
  
  return $TextBoxCopyWith<$Res>(_self.box, (value) {
    return _then(_self.copyWith(box: value));
  });
}
}

// dart format on
