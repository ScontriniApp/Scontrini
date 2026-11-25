// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PantryHistory {

 List<PantryHistoryLot> get lots;
/// Create a copy of PantryHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryHistoryCopyWith<PantryHistory> get copyWith => _$PantryHistoryCopyWithImpl<PantryHistory>(this as PantryHistory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PantryHistory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryHistory&&const DeepCollectionEquality().equals(other.lots, _this.lots));
}


@override
int get hashCode {
  final _this = this as PantryHistory;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lots));
}

@override
String toString() {
  final _this = this as PantryHistory;
  return 'PantryHistory(lots: ${_this.lots})';
}


}

/// @nodoc
abstract mixin class $PantryHistoryCopyWith<$Res>  {
  factory $PantryHistoryCopyWith(PantryHistory value, $Res Function(PantryHistory) _then) = _$PantryHistoryCopyWithImpl;
@useResult
$Res call({
 List<PantryHistoryLot> lots
});




}
/// @nodoc
class _$PantryHistoryCopyWithImpl<$Res>
    implements $PantryHistoryCopyWith<$Res> {
  _$PantryHistoryCopyWithImpl(this._self, this._then);

  final PantryHistory _self;
  final $Res Function(PantryHistory) _then;

/// Create a copy of PantryHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lots = null,}) {
  return _then(PantryHistory(
lots: null == lots ? _self.lots : lots // ignore: cast_nullable_to_non_nullable
as List<PantryHistoryLot>,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryHistory].
extension PantryHistoryPatterns on PantryHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryHistory value)  $default,){
final _that = this;
switch (_that) {
case _PantryHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryHistory value)?  $default,){
final _that = this;
switch (_that) {
case _PantryHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PantryHistoryLot> lots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryHistory() when $default != null:
return $default(_that.lots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PantryHistoryLot> lots)  $default,) {final _that = this;
switch (_that) {
case _PantryHistory():
return $default(_that.lots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PantryHistoryLot> lots)?  $default,) {final _that = this;
switch (_that) {
case _PantryHistory() when $default != null:
return $default(_that.lots);case _:
  return null;

}
}

}

/// @nodoc


class _PantryHistory extends PantryHistory {
  const _PantryHistory({required  List<PantryHistoryLot> lots}): _lots = lots,super._();
  

 final  List<PantryHistoryLot> _lots;
@override List<PantryHistoryLot> get lots {
  if (_lots is EqualUnmodifiableListView) return _lots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lots);
}


/// Create a copy of PantryHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryHistoryCopyWith<_PantryHistory> get copyWith => __$PantryHistoryCopyWithImpl<_PantryHistory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryHistory&&const DeepCollectionEquality().equals(other.lots, _lots));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lots));
}

@override
String toString() {
    return 'PantryHistory(lots: $lots)';
}


}

/// @nodoc
abstract mixin class _$PantryHistoryCopyWith<$Res> implements $PantryHistoryCopyWith<$Res> {
  factory _$PantryHistoryCopyWith(_PantryHistory value, $Res Function(_PantryHistory) _then) = __$PantryHistoryCopyWithImpl;
@override @useResult
$Res call({
 List<PantryHistoryLot> lots
});




}
/// @nodoc
class __$PantryHistoryCopyWithImpl<$Res>
    implements _$PantryHistoryCopyWith<$Res> {
  __$PantryHistoryCopyWithImpl(this._self, this._then);

  final _PantryHistory _self;
  final $Res Function(_PantryHistory) _then;

/// Create a copy of PantryHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lots = null,}) {
  return _then(_PantryHistory(
lots: null == lots ? _self._lots : lots // ignore: cast_nullable_to_non_nullable
as List<PantryHistoryLot>,
  ));
}


}

