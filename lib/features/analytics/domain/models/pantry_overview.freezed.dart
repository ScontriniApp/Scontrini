// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PantryOverview {

/// Whether the pantry has any lot at all; false shows the empty state.
 bool get hasPantry;/// Euros thrown away in the period (by the day of the discard), against
/// the compared period. A discarded share of a lot is worth that share
/// of its price.
 PeriodAmount get wasted;/// Wasted ÷ (wasted + used) in the period, in euros, as a fraction;
/// null when nothing left the pantry.
 double? get wasteRate;/// Lots with no price that had something thrown away in the period:
/// counted here, not in [wasted].
 int get unpricedDiscards;/// [wasted] by reason, largest first.
 List<WasteByReason> get reasons;/// [wasted] by category, largest first.
 List<WasteByCategory> get categories;/// [wasted] by product, largest first.
 List<WastedProduct> get products;/// Where the money spent in the period went.
 SpendingFate get fate;
/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryOverviewCopyWith<PantryOverview> get copyWith => _$PantryOverviewCopyWithImpl<PantryOverview>(this as PantryOverview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PantryOverview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryOverview&&(identical(other.hasPantry, _this.hasPantry) || other.hasPantry == _this.hasPantry)&&(identical(other.wasted, _this.wasted) || other.wasted == _this.wasted)&&(identical(other.wasteRate, _this.wasteRate) || other.wasteRate == _this.wasteRate)&&(identical(other.unpricedDiscards, _this.unpricedDiscards) || other.unpricedDiscards == _this.unpricedDiscards)&&const DeepCollectionEquality().equals(other.reasons, _this.reasons)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.products, _this.products)&&(identical(other.fate, _this.fate) || other.fate == _this.fate));
}


@override
int get hashCode {
  final _this = this as PantryOverview;
  return Object.hash(runtimeType,_this.hasPantry,_this.wasted,_this.wasteRate,_this.unpricedDiscards,const DeepCollectionEquality().hash(_this.reasons),const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.products),_this.fate);
}

@override
String toString() {
  final _this = this as PantryOverview;
  return 'PantryOverview(hasPantry: ${_this.hasPantry}, wasted: ${_this.wasted}, wasteRate: ${_this.wasteRate}, unpricedDiscards: ${_this.unpricedDiscards}, reasons: ${_this.reasons}, categories: ${_this.categories}, products: ${_this.products}, fate: ${_this.fate})';
}


}

/// @nodoc
abstract mixin class $PantryOverviewCopyWith<$Res>  {
  factory $PantryOverviewCopyWith(PantryOverview value, $Res Function(PantryOverview) _then) = _$PantryOverviewCopyWithImpl;
@useResult
$Res call({
 bool hasPantry, PeriodAmount wasted, double? wasteRate, int unpricedDiscards, List<WasteByReason> reasons, List<WasteByCategory> categories, List<WastedProduct> products, SpendingFate fate
});


$PeriodAmountCopyWith<$Res> get wasted;$SpendingFateCopyWith<$Res> get fate;

}
/// @nodoc
class _$PantryOverviewCopyWithImpl<$Res>
    implements $PantryOverviewCopyWith<$Res> {
  _$PantryOverviewCopyWithImpl(this._self, this._then);

  final PantryOverview _self;
  final $Res Function(PantryOverview) _then;

/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasPantry = null,Object? wasted = null,Object? wasteRate = freezed,Object? unpricedDiscards = null,Object? reasons = null,Object? categories = null,Object? products = null,Object? fate = null,}) {
  return _then(PantryOverview(
hasPantry: null == hasPantry ? _self.hasPantry : hasPantry // ignore: cast_nullable_to_non_nullable
as bool,wasted: null == wasted ? _self.wasted : wasted // ignore: cast_nullable_to_non_nullable
as PeriodAmount,wasteRate: freezed == wasteRate ? _self.wasteRate : wasteRate // ignore: cast_nullable_to_non_nullable
as double?,unpricedDiscards: null == unpricedDiscards ? _self.unpricedDiscards : unpricedDiscards // ignore: cast_nullable_to_non_nullable
as int,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<WasteByReason>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<WasteByCategory>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<WastedProduct>,fate: null == fate ? _self.fate : fate // ignore: cast_nullable_to_non_nullable
as SpendingFate,
  ));
}
/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<$Res> get wasted {
  
  return $PeriodAmountCopyWith<$Res>(_self.wasted, (value) {
    return _then(_self.copyWith(wasted: value));
  });
}/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingFateCopyWith<$Res> get fate {
  
  return $SpendingFateCopyWith<$Res>(_self.fate, (value) {
    return _then(_self.copyWith(fate: value));
  });
}
}


