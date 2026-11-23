// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSummary {

/// The calendar month containing today.
 DateRange get month;/// The days of [month] up to and including today.
 DateRange get monthToDate;/// Printed totals of the confirmed receipts in [monthToDate] (M1).
 int get monthToDateCents; int get receiptCount;/// Category slices of [monthToDate], largest first, the rest last.
 List<DashboardSlice> get slices;/// Whether any confirmed receipt was loaded at all (this month or the
/// three before). False means a new user: the dashboard shows its empty
/// state.
 bool get hasHistory;/// Average spent in the same days (1 to today's day) of the previous
/// months that had receipts, up to three; null when none had.
 int? get usualCents;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.monthToDate, _this.monthToDate) || other.monthToDate == _this.monthToDate)&&(identical(other.monthToDateCents, _this.monthToDateCents) || other.monthToDateCents == _this.monthToDateCents)&&(identical(other.receiptCount, _this.receiptCount) || other.receiptCount == _this.receiptCount)&&const DeepCollectionEquality().equals(other.slices, _this.slices)&&(identical(other.hasHistory, _this.hasHistory) || other.hasHistory == _this.hasHistory)&&(identical(other.usualCents, _this.usualCents) || other.usualCents == _this.usualCents));
}


@override
int get hashCode {
  final _this = this as DashboardSummary;
  return Object.hash(runtimeType,_this.month,_this.monthToDate,_this.monthToDateCents,_this.receiptCount,const DeepCollectionEquality().hash(_this.slices),_this.hasHistory,_this.usualCents);
}

@override
String toString() {
  final _this = this as DashboardSummary;
  return 'DashboardSummary(month: ${_this.month}, monthToDate: ${_this.monthToDate}, monthToDateCents: ${_this.monthToDateCents}, receiptCount: ${_this.receiptCount}, slices: ${_this.slices}, hasHistory: ${_this.hasHistory}, usualCents: ${_this.usualCents})';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 DateRange month, DateRange monthToDate, int monthToDateCents, int receiptCount, List<DashboardSlice> slices, bool hasHistory, int? usualCents
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? monthToDate = null,Object? monthToDateCents = null,Object? receiptCount = null,Object? slices = null,Object? hasHistory = null,Object? usualCents = freezed,}) {
  return _then(DashboardSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateRange,monthToDate: null == monthToDate ? _self.monthToDate : monthToDate // ignore: cast_nullable_to_non_nullable
as DateRange,monthToDateCents: null == monthToDateCents ? _self.monthToDateCents : monthToDateCents // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,slices: null == slices ? _self.slices : slices // ignore: cast_nullable_to_non_nullable
as List<DashboardSlice>,hasHistory: null == hasHistory ? _self.hasHistory : hasHistory // ignore: cast_nullable_to_non_nullable
as bool,usualCents: freezed == usualCents ? _self.usualCents : usualCents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateRange month,  DateRange monthToDate,  int monthToDateCents,  int receiptCount,  List<DashboardSlice> slices,  bool hasHistory,  int? usualCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.month,_that.monthToDate,_that.monthToDateCents,_that.receiptCount,_that.slices,_that.hasHistory,_that.usualCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateRange month,  DateRange monthToDate,  int monthToDateCents,  int receiptCount,  List<DashboardSlice> slices,  bool hasHistory,  int? usualCents)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.month,_that.monthToDate,_that.monthToDateCents,_that.receiptCount,_that.slices,_that.hasHistory,_that.usualCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateRange month,  DateRange monthToDate,  int monthToDateCents,  int receiptCount,  List<DashboardSlice> slices,  bool hasHistory,  int? usualCents)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.month,_that.monthToDate,_that.monthToDateCents,_that.receiptCount,_that.slices,_that.hasHistory,_that.usualCents);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSummary extends DashboardSummary {
  const _DashboardSummary({required this.month, required this.monthToDate, required this.monthToDateCents, required this.receiptCount, required  List<DashboardSlice> slices, required this.hasHistory, this.usualCents}): _slices = slices,super._();
  

/// The calendar month containing today.
@override final  DateRange month;
/// The days of [month] up to and including today.
@override final  DateRange monthToDate;
/// Printed totals of the confirmed receipts in [monthToDate] (M1).
@override final  int monthToDateCents;
@override final  int receiptCount;
/// Category slices of [monthToDate], largest first, the rest last.
 final  List<DashboardSlice> _slices;
/// Category slices of [monthToDate], largest first, the rest last.
@override List<DashboardSlice> get slices {
  if (_slices is EqualUnmodifiableListView) return _slices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slices);
}

