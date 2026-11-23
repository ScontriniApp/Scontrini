// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedItem {

/// Name exactly as printed.
 String get rawName; int get unitPriceCents;/// Amount printed on the line, before [discountCents].
 int get lineTotalCents;/// Pieces, or kg/l for weighed items.
 double get quantity; QuantityUnit get unit;/// Discounts printed right after this item, as a positive amount.
 int get discountCents;/// VAT rate printed for this item, in percent (4, 5, 10, 22), or 0 when
/// it is not subject to VAT (e.g. `*NS` newspapers). `null` when the
/// receipt doesn't say.
 int? get vatPercent; List<ParseWarning> get warnings;
/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedItemCopyWith<ParsedItem> get copyWith => _$ParsedItemCopyWithImpl<ParsedItem>(this as ParsedItem, _$identity);

  /// Serializes this ParsedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ParsedItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedItem&&(identical(other.rawName, _this.rawName) || other.rawName == _this.rawName)&&(identical(other.unitPriceCents, _this.unitPriceCents) || other.unitPriceCents == _this.unitPriceCents)&&(identical(other.lineTotalCents, _this.lineTotalCents) || other.lineTotalCents == _this.lineTotalCents)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.discountCents, _this.discountCents) || other.discountCents == _this.discountCents)&&(identical(other.vatPercent, _this.vatPercent) || other.vatPercent == _this.vatPercent)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ParsedItem;
  return Object.hash(runtimeType,_this.rawName,_this.unitPriceCents,_this.lineTotalCents,_this.quantity,_this.unit,_this.discountCents,_this.vatPercent,const DeepCollectionEquality().hash(_this.warnings));
}

@override
String toString() {
  final _this = this as ParsedItem;
  return 'ParsedItem(rawName: ${_this.rawName}, unitPriceCents: ${_this.unitPriceCents}, lineTotalCents: ${_this.lineTotalCents}, quantity: ${_this.quantity}, unit: ${_this.unit}, discountCents: ${_this.discountCents}, vatPercent: ${_this.vatPercent}, warnings: ${_this.warnings})';
}


}

