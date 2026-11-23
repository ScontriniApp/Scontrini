// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_bucket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimeBucket {

 DateRange get range; int get totalCents; int get receiptCount;
/// Create a copy of TimeBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeBucketCopyWith<TimeBucket> get copyWith => _$TimeBucketCopyWithImpl<TimeBucket>(this as TimeBucket, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimeBucket;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeBucket&&(identical(other.range, _this.range) || other.range == _this.range)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.receiptCount, _this.receiptCount) || other.receiptCount == _this.receiptCount));
}


@override
int get hashCode {
  final _this = this as TimeBucket;
  return Object.hash(runtimeType,_this.range,_this.totalCents,_this.receiptCount);
}

@override
String toString() {
  final _this = this as TimeBucket;
  return 'TimeBucket(range: ${_this.range}, totalCents: ${_this.totalCents}, receiptCount: ${_this.receiptCount})';
}


}

/// @nodoc
abstract mixin class $TimeBucketCopyWith<$Res>  {
  factory $TimeBucketCopyWith(TimeBucket value, $Res Function(TimeBucket) _then) = _$TimeBucketCopyWithImpl;
@useResult
$Res call({
 DateRange range, int totalCents, int receiptCount
});




}
/// @nodoc
class _$TimeBucketCopyWithImpl<$Res>
    implements $TimeBucketCopyWith<$Res> {
  _$TimeBucketCopyWithImpl(this._self, this._then);

  final TimeBucket _self;
  final $Res Function(TimeBucket) _then;

/// Create a copy of TimeBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? totalCents = null,Object? receiptCount = null,}) {
  return _then(TimeBucket(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as DateRange,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeBucket].
extension TimeBucketPatterns on TimeBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeBucket value)  $default,){
final _that = this;
switch (_that) {
case _TimeBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeBucket value)?  $default,){
final _that = this;
switch (_that) {
case _TimeBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateRange range,  int totalCents,  int receiptCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeBucket() when $default != null:
return $default(_that.range,_that.totalCents,_that.receiptCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateRange range,  int totalCents,  int receiptCount)  $default,) {final _that = this;
switch (_that) {
case _TimeBucket():
return $default(_that.range,_that.totalCents,_that.receiptCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateRange range,  int totalCents,  int receiptCount)?  $default,) {final _that = this;
switch (_that) {
case _TimeBucket() when $default != null:
return $default(_that.range,_that.totalCents,_that.receiptCount);case _:
  return null;

}
}

}

/// @nodoc


class _TimeBucket implements TimeBucket {
  const _TimeBucket({required this.range, required this.totalCents, required this.receiptCount});
  

@override final  DateRange range;
@override final  int totalCents;
@override final  int receiptCount;

/// Create a copy of TimeBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeBucketCopyWith<_TimeBucket> get copyWith => __$TimeBucketCopyWithImpl<_TimeBucket>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeBucket&&(identical(other.range, range) || other.range == range)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.receiptCount, receiptCount) || other.receiptCount == receiptCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,range,totalCents,receiptCount);
}

@override
String toString() {
    return 'TimeBucket(range: $range, totalCents: $totalCents, receiptCount: $receiptCount)';
}


}

/// @nodoc
abstract mixin class _$TimeBucketCopyWith<$Res> implements $TimeBucketCopyWith<$Res> {
  factory _$TimeBucketCopyWith(_TimeBucket value, $Res Function(_TimeBucket) _then) = __$TimeBucketCopyWithImpl;
@override @useResult
$Res call({
 DateRange range, int totalCents, int receiptCount
});




}
/// @nodoc
class __$TimeBucketCopyWithImpl<$Res>
    implements _$TimeBucketCopyWith<$Res> {
  __$TimeBucketCopyWithImpl(this._self, this._then);

  final _TimeBucket _self;
  final $Res Function(_TimeBucket) _then;

/// Create a copy of TimeBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? totalCents = null,Object? receiptCount = null,}) {
  return _then(_TimeBucket(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as DateRange,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
