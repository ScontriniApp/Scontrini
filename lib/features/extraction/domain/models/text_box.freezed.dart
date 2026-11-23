// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_box.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextBox {

 double get left; double get top; double get right; double get bottom;
/// Create a copy of TextBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextBoxCopyWith<TextBox> get copyWith => _$TextBoxCopyWithImpl<TextBox>(this as TextBox, _$identity);

  /// Serializes this TextBox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextBox;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextBox&&(identical(other.left, _this.left) || other.left == _this.left)&&(identical(other.top, _this.top) || other.top == _this.top)&&(identical(other.right, _this.right) || other.right == _this.right)&&(identical(other.bottom, _this.bottom) || other.bottom == _this.bottom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextBox;
  return Object.hash(runtimeType,_this.left,_this.top,_this.right,_this.bottom);
}

@override
String toString() {
  final _this = this as TextBox;
  return 'TextBox(left: ${_this.left}, top: ${_this.top}, right: ${_this.right}, bottom: ${_this.bottom})';
}


}

/// @nodoc
abstract mixin class $TextBoxCopyWith<$Res>  {
  factory $TextBoxCopyWith(TextBox value, $Res Function(TextBox) _then) = _$TextBoxCopyWithImpl;
@useResult
$Res call({
 double left, double top, double right, double bottom
});




}
/// @nodoc
class _$TextBoxCopyWithImpl<$Res>
    implements $TextBoxCopyWith<$Res> {
  _$TextBoxCopyWithImpl(this._self, this._then);

  final TextBox _self;
  final $Res Function(TextBox) _then;

/// Create a copy of TextBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? left = null,Object? top = null,Object? right = null,Object? bottom = null,}) {
  return _then(TextBox(
left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double,right: null == right ? _self.right : right // ignore: cast_nullable_to_non_nullable
as double,bottom: null == bottom ? _self.bottom : bottom // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextBox].
extension TextBoxPatterns on TextBox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextBox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextBox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextBox value)  $default,){
final _that = this;
switch (_that) {
case _TextBox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextBox value)?  $default,){
final _that = this;
switch (_that) {
case _TextBox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double left,  double top,  double right,  double bottom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextBox() when $default != null:
return $default(_that.left,_that.top,_that.right,_that.bottom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double left,  double top,  double right,  double bottom)  $default,) {final _that = this;
switch (_that) {
case _TextBox():
return $default(_that.left,_that.top,_that.right,_that.bottom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double left,  double top,  double right,  double bottom)?  $default,) {final _that = this;
switch (_that) {
case _TextBox() when $default != null:
return $default(_that.left,_that.top,_that.right,_that.bottom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextBox extends TextBox {
  const _TextBox({required this.left, required this.top, required this.right, required this.bottom}): super._();
  factory _TextBox.fromJson(Map<String, dynamic> json) => _$TextBoxFromJson(json);

@override final  double left;
@override final  double top;
@override final  double right;
@override final  double bottom;

/// Create a copy of TextBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextBoxCopyWith<_TextBox> get copyWith => __$TextBoxCopyWithImpl<_TextBox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextBoxToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextBox&&(identical(other.left, left) || other.left == left)&&(identical(other.top, top) || other.top == top)&&(identical(other.right, right) || other.right == right)&&(identical(other.bottom, bottom) || other.bottom == bottom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,left,top,right,bottom);
}

@override
String toString() {
    return 'TextBox(left: $left, top: $top, right: $right, bottom: $bottom)';
}


}

/// @nodoc
abstract mixin class _$TextBoxCopyWith<$Res> implements $TextBoxCopyWith<$Res> {
  factory _$TextBoxCopyWith(_TextBox value, $Res Function(_TextBox) _then) = __$TextBoxCopyWithImpl;
@override @useResult
$Res call({
 double left, double top, double right, double bottom
});




}
/// @nodoc
class __$TextBoxCopyWithImpl<$Res>
    implements _$TextBoxCopyWith<$Res> {
  __$TextBoxCopyWithImpl(this._self, this._then);

  final _TextBox _self;
  final $Res Function(_TextBox) _then;

/// Create a copy of TextBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? left = null,Object? top = null,Object? right = null,Object? bottom = null,}) {
  return _then(_TextBox(
left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double,right: null == right ? _self.right : right // ignore: cast_nullable_to_non_nullable
as double,bottom: null == bottom ? _self.bottom : bottom // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
