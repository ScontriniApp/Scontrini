// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Insight {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Insight);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Insight()';
}


}

/// @nodoc
class $InsightCopyWith<$Res>  {
$InsightCopyWith(Insight _, $Res Function(Insight) __);
}


/// Adds pattern-matching-related methods to [Insight].
extension InsightPatterns on Insight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CategorySpikeInsight value)?  categorySpike,TResult Function( FrequentWasteInsight value)?  frequentWaste,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CategorySpikeInsight() when categorySpike != null:
return categorySpike(_that);case FrequentWasteInsight() when frequentWaste != null:
return frequentWaste(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CategorySpikeInsight value)  categorySpike,required TResult Function( FrequentWasteInsight value)  frequentWaste,}){
final _that = this;
switch (_that) {
case CategorySpikeInsight():
return categorySpike(_that);case FrequentWasteInsight():
return frequentWaste(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CategorySpikeInsight value)?  categorySpike,TResult? Function( FrequentWasteInsight value)?  frequentWaste,}){
final _that = this;
switch (_that) {
case CategorySpikeInsight() when categorySpike != null:
return categorySpike(_that);case FrequentWasteInsight() when frequentWaste != null:
return frequentWaste(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int categoryId,  String categoryName,  int cents,  int usualCents,  int monthsCompared)?  categorySpike,TResult Function( String productName,  int wastedLots,  int closedLots,  int wastedCents,  int days,  int? productId)?  frequentWaste,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CategorySpikeInsight() when categorySpike != null:
return categorySpike(_that.categoryId,_that.categoryName,_that.cents,_that.usualCents,_that.monthsCompared);case FrequentWasteInsight() when frequentWaste != null:
return frequentWaste(_that.productName,_that.wastedLots,_that.closedLots,_that.wastedCents,_that.days,_that.productId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int categoryId,  String categoryName,  int cents,  int usualCents,  int monthsCompared)  categorySpike,required TResult Function( String productName,  int wastedLots,  int closedLots,  int wastedCents,  int days,  int? productId)  frequentWaste,}) {final _that = this;
switch (_that) {
case CategorySpikeInsight():
return categorySpike(_that.categoryId,_that.categoryName,_that.cents,_that.usualCents,_that.monthsCompared);case FrequentWasteInsight():
return frequentWaste(_that.productName,_that.wastedLots,_that.closedLots,_that.wastedCents,_that.days,_that.productId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int categoryId,  String categoryName,  int cents,  int usualCents,  int monthsCompared)?  categorySpike,TResult? Function( String productName,  int wastedLots,  int closedLots,  int wastedCents,  int days,  int? productId)?  frequentWaste,}) {final _that = this;
switch (_that) {
case CategorySpikeInsight() when categorySpike != null:
return categorySpike(_that.categoryId,_that.categoryName,_that.cents,_that.usualCents,_that.monthsCompared);case FrequentWasteInsight() when frequentWaste != null:
return frequentWaste(_that.productName,_that.wastedLots,_that.closedLots,_that.wastedCents,_that.days,_that.productId);case _:
  return null;

}
}

}

/// @nodoc


class CategorySpikeInsight extends Insight {
  const CategorySpikeInsight({required this.categoryId, required this.categoryName, required this.cents, required this.usualCents, required this.monthsCompared}): super._();
  

 final  int categoryId;
 final  String categoryName;
/// Spent in the category, month to date.
 final  int cents;
/// Average of the same days of the months compared.
 final  int usualCents;
/// How many earlier months the average is over.
 final  int monthsCompared;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySpikeInsightCopyWith<CategorySpikeInsight> get copyWith => _$CategorySpikeInsightCopyWithImpl<CategorySpikeInsight>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySpikeInsight&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.cents, cents) || other.cents == cents)&&(identical(other.usualCents, usualCents) || other.usualCents == usualCents)&&(identical(other.monthsCompared, monthsCompared) || other.monthsCompared == monthsCompared));
}


@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,categoryName,cents,usualCents,monthsCompared);
}

