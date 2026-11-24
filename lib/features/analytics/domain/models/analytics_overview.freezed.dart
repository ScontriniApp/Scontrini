// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsOverview {

/// The period shown.
 AnalyticsPeriod get period;/// The days of the period up to today.
 DateRange get range;/// What [range] is compared with (see `AnalyticsPeriod.comparison`).
 DateRange get comparedRange;/// M1 over [range], against [comparedRange].
 PeriodAmount get total; int get receiptCount;/// M2 over the whole period (days after today are empty buckets).
 List<TimeBucket> get buckets; Granularity get granularity;/// M3: every category with spending, largest first, then the rest.
 List<DashboardSlice> get categories;/// M4, largest total first.
 List<NamedStore> get stores;/// M8 over [range], against [comparedRange].
 Savings get savings;/// M7, most receipts first.
 List<NamedFrequency> get mostBought;/// M6 on the full price, at least `AnalyticsMetrics.minPriceChange`
/// up, largest rise first.
 List<NamedPriceChange> get priceRises;/// The same, down, largest drop first.
 List<NamedPriceChange> get priceDrops;
/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsOverviewCopyWith<AnalyticsOverview> get copyWith => _$AnalyticsOverviewCopyWithImpl<AnalyticsOverview>(this as AnalyticsOverview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnalyticsOverview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsOverview&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.range, _this.range) || other.range == _this.range)&&(identical(other.comparedRange, _this.comparedRange) || other.comparedRange == _this.comparedRange)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.receiptCount, _this.receiptCount) || other.receiptCount == _this.receiptCount)&&const DeepCollectionEquality().equals(other.buckets, _this.buckets)&&(identical(other.granularity, _this.granularity) || other.granularity == _this.granularity)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.stores, _this.stores)&&(identical(other.savings, _this.savings) || other.savings == _this.savings)&&const DeepCollectionEquality().equals(other.mostBought, _this.mostBought)&&const DeepCollectionEquality().equals(other.priceRises, _this.priceRises)&&const DeepCollectionEquality().equals(other.priceDrops, _this.priceDrops));
}


@override
int get hashCode {
  final _this = this as AnalyticsOverview;
  return Object.hash(runtimeType,_this.period,_this.range,_this.comparedRange,_this.total,_this.receiptCount,const DeepCollectionEquality().hash(_this.buckets),_this.granularity,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.stores),_this.savings,const DeepCollectionEquality().hash(_this.mostBought),const DeepCollectionEquality().hash(_this.priceRises),const DeepCollectionEquality().hash(_this.priceDrops));
}

@override
String toString() {
  final _this = this as AnalyticsOverview;
  return 'AnalyticsOverview(period: ${_this.period}, range: ${_this.range}, comparedRange: ${_this.comparedRange}, total: ${_this.total}, receiptCount: ${_this.receiptCount}, buckets: ${_this.buckets}, granularity: ${_this.granularity}, categories: ${_this.categories}, stores: ${_this.stores}, savings: ${_this.savings}, mostBought: ${_this.mostBought}, priceRises: ${_this.priceRises}, priceDrops: ${_this.priceDrops})';
}


}