/// Adds pattern-matching-related methods to [PantryOverview].
extension PantryOverviewPatterns on PantryOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryOverview value)  $default,){
final _that = this;
switch (_that) {
case _PantryOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryOverview value)?  $default,){
final _that = this;
switch (_that) {
case _PantryOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasPantry,  PeriodAmount wasted,  double? wasteRate,  int unpricedDiscards,  List<WasteByReason> reasons,  List<WasteByCategory> categories,  List<WastedProduct> products,  SpendingFate fate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryOverview() when $default != null:
return $default(_that.hasPantry,_that.wasted,_that.wasteRate,_that.unpricedDiscards,_that.reasons,_that.categories,_that.products,_that.fate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasPantry,  PeriodAmount wasted,  double? wasteRate,  int unpricedDiscards,  List<WasteByReason> reasons,  List<WasteByCategory> categories,  List<WastedProduct> products,  SpendingFate fate)  $default,) {final _that = this;
switch (_that) {
case _PantryOverview():
return $default(_that.hasPantry,_that.wasted,_that.wasteRate,_that.unpricedDiscards,_that.reasons,_that.categories,_that.products,_that.fate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasPantry,  PeriodAmount wasted,  double? wasteRate,  int unpricedDiscards,  List<WasteByReason> reasons,  List<WasteByCategory> categories,  List<WastedProduct> products,  SpendingFate fate)?  $default,) {final _that = this;
switch (_that) {
case _PantryOverview() when $default != null:
return $default(_that.hasPantry,_that.wasted,_that.wasteRate,_that.unpricedDiscards,_that.reasons,_that.categories,_that.products,_that.fate);case _:
  return null;

}
}

}

/// @nodoc


class _PantryOverview implements PantryOverview {
  const _PantryOverview({required this.hasPantry, required this.wasted, required this.wasteRate, required this.unpricedDiscards, required  List<WasteByReason> reasons, required  List<WasteByCategory> categories, required  List<WastedProduct> products, required this.fate}): _reasons = reasons,_categories = categories,_products = products;
  

/// Whether the pantry has any lot at all; false shows the empty state.
@override final  bool hasPantry;
/// Euros thrown away in the period (by the day of the discard), against
/// the compared period. A discarded share of a lot is worth that share
/// of its price.
@override final  PeriodAmount wasted;
/// Wasted ÷ (wasted + used) in the period, in euros, as a fraction;
/// null when nothing left the pantry.
@override final  double? wasteRate;
/// Lots with no price that had something thrown away in the period:
/// counted here, not in [wasted].
@override final  int unpricedDiscards;
/// [wasted] by reason, largest first.
 final  List<WasteByReason> _reasons;
/// [wasted] by reason, largest first.
@override List<WasteByReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

/// [wasted] by category, largest first.
 final  List<WasteByCategory> _categories;
/// [wasted] by category, largest first.
@override List<WasteByCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// [wasted] by product, largest first.
 final  List<WastedProduct> _products;
/// [wasted] by product, largest first.
@override List<WastedProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

/// Where the money spent in the period went.
@override final  SpendingFate fate;

/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryOverviewCopyWith<_PantryOverview> get copyWith => __$PantryOverviewCopyWithImpl<_PantryOverview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryOverview&&(identical(other.hasPantry, hasPantry) || other.hasPantry == hasPantry)&&(identical(other.wasted, wasted) || other.wasted == wasted)&&(identical(other.wasteRate, wasteRate) || other.wasteRate == wasteRate)&&(identical(other.unpricedDiscards, unpricedDiscards) || other.unpricedDiscards == unpricedDiscards)&&const DeepCollectionEquality().equals(other.reasons, _reasons)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.products, _products)&&(identical(other.fate, fate) || other.fate == fate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,hasPantry,wasted,wasteRate,unpricedDiscards,const DeepCollectionEquality().hash(_reasons),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_products),fate);
}