/// Whether any confirmed receipt was loaded at all (this month or the
/// three before). False means a new user: the dashboard shows its empty
/// state.
@override final  bool hasHistory;
/// Average spent in the same days (1 to today's day) of the previous
/// months that had receipts, up to three; null when none had.
@override final  int? usualCents;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.month, month) || other.month == month)&&(identical(other.monthToDate, monthToDate) || other.monthToDate == monthToDate)&&(identical(other.monthToDateCents, monthToDateCents) || other.monthToDateCents == monthToDateCents)&&(identical(other.receiptCount, receiptCount) || other.receiptCount == receiptCount)&&const DeepCollectionEquality().equals(other.slices, _slices)&&(identical(other.hasHistory, hasHistory) || other.hasHistory == hasHistory)&&(identical(other.usualCents, usualCents) || other.usualCents == usualCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,monthToDate,monthToDateCents,receiptCount,const DeepCollectionEquality().hash(_slices),hasHistory,usualCents);
}

@override
String toString() {
    return 'DashboardSummary(month: $month, monthToDate: $monthToDate, monthToDateCents: $monthToDateCents, receiptCount: $receiptCount, slices: $slices, hasHistory: $hasHistory, usualCents: $usualCents)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 DateRange month, DateRange monthToDate, int monthToDateCents, int receiptCount, List<DashboardSlice> slices, bool hasHistory, int? usualCents
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? monthToDate = null,Object? monthToDateCents = null,Object? receiptCount = null,Object? slices = null,Object? hasHistory = null,Object? usualCents = freezed,}) {
  return _then(_DashboardSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateRange,monthToDate: null == monthToDate ? _self.monthToDate : monthToDate // ignore: cast_nullable_to_non_nullable
as DateRange,monthToDateCents: null == monthToDateCents ? _self.monthToDateCents : monthToDateCents // ignore: cast_nullable_to_non_nullable
as int,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,slices: null == slices ? _self._slices : slices // ignore: cast_nullable_to_non_nullable
as List<DashboardSlice>,hasHistory: null == hasHistory ? _self.hasHistory : hasHistory // ignore: cast_nullable_to_non_nullable
as bool,usualCents: freezed == usualCents ? _self.usualCents : usualCents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$DashboardSlice {

/// Amount of the slice, always positive.
 int get cents;/// [cents] ÷ the sum of all slices.
 double get share;/// The category; null for the slice that groups the rest (smaller
/// categories, uncategorised items and the gap to the receipt totals).
 CategoryInfo? get category;/// Position of [category] among all categories by id, so a category
/// keeps its colour whatever its rank this month. Null for the rest.
 int? get colorSlot;/// The items behind the slice, newest first.
 List<CategoryPurchase> get purchases;
/// Create a copy of DashboardSlice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSliceCopyWith<DashboardSlice> get copyWith => _$DashboardSliceCopyWithImpl<DashboardSlice>(this as DashboardSlice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardSlice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSlice&&(identical(other.cents, _this.cents) || other.cents == _this.cents)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.colorSlot, _this.colorSlot) || other.colorSlot == _this.colorSlot)&&const DeepCollectionEquality().equals(other.purchases, _this.purchases));
}


@override
int get hashCode {
  final _this = this as DashboardSlice;
  return Object.hash(runtimeType,_this.cents,_this.share,_this.category,_this.colorSlot,const DeepCollectionEquality().hash(_this.purchases));
}

@override
String toString() {
  final _this = this as DashboardSlice;
  return 'DashboardSlice(cents: ${_this.cents}, share: ${_this.share}, category: ${_this.category}, colorSlot: ${_this.colorSlot}, purchases: ${_this.purchases})';
}


}

/// @nodoc
abstract mixin class $DashboardSliceCopyWith<$Res>  {
  factory $DashboardSliceCopyWith(DashboardSlice value, $Res Function(DashboardSlice) _then) = _$DashboardSliceCopyWithImpl;
@useResult
$Res call({
 int cents, double share, CategoryInfo? category, int? colorSlot, List<CategoryPurchase> purchases
});


$CategoryInfoCopyWith<$Res>? get category;

}
/// @nodoc
class _$DashboardSliceCopyWithImpl<$Res>
    implements $DashboardSliceCopyWith<$Res> {
  _$DashboardSliceCopyWithImpl(this._self, this._then);

  final DashboardSlice _self;
  final $Res Function(DashboardSlice) _then;

/// Create a copy of DashboardSlice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cents = null,Object? share = null,Object? category = freezed,Object? colorSlot = freezed,Object? purchases = null,}) {
  return _then(DashboardSlice(
cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryInfo?,colorSlot: freezed == colorSlot ? _self.colorSlot : colorSlot // ignore: cast_nullable_to_non_nullable
as int?,purchases: null == purchases ? _self.purchases : purchases // ignore: cast_nullable_to_non_nullable
as List<CategoryPurchase>,
  ));
}
/// Create a copy of DashboardSlice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryInfoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryInfoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardSlice].
extension DashboardSlicePatterns on DashboardSlice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSlice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSlice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSlice value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSlice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSlice value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSlice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cents,  double share,  CategoryInfo? category,  int? colorSlot,  List<CategoryPurchase> purchases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSlice() when $default != null:
return $default(_that.cents,_that.share,_that.category,_that.colorSlot,_that.purchases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cents,  double share,  CategoryInfo? category,  int? colorSlot,  List<CategoryPurchase> purchases)  $default,) {final _that = this;
switch (_that) {
case _DashboardSlice():
return $default(_that.cents,_that.share,_that.category,_that.colorSlot,_that.purchases);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cents,  double share,  CategoryInfo? category,  int? colorSlot,  List<CategoryPurchase> purchases)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSlice() when $default != null:
return $default(_that.cents,_that.share,_that.category,_that.colorSlot,_that.purchases);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSlice extends DashboardSlice {
  const _DashboardSlice({required this.cents, required this.share, this.category, this.colorSlot,  List<CategoryPurchase> purchases = const <CategoryPurchase>[]}): _purchases = purchases,super._();
  

/// Amount of the slice, always positive.
@override final  int cents;
/// [cents] ÷ the sum of all slices.
@override final  double share;
/// The category; null for the slice that groups the rest (smaller
/// categories, uncategorised items and the gap to the receipt totals).
@override final  CategoryInfo? category;
/// Position of [category] among all categories by id, so a category
/// keeps its colour whatever its rank this month. Null for the rest.
@override final  int? colorSlot;
/// The items behind the slice, newest first.
 final  List<CategoryPurchase> _purchases;
/// The items behind the slice, newest first.
@override@JsonKey() List<CategoryPurchase> get purchases {
  if (_purchases is EqualUnmodifiableListView) return _purchases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_purchases);
}


/// Create a copy of DashboardSlice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSliceCopyWith<_DashboardSlice> get copyWith => __$DashboardSliceCopyWithImpl<_DashboardSlice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSlice&&(identical(other.cents, cents) || other.cents == cents)&&(identical(other.share, share) || other.share == share)&&(identical(other.category, category) || other.category == category)&&(identical(other.colorSlot, colorSlot) || other.colorSlot == colorSlot)&&const DeepCollectionEquality().equals(other.purchases, _purchases));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cents,share,category,colorSlot,const DeepCollectionEquality().hash(_purchases));
}