@override
String toString() {
    return 'Insight.categorySpike(categoryId: $categoryId, categoryName: $categoryName, cents: $cents, usualCents: $usualCents, monthsCompared: $monthsCompared)';
}


}

/// @nodoc
abstract mixin class $CategorySpikeInsightCopyWith<$Res> implements $InsightCopyWith<$Res> {
  factory $CategorySpikeInsightCopyWith(CategorySpikeInsight value, $Res Function(CategorySpikeInsight) _then) = _$CategorySpikeInsightCopyWithImpl;
@useResult
$Res call({
 int categoryId, String categoryName, int cents, int usualCents, int monthsCompared
});




}
/// @nodoc
class _$CategorySpikeInsightCopyWithImpl<$Res>
    implements $CategorySpikeInsightCopyWith<$Res> {
  _$CategorySpikeInsightCopyWithImpl(this._self, this._then);

  final CategorySpikeInsight _self;
  final $Res Function(CategorySpikeInsight) _then;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? categoryName = null,Object? cents = null,Object? usualCents = null,Object? monthsCompared = null,}) {
  return _then(CategorySpikeInsight(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,usualCents: null == usualCents ? _self.usualCents : usualCents // ignore: cast_nullable_to_non_nullable
as int,monthsCompared: null == monthsCompared ? _self.monthsCompared : monthsCompared // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FrequentWasteInsight extends Insight {
  const FrequentWasteInsight({required this.productName, required this.wastedLots, required this.closedLots, required this.wastedCents, required this.days, this.productId}): super._();
  

 final  String productName;
/// Lots of it that had something thrown away, out of [closedLots].
 final  int wastedLots;
/// Lots of it finished or thrown away in the window.
 final  int closedLots;
/// Value of what was thrown away in the window.
 final  int wastedCents;
/// Length of the window, in days.
 final  int days;
/// Null for lots matched to no product.
 final  int? productId;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FrequentWasteInsightCopyWith<FrequentWasteInsight> get copyWith => _$FrequentWasteInsightCopyWithImpl<FrequentWasteInsight>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FrequentWasteInsight&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.wastedLots, wastedLots) || other.wastedLots == wastedLots)&&(identical(other.closedLots, closedLots) || other.closedLots == closedLots)&&(identical(other.wastedCents, wastedCents) || other.wastedCents == wastedCents)&&(identical(other.days, days) || other.days == days)&&(identical(other.productId, productId) || other.productId == productId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productName,wastedLots,closedLots,wastedCents,days,productId);
}

@override
String toString() {
    return 'Insight.frequentWaste(productName: $productName, wastedLots: $wastedLots, closedLots: $closedLots, wastedCents: $wastedCents, days: $days, productId: $productId)';
}


}

/// @nodoc
abstract mixin class $FrequentWasteInsightCopyWith<$Res> implements $InsightCopyWith<$Res> {
  factory $FrequentWasteInsightCopyWith(FrequentWasteInsight value, $Res Function(FrequentWasteInsight) _then) = _$FrequentWasteInsightCopyWithImpl;
@useResult
$Res call({
 String productName, int wastedLots, int closedLots, int wastedCents, int days, int? productId
});




}
/// @nodoc
class _$FrequentWasteInsightCopyWithImpl<$Res>
    implements $FrequentWasteInsightCopyWith<$Res> {
  _$FrequentWasteInsightCopyWithImpl(this._self, this._then);

  final FrequentWasteInsight _self;
  final $Res Function(FrequentWasteInsight) _then;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? wastedLots = null,Object? closedLots = null,Object? wastedCents = null,Object? days = null,Object? productId = freezed,}) {
  return _then(FrequentWasteInsight(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,wastedLots: null == wastedLots ? _self.wastedLots : wastedLots // ignore: cast_nullable_to_non_nullable
as int,closedLots: null == closedLots ? _self.closedLots : closedLots // ignore: cast_nullable_to_non_nullable
as int,wastedCents: null == wastedCents ? _self.wastedCents : wastedCents // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