@override
String toString() {
    return 'PantryOverview(hasPantry: $hasPantry, wasted: $wasted, wasteRate: $wasteRate, unpricedDiscards: $unpricedDiscards, reasons: $reasons, categories: $categories, products: $products, fate: $fate)';
}


}

/// @nodoc
abstract mixin class _$PantryOverviewCopyWith<$Res> implements $PantryOverviewCopyWith<$Res> {
  factory _$PantryOverviewCopyWith(_PantryOverview value, $Res Function(_PantryOverview) _then) = __$PantryOverviewCopyWithImpl;
@override @useResult
$Res call({
 bool hasPantry, PeriodAmount wasted, double? wasteRate, int unpricedDiscards, List<WasteByReason> reasons, List<WasteByCategory> categories, List<WastedProduct> products, SpendingFate fate
});


@override $PeriodAmountCopyWith<$Res> get wasted;@override $SpendingFateCopyWith<$Res> get fate;

}
/// @nodoc
class __$PantryOverviewCopyWithImpl<$Res>
    implements _$PantryOverviewCopyWith<$Res> {
  __$PantryOverviewCopyWithImpl(this._self, this._then);

  final _PantryOverview _self;
  final $Res Function(_PantryOverview) _then;

/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasPantry = null,Object? wasted = null,Object? wasteRate = freezed,Object? unpricedDiscards = null,Object? reasons = null,Object? categories = null,Object? products = null,Object? fate = null,}) {
  return _then(_PantryOverview(
hasPantry: null == hasPantry ? _self.hasPantry : hasPantry // ignore: cast_nullable_to_non_nullable
as bool,wasted: null == wasted ? _self.wasted : wasted // ignore: cast_nullable_to_non_nullable
as PeriodAmount,wasteRate: freezed == wasteRate ? _self.wasteRate : wasteRate // ignore: cast_nullable_to_non_nullable
as double?,unpricedDiscards: null == unpricedDiscards ? _self.unpricedDiscards : unpricedDiscards // ignore: cast_nullable_to_non_nullable
as int,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<WasteByReason>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<WasteByCategory>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<WastedProduct>,fate: null == fate ? _self.fate : fate // ignore: cast_nullable_to_non_nullable
as SpendingFate,
  ));
}

/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodAmountCopyWith<$Res> get wasted {
  
  return $PeriodAmountCopyWith<$Res>(_self.wasted, (value) {
    return _then(_self.copyWith(wasted: value));
  });
}/// Create a copy of PantryOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingFateCopyWith<$Res> get fate {
  
  return $SpendingFateCopyWith<$Res>(_self.fate, (value) {
    return _then(_self.copyWith(fate: value));
  });
}
}

/// @nodoc
mixin _$WasteByReason {

 PantryEventReason get reason; int get cents;
/// Create a copy of WasteByReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WasteByReasonCopyWith<WasteByReason> get copyWith => _$WasteByReasonCopyWithImpl<WasteByReason>(this as WasteByReason, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WasteByReason;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WasteByReason&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.cents, _this.cents) || other.cents == _this.cents));
}


@override
int get hashCode {
  final _this = this as WasteByReason;
  return Object.hash(runtimeType,_this.reason,_this.cents);
}

@override
String toString() {
  final _this = this as WasteByReason;
  return 'WasteByReason(reason: ${_this.reason}, cents: ${_this.cents})';
}


}

