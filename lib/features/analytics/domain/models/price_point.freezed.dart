// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PricePoint {

 int get productId; int get receiptId;/// Instant of purchase (UTC, like `PurchaseReceipt.purchaseDate`).
 DateTime get purchaseDate;/// Pieces, or kg/l for weighed items. Always positive.
 double get quantity;/// Amount paid for the rows, after their discounts.
 int get netCents;/// Amount of the rows before their discounts.
 int get fullCents; int? get storeId; ProductUnit? get unit;
/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricePointCopyWith<PricePoint> get copyWith => _$PricePointCopyWithImpl<PricePoint>(this as PricePoint, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PricePoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricePoint&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.receiptId, _this.receiptId) || other.receiptId == _this.receiptId)&&(identical(other.purchaseDate, _this.purchaseDate) || other.purchaseDate == _this.purchaseDate)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.netCents, _this.netCents) || other.netCents == _this.netCents)&&(identical(other.fullCents, _this.fullCents) || other.fullCents == _this.fullCents)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as PricePoint;
  return Object.hash(runtimeType,_this.productId,_this.receiptId,_this.purchaseDate,_this.quantity,_this.netCents,_this.fullCents,_this.storeId,_this.unit);
}

@override
String toString() {
  final _this = this as PricePoint;
  return 'PricePoint(productId: ${_this.productId}, receiptId: ${_this.receiptId}, purchaseDate: ${_this.purchaseDate}, quantity: ${_this.quantity}, netCents: ${_this.netCents}, fullCents: ${_this.fullCents}, storeId: ${_this.storeId}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $PricePointCopyWith<$Res>  {
  factory $PricePointCopyWith(PricePoint value, $Res Function(PricePoint) _then) = _$PricePointCopyWithImpl;
@useResult
$Res call({
 int productId, int receiptId, DateTime purchaseDate, double quantity, int netCents, int fullCents, int? storeId, ProductUnit? unit
});




}
/// @nodoc
class _$PricePointCopyWithImpl<$Res>
    implements $PricePointCopyWith<$Res> {
  _$PricePointCopyWithImpl(this._self, this._then);

  final PricePoint _self;
  final $Res Function(PricePoint) _then;

/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? receiptId = null,Object? purchaseDate = null,Object? quantity = null,Object? netCents = null,Object? fullCents = null,Object? storeId = freezed,Object? unit = freezed,}) {
  return _then(PricePoint(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,netCents: null == netCents ? _self.netCents : netCents // ignore: cast_nullable_to_non_nullable
as int,fullCents: null == fullCents ? _self.fullCents : fullCents // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit?,
  ));
}

}


/// Adds pattern-matching-related methods to [PricePoint].
extension PricePointPatterns on PricePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricePoint value)  $default,){
final _that = this;
switch (_that) {
case _PricePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricePoint value)?  $default,){
final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int receiptId,  DateTime purchaseDate,  double quantity,  int netCents,  int fullCents,  int? storeId,  ProductUnit? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
return $default(_that.productId,_that.receiptId,_that.purchaseDate,_that.quantity,_that.netCents,_that.fullCents,_that.storeId,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int receiptId,  DateTime purchaseDate,  double quantity,  int netCents,  int fullCents,  int? storeId,  ProductUnit? unit)  $default,) {final _that = this;
switch (_that) {
case _PricePoint():
return $default(_that.productId,_that.receiptId,_that.purchaseDate,_that.quantity,_that.netCents,_that.fullCents,_that.storeId,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int receiptId,  DateTime purchaseDate,  double quantity,  int netCents,  int fullCents,  int? storeId,  ProductUnit? unit)?  $default,) {final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
return $default(_that.productId,_that.receiptId,_that.purchaseDate,_that.quantity,_that.netCents,_that.fullCents,_that.storeId,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _PricePoint extends PricePoint {
  const _PricePoint({required this.productId, required this.receiptId, required this.purchaseDate, required this.quantity, required this.netCents, required this.fullCents, this.storeId, this.unit}): super._();
  

@override final  int productId;
@override final  int receiptId;
/// Instant of purchase (UTC, like `PurchaseReceipt.purchaseDate`).
@override final  DateTime purchaseDate;
/// Pieces, or kg/l for weighed items. Always positive.
@override final  double quantity;
/// Amount paid for the rows, after their discounts.
@override final  int netCents;
/// Amount of the rows before their discounts.
@override final  int fullCents;
@override final  int? storeId;
@override final  ProductUnit? unit;

/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricePointCopyWith<_PricePoint> get copyWith => __$PricePointCopyWithImpl<_PricePoint>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricePoint&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.netCents, netCents) || other.netCents == netCents)&&(identical(other.fullCents, fullCents) || other.fullCents == fullCents)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,receiptId,purchaseDate,quantity,netCents,fullCents,storeId,unit);
}

@override
String toString() {
    return 'PricePoint(productId: $productId, receiptId: $receiptId, purchaseDate: $purchaseDate, quantity: $quantity, netCents: $netCents, fullCents: $fullCents, storeId: $storeId, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$PricePointCopyWith<$Res> implements $PricePointCopyWith<$Res> {
  factory _$PricePointCopyWith(_PricePoint value, $Res Function(_PricePoint) _then) = __$PricePointCopyWithImpl;
@override @useResult
$Res call({
 int productId, int receiptId, DateTime purchaseDate, double quantity, int netCents, int fullCents, int? storeId, ProductUnit? unit
});




}
/// @nodoc
class __$PricePointCopyWithImpl<$Res>
    implements _$PricePointCopyWith<$Res> {
  __$PricePointCopyWithImpl(this._self, this._then);

  final _PricePoint _self;
  final $Res Function(_PricePoint) _then;

/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? receiptId = null,Object? purchaseDate = null,Object? quantity = null,Object? netCents = null,Object? fullCents = null,Object? storeId = freezed,Object? unit = freezed,}) {
  return _then(_PricePoint(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receiptId: null == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,netCents: null == netCents ? _self.netCents : netCents // ignore: cast_nullable_to_non_nullable
as int,fullCents: null == fullCents ? _self.fullCents : fullCents // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit?,
  ));
}


}

// dart format on
