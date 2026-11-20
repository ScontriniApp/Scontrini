// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Savings {

/// Item and receipt discounts, with the previous equal-length period.
 PeriodAmount get saved;/// Amount actually paid in the period (M1).
 int get paidCents;
/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsCopyWith<Savings> get copyWith => _$SavingsCopyWithImpl<Savings>(this as Savings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Savings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Savings&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.paidCents, _this.paidCents) || other.paidCents == _this.paidCents));
}


@override
int get hashCode {
  final _this = this as Savings;
  return Object.hash(runtimeType,_this.saved,_this.paidCents);
}

@override
String toString() {
  final _this = this as Savings;
  return 'Savings(saved: ${_this.saved}, paidCents: ${_this.paidCents})';
}


}

/// @nodoc
abstract mixin class $SavingsCopyWith<$Res>  {
  factory $SavingsCopyWith(Savings value, $Res Function(Savings) _then) = _$SavingsCopyWithImpl;
@useResult
$Res call({
 PeriodAmount saved, int paidCents
});


$PeriodAmountCopyWith<$Res> get saved;

}
/// @nodoc
class _$SavingsCopyWithImpl<$Res>
    implements $SavingsCopyWith<$Res> {
  _$SavingsCopyWithImpl(this._self, this._then);

  final Savings _self;
  final $Res Function(Savings) _then;

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? saved = null,Object? paidCents = null,}) {
  return _then(Savings(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as PeriodAmount,paidCents: null == paidCents ? _self.paidCents : paidCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<$Res> get saved {
  
  return $PeriodAmountCopyWith<$Res>(_self.saved, (value) {
    return _then(_self.copyWith(saved: value));
  });
}
}


/// Adds pattern-matching-related methods to [Savings].
extension SavingsPatterns on Savings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Savings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Savings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Savings value)  $default,){
final _that = this;
switch (_that) {
case _Savings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Savings value)?  $default,){
final _that = this;
switch (_that) {
case _Savings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PeriodAmount saved,  int paidCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Savings() when $default != null:
return $default(_that.saved,_that.paidCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PeriodAmount saved,  int paidCents)  $default,) {final _that = this;
switch (_that) {
case _Savings():
return $default(_that.saved,_that.paidCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PeriodAmount saved,  int paidCents)?  $default,) {final _that = this;
switch (_that) {
case _Savings() when $default != null:
return $default(_that.saved,_that.paidCents);case _:
  return null;

}
}

}

/// @nodoc


class _Savings extends Savings {
  const _Savings({required this.saved, required this.paidCents}): super._();
  

/// Item and receipt discounts, with the previous equal-length period.
@override final  PeriodAmount saved;
/// Amount actually paid in the period (M1).
@override final  int paidCents;

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsCopyWith<_Savings> get copyWith => __$SavingsCopyWithImpl<_Savings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Savings&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.paidCents, paidCents) || other.paidCents == paidCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,saved,paidCents);
}

@override
String toString() {
    return 'Savings(saved: $saved, paidCents: $paidCents)';
}


}

/// @nodoc
abstract mixin class _$SavingsCopyWith<$Res> implements $SavingsCopyWith<$Res> {
  factory _$SavingsCopyWith(_Savings value, $Res Function(_Savings) _then) = __$SavingsCopyWithImpl;
@override @useResult
$Res call({
 PeriodAmount saved, int paidCents
});


@override $PeriodAmountCopyWith<$Res> get saved;

}
/// @nodoc
class __$SavingsCopyWithImpl<$Res>
    implements _$SavingsCopyWith<$Res> {
  __$SavingsCopyWithImpl(this._self, this._then);

  final _Savings _self;
  final $Res Function(_Savings) _then;

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? saved = null,Object? paidCents = null,}) {
  return _then(_Savings(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as PeriodAmount,paidCents: null == paidCents ? _self.paidCents : paidCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<$Res> get saved {
  
  return $PeriodAmountCopyWith<$Res>(_self.saved, (value) {
    return _then(_self.copyWith(saved: value));
  });
}
}

// dart format on