/// @nodoc
abstract mixin class $WasteByReasonCopyWith<$Res>  {
  factory $WasteByReasonCopyWith(WasteByReason value, $Res Function(WasteByReason) _then) = _$WasteByReasonCopyWithImpl;
@useResult
$Res call({
 PantryEventReason reason, int cents
});




}
/// @nodoc
class _$WasteByReasonCopyWithImpl<$Res>
    implements $WasteByReasonCopyWith<$Res> {
  _$WasteByReasonCopyWithImpl(this._self, this._then);

  final WasteByReason _self;
  final $Res Function(WasteByReason) _then;

/// Create a copy of WasteByReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? cents = null,}) {
  return _then(WasteByReason(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as PantryEventReason,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WasteByReason].
extension WasteByReasonPatterns on WasteByReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WasteByReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WasteByReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WasteByReason value)  $default,){
final _that = this;
switch (_that) {
case _WasteByReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WasteByReason value)?  $default,){
final _that = this;
switch (_that) {
case _WasteByReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PantryEventReason reason,  int cents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WasteByReason() when $default != null:
return $default(_that.reason,_that.cents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PantryEventReason reason,  int cents)  $default,) {final _that = this;
switch (_that) {
case _WasteByReason():
return $default(_that.reason,_that.cents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PantryEventReason reason,  int cents)?  $default,) {final _that = this;
switch (_that) {
case _WasteByReason() when $default != null:
return $default(_that.reason,_that.cents);case _:
  return null;

}
}

}

/// @nodoc


class _WasteByReason implements WasteByReason {
  const _WasteByReason({required this.reason, required this.cents});
  

@override final  PantryEventReason reason;
@override final  int cents;

/// Create a copy of WasteByReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WasteByReasonCopyWith<_WasteByReason> get copyWith => __$WasteByReasonCopyWithImpl<_WasteByReason>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WasteByReason&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.cents, cents) || other.cents == cents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason,cents);
}

@override
String toString() {
    return 'WasteByReason(reason: $reason, cents: $cents)';
}


}