/// @nodoc
abstract mixin class $AnalyticsOverviewCopyWith<$Res>  {
  factory $AnalyticsOverviewCopyWith(AnalyticsOverview value, $Res Function(AnalyticsOverview) _then) = _$AnalyticsOverviewCopyWithImpl;
@useResult
$Res call({
 AnalyticsPeriod period, DateRange range, DateRange comparedRange, PeriodAmount total, int receiptCount, List<TimeBucket> buckets, Granularity granularity, List<DashboardSlice> categories, List<NamedStore> stores, Savings savings, List<NamedFrequency> mostBought, List<NamedPriceChange> priceRises, List<NamedPriceChange> priceDrops
});


$PeriodAmountCopyWith<$Res> get total;$SavingsCopyWith<$Res> get savings;

}
/// @nodoc
class _$AnalyticsOverviewCopyWithImpl<$Res>
    implements $AnalyticsOverviewCopyWith<$Res> {
  _$AnalyticsOverviewCopyWithImpl(this._self, this._then);

  final AnalyticsOverview _self;
  final $Res Function(AnalyticsOverview) _then;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? range = null,Object? comparedRange = null,Object? total = null,Object? receiptCount = null,Object? buckets = null,Object? granularity = null,Object? categories = null,Object? stores = null,Object? savings = null,Object? mostBought = null,Object? priceRises = null,Object? priceDrops = null,}) {
  return _then(AnalyticsOverview(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as DateRange,comparedRange: null == comparedRange ? _self.comparedRange : comparedRange // ignore: cast_nullable_to_non_nullable
as DateRange,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as PeriodAmount,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<TimeBucket>,granularity: null == granularity ? _self.granularity : granularity // ignore: cast_nullable_to_non_nullable
as Granularity,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<DashboardSlice>,stores: null == stores ? _self.stores : stores // ignore: cast_nullable_to_non_nullable
as List<NamedStore>,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as Savings,mostBought: null == mostBought ? _self.mostBought : mostBought // ignore: cast_nullable_to_non_nullable
as List<NamedFrequency>,priceRises: null == priceRises ? _self.priceRises : priceRises // ignore: cast_nullable_to_non_nullable
as List<NamedPriceChange>,priceDrops: null == priceDrops ? _self.priceDrops : priceDrops // ignore: cast_nullable_to_non_nullable
as List<NamedPriceChange>,
  ));
}
/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<$Res> get total {
  
  return $PeriodAmountCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingsCopyWith<$Res> get savings {
  
  return $SavingsCopyWith<$Res>(_self.savings, (value) {
    return _then(_self.copyWith(savings: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsOverview].
extension AnalyticsOverviewPatterns on AnalyticsOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsOverview value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsOverview value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsPeriod period,  DateRange range,  DateRange comparedRange,  PeriodAmount total,  int receiptCount,  List<TimeBucket> buckets,  Granularity granularity,  List<DashboardSlice> categories,  List<NamedStore> stores,  Savings savings,  List<NamedFrequency> mostBought,  List<NamedPriceChange> priceRises,  List<NamedPriceChange> priceDrops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
return $default(_that.period,_that.range,_that.comparedRange,_that.total,_that.receiptCount,_that.buckets,_that.granularity,_that.categories,_that.stores,_that.savings,_that.mostBought,_that.priceRises,_that.priceDrops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsPeriod period,  DateRange range,  DateRange comparedRange,  PeriodAmount total,  int receiptCount,  List<TimeBucket> buckets,  Granularity granularity,  List<DashboardSlice> categories,  List<NamedStore> stores,  Savings savings,  List<NamedFrequency> mostBought,  List<NamedPriceChange> priceRises,  List<NamedPriceChange> priceDrops)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsOverview():
return $default(_that.period,_that.range,_that.comparedRange,_that.total,_that.receiptCount,_that.buckets,_that.granularity,_that.categories,_that.stores,_that.savings,_that.mostBought,_that.priceRises,_that.priceDrops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsPeriod period,  DateRange range,  DateRange comparedRange,  PeriodAmount total,  int receiptCount,  List<TimeBucket> buckets,  Granularity granularity,  List<DashboardSlice> categories,  List<NamedStore> stores,  Savings savings,  List<NamedFrequency> mostBought,  List<NamedPriceChange> priceRises,  List<NamedPriceChange> priceDrops)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
return $default(_that.period,_that.range,_that.comparedRange,_that.total,_that.receiptCount,_that.buckets,_that.granularity,_that.categories,_that.stores,_that.savings,_that.mostBought,_that.priceRises,_that.priceDrops);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsOverview extends AnalyticsOverview {
  const _AnalyticsOverview({required this.period, required this.range, required this.comparedRange, required this.total, required this.receiptCount, required  List<TimeBucket> buckets, required this.granularity, required  List<DashboardSlice> categories, required  List<NamedStore> stores, required this.savings, required  List<NamedFrequency> mostBought, required  List<NamedPriceChange> priceRises, required  List<NamedPriceChange> priceDrops}): _buckets = buckets,_categories = categories,_stores = stores,_mostBought = mostBought,_priceRises = priceRises,_priceDrops = priceDrops,super._();
  

/// The period shown.
@override final  AnalyticsPeriod period;
/// The days of the period up to today.
@override final  DateRange range;
/// What [range] is compared with (see `AnalyticsPeriod.comparison`).
@override final  DateRange comparedRange;
/// M1 over [range], against [comparedRange].
@override final  PeriodAmount total;
@override final  int receiptCount;
/// M2 over the whole period (days after today are empty buckets).
 final  List<TimeBucket> _buckets;
/// M2 over the whole period (days after today are empty buckets).
@override List<TimeBucket> get buckets {
  if (_buckets is EqualUnmodifiableListView) return _buckets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buckets);
}

@override final  Granularity granularity;
/// M3: every category with spending, largest first, then the rest.
 final  List<DashboardSlice> _categories;
/// M3: every category with spending, largest first, then the rest.
@override List<DashboardSlice> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// M4, largest total first.
 final  List<NamedStore> _stores;
/// M4, largest total first.
@override List<NamedStore> get stores {
  if (_stores is EqualUnmodifiableListView) return _stores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stores);
}

/// M8 over [range], against [comparedRange].
@override final  Savings savings;
/// M7, most receipts first.
 final  List<NamedFrequency> _mostBought;
/// M7, most receipts first.
@override List<NamedFrequency> get mostBought {
  if (_mostBought is EqualUnmodifiableListView) return _mostBought;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mostBought);
}

/// M6 on the full price, at least `AnalyticsMetrics.minPriceChange`
/// up, largest rise first.
 final  List<NamedPriceChange> _priceRises;
/// M6 on the full price, at least `AnalyticsMetrics.minPriceChange`
/// up, largest rise first.
@override List<NamedPriceChange> get priceRises {
  if (_priceRises is EqualUnmodifiableListView) return _priceRises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priceRises);
}

/// The same, down, largest drop first.
 final  List<NamedPriceChange> _priceDrops;
/// The same, down, largest drop first.
@override List<NamedPriceChange> get priceDrops {
  if (_priceDrops is EqualUnmodifiableListView) return _priceDrops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priceDrops);
}


/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsOverviewCopyWith<_AnalyticsOverview> get copyWith => __$AnalyticsOverviewCopyWithImpl<_AnalyticsOverview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsOverview&&(identical(other.period, period) || other.period == period)&&(identical(other.range, range) || other.range == range)&&(identical(other.comparedRange, comparedRange) || other.comparedRange == comparedRange)&&(identical(other.total, total) || other.total == total)&&(identical(other.receiptCount, receiptCount) || other.receiptCount == receiptCount)&&const DeepCollectionEquality().equals(other.buckets, _buckets)&&(identical(other.granularity, granularity) || other.granularity == granularity)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.stores, _stores)&&(identical(other.savings, savings) || other.savings == savings)&&const DeepCollectionEquality().equals(other.mostBought, _mostBought)&&const DeepCollectionEquality().equals(other.priceRises, _priceRises)&&const DeepCollectionEquality().equals(other.priceDrops, _priceDrops));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,range,comparedRange,total,receiptCount,const DeepCollectionEquality().hash(_buckets),granularity,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_stores),savings,const DeepCollectionEquality().hash(_mostBought),const DeepCollectionEquality().hash(_priceRises),const DeepCollectionEquality().hash(_priceDrops));
}

