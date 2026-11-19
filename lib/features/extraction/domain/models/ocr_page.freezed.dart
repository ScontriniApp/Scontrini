// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OcrPage {

 double get width; double get height; List<OcrLine> get lines;
/// Create a copy of OcrPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrPageCopyWith<OcrPage> get copyWith => _$OcrPageCopyWithImpl<OcrPage>(this as OcrPage, _$identity);

  /// Serializes this OcrPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OcrPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrPage&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OcrPage;
  return Object.hash(runtimeType,_this.width,_this.height,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as OcrPage;
  return 'OcrPage(width: ${_this.width}, height: ${_this.height}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $OcrPageCopyWith<$Res>  {
  factory $OcrPageCopyWith(OcrPage value, $Res Function(OcrPage) _then) = _$OcrPageCopyWithImpl;
@useResult
$Res call({
 double width, double height, List<OcrLine> lines
});




}
/// @nodoc
class _$OcrPageCopyWithImpl<$Res>
    implements $OcrPageCopyWith<$Res> {
  _$OcrPageCopyWithImpl(this._self, this._then);

  final OcrPage _self;
  final $Res Function(OcrPage) _then;

/// Create a copy of OcrPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? lines = null,}) {
  return _then(OcrPage(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<OcrLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrPage].
extension OcrPagePatterns on OcrPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrPage value)  $default,){
final _that = this;
switch (_that) {
case _OcrPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrPage value)?  $default,){
final _that = this;
switch (_that) {
case _OcrPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double width,  double height,  List<OcrLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrPage() when $default != null:
return $default(_that.width,_that.height,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double width,  double height,  List<OcrLine> lines)  $default,) {final _that = this;
switch (_that) {
case _OcrPage():
return $default(_that.width,_that.height,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double width,  double height,  List<OcrLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _OcrPage() when $default != null:
return $default(_that.width,_that.height,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OcrPage implements OcrPage {
  const _OcrPage({required this.width, required this.height, required  List<OcrLine> lines}): _lines = lines;
  factory _OcrPage.fromJson(Map<String, dynamic> json) => _$OcrPageFromJson(json);

@override final  double width;
@override final  double height;
 final  List<OcrLine> _lines;
@override List<OcrLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of OcrPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrPageCopyWith<_OcrPage> get copyWith => __$OcrPageCopyWithImpl<_OcrPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OcrPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrPage&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,width,height,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'OcrPage(width: $width, height: $height, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$OcrPageCopyWith<$Res> implements $OcrPageCopyWith<$Res> {
  factory _$OcrPageCopyWith(_OcrPage value, $Res Function(_OcrPage) _then) = __$OcrPageCopyWithImpl;
@override @useResult
$Res call({
 double width, double height, List<OcrLine> lines
});




}
/// @nodoc
class __$OcrPageCopyWithImpl<$Res>
    implements _$OcrPageCopyWith<$Res> {
  __$OcrPageCopyWithImpl(this._self, this._then);

  final _OcrPage _self;
  final $Res Function(_OcrPage) _then;

/// Create a copy of OcrPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? lines = null,}) {
  return _then(_OcrPage(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<OcrLine>,
  ));
}


}

// dart format on