/// @nodoc
mixin _$PantryHistoryLot {

 int get id; String get name; PantrySource get source;/// Purchased quantity (pieces, kg or l).
 double get initialQuantity;/// UTC.
 DateTime get addedAt;/// In insertion (id) order, reverts included.
 List<PantryEvent> get events;/// Set exactly for [PantrySource.receipt] lots.
 int? get receiptId; int? get productId; int? get categoryId;/// What was paid for the lot after discounts; null for gifts, things
/// already at home and manual purchases with no price.
 int? get priceCents;
/// Create a copy of PantryHistoryLot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryHistoryLotCopyWith<PantryHistoryLot> get copyWith => _$PantryHistoryLotCopyWithImpl<PantryHistoryLot>(this as PantryHistoryLot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PantryHistoryLot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryHistoryLot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.initialQuantity, _this.initialQuantity) || other.initialQuantity == _this.initialQuantity)&&(identical(other.addedAt, _this.addedAt) || other.addedAt == _this.addedAt)&&const DeepCollectionEquality().equals(other.events, _this.events)&&(identical(other.receiptId, _this.receiptId) || other.receiptId == _this.receiptId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.priceCents, _this.priceCents) || other.priceCents == _this.priceCents));
}


@override
int get hashCode {
  final _this = this as PantryHistoryLot;
  return Object.hash(runtimeType,_this.id,_this.name,_this.source,_this.initialQuantity,_this.addedAt,const DeepCollectionEquality().hash(_this.events),_this.receiptId,_this.productId,_this.categoryId,_this.priceCents);
}

@override
String toString() {
  final _this = this as PantryHistoryLot;
  return 'PantryHistoryLot(id: ${_this.id}, name: ${_this.name}, source: ${_this.source}, initialQuantity: ${_this.initialQuantity}, addedAt: ${_this.addedAt}, events: ${_this.events}, receiptId: ${_this.receiptId}, productId: ${_this.productId}, categoryId: ${_this.categoryId}, priceCents: ${_this.priceCents})';
}


}

