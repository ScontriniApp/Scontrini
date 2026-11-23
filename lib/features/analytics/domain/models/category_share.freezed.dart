// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_share.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryShare {

 CategoryShareKind get kind;/// Net amount: item amounts after their own discounts and their part of
/// any basket coupon. Returns reduce it.
 int get cents;/// [cents] ÷ the total of all slices (which equals M1), as a fraction;
/// 0 when that total is not positive.
 double get share;/// Set exactly when [kind] is [CategoryShareKind.category].
 int? get categoryId;
/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryShareCopyWith<CategoryShare> get copyWith => _$CategoryShareCopyWithImpl<CategoryShare>(this as CategoryShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryShare&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.cents, _this.cents) || other.cents == _this.cents)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId));
}


@override
int get hashCode {
  final _this = this as CategoryShare;
  return Object.hash(runtimeType,_this.kind,_this.cents,_this.share,_this.categoryId);
}

@override
String toString() {
  final _this = this as CategoryShare;
  return 'CategoryShare(kind: ${_this.kind}, cents: ${_this.cents}, share: ${_this.share}, categoryId: ${_this.categoryId})';
}


}

/// @nodoc
abstract mixin class $CategoryShareCopyWith<$Res>  {
  factory $CategoryShareCopyWith(CategoryShare value, $Res Function(CategoryShare) _then) = _$CategoryShareCopyWithImpl;
@useResult
$Res call({
 CategoryShareKind kind, int cents, double share, int? categoryId
});




}
/// @nodoc
class _$CategoryShareCopyWithImpl<$Res>
    implements $CategoryShareCopyWith<$Res> {
  _$CategoryShareCopyWithImpl(this._self, this._then);

  final CategoryShare _self;
  final $Res Function(CategoryShare) _then;

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? cents = null,Object? share = null,Object? categoryId = freezed,}) {
  return _then(CategoryShare(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CategoryShareKind,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryShare].
extension CategorySharePatterns on CategoryShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryShare value)  $default,){
final _that = this;
switch (_that) {
case _CategoryShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryShare value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategoryShareKind kind,  int cents,  double share,  int? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
return $default(_that.kind,_that.cents,_that.share,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategoryShareKind kind,  int cents,  double share,  int? categoryId)  $default,) {final _that = this;
switch (_that) {
case _CategoryShare():
return $default(_that.kind,_that.cents,_that.share,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategoryShareKind kind,  int cents,  double share,  int? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
return $default(_that.kind,_that.cents,_that.share,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryShare implements CategoryShare {
  const _CategoryShare({required this.kind, required this.cents, required this.share, this.categoryId});
  

@override final  CategoryShareKind kind;
/// Net amount: item amounts after their own discounts and their part of
/// any basket coupon. Returns reduce it.
@override final  int cents;
/// [cents] ÷ the total of all slices (which equals M1), as a fraction;
/// 0 when that total is not positive.
@override final  double share;
/// Set exactly when [kind] is [CategoryShareKind.category].
@override final  int? categoryId;

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryShareCopyWith<_CategoryShare> get copyWith => __$CategoryShareCopyWithImpl<_CategoryShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryShare&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.cents, cents) || other.cents == cents)&&(identical(other.share, share) || other.share == share)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,cents,share,categoryId);
}

@override
String toString() {
    return 'CategoryShare(kind: $kind, cents: $cents, share: $share, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$CategoryShareCopyWith<$Res> implements $CategoryShareCopyWith<$Res> {
  factory _$CategoryShareCopyWith(_CategoryShare value, $Res Function(_CategoryShare) _then) = __$CategoryShareCopyWithImpl;
@override @useResult
$Res call({
 CategoryShareKind kind, int cents, double share, int? categoryId
});




}
/// @nodoc
class __$CategoryShareCopyWithImpl<$Res>
    implements _$CategoryShareCopyWith<$Res> {
  __$CategoryShareCopyWithImpl(this._self, this._then);

  final _CategoryShare _self;
  final $Res Function(_CategoryShare) _then;

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? cents = null,Object? share = null,Object? categoryId = freezed,}) {
  return _then(_CategoryShare(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CategoryShareKind,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
