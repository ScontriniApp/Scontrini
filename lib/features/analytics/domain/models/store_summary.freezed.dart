// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoreSummary {

/// Sum of the printed receipt totals.
 int get totalCents;/// Number of receipts (visits).
 int get receiptCount;/// `null` for receipts whose store was never recognised.
 int? get storeId;
/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<StoreSummary> get copyWith => _$StoreSummaryCopyWithImpl<StoreSummary>(this as StoreSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoreSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreSummary&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.receiptCount, _this.receiptCount) || other.receiptCount == _this.receiptCount)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId));
}


@override
int get hashCode {
  final _this = this as StoreSummary;
  return Object.hash(runtimeType,_this.totalCents,_this.receiptCount,_this.storeId);
}

@override
String toString() {
  final _this = this as StoreSummary;
  return 'StoreSummary(totalCents: ${_this.totalCents}, receiptCount: ${_this.receiptCount}, storeId: ${_this.storeId})';
}


}

/// @nodoc
abstract mixin class $StoreSummaryCopyWith<$Res>  {
  factory $StoreSummaryCopyWith(StoreSummary value, $Res Function(StoreSummary) _then) = _$StoreSummaryCopyWithImpl;
@useResult
$Res call({
 int totalCents, int receiptCount, int? storeId
});




}
/// @nodoc
class _$StoreSummaryCopyWithImpl<$Res>
    implements $StoreSummaryCopyWith<$Res> {
  _$StoreSummaryCopyWithImpl(this._self, this._then);

  final StoreSummary _self;
  final $Res Function(StoreSummary) _then;

/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCents = null,Object? receiptCount = null,Object? storeId = freezed,}) {
  return _then(StoreSummary(
totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreSummary].
extension StoreSummaryPatterns on StoreSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreSummary value)  $default,){
final _that = this;
switch (_that) {
case _StoreSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCents,  int receiptCount,  int? storeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
return $default(_that.totalCents,_that.receiptCount,_that.storeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCents,  int receiptCount,  int? storeId)  $default,) {final _that = this;
switch (_that) {
case _StoreSummary():
return $default(_that.totalCents,_that.receiptCount,_that.storeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCents,  int receiptCount,  int? storeId)?  $default,) {final _that = this;
switch (_that) {
case _StoreSummary() when $default != null:
return $default(_that.totalCents,_that.receiptCount,_that.storeId);case _:
  return null;

}
}

}

/// @nodoc


class _StoreSummary extends StoreSummary {
  const _StoreSummary({required this.totalCents, required this.receiptCount, this.storeId}): super._();
  

/// Sum of the printed receipt totals.
@override final  int totalCents;
/// Number of receipts (visits).
@override final  int receiptCount;
/// `null` for receipts whose store was never recognised.
@override final  int? storeId;

/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreSummaryCopyWith<_StoreSummary> get copyWith => __$StoreSummaryCopyWithImpl<_StoreSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreSummary&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.receiptCount, receiptCount) || other.receiptCount == receiptCount)&&(identical(other.storeId, storeId) || other.storeId == storeId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totalCents,receiptCount,storeId);
}

@override
String toString() {
    return 'StoreSummary(totalCents: $totalCents, receiptCount: $receiptCount, storeId: $storeId)';
}


}

/// @nodoc
abstract mixin class _$StoreSummaryCopyWith<$Res> implements $StoreSummaryCopyWith<$Res> {
  factory _$StoreSummaryCopyWith(_StoreSummary value, $Res Function(_StoreSummary) _then) = __$StoreSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalCents, int receiptCount, int? storeId
});




}
/// @nodoc
class __$StoreSummaryCopyWithImpl<$Res>
    implements _$StoreSummaryCopyWith<$Res> {
  __$StoreSummaryCopyWithImpl(this._self, this._then);

  final _StoreSummary _self;
  final $Res Function(_StoreSummary) _then;

/// Create a copy of StoreSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCents = null,Object? receiptCount = null,Object? storeId = freezed,}) {
  return _then(_StoreSummary(
totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
