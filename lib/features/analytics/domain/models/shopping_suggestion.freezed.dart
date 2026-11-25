// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShoppingSuggestion {

 int get productId; String get name; ShoppingReason get reason;/// Local day it is needed by (today or earlier when it is overdue).
 DateTime get dueDay;/// Last purchase (UTC).
 DateTime get lastPurchase;/// Typical days between purchases (median), when bought often enough.
 int? get intervalDays;/// What the pantry has left, for [ShoppingReason.runningLow].
 double? get remaining;/// `pz`, `kg` or `l` of [remaining].
 String? get unit;
/// Create a copy of ShoppingSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingSuggestionCopyWith<ShoppingSuggestion> get copyWith => _$ShoppingSuggestionCopyWithImpl<ShoppingSuggestion>(this as ShoppingSuggestion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShoppingSuggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingSuggestion&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.dueDay, _this.dueDay) || other.dueDay == _this.dueDay)&&(identical(other.lastPurchase, _this.lastPurchase) || other.lastPurchase == _this.lastPurchase)&&(identical(other.intervalDays, _this.intervalDays) || other.intervalDays == _this.intervalDays)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as ShoppingSuggestion;
  return Object.hash(runtimeType,_this.productId,_this.name,_this.reason,_this.dueDay,_this.lastPurchase,_this.intervalDays,_this.remaining,_this.unit);
}

@override
String toString() {
  final _this = this as ShoppingSuggestion;
  return 'ShoppingSuggestion(productId: ${_this.productId}, name: ${_this.name}, reason: ${_this.reason}, dueDay: ${_this.dueDay}, lastPurchase: ${_this.lastPurchase}, intervalDays: ${_this.intervalDays}, remaining: ${_this.remaining}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $ShoppingSuggestionCopyWith<$Res>  {
  factory $ShoppingSuggestionCopyWith(ShoppingSuggestion value, $Res Function(ShoppingSuggestion) _then) = _$ShoppingSuggestionCopyWithImpl;
@useResult
$Res call({
 int productId, String name, ShoppingReason reason, DateTime dueDay, DateTime lastPurchase, int? intervalDays, double? remaining, String? unit
});




}
/// @nodoc
class _$ShoppingSuggestionCopyWithImpl<$Res>
    implements $ShoppingSuggestionCopyWith<$Res> {
  _$ShoppingSuggestionCopyWithImpl(this._self, this._then);

  final ShoppingSuggestion _self;
  final $Res Function(ShoppingSuggestion) _then;

/// Create a copy of ShoppingSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? reason = null,Object? dueDay = null,Object? lastPurchase = null,Object? intervalDays = freezed,Object? remaining = freezed,Object? unit = freezed,}) {
  return _then(ShoppingSuggestion(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ShoppingReason,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as DateTime,lastPurchase: null == lastPurchase ? _self.lastPurchase : lastPurchase // ignore: cast_nullable_to_non_nullable
as DateTime,intervalDays: freezed == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingSuggestion].
extension ShoppingSuggestionPatterns on ShoppingSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String name,  ShoppingReason reason,  DateTime dueDay,  DateTime lastPurchase,  int? intervalDays,  double? remaining,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingSuggestion() when $default != null:
return $default(_that.productId,_that.name,_that.reason,_that.dueDay,_that.lastPurchase,_that.intervalDays,_that.remaining,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String name,  ShoppingReason reason,  DateTime dueDay,  DateTime lastPurchase,  int? intervalDays,  double? remaining,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _ShoppingSuggestion():
return $default(_that.productId,_that.name,_that.reason,_that.dueDay,_that.lastPurchase,_that.intervalDays,_that.remaining,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String name,  ShoppingReason reason,  DateTime dueDay,  DateTime lastPurchase,  int? intervalDays,  double? remaining,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingSuggestion() when $default != null:
return $default(_that.productId,_that.name,_that.reason,_that.dueDay,_that.lastPurchase,_that.intervalDays,_that.remaining,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingSuggestion implements ShoppingSuggestion {
  const _ShoppingSuggestion({required this.productId, required this.name, required this.reason, required this.dueDay, required this.lastPurchase, this.intervalDays, this.remaining, this.unit});
  

@override final  int productId;
@override final  String name;
@override final  ShoppingReason reason;
/// Local day it is needed by (today or earlier when it is overdue).
@override final  DateTime dueDay;
/// Last purchase (UTC).
@override final  DateTime lastPurchase;
/// Typical days between purchases (median), when bought often enough.
@override final  int? intervalDays;
/// What the pantry has left, for [ShoppingReason.runningLow].
@override final  double? remaining;
/// `pz`, `kg` or `l` of [remaining].
@override final  String? unit;

/// Create a copy of ShoppingSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingSuggestionCopyWith<_ShoppingSuggestion> get copyWith => __$ShoppingSuggestionCopyWithImpl<_ShoppingSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingSuggestion&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.dueDay, dueDay) || other.dueDay == dueDay)&&(identical(other.lastPurchase, lastPurchase) || other.lastPurchase == lastPurchase)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,name,reason,dueDay,lastPurchase,intervalDays,remaining,unit);
}

@override
String toString() {
    return 'ShoppingSuggestion(productId: $productId, name: $name, reason: $reason, dueDay: $dueDay, lastPurchase: $lastPurchase, intervalDays: $intervalDays, remaining: $remaining, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$ShoppingSuggestionCopyWith<$Res> implements $ShoppingSuggestionCopyWith<$Res> {
  factory _$ShoppingSuggestionCopyWith(_ShoppingSuggestion value, $Res Function(_ShoppingSuggestion) _then) = __$ShoppingSuggestionCopyWithImpl;
@override @useResult
$Res call({
 int productId, String name, ShoppingReason reason, DateTime dueDay, DateTime lastPurchase, int? intervalDays, double? remaining, String? unit
});




}
/// @nodoc
class __$ShoppingSuggestionCopyWithImpl<$Res>
    implements _$ShoppingSuggestionCopyWith<$Res> {
  __$ShoppingSuggestionCopyWithImpl(this._self, this._then);

  final _ShoppingSuggestion _self;
  final $Res Function(_ShoppingSuggestion) _then;

/// Create a copy of ShoppingSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? reason = null,Object? dueDay = null,Object? lastPurchase = null,Object? intervalDays = freezed,Object? remaining = freezed,Object? unit = freezed,}) {
  return _then(_ShoppingSuggestion(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ShoppingReason,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as DateTime,lastPurchase: null == lastPurchase ? _self.lastPurchase : lastPurchase // ignore: cast_nullable_to_non_nullable
as DateTime,intervalDays: freezed == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