@override
String toString() {
    return 'DashboardSlice(cents: $cents, share: $share, category: $category, colorSlot: $colorSlot, purchases: $purchases)';
}


}

/// @nodoc
abstract mixin class _$DashboardSliceCopyWith<$Res> implements $DashboardSliceCopyWith<$Res> {
  factory _$DashboardSliceCopyWith(_DashboardSlice value, $Res Function(_DashboardSlice) _then) = __$DashboardSliceCopyWithImpl;
@override @useResult
$Res call({
 int cents, double share, CategoryInfo? category, int? colorSlot, List<CategoryPurchase> purchases
});


@override $CategoryInfoCopyWith<$Res>? get category;

}
/// @nodoc
class __$DashboardSliceCopyWithImpl<$Res>
    implements _$DashboardSliceCopyWith<$Res> {
  __$DashboardSliceCopyWithImpl(this._self, this._then);

  final _DashboardSlice _self;
  final $Res Function(_DashboardSlice) _then;

/// Create a copy of DashboardSlice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cents = null,Object? share = null,Object? category = freezed,Object? colorSlot = freezed,Object? purchases = null,}) {
  return _then(_DashboardSlice(
cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryInfo?,colorSlot: freezed == colorSlot ? _self.colorSlot : colorSlot // ignore: cast_nullable_to_non_nullable
as int?,purchases: null == purchases ? _self._purchases : purchases // ignore: cast_nullable_to_non_nullable
as List<CategoryPurchase>,
  ));
}