@override
String toString() {
    return 'AnalyticsOverview(period: $period, range: $range, comparedRange: $comparedRange, total: $total, receiptCount: $receiptCount, buckets: $buckets, granularity: $granularity, categories: $categories, stores: $stores, savings: $savings, mostBought: $mostBought, priceRises: $priceRises, priceDrops: $priceDrops)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsOverviewCopyWith<$Res> implements $AnalyticsOverviewCopyWith<$Res> {
  factory _$AnalyticsOverviewCopyWith(_AnalyticsOverview value, $Res Function(_AnalyticsOverview) _then) = __$AnalyticsOverviewCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsPeriod period, DateRange range, DateRange comparedRange, PeriodAmount total, int receiptCount, List<TimeBucket> buckets, Granularity granularity, List<DashboardSlice> categories, List<NamedStore> stores, Savings savings, List<NamedFrequency> mostBought, List<NamedPriceChange> priceRises, List<NamedPriceChange> priceDrops
});


@override $PeriodAmountCopyWith<$Res> get total;@override $SavingsCopyWith<$Res> get savings;

}
/// @nodoc
class __$AnalyticsOverviewCopyWithImpl<$Res>
    implements _$AnalyticsOverviewCopyWith<$Res> {
  __$AnalyticsOverviewCopyWithImpl(this._self, this._then);

  final _AnalyticsOverview _self;
  final $Res Function(_AnalyticsOverview) _then;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? range = null,Object? comparedRange = null,Object? total = null,Object? receiptCount = null,Object? buckets = null,Object? granularity = null,Object? categories = null,Object? stores = null,Object? savings = null,Object? mostBought = null,Object? priceRises = null,Object? priceDrops = null,}) {
  return _then(_AnalyticsOverview(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalyticsPeriod,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as DateRange,comparedRange: null == comparedRange ? _self.comparedRange : comparedRange // ignore: cast_nullable_to_non_nullable
as DateRange,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as PeriodAmount,receiptCount: null == receiptCount ? _self.receiptCount : receiptCount // ignore: cast_nullable_to_non_nullable
as int,buckets: null == buckets ? _self._buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<TimeBucket>,granularity: null == granularity ? _self.granularity : granularity // ignore: cast_nullable_to_non_nullable
as Granularity,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<DashboardSlice>,stores: null == stores ? _self._stores : stores // ignore: cast_nullable_to_non_nullable
as List<NamedStore>,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as Savings,mostBought: null == mostBought ? _self._mostBought : mostBought // ignore: cast_nullable_to_non_nullable
as List<NamedFrequency>,priceRises: null == priceRises ? _self._priceRises : priceRises // ignore: cast_nullable_to_non_nullable
as List<NamedPriceChange>,priceDrops: null == priceDrops ? _self._priceDrops : priceDrops // ignore: cast_nullable_to_non_nullable
as List<NamedPriceChange>,
  ));
}

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<$Res> get total {
  
  return $PeriodAmountCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingsCopyWith<$Res> get savings {
  
  return $SavingsCopyWith<$Res>(_self.savings, (value) {
    return _then(_self.copyWith(savings: value));
  });
}
}

