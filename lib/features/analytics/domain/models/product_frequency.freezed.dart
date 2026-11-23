// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_frequency.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductFrequency {

 int get productId;/// Number of receipts the product appears on.
 int get receiptCount;/// Total quantity bought (pieces, kg or l). Summed across units if the
/// product was bought in more than one; only used to break ties.
 double get quantity;/// Total paid for the product, after discounts.
 int get netCents;/// Instant of the latest purchase (UTC).
 DateTime get lastPurchaseDate;
/// Create a copy of ProductFrequency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductFrequencyCopyWith<ProductFrequency> get copyWith => _$ProductFrequencyCopyWithImpl<ProductFrequency>(this as ProductFrequency, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductFrequency;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductFrequency&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.receiptCount, _this.receiptCount) || other.receiptCount == _this.receiptCount)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.netCents, _this.netCents) || other.netCents == _this.netCents)&&(identical(other.lastPurchaseDate, _this.lastPurchaseDate) || other.lastPurchaseDate == _this.lastPurchaseDate));
}


@override
int get hashCode {
  final _this = this as ProductFrequency;
  return Object.hash(runtimeType,_this.productId,_this.receiptCount,_this.quantity,_this.netCents,_this.lastPurchaseDate);
}

@override
String toString() {
  final _this = this as ProductFrequency;
  return 'ProductFrequency(productId: ${_this.productId}, receiptCount: ${_this.receiptCount}, quantity: ${_this.quantity}, netCents: ${_this.netCents}, lastPurchaseDate: ${_this.lastPurchaseDate})';
}


}

/// @nodoc
abstract mixin class $ProductFrequencyCopyWith<$Res>  {
  factory $ProductFrequencyCopyWith(ProductFrequency value, $Res Function(ProductFrequency) _then) = _$ProductFrequencyCopyWithImpl;
@useResult
$Res call({
 int productId, int receiptCount, double quantity, int netCents, DateTime lastPurchaseDate
});




}
/// @nodoc
class _$ProductFrequencyCopyWithImpl<$Res>
    implements $ProductFrequencyCopyWith<$Res> {
  _$ProductFrequencyCopyWithImpl(this._self, this._then);

  final ProductFrequency _self;
  final $Res Function(ProductFrequency) _then;

/// Create a copy of ProductFrequency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? receiptCount = null,Object? quantity = null,Object? netCents = null,Object? lastPurchaseDate = null,}) {
  return _then(ProductFrequency(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,netCents: null == netCents ? _self.netCents : netCents // ignore: cast_nullable_to_non_nullable
as int,lastPurchaseDate: null == lastPurchaseDate ? _self.lastPurchaseDate : lastPurchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductFrequency].
extension ProductFrequencyPatterns on ProductFrequency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductFrequency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductFrequency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductFrequency value)  $default,){
final _that = this;
switch (_that) {
case _ProductFrequency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductFrequency value)?  $default,){
final _that = this;
switch (_that) {
case _ProductFrequency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int receiptCount,  double quantity,  int netCents,  DateTime lastPurchaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductFrequency() when $default != null:
return $default(_that.productId,_that.receiptCount,_that.quantity,_that.netCents,_that.lastPurchaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int receiptCount,  double quantity,  int netCents,  DateTime lastPurchaseDate)  $default,) {final _that = this;
switch (_that) {
case _ProductFrequency():
return $default(_that.productId,_that.receiptCount,_that.quantity,_that.netCents,_that.lastPurchaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int receiptCount,  double quantity,  int netCents,  DateTime lastPurchaseDate)?  $default,) {final _that = this;
switch (_that) {
case _ProductFrequency() when $default != null:
return $default(_that.productId,_that.receiptCount,_that.quantity,_that.netCents,_that.lastPurchaseDate);case _:
  return null;

}
}

}

/// @nodoc


class _ProductFrequency implements ProductFrequency {
  const _ProductFrequency({required this.productId, required this.receiptCount, required this.quantity, required this.netCents, required this.lastPurchaseDate});
  

@override final  int productId;
/// Number of receipts the product appears on.
@override final  int receiptCount;
/// Total quantity bought (pieces, kg or l). Summed across units if the
/// product was bought in more than one; only used to break ties.
@override final  double quantity;
/// Total paid for the product, after discounts.
@override final  int netCents;
/// Instant of the latest purchase (UTC).
@override final  DateTime lastPurchaseDate;

/// Create a copy of ProductFrequency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFrequencyCopyWith<_ProductFrequency> get copyWith => __$ProductFrequencyCopyWithImpl<_ProductFrequency>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFrequency&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.receiptCount, receiptCount) || other.receiptCount == receiptCount)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.netCents, netCents) || other.netCents == netCents)&&(identical(other.lastPurchaseDate, lastPurchaseDate) || other.lastPurchaseDate == lastPurchaseDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,receiptCount,quantity,netCents,lastPurchaseDate);
}

@override
String toString() {
    return 'ProductFrequency(productId: $productId, receiptCount: $receiptCount, quantity: $quantity, netCents: $netCents, lastPurchaseDate: $lastPurchaseDate)';
}


}

/// @nodoc
abstract mixin class _$ProductFrequencyCopyWith<$Res> implements $ProductFrequencyCopyWith<$Res> {
  factory _$ProductFrequencyCopyWith(_ProductFrequency value, $Res Function(_ProductFrequency) _then) = __$ProductFrequencyCopyWithImpl;
@override @useResult
$Res call({
 int productId, int receiptCount, double quantity, int netCents, DateTime lastPurchaseDate
});




}
/// @nodoc
class __$ProductFrequencyCopyWithImpl<$Res>
    implements _$ProductFrequencyCopyWith<$Res> {
  __$ProductFrequencyCopyWithImpl(this._self, this._then);

  final _ProductFrequency _self;
  final $Res Function(_ProductFrequency) _then;

/// Create a copy of ProductFrequency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? receiptCount = null,Object? quantity = null,Object? netCents = null,Object? lastPurchaseDate = null,}) {
  return _then(_ProductFrequency(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,netCents: null == netCents ? _self.netCents : netCents // ignore: cast_nullable_to_non_nullable
as int,lastPurchaseDate: null == lastPurchaseDate ? _self.lastPurchaseDate : lastPurchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