/// Create a copy of DashboardSlice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryInfoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryInfoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

/// @nodoc
mixin _$CategoryPurchase {

 int get itemId;/// The product's name, or the name printed on the receipt when the item
/// is matched to no product.
 String get name;/// Name as printed on the receipt.
 String get rawName;/// When the receipt was bought (UTC).
 DateTime get purchaseDate;/// Price paid, after the item's own discount.
 int get netCents;/// Price before the item's discount.
 int get fullCents; double get quantity; ProductUnit? get unit; String? get storeName;/// The item's category; set in the rest slice, where categories mix.
/// Null there for an uncategorised item.
 String? get categoryName;
/// Create a copy of CategoryPurchase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryPurchaseCopyWith<CategoryPurchase> get copyWith => _$CategoryPurchaseCopyWithImpl<CategoryPurchase>(this as CategoryPurchase, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryPurchase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryPurchase&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.rawName, _this.rawName) || other.rawName == _this.rawName)&&(identical(other.purchaseDate, _this.purchaseDate) || other.purchaseDate == _this.purchaseDate)&&(identical(other.netCents, _this.netCents) || other.netCents == _this.netCents)&&(identical(other.fullCents, _this.fullCents) || other.fullCents == _this.fullCents)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.storeName, _this.storeName) || other.storeName == _this.storeName)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName));
}


@override
int get hashCode {
  final _this = this as CategoryPurchase;
  return Object.hash(runtimeType,_this.itemId,_this.name,_this.rawName,_this.purchaseDate,_this.netCents,_this.fullCents,_this.quantity,_this.unit,_this.storeName,_this.categoryName);
}

@override
String toString() {
  final _this = this as CategoryPurchase;
  return 'CategoryPurchase(itemId: ${_this.itemId}, name: ${_this.name}, rawName: ${_this.rawName}, purchaseDate: ${_this.purchaseDate}, netCents: ${_this.netCents}, fullCents: ${_this.fullCents}, quantity: ${_this.quantity}, unit: ${_this.unit}, storeName: ${_this.storeName}, categoryName: ${_this.categoryName})';
}


}