/// @nodoc
mixin _$NamedStore {

 StoreSummary get summary; String? get name;
/// Create a copy of NamedStore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NamedStoreCopyWith<NamedStore> get copyWith => _$NamedStoreCopyWithImpl<NamedStore>(this as NamedStore, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NamedStore;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NamedStore&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as NamedStore;
  return Object.hash(runtimeType,_this.summary,_this.name);
}

@override
String toString() {
  final _this = this as NamedStore;
  return 'NamedStore(summary: ${_this.summary}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $NamedStoreCopyWith<$Res>  {
  factory $NamedStoreCopyWith(NamedStore value, $Res Function(NamedStore) _then) = _$NamedStoreCopyWithImpl;
@useResult
$Res call({
 StoreSummary summary, String? name
});


$StoreSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$NamedStoreCopyWithImpl<$Res>
    implements $NamedStoreCopyWith<$Res> {
  _$NamedStoreCopyWithImpl(this._self, this._then);

  final NamedStore _self;
  final $Res Function(NamedStore) _then;

/// Create a copy of NamedStore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? name = freezed,}) {
  return _then(NamedStore(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as StoreSummary,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of NamedStore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get summary {
  
  return $StoreSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [NamedStore].
extension NamedStorePatterns on NamedStore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NamedStore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NamedStore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NamedStore value)  $default,){
final _that = this;
switch (_that) {
case _NamedStore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NamedStore value)?  $default,){
final _that = this;
switch (_that) {
case _NamedStore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoreSummary summary,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NamedStore() when $default != null:
return $default(_that.summary,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoreSummary summary,  String? name)  $default,) {final _that = this;
switch (_that) {
case _NamedStore():
return $default(_that.summary,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoreSummary summary,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _NamedStore() when $default != null:
return $default(_that.summary,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _NamedStore implements NamedStore {
  const _NamedStore({required this.summary, this.name});
  

@override final  StoreSummary summary;
@override final  String? name;

/// Create a copy of NamedStore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NamedStoreCopyWith<_NamedStore> get copyWith => __$NamedStoreCopyWithImpl<_NamedStore>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NamedStore&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,summary,name);
}

@override
String toString() {
    return 'NamedStore(summary: $summary, name: $name)';
}


}

/// @nodoc
abstract mixin class _$NamedStoreCopyWith<$Res> implements $NamedStoreCopyWith<$Res> {
  factory _$NamedStoreCopyWith(_NamedStore value, $Res Function(_NamedStore) _then) = __$NamedStoreCopyWithImpl;
@override @useResult
$Res call({
 StoreSummary summary, String? name
});


@override $StoreSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$NamedStoreCopyWithImpl<$Res>
    implements _$NamedStoreCopyWith<$Res> {
  __$NamedStoreCopyWithImpl(this._self, this._then);

  final _NamedStore _self;
  final $Res Function(_NamedStore) _then;

/// Create a copy of NamedStore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? name = freezed,}) {
  return _then(_NamedStore(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as StoreSummary,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of NamedStore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StoreSummaryCopyWith<$Res> get summary {
  
  return $StoreSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

/// @nodoc
mixin _$NamedFrequency {

 ProductFrequency get frequency; String get name;
/// Create a copy of NamedFrequency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NamedFrequencyCopyWith<NamedFrequency> get copyWith => _$NamedFrequencyCopyWithImpl<NamedFrequency>(this as NamedFrequency, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NamedFrequency;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NamedFrequency&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as NamedFrequency;
  return Object.hash(runtimeType,_this.frequency,_this.name);
}

@override
String toString() {
  final _this = this as NamedFrequency;
  return 'NamedFrequency(frequency: ${_this.frequency}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $NamedFrequencyCopyWith<$Res>  {
  factory $NamedFrequencyCopyWith(NamedFrequency value, $Res Function(NamedFrequency) _then) = _$NamedFrequencyCopyWithImpl;
@useResult
$Res call({
 ProductFrequency frequency, String name
});


$ProductFrequencyCopyWith<$Res> get frequency;

}
/// @nodoc
class _$NamedFrequencyCopyWithImpl<$Res>
    implements $NamedFrequencyCopyWith<$Res> {
  _$NamedFrequencyCopyWithImpl(this._self, this._then);

  final NamedFrequency _self;
  final $Res Function(NamedFrequency) _then;

/// Create a copy of NamedFrequency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frequency = null,Object? name = null,}) {
  return _then(NamedFrequency(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as ProductFrequency,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of NamedFrequency
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductFrequencyCopyWith<$Res> get frequency {
  
  return $ProductFrequencyCopyWith<$Res>(_self.frequency, (value) {
    return _then(_self.copyWith(frequency: value));
  });
}
}


/// Adds pattern-matching-related methods to [NamedFrequency].
extension NamedFrequencyPatterns on NamedFrequency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NamedFrequency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NamedFrequency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NamedFrequency value)  $default,){
final _that = this;
switch (_that) {
case _NamedFrequency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NamedFrequency value)?  $default,){
final _that = this;
switch (_that) {
case _NamedFrequency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductFrequency frequency,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NamedFrequency() when $default != null:
return $default(_that.frequency,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductFrequency frequency,  String name)  $default,) {final _that = this;
switch (_that) {
case _NamedFrequency():
return $default(_that.frequency,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductFrequency frequency,  String name)?  $default,) {final _that = this;
switch (_that) {
case _NamedFrequency() when $default != null:
return $default(_that.frequency,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _NamedFrequency implements NamedFrequency {
  const _NamedFrequency({required this.frequency, required this.name});
  

@override final  ProductFrequency frequency;
@override final  String name;

/// Create a copy of NamedFrequency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NamedFrequencyCopyWith<_NamedFrequency> get copyWith => __$NamedFrequencyCopyWithImpl<_NamedFrequency>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NamedFrequency&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,frequency,name);
}

@override
String toString() {
    return 'NamedFrequency(frequency: $frequency, name: $name)';
}


}

/// @nodoc
abstract mixin class _$NamedFrequencyCopyWith<$Res> implements $NamedFrequencyCopyWith<$Res> {
  factory _$NamedFrequencyCopyWith(_NamedFrequency value, $Res Function(_NamedFrequency) _then) = __$NamedFrequencyCopyWithImpl;
@override @useResult
$Res call({
 ProductFrequency frequency, String name
});


@override $ProductFrequencyCopyWith<$Res> get frequency;

}
/// @nodoc
class __$NamedFrequencyCopyWithImpl<$Res>
    implements _$NamedFrequencyCopyWith<$Res> {
  __$NamedFrequencyCopyWithImpl(this._self, this._then);

  final _NamedFrequency _self;
  final $Res Function(_NamedFrequency) _then;

/// Create a copy of NamedFrequency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frequency = null,Object? name = null,}) {
  return _then(_NamedFrequency(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as ProductFrequency,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of NamedFrequency
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductFrequencyCopyWith<$Res> get frequency {
  
  return $ProductFrequencyCopyWith<$Res>(_self.frequency, (value) {
    return _then(_self.copyWith(frequency: value));
  });
}
}

/// @nodoc
mixin _$NamedPriceChange {

 PriceChange get change; String get name;
/// Create a copy of NamedPriceChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NamedPriceChangeCopyWith<NamedPriceChange> get copyWith => _$NamedPriceChangeCopyWithImpl<NamedPriceChange>(this as NamedPriceChange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NamedPriceChange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NamedPriceChange&&(identical(other.change, _this.change) || other.change == _this.change)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as NamedPriceChange;
  return Object.hash(runtimeType,_this.change,_this.name);
}

@override
String toString() {
  final _this = this as NamedPriceChange;
  return 'NamedPriceChange(change: ${_this.change}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $NamedPriceChangeCopyWith<$Res>  {
  factory $NamedPriceChangeCopyWith(NamedPriceChange value, $Res Function(NamedPriceChange) _then) = _$NamedPriceChangeCopyWithImpl;
@useResult
$Res call({
 PriceChange change, String name
});


$PriceChangeCopyWith<$Res> get change;

}
/// @nodoc
class _$NamedPriceChangeCopyWithImpl<$Res>
    implements $NamedPriceChangeCopyWith<$Res> {
  _$NamedPriceChangeCopyWithImpl(this._self, this._then);

  final NamedPriceChange _self;
  final $Res Function(NamedPriceChange) _then;

/// Create a copy of NamedPriceChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? change = null,Object? name = null,}) {
  return _then(NamedPriceChange(
change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as PriceChange,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of NamedPriceChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceChangeCopyWith<$Res> get change {
  
  return $PriceChangeCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}
}


/// Adds pattern-matching-related methods to [NamedPriceChange].
extension NamedPriceChangePatterns on NamedPriceChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NamedPriceChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NamedPriceChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NamedPriceChange value)  $default,){
final _that = this;
switch (_that) {
case _NamedPriceChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NamedPriceChange value)?  $default,){
final _that = this;
switch (_that) {
case _NamedPriceChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PriceChange change,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NamedPriceChange() when $default != null:
return $default(_that.change,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PriceChange change,  String name)  $default,) {final _that = this;
switch (_that) {
case _NamedPriceChange():
return $default(_that.change,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PriceChange change,  String name)?  $default,) {final _that = this;
switch (_that) {
case _NamedPriceChange() when $default != null:
return $default(_that.change,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _NamedPriceChange implements NamedPriceChange {
  const _NamedPriceChange({required this.change, required this.name});
  

@override final  PriceChange change;
@override final  String name;

/// Create a copy of NamedPriceChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NamedPriceChangeCopyWith<_NamedPriceChange> get copyWith => __$NamedPriceChangeCopyWithImpl<_NamedPriceChange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NamedPriceChange&&(identical(other.change, change) || other.change == change)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,change,name);
}

@override
String toString() {
    return 'NamedPriceChange(change: $change, name: $name)';
}


}

/// @nodoc
abstract mixin class _$NamedPriceChangeCopyWith<$Res> implements $NamedPriceChangeCopyWith<$Res> {
  factory _$NamedPriceChangeCopyWith(_NamedPriceChange value, $Res Function(_NamedPriceChange) _then) = __$NamedPriceChangeCopyWithImpl;
@override @useResult
$Res call({
 PriceChange change, String name
});


@override $PriceChangeCopyWith<$Res> get change;

}
/// @nodoc
class __$NamedPriceChangeCopyWithImpl<$Res>
    implements _$NamedPriceChangeCopyWith<$Res> {
  __$NamedPriceChangeCopyWithImpl(this._self, this._then);

  final _NamedPriceChange _self;
  final $Res Function(_NamedPriceChange) _then;

/// Create a copy of NamedPriceChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? change = null,Object? name = null,}) {
  return _then(_NamedPriceChange(
change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as PriceChange,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of NamedPriceChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceChangeCopyWith<$Res> get change {
  
  return $PriceChangeCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}
}

// dart format on