/// @nodoc
abstract mixin class $PantryHistoryLotCopyWith<$Res>  {
  factory $PantryHistoryLotCopyWith(PantryHistoryLot value, $Res Function(PantryHistoryLot) _then) = _$PantryHistoryLotCopyWithImpl;
@useResult
$Res call({
 int id, String name, PantrySource source, double initialQuantity, DateTime addedAt, List<PantryEvent> events, int? receiptId, int? productId, int? categoryId, int? priceCents
});




}
/// @nodoc
class _$PantryHistoryLotCopyWithImpl<$Res>
    implements $PantryHistoryLotCopyWith<$Res> {
  _$PantryHistoryLotCopyWithImpl(this._self, this._then);

  final PantryHistoryLot _self;
  final $Res Function(PantryHistoryLot) _then;

/// Create a copy of PantryHistoryLot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? source = null,Object? initialQuantity = null,Object? addedAt = null,Object? events = null,Object? receiptId = freezed,Object? productId = freezed,Object? categoryId = freezed,Object? priceCents = freezed,}) {
  return _then(PantryHistoryLot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PantrySource,initialQuantity: null == initialQuantity ? _self.initialQuantity : initialQuantity // ignore: cast_nullable_to_non_nullable
as double,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<PantryEvent>,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as int?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryHistoryLot].
extension PantryHistoryLotPatterns on PantryHistoryLot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryHistoryLot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryHistoryLot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryHistoryLot value)  $default,){
final _that = this;
switch (_that) {
case _PantryHistoryLot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryHistoryLot value)?  $default,){
final _that = this;
switch (_that) {
case _PantryHistoryLot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  PantrySource source,  double initialQuantity,  DateTime addedAt,  List<PantryEvent> events,  int? receiptId,  int? productId,  int? categoryId,  int? priceCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryHistoryLot() when $default != null:
return $default(_that.id,_that.name,_that.source,_that.initialQuantity,_that.addedAt,_that.events,_that.receiptId,_that.productId,_that.categoryId,_that.priceCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  PantrySource source,  double initialQuantity,  DateTime addedAt,  List<PantryEvent> events,  int? receiptId,  int? productId,  int? categoryId,  int? priceCents)  $default,) {final _that = this;
switch (_that) {
case _PantryHistoryLot():
return $default(_that.id,_that.name,_that.source,_that.initialQuantity,_that.addedAt,_that.events,_that.receiptId,_that.productId,_that.categoryId,_that.priceCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  PantrySource source,  double initialQuantity,  DateTime addedAt,  List<PantryEvent> events,  int? receiptId,  int? productId,  int? categoryId,  int? priceCents)?  $default,) {final _that = this;
switch (_that) {
case _PantryHistoryLot() when $default != null:
return $default(_that.id,_that.name,_that.source,_that.initialQuantity,_that.addedAt,_that.events,_that.receiptId,_that.productId,_that.categoryId,_that.priceCents);case _:
  return null;

}
}

}

/// @nodoc


class _PantryHistoryLot implements PantryHistoryLot {
  const _PantryHistoryLot({required this.id, required this.name, required this.source, required this.initialQuantity, required this.addedAt, required  List<PantryEvent> events, this.receiptId, this.productId, this.categoryId, this.priceCents}): _events = events;
  

@override final  int id;
@override final  String name;
@override final  PantrySource source;
/// Purchased quantity (pieces, kg or l).
@override final  double initialQuantity;
/// UTC.
@override final  DateTime addedAt;
/// In insertion (id) order, reverts included.
 final  List<PantryEvent> _events;
/// In insertion (id) order, reverts included.
@override List<PantryEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

/// Set exactly for [PantrySource.receipt] lots.
@override final  int? receiptId;
@override final  int? productId;
@override final  int? categoryId;
/// What was paid for the lot after discounts; null for gifts, things
/// already at home and manual purchases with no price.
@override final  int? priceCents;

/// Create a copy of PantryHistoryLot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryHistoryLotCopyWith<_PantryHistoryLot> get copyWith => __$PantryHistoryLotCopyWithImpl<_PantryHistoryLot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryHistoryLot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.initialQuantity, initialQuantity) || other.initialQuantity == initialQuantity)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&const DeepCollectionEquality().equals(other.events, _events)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,source,initialQuantity,addedAt,const DeepCollectionEquality().hash(_events),receiptId,productId,categoryId,priceCents);
}

@override
String toString() {
    return 'PantryHistoryLot(id: $id, name: $name, source: $source, initialQuantity: $initialQuantity, addedAt: $addedAt, events: $events, receiptId: $receiptId, productId: $productId, categoryId: $categoryId, priceCents: $priceCents)';
}


}

/// @nodoc
abstract mixin class _$PantryHistoryLotCopyWith<$Res> implements $PantryHistoryLotCopyWith<$Res> {
  factory _$PantryHistoryLotCopyWith(_PantryHistoryLot value, $Res Function(_PantryHistoryLot) _then) = __$PantryHistoryLotCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, PantrySource source, double initialQuantity, DateTime addedAt, List<PantryEvent> events, int? receiptId, int? productId, int? categoryId, int? priceCents
});




}
/// @nodoc
class __$PantryHistoryLotCopyWithImpl<$Res>
    implements _$PantryHistoryLotCopyWith<$Res> {
  __$PantryHistoryLotCopyWithImpl(this._self, this._then);

  final _PantryHistoryLot _self;
  final $Res Function(_PantryHistoryLot) _then;

/// Create a copy of PantryHistoryLot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? source = null,Object? initialQuantity = null,Object? addedAt = null,Object? events = null,Object? receiptId = freezed,Object? productId = freezed,Object? categoryId = freezed,Object? priceCents = freezed,}) {
  return _then(_PantryHistoryLot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PantrySource,initialQuantity: null == initialQuantity ? _self.initialQuantity : initialQuantity // ignore: cast_nullable_to_non_nullable
as double,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<PantryEvent>,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as int?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