/// @nodoc
abstract mixin class $CategoryPurchaseCopyWith<$Res>  {
  factory $CategoryPurchaseCopyWith(CategoryPurchase value, $Res Function(CategoryPurchase) _then) = _$CategoryPurchaseCopyWithImpl;
@useResult
$Res call({
 int itemId, String name, String rawName, DateTime purchaseDate, int netCents, int fullCents, double quantity, ProductUnit? unit, String? storeName, String? categoryName
});




}
/// @nodoc
class _$CategoryPurchaseCopyWithImpl<$Res>
    implements $CategoryPurchaseCopyWith<$Res> {
  _$CategoryPurchaseCopyWithImpl(this._self, this._then);

  final CategoryPurchase _self;
  final $Res Function(CategoryPurchase) _then;

/// Create a copy of CategoryPurchase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? name = null,Object? rawName = null,Object? purchaseDate = null,Object? netCents = null,Object? fullCents = null,Object? quantity = null,Object? unit = freezed,Object? storeName = freezed,Object? categoryName = freezed,}) {
  return _then(CategoryPurchase(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,netCents: null == netCents ? _self.netCents : netCents // ignore: cast_nullable_to_non_nullable
as int,fullCents: null == fullCents ? _self.fullCents : fullCents // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryPurchase].
extension CategoryPurchasePatterns on CategoryPurchase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryPurchase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryPurchase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryPurchase value)  $default,){
final _that = this;
switch (_that) {
case _CategoryPurchase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryPurchase value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryPurchase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int itemId,  String name,  String rawName,  DateTime purchaseDate,  int netCents,  int fullCents,  double quantity,  ProductUnit? unit,  String? storeName,  String? categoryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryPurchase() when $default != null:
return $default(_that.itemId,_that.name,_that.rawName,_that.purchaseDate,_that.netCents,_that.fullCents,_that.quantity,_that.unit,_that.storeName,_that.categoryName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int itemId,  String name,  String rawName,  DateTime purchaseDate,  int netCents,  int fullCents,  double quantity,  ProductUnit? unit,  String? storeName,  String? categoryName)  $default,) {final _that = this;
switch (_that) {
case _CategoryPurchase():
return $default(_that.itemId,_that.name,_that.rawName,_that.purchaseDate,_that.netCents,_that.fullCents,_that.quantity,_that.unit,_that.storeName,_that.categoryName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int itemId,  String name,  String rawName,  DateTime purchaseDate,  int netCents,  int fullCents,  double quantity,  ProductUnit? unit,  String? storeName,  String? categoryName)?  $default,) {final _that = this;
switch (_that) {
case _CategoryPurchase() when $default != null:
return $default(_that.itemId,_that.name,_that.rawName,_that.purchaseDate,_that.netCents,_that.fullCents,_that.quantity,_that.unit,_that.storeName,_that.categoryName);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryPurchase extends CategoryPurchase {
  const _CategoryPurchase({required this.itemId, required this.name, required this.rawName, required this.purchaseDate, required this.netCents, required this.fullCents, required this.quantity, this.unit, this.storeName, this.categoryName}): super._();
  

@override final  int itemId;
/// The product's name, or the name printed on the receipt when the item
/// is matched to no product.
@override final  String name;
/// Name as printed on the receipt.
@override final  String rawName;
/// When the receipt was bought (UTC).
@override final  DateTime purchaseDate;
/// Price paid, after the item's own discount.
@override final  int netCents;
/// Price before the item's discount.
@override final  int fullCents;
@override final  double quantity;
@override final  ProductUnit? unit;
@override final  String? storeName;
/// The item's category; set in the rest slice, where categories mix.
/// Null there for an uncategorised item.
@override final  String? categoryName;

/// Create a copy of CategoryPurchase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryPurchaseCopyWith<_CategoryPurchase> get copyWith => __$CategoryPurchaseCopyWithImpl<_CategoryPurchase>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryPurchase&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.netCents, netCents) || other.netCents == netCents)&&(identical(other.fullCents, fullCents) || other.fullCents == fullCents)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemId,name,rawName,purchaseDate,netCents,fullCents,quantity,unit,storeName,categoryName);
}

@override
String toString() {
    return 'CategoryPurchase(itemId: $itemId, name: $name, rawName: $rawName, purchaseDate: $purchaseDate, netCents: $netCents, fullCents: $fullCents, quantity: $quantity, unit: $unit, storeName: $storeName, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class _$CategoryPurchaseCopyWith<$Res> implements $CategoryPurchaseCopyWith<$Res> {
  factory _$CategoryPurchaseCopyWith(_CategoryPurchase value, $Res Function(_CategoryPurchase) _then) = __$CategoryPurchaseCopyWithImpl;
@override @useResult
$Res call({
 int itemId, String name, String rawName, DateTime purchaseDate, int netCents, int fullCents, double quantity, ProductUnit? unit, String? storeName, String? categoryName
});




}
/// @nodoc
class __$CategoryPurchaseCopyWithImpl<$Res>
    implements _$CategoryPurchaseCopyWith<$Res> {
  __$CategoryPurchaseCopyWithImpl(this._self, this._then);

  final _CategoryPurchase _self;
  final $Res Function(_CategoryPurchase) _then;

/// Create a copy of CategoryPurchase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? name = null,Object? rawName = null,Object? purchaseDate = null,Object? netCents = null,Object? fullCents = null,Object? quantity = null,Object? unit = freezed,Object? storeName = freezed,Object? categoryName = freezed,}) {
  return _then(_CategoryPurchase(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,netCents: null == netCents ? _self.netCents : netCents // ignore: cast_nullable_to_non_nullable
as int,fullCents: null == fullCents ? _self.fullCents : fullCents // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
