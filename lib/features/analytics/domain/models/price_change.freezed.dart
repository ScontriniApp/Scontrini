// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceChange {

 int get productId;/// The latest purchase in the range.
 PricePoint get latest;/// Median unit price of the earlier purchases in the reference window,
/// rounded to the nearest cent.
 int get referenceCents;/// How many earlier purchases the median is taken over.
 int get referenceCount; PriceBasis get basis;
/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceChangeCopyWith<PriceChange> get copyWith => _$PriceChangeCopyWithImpl<PriceChange>(this as PriceChange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceChange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceChange&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.latest, _this.latest) || other.latest == _this.latest)&&(identical(other.referenceCents, _this.referenceCents) || other.referenceCents == _this.referenceCents)&&(identical(other.referenceCount, _this.referenceCount) || other.referenceCount == _this.referenceCount)&&(identical(other.basis, _this.basis) || other.basis == _this.basis));
}


@override
int get hashCode {
  final _this = this as PriceChange;
  return Object.hash(runtimeType,_this.productId,_this.latest,_this.referenceCents,_this.referenceCount,_this.basis);
}

@override
String toString() {
  final _this = this as PriceChange;
  return 'PriceChange(productId: ${_this.productId}, latest: ${_this.latest}, referenceCents: ${_this.referenceCents}, referenceCount: ${_this.referenceCount}, basis: ${_this.basis})';
}


}

/// @nodoc
abstract mixin class $PriceChangeCopyWith<$Res>  {
  factory $PriceChangeCopyWith(PriceChange value, $Res Function(PriceChange) _then) = _$PriceChangeCopyWithImpl;
@useResult
$Res call({
 int productId, PricePoint latest, int referenceCents, int referenceCount, PriceBasis basis
});


$PricePointCopyWith<$Res> get latest;

}
/// @nodoc
class _$PriceChangeCopyWithImpl<$Res>
    implements $PriceChangeCopyWith<$Res> {
  _$PriceChangeCopyWithImpl(this._self, this._then);

  final PriceChange _self;
  final $Res Function(PriceChange) _then;

/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? latest = null,Object? referenceCents = null,Object? referenceCount = null,Object? basis = null,}) {
  return _then(PriceChange(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,latest: null == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as PricePoint,referenceCents: null == referenceCents ? _self.referenceCents : referenceCents // ignore: cast_nullable_to_non_nullable
as int,referenceCount: null == referenceCount ? _self.referenceCount : referenceCount // ignore: cast_nullable_to_non_nullable
as int,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as PriceBasis,
  ));
}
/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PricePointCopyWith<$Res> get latest {
  
  return $PricePointCopyWith<$Res>(_self.latest, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// Adds pattern-matching-related methods to [PriceChange].
extension PriceChangePatterns on PriceChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceChange value)  $default,){
final _that = this;
switch (_that) {
case _PriceChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceChange value)?  $default,){
final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  PricePoint latest,  int referenceCents,  int referenceCount,  PriceBasis basis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
return $default(_that.productId,_that.latest,_that.referenceCents,_that.referenceCount,_that.basis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  PricePoint latest,  int referenceCents,  int referenceCount,  PriceBasis basis)  $default,) {final _that = this;
switch (_that) {
case _PriceChange():
return $default(_that.productId,_that.latest,_that.referenceCents,_that.referenceCount,_that.basis);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  PricePoint latest,  int referenceCents,  int referenceCount,  PriceBasis basis)?  $default,) {final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
return $default(_that.productId,_that.latest,_that.referenceCents,_that.referenceCount,_that.basis);case _:
  return null;

}
}

}

/// @nodoc


class _PriceChange extends PriceChange {
  const _PriceChange({required this.productId, required this.latest, required this.referenceCents, required this.referenceCount, required this.basis}): super._();
  

@override final  int productId;
/// The latest purchase in the range.
@override final  PricePoint latest;
/// Median unit price of the earlier purchases in the reference window,
/// rounded to the nearest cent.
@override final  int referenceCents;
/// How many earlier purchases the median is taken over.
@override final  int referenceCount;
@override final  PriceBasis basis;

/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceChangeCopyWith<_PriceChange> get copyWith => __$PriceChangeCopyWithImpl<_PriceChange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceChange&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.referenceCents, referenceCents) || other.referenceCents == referenceCents)&&(identical(other.referenceCount, referenceCount) || other.referenceCount == referenceCount)&&(identical(other.basis, basis) || other.basis == basis));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,latest,referenceCents,referenceCount,basis);
}

@override
String toString() {
    return 'PriceChange(productId: $productId, latest: $latest, referenceCents: $referenceCents, referenceCount: $referenceCount, basis: $basis)';
}


}

/// @nodoc
abstract mixin class _$PriceChangeCopyWith<$Res> implements $PriceChangeCopyWith<$Res> {
  factory _$PriceChangeCopyWith(_PriceChange value, $Res Function(_PriceChange) _then) = __$PriceChangeCopyWithImpl;
@override @useResult
$Res call({
 int productId, PricePoint latest, int referenceCents, int referenceCount, PriceBasis basis
});


@override $PricePointCopyWith<$Res> get latest;

}
/// @nodoc
class __$PriceChangeCopyWithImpl<$Res>
    implements _$PriceChangeCopyWith<$Res> {
  __$PriceChangeCopyWithImpl(this._self, this._then);

  final _PriceChange _self;
  final $Res Function(_PriceChange) _then;

/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? latest = null,Object? referenceCents = null,Object? referenceCount = null,Object? basis = null,}) {
  return _then(_PriceChange(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,latest: null == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as PricePoint,referenceCents: null == referenceCents ? _self.referenceCents : referenceCents // ignore: cast_nullable_to_non_nullable
as int,referenceCount: null == referenceCount ? _self.referenceCount : referenceCount // ignore: cast_nullable_to_non_nullable
as int,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as PriceBasis,
  ));
}

/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PricePointCopyWith<$Res> get latest {
  
  return $PricePointCopyWith<$Res>(_self.latest, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}

// dart format on