/// @nodoc
abstract mixin class _$WasteByReasonCopyWith<$Res> implements $WasteByReasonCopyWith<$Res> {
  factory _$WasteByReasonCopyWith(_WasteByReason value, $Res Function(_WasteByReason) _then) = __$WasteByReasonCopyWithImpl;
@override @useResult
$Res call({
 PantryEventReason reason, int cents
});




}
/// @nodoc
class __$WasteByReasonCopyWithImpl<$Res>
    implements _$WasteByReasonCopyWith<$Res> {
  __$WasteByReasonCopyWithImpl(this._self, this._then);

  final _WasteByReason _self;
  final $Res Function(_WasteByReason) _then;

/// Create a copy of WasteByReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? cents = null,}) {
  return _then(_WasteByReason(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as PantryEventReason,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$WasteByCategory {

 int get cents;/// Null for lots with no category.
 CategoryInfo? get category;/// Same slot as the spending charts (position among category ids).
 int? get colorSlot;
/// Create a copy of WasteByCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WasteByCategoryCopyWith<WasteByCategory> get copyWith => _$WasteByCategoryCopyWithImpl<WasteByCategory>(this as WasteByCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WasteByCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WasteByCategory&&(identical(other.cents, _this.cents) || other.cents == _this.cents)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.colorSlot, _this.colorSlot) || other.colorSlot == _this.colorSlot));
}


@override
int get hashCode {
  final _this = this as WasteByCategory;
  return Object.hash(runtimeType,_this.cents,_this.category,_this.colorSlot);
}

@override
String toString() {
  final _this = this as WasteByCategory;
  return 'WasteByCategory(cents: ${_this.cents}, category: ${_this.category}, colorSlot: ${_this.colorSlot})';
}


}

/// @nodoc
abstract mixin class $WasteByCategoryCopyWith<$Res>  {
  factory $WasteByCategoryCopyWith(WasteByCategory value, $Res Function(WasteByCategory) _then) = _$WasteByCategoryCopyWithImpl;
@useResult
$Res call({
 int cents, CategoryInfo? category, int? colorSlot
});


$CategoryInfoCopyWith<$Res>? get category;

}
/// @nodoc
class _$WasteByCategoryCopyWithImpl<$Res>
    implements $WasteByCategoryCopyWith<$Res> {
  _$WasteByCategoryCopyWithImpl(this._self, this._then);

  final WasteByCategory _self;
  final $Res Function(WasteByCategory) _then;

/// Create a copy of WasteByCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cents = null,Object? category = freezed,Object? colorSlot = freezed,}) {
  return _then(WasteByCategory(
cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryInfo?,colorSlot: freezed == colorSlot ? _self.colorSlot : colorSlot // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of WasteByCategory
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


/// Adds pattern-matching-related methods to [WasteByCategory].
extension WasteByCategoryPatterns on WasteByCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WasteByCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WasteByCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WasteByCategory value)  $default,){
final _that = this;
switch (_that) {
case _WasteByCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WasteByCategory value)?  $default,){
final _that = this;
switch (_that) {
case _WasteByCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cents,  CategoryInfo? category,  int? colorSlot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WasteByCategory() when $default != null:
return $default(_that.cents,_that.category,_that.colorSlot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cents,  CategoryInfo? category,  int? colorSlot)  $default,) {final _that = this;
switch (_that) {
case _WasteByCategory():
return $default(_that.cents,_that.category,_that.colorSlot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cents,  CategoryInfo? category,  int? colorSlot)?  $default,) {final _that = this;
switch (_that) {
case _WasteByCategory() when $default != null:
return $default(_that.cents,_that.category,_that.colorSlot);case _:
  return null;

}
}

}

/// @nodoc


class _WasteByCategory implements WasteByCategory {
  const _WasteByCategory({required this.cents, this.category, this.colorSlot});
  

@override final  int cents;
/// Null for lots with no category.
@override final  CategoryInfo? category;
/// Same slot as the spending charts (position among category ids).
@override final  int? colorSlot;

/// Create a copy of WasteByCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WasteByCategoryCopyWith<_WasteByCategory> get copyWith => __$WasteByCategoryCopyWithImpl<_WasteByCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WasteByCategory&&(identical(other.cents, cents) || other.cents == cents)&&(identical(other.category, category) || other.category == category)&&(identical(other.colorSlot, colorSlot) || other.colorSlot == colorSlot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cents,category,colorSlot);
}

@override
String toString() {
    return 'WasteByCategory(cents: $cents, category: $category, colorSlot: $colorSlot)';
}


}

/// @nodoc
abstract mixin class _$WasteByCategoryCopyWith<$Res> implements $WasteByCategoryCopyWith<$Res> {
  factory _$WasteByCategoryCopyWith(_WasteByCategory value, $Res Function(_WasteByCategory) _then) = __$WasteByCategoryCopyWithImpl;
@override @useResult
$Res call({
 int cents, CategoryInfo? category, int? colorSlot
});


@override $CategoryInfoCopyWith<$Res>? get category;

}
/// @nodoc
class __$WasteByCategoryCopyWithImpl<$Res>
    implements _$WasteByCategoryCopyWith<$Res> {
  __$WasteByCategoryCopyWithImpl(this._self, this._then);

  final _WasteByCategory _self;
  final $Res Function(_WasteByCategory) _then;

/// Create a copy of WasteByCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cents = null,Object? category = freezed,Object? colorSlot = freezed,}) {
  return _then(_WasteByCategory(
cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryInfo?,colorSlot: freezed == colorSlot ? _self.colorSlot : colorSlot // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of WasteByCategory
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
mixin _$WastedProduct {

 String get name; int get cents;/// How many lots of it had something thrown away.
 int get lotCount;/// Null for lots matched to no product (grouped by name).
 int? get productId;
/// Create a copy of WastedProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WastedProductCopyWith<WastedProduct> get copyWith => _$WastedProductCopyWithImpl<WastedProduct>(this as WastedProduct, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WastedProduct;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WastedProduct&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.cents, _this.cents) || other.cents == _this.cents)&&(identical(other.lotCount, _this.lotCount) || other.lotCount == _this.lotCount)&&(identical(other.productId, _this.productId) || other.productId == _this.productId));
}


@override
int get hashCode {
  final _this = this as WastedProduct;
  return Object.hash(runtimeType,_this.name,_this.cents,_this.lotCount,_this.productId);
}

@override
String toString() {
  final _this = this as WastedProduct;
  return 'WastedProduct(name: ${_this.name}, cents: ${_this.cents}, lotCount: ${_this.lotCount}, productId: ${_this.productId})';
}


}

/// @nodoc
abstract mixin class $WastedProductCopyWith<$Res>  {
  factory $WastedProductCopyWith(WastedProduct value, $Res Function(WastedProduct) _then) = _$WastedProductCopyWithImpl;
@useResult
$Res call({
 String name, int cents, int lotCount, int? productId
});




}
/// @nodoc
class _$WastedProductCopyWithImpl<$Res>
    implements $WastedProductCopyWith<$Res> {
  _$WastedProductCopyWithImpl(this._self, this._then);

  final WastedProduct _self;
  final $Res Function(WastedProduct) _then;

/// Create a copy of WastedProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? cents = null,Object? lotCount = null,Object? productId = freezed,}) {
  return _then(WastedProduct(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,lotCount: null == lotCount ? _self.lotCount : lotCount // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [WastedProduct].
extension WastedProductPatterns on WastedProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WastedProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WastedProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WastedProduct value)  $default,){
final _that = this;
switch (_that) {
case _WastedProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WastedProduct value)?  $default,){
final _that = this;
switch (_that) {
case _WastedProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int cents,  int lotCount,  int? productId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WastedProduct() when $default != null:
return $default(_that.name,_that.cents,_that.lotCount,_that.productId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int cents,  int lotCount,  int? productId)  $default,) {final _that = this;
switch (_that) {
case _WastedProduct():
return $default(_that.name,_that.cents,_that.lotCount,_that.productId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int cents,  int lotCount,  int? productId)?  $default,) {final _that = this;
switch (_that) {
case _WastedProduct() when $default != null:
return $default(_that.name,_that.cents,_that.lotCount,_that.productId);case _:
  return null;

}
}

}

/// @nodoc


class _WastedProduct implements WastedProduct {
  const _WastedProduct({required this.name, required this.cents, required this.lotCount, this.productId});
  

@override final  String name;
@override final  int cents;
/// How many lots of it had something thrown away.
@override final  int lotCount;
/// Null for lots matched to no product (grouped by name).
@override final  int? productId;

/// Create a copy of WastedProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WastedProductCopyWith<_WastedProduct> get copyWith => __$WastedProductCopyWithImpl<_WastedProduct>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WastedProduct&&(identical(other.name, name) || other.name == name)&&(identical(other.cents, cents) || other.cents == cents)&&(identical(other.lotCount, lotCount) || other.lotCount == lotCount)&&(identical(other.productId, productId) || other.productId == productId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,cents,lotCount,productId);
}

@override
String toString() {
    return 'WastedProduct(name: $name, cents: $cents, lotCount: $lotCount, productId: $productId)';
}


}

/// @nodoc
abstract mixin class _$WastedProductCopyWith<$Res> implements $WastedProductCopyWith<$Res> {
  factory _$WastedProductCopyWith(_WastedProduct value, $Res Function(_WastedProduct) _then) = __$WastedProductCopyWithImpl;
@override @useResult
$Res call({
 String name, int cents, int lotCount, int? productId
});




}
/// @nodoc
class __$WastedProductCopyWithImpl<$Res>
    implements _$WastedProductCopyWith<$Res> {
  __$WastedProductCopyWithImpl(this._self, this._then);

  final _WastedProduct _self;
  final $Res Function(_WastedProduct) _then;

/// Create a copy of WastedProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? cents = null,Object? lotCount = null,Object? productId = freezed,}) {
  return _then(_WastedProduct(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cents: null == cents ? _self.cents : cents // ignore: cast_nullable_to_non_nullable
as int,lotCount: null == lotCount ? _self.lotCount : lotCount // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$SpendingFate {

/// Printed totals of the period's receipts (M1), or the lots' prices if
/// those are larger.
 int get totalCents; int get usedCents; int get wastedCents; int get inPantryCents; int get notInPantryCents;/// Lots of the period's receipts.
 int get lotCount;/// How many of them were never moved (no use, discard or recount): they
/// count as still in the pantry.
 int get untouchedLotCount;
/// Create a copy of SpendingFate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpendingFateCopyWith<SpendingFate> get copyWith => _$SpendingFateCopyWithImpl<SpendingFate>(this as SpendingFate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SpendingFate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpendingFate&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.usedCents, _this.usedCents) || other.usedCents == _this.usedCents)&&(identical(other.wastedCents, _this.wastedCents) || other.wastedCents == _this.wastedCents)&&(identical(other.inPantryCents, _this.inPantryCents) || other.inPantryCents == _this.inPantryCents)&&(identical(other.notInPantryCents, _this.notInPantryCents) || other.notInPantryCents == _this.notInPantryCents)&&(identical(other.lotCount, _this.lotCount) || other.lotCount == _this.lotCount)&&(identical(other.untouchedLotCount, _this.untouchedLotCount) || other.untouchedLotCount == _this.untouchedLotCount));
}


@override
int get hashCode {
  final _this = this as SpendingFate;
  return Object.hash(runtimeType,_this.totalCents,_this.usedCents,_this.wastedCents,_this.inPantryCents,_this.notInPantryCents,_this.lotCount,_this.untouchedLotCount);
}

@override
String toString() {
  final _this = this as SpendingFate;
  return 'SpendingFate(totalCents: ${_this.totalCents}, usedCents: ${_this.usedCents}, wastedCents: ${_this.wastedCents}, inPantryCents: ${_this.inPantryCents}, notInPantryCents: ${_this.notInPantryCents}, lotCount: ${_this.lotCount}, untouchedLotCount: ${_this.untouchedLotCount})';
}


}

/// @nodoc
abstract mixin class $SpendingFateCopyWith<$Res>  {
  factory $SpendingFateCopyWith(SpendingFate value, $Res Function(SpendingFate) _then) = _$SpendingFateCopyWithImpl;
@useResult
$Res call({
 int totalCents, int usedCents, int wastedCents, int inPantryCents, int notInPantryCents, int lotCount, int untouchedLotCount
});




}
/// @nodoc
class _$SpendingFateCopyWithImpl<$Res>
    implements $SpendingFateCopyWith<$Res> {
  _$SpendingFateCopyWithImpl(this._self, this._then);

  final SpendingFate _self;
  final $Res Function(SpendingFate) _then;

/// Create a copy of SpendingFate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCents = null,Object? usedCents = null,Object? wastedCents = null,Object? inPantryCents = null,Object? notInPantryCents = null,Object? lotCount = null,Object? untouchedLotCount = null,}) {
  return _then(SpendingFate(
totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,usedCents: null == usedCents ? _self.usedCents : usedCents // ignore: cast_nullable_to_non_nullable
as int,wastedCents: null == wastedCents ? _self.wastedCents : wastedCents // ignore: cast_nullable_to_non_nullable
as int,inPantryCents: null == inPantryCents ? _self.inPantryCents : inPantryCents // ignore: cast_nullable_to_non_nullable
as int,notInPantryCents: null == notInPantryCents ? _self.notInPantryCents : notInPantryCents // ignore: cast_nullable_to_non_nullable
as int,lotCount: null == lotCount ? _self.lotCount : lotCount // ignore: cast_nullable_to_non_nullable
as int,untouchedLotCount: null == untouchedLotCount ? _self.untouchedLotCount : untouchedLotCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SpendingFate].
extension SpendingFatePatterns on SpendingFate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpendingFate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpendingFate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpendingFate value)  $default,){
final _that = this;
switch (_that) {
case _SpendingFate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpendingFate value)?  $default,){
final _that = this;
switch (_that) {
case _SpendingFate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCents,  int usedCents,  int wastedCents,  int inPantryCents,  int notInPantryCents,  int lotCount,  int untouchedLotCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpendingFate() when $default != null:
return $default(_that.totalCents,_that.usedCents,_that.wastedCents,_that.inPantryCents,_that.notInPantryCents,_that.lotCount,_that.untouchedLotCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCents,  int usedCents,  int wastedCents,  int inPantryCents,  int notInPantryCents,  int lotCount,  int untouchedLotCount)  $default,) {final _that = this;
switch (_that) {
case _SpendingFate():
return $default(_that.totalCents,_that.usedCents,_that.wastedCents,_that.inPantryCents,_that.notInPantryCents,_that.lotCount,_that.untouchedLotCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCents,  int usedCents,  int wastedCents,  int inPantryCents,  int notInPantryCents,  int lotCount,  int untouchedLotCount)?  $default,) {final _that = this;
switch (_that) {
case _SpendingFate() when $default != null:
return $default(_that.totalCents,_that.usedCents,_that.wastedCents,_that.inPantryCents,_that.notInPantryCents,_that.lotCount,_that.untouchedLotCount);case _:
  return null;

}
}

}

/// @nodoc


class _SpendingFate extends SpendingFate {
  const _SpendingFate({required this.totalCents, required this.usedCents, required this.wastedCents, required this.inPantryCents, required this.notInPantryCents, required this.lotCount, required this.untouchedLotCount}): super._();
  

/// Printed totals of the period's receipts (M1), or the lots' prices if
/// those are larger.
@override final  int totalCents;
@override final  int usedCents;
@override final  int wastedCents;
@override final  int inPantryCents;
@override final  int notInPantryCents;
/// Lots of the period's receipts.
@override final  int lotCount;
/// How many of them were never moved (no use, discard or recount): they
/// count as still in the pantry.
@override final  int untouchedLotCount;

/// Create a copy of SpendingFate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpendingFateCopyWith<_SpendingFate> get copyWith => __$SpendingFateCopyWithImpl<_SpendingFate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpendingFate&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.usedCents, usedCents) || other.usedCents == usedCents)&&(identical(other.wastedCents, wastedCents) || other.wastedCents == wastedCents)&&(identical(other.inPantryCents, inPantryCents) || other.inPantryCents == inPantryCents)&&(identical(other.notInPantryCents, notInPantryCents) || other.notInPantryCents == notInPantryCents)&&(identical(other.lotCount, lotCount) || other.lotCount == lotCount)&&(identical(other.untouchedLotCount, untouchedLotCount) || other.untouchedLotCount == untouchedLotCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totalCents,usedCents,wastedCents,inPantryCents,notInPantryCents,lotCount,untouchedLotCount);
}

@override
String toString() {
    return 'SpendingFate(totalCents: $totalCents, usedCents: $usedCents, wastedCents: $wastedCents, inPantryCents: $inPantryCents, notInPantryCents: $notInPantryCents, lotCount: $lotCount, untouchedLotCount: $untouchedLotCount)';
}


}

/// @nodoc
abstract mixin class _$SpendingFateCopyWith<$Res> implements $SpendingFateCopyWith<$Res> {
  factory _$SpendingFateCopyWith(_SpendingFate value, $Res Function(_SpendingFate) _then) = __$SpendingFateCopyWithImpl;
@override @useResult
$Res call({
 int totalCents, int usedCents, int wastedCents, int inPantryCents, int notInPantryCents, int lotCount, int untouchedLotCount
});




}
/// @nodoc
class __$SpendingFateCopyWithImpl<$Res>
    implements _$SpendingFateCopyWith<$Res> {
  __$SpendingFateCopyWithImpl(this._self, this._then);

  final _SpendingFate _self;
  final $Res Function(_SpendingFate) _then;

/// Create a copy of SpendingFate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCents = null,Object? usedCents = null,Object? wastedCents = null,Object? inPantryCents = null,Object? notInPantryCents = null,Object? lotCount = null,Object? untouchedLotCount = null,}) {
  return _then(_SpendingFate(
totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,usedCents: null == usedCents ? _self.usedCents : usedCents // ignore: cast_nullable_to_non_nullable
as int,wastedCents: null == wastedCents ? _self.wastedCents : wastedCents // ignore: cast_nullable_to_non_nullable
as int,inPantryCents: null == inPantryCents ? _self.inPantryCents : inPantryCents // ignore: cast_nullable_to_non_nullable
as int,notInPantryCents: null == notInPantryCents ? _self.notInPantryCents : notInPantryCents // ignore: cast_nullable_to_non_nullable
as int,lotCount: null == lotCount ? _self.lotCount : lotCount // ignore: cast_nullable_to_non_nullable
as int,untouchedLotCount: null == untouchedLotCount ? _self.untouchedLotCount : untouchedLotCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