/// @nodoc
abstract mixin class $ParsedItemCopyWith<$Res>  {
  factory $ParsedItemCopyWith(ParsedItem value, $Res Function(ParsedItem) _then) = _$ParsedItemCopyWithImpl;
@useResult
$Res call({
 String rawName, int unitPriceCents, int lineTotalCents, double quantity, QuantityUnit unit, int discountCents, int? vatPercent, List<ParseWarning> warnings
});




}
/// @nodoc
class _$ParsedItemCopyWithImpl<$Res>
    implements $ParsedItemCopyWith<$Res> {
  _$ParsedItemCopyWithImpl(this._self, this._then);

  final ParsedItem _self;
  final $Res Function(ParsedItem) _then;

/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawName = null,Object? unitPriceCents = null,Object? lineTotalCents = null,Object? quantity = null,Object? unit = null,Object? discountCents = null,Object? vatPercent = freezed,Object? warnings = null,}) {
  return _then(ParsedItem(
rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,unitPriceCents: null == unitPriceCents ? _self.unitPriceCents : unitPriceCents // ignore: cast_nullable_to_non_nullable
as int,lineTotalCents: null == lineTotalCents ? _self.lineTotalCents : lineTotalCents // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,vatPercent: freezed == vatPercent ? _self.vatPercent : vatPercent // ignore: cast_nullable_to_non_nullable
as int?,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ParseWarning>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedItem].
extension ParsedItemPatterns on ParsedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedItem value)  $default,){
final _that = this;
switch (_that) {
case _ParsedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedItem value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawName,  int unitPriceCents,  int lineTotalCents,  double quantity,  QuantityUnit unit,  int discountCents,  int? vatPercent,  List<ParseWarning> warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
return $default(_that.rawName,_that.unitPriceCents,_that.lineTotalCents,_that.quantity,_that.unit,_that.discountCents,_that.vatPercent,_that.warnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawName,  int unitPriceCents,  int lineTotalCents,  double quantity,  QuantityUnit unit,  int discountCents,  int? vatPercent,  List<ParseWarning> warnings)  $default,) {final _that = this;
switch (_that) {
case _ParsedItem():
return $default(_that.rawName,_that.unitPriceCents,_that.lineTotalCents,_that.quantity,_that.unit,_that.discountCents,_that.vatPercent,_that.warnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawName,  int unitPriceCents,  int lineTotalCents,  double quantity,  QuantityUnit unit,  int discountCents,  int? vatPercent,  List<ParseWarning> warnings)?  $default,) {final _that = this;
switch (_that) {
case _ParsedItem() when $default != null:
return $default(_that.rawName,_that.unitPriceCents,_that.lineTotalCents,_that.quantity,_that.unit,_that.discountCents,_that.vatPercent,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedItem extends ParsedItem {
  const _ParsedItem({required this.rawName, required this.unitPriceCents, required this.lineTotalCents, this.quantity = 1, this.unit = QuantityUnit.piece, this.discountCents = 0, this.vatPercent,  List<ParseWarning> warnings = const <ParseWarning>[]}): _warnings = warnings,super._();
  factory _ParsedItem.fromJson(Map<String, dynamic> json) => _$ParsedItemFromJson(json);

/// Name exactly as printed.
@override final  String rawName;
@override final  int unitPriceCents;
/// Amount printed on the line, before [discountCents].
@override final  int lineTotalCents;
/// Pieces, or kg/l for weighed items.
@override@JsonKey() final  double quantity;
@override@JsonKey() final  QuantityUnit unit;
/// Discounts printed right after this item, as a positive amount.
@override@JsonKey() final  int discountCents;
/// VAT rate printed for this item, in percent (4, 5, 10, 22), or 0 when
/// it is not subject to VAT (e.g. `*NS` newspapers). `null` when the
/// receipt doesn't say.
@override final  int? vatPercent;
 final  List<ParseWarning> _warnings;
@override@JsonKey() List<ParseWarning> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}


/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedItemCopyWith<_ParsedItem> get copyWith => __$ParsedItemCopyWithImpl<_ParsedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedItem&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.unitPriceCents, unitPriceCents) || other.unitPriceCents == unitPriceCents)&&(identical(other.lineTotalCents, lineTotalCents) || other.lineTotalCents == lineTotalCents)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.discountCents, discountCents) || other.discountCents == discountCents)&&(identical(other.vatPercent, vatPercent) || other.vatPercent == vatPercent)&&const DeepCollectionEquality().equals(other.warnings, _warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rawName,unitPriceCents,lineTotalCents,quantity,unit,discountCents,vatPercent,const DeepCollectionEquality().hash(_warnings));
}

@override
String toString() {
    return 'ParsedItem(rawName: $rawName, unitPriceCents: $unitPriceCents, lineTotalCents: $lineTotalCents, quantity: $quantity, unit: $unit, discountCents: $discountCents, vatPercent: $vatPercent, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$ParsedItemCopyWith<$Res> implements $ParsedItemCopyWith<$Res> {
  factory _$ParsedItemCopyWith(_ParsedItem value, $Res Function(_ParsedItem) _then) = __$ParsedItemCopyWithImpl;
@override @useResult
$Res call({
 String rawName, int unitPriceCents, int lineTotalCents, double quantity, QuantityUnit unit, int discountCents, int? vatPercent, List<ParseWarning> warnings
});




}
/// @nodoc
class __$ParsedItemCopyWithImpl<$Res>
    implements _$ParsedItemCopyWith<$Res> {
  __$ParsedItemCopyWithImpl(this._self, this._then);

  final _ParsedItem _self;
  final $Res Function(_ParsedItem) _then;

/// Create a copy of ParsedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawName = null,Object? unitPriceCents = null,Object? lineTotalCents = null,Object? quantity = null,Object? unit = null,Object? discountCents = null,Object? vatPercent = freezed,Object? warnings = null,}) {
  return _then(_ParsedItem(
rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,unitPriceCents: null == unitPriceCents ? _self.unitPriceCents : unitPriceCents // ignore: cast_nullable_to_non_nullable
as int,lineTotalCents: null == lineTotalCents ? _self.lineTotalCents : lineTotalCents // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,vatPercent: freezed == vatPercent ? _self.vatPercent : vatPercent // ignore: cast_nullable_to_non_nullable
as int?,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ParseWarning>,
  ));
}


}

// dart format on
