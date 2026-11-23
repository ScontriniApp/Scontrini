// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period_amount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeriodAmount {

 int get cents; int get previousCents;
/// Create a copy of PeriodAmount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<PeriodAmount> get copyWith => _$PeriodAmountCopyWithImpl<PeriodAmount>(this as PeriodAmount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PeriodAmount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodAmount&&(identical(other.cents, _this.cents) || other.cents == _this.cents)&&(identical(other.previousCents, _this.previousCents) || other.previousCents == _this.previousCents));
}


@override
int get hashCode {
  final _this = this as PeriodAmount;
  return Object.hash(runtimeType,_this.cents,_this.previousCents);
}

@override
String toString() {
  final _this = this as PeriodAmount;
  return 'PeriodAmount(cents: ${_this.cents}, previousCents: ${_this.previousCents})';
}


}

/// @nodoc
abstract mixin class $PeriodAmountCopyWith<$Res>  {
  factory $PeriodAmountCopyWith(PeriodAmount value, $Res Function(PeriodAmount) _then) = _$PeriodAmountCopyWithImpl;
@useResult
$Res call({
 int cents, int previousCents
});




}
/// @nodoc
class _$PeriodAmountCopyWithImpl<$Res>
    implements $PeriodAmountCopyWith<$Res> {
  _$PeriodAmountCopyWithImpl(this._self, this._then);

  final PeriodAmount _self;
  final $Res Function(PeriodAmount) _then;

/// Create a copy of PeriodAmount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cents = null,Object? previousCents = null,}) {
  return _then(PeriodAmount(
cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,previousCents: null == previousCents ? _self.previousCents : previousCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodAmount].
extension PeriodAmountPatterns on PeriodAmount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodAmount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodAmount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodAmount value)  $default,){
final _that = this;
switch (_that) {
case _PeriodAmount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodAmount value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodAmount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cents,  int previousCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodAmount() when $default != null:
return $default(_that.cents,_that.previousCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cents,  int previousCents)  $default,) {final _that = this;
switch (_that) {
case _PeriodAmount():
return $default(_that.cents,_that.previousCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cents,  int previousCents)?  $default,) {final _that = this;
switch (_that) {
case _PeriodAmount() when $default != null:
return $default(_that.cents,_that.previousCents);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodAmount extends PeriodAmount {
  const _PeriodAmount({required this.cents, required this.previousCents}): super._();
  

@override final  int cents;
@override final  int previousCents;

/// Create a copy of PeriodAmount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodAmountCopyWith<_PeriodAmount> get copyWith => __$PeriodAmountCopyWithImpl<_PeriodAmount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodAmount&&(identical(other.cents, cents) || other.cents == cents)&&(identical(other.previousCents, previousCents) || other.previousCents == previousCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cents,previousCents);
}

@override
String toString() {
    return 'PeriodAmount(cents: $cents, previousCents: $previousCents)';
}


}

/// @nodoc
abstract mixin class _$PeriodAmountCopyWith<$Res> implements $PeriodAmountCopyWith<$Res> {
  factory _$PeriodAmountCopyWith(_PeriodAmount value, $Res Function(_PeriodAmount) _then) = __$PeriodAmountCopyWithImpl;
@override @useResult
$Res call({
 int cents, int previousCents
});




}
/// @nodoc
class __$PeriodAmountCopyWithImpl<$Res>
    implements _$PeriodAmountCopyWith<$Res> {
  __$PeriodAmountCopyWithImpl(this._self, this._then);

  final _PeriodAmount _self;
  final $Res Function(_PeriodAmount) _then;

/// Create a copy of PeriodAmount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cents = null,Object? previousCents = null,}) {
  return _then(_PeriodAmount(
cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,previousCents: null == previousCents ? _self.previousCents : previousCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
