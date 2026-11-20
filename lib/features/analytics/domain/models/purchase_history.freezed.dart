// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseHistory {

/// Confirmed receipts, oldest first.
 List<PurchaseReceipt> get receipts; Map<int, ProductInfo> get products; Map<int, CategoryInfo> get categories; Map<int, StoreInfo> get stores;
/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseHistoryCopyWith<PurchaseHistory> get copyWith => _$PurchaseHistoryCopyWithImpl<PurchaseHistory>(this as PurchaseHistory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseHistory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseHistory&&const DeepCollectionEquality().equals(other.receipts, _this.receipts)&&const DeepCollectionEquality().equals(other.products, _this.products)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.stores, _this.stores));
}


@override
int get hashCode {
  final _this = this as PurchaseHistory;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.receipts),const DeepCollectionEquality().hash(_this.products),const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.stores));
}

@override
String toString() {
  final _this = this as PurchaseHistory;
  return 'PurchaseHistory(receipts: ${_this.receipts}, products: ${_this.products}, categories: ${_this.categories}, stores: ${_this.stores})';
}


}

/// @nodoc
abstract mixin class $PurchaseHistoryCopyWith<$Res>  {
  factory $PurchaseHistoryCopyWith(PurchaseHistory value, $Res Function(PurchaseHistory) _then) = _$PurchaseHistoryCopyWithImpl;
@useResult
$Res call({
 List<PurchaseReceipt> receipts, Map<int, ProductInfo> products, Map<int, CategoryInfo> categories, Map<int, StoreInfo> stores
});




}
/// @nodoc
class _$PurchaseHistoryCopyWithImpl<$Res>
    implements $PurchaseHistoryCopyWith<$Res> {
  _$PurchaseHistoryCopyWithImpl(this._self, this._then);

  final PurchaseHistory _self;
  final $Res Function(PurchaseHistory) _then;

/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receipts = null,Object? products = null,Object? categories = null,Object? stores = null,}) {
  return _then(PurchaseHistory(
receipts: null == receipts ? _self.receipts : receipts // ignore: cast_nullable_to_non_nullable
as List<PurchaseReceipt>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as Map<int, ProductInfo>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as Map<int, CategoryInfo>,stores: null == stores ? _self.stores : stores // ignore: cast_nullable_to_non_nullable
as Map<int, StoreInfo>,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseHistory].
extension PurchaseHistoryPatterns on PurchaseHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseHistory value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseHistory value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PurchaseReceipt> receipts,  Map<int, ProductInfo> products,  Map<int, CategoryInfo> categories,  Map<int, StoreInfo> stores)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
return $default(_that.receipts,_that.products,_that.categories,_that.stores);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PurchaseReceipt> receipts,  Map<int, ProductInfo> products,  Map<int, CategoryInfo> categories,  Map<int, StoreInfo> stores)  $default,) {final _that = this;
switch (_that) {
case _PurchaseHistory():
return $default(_that.receipts,_that.products,_that.categories,_that.stores);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PurchaseReceipt> receipts,  Map<int, ProductInfo> products,  Map<int, CategoryInfo> categories,  Map<int, StoreInfo> stores)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
return $default(_that.receipts,_that.products,_that.categories,_that.stores);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseHistory extends PurchaseHistory {
  const _PurchaseHistory({required  List<PurchaseReceipt> receipts,  Map<int, ProductInfo> products = const <int, ProductInfo>{},  Map<int, CategoryInfo> categories = const <int, CategoryInfo>{},  Map<int, StoreInfo> stores = const <int, StoreInfo>{}}): _receipts = receipts,_products = products,_categories = categories,_stores = stores,super._();
  

/// Confirmed receipts, oldest first.
 final  List<PurchaseReceipt> _receipts;
/// Confirmed receipts, oldest first.
@override List<PurchaseReceipt> get receipts {
  if (_receipts is EqualUnmodifiableListView) return _receipts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_receipts);
}

 final  Map<int, ProductInfo> _products;
@override@JsonKey() Map<int, ProductInfo> get products {
  if (_products is EqualUnmodifiableMapView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_products);
}

 final  Map<int, CategoryInfo> _categories;
@override@JsonKey() Map<int, CategoryInfo> get categories {
  if (_categories is EqualUnmodifiableMapView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categories);
}

 final  Map<int, StoreInfo> _stores;
@override@JsonKey() Map<int, StoreInfo> get stores {
  if (_stores is EqualUnmodifiableMapView) return _stores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stores);
}


/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseHistoryCopyWith<_PurchaseHistory> get copyWith => __$PurchaseHistoryCopyWithImpl<_PurchaseHistory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseHistory&&const DeepCollectionEquality().equals(other.receipts, _receipts)&&const DeepCollectionEquality().equals(other.products, _products)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.stores, _stores));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_receipts),const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_stores));
}

@override
String toString() {
    return 'PurchaseHistory(receipts: $receipts, products: $products, categories: $categories, stores: $stores)';
}


}

/// @nodoc
abstract mixin class _$PurchaseHistoryCopyWith<$Res> implements $PurchaseHistoryCopyWith<$Res> {
  factory _$PurchaseHistoryCopyWith(_PurchaseHistory value, $Res Function(_PurchaseHistory) _then) = __$PurchaseHistoryCopyWithImpl;
@override @useResult
$Res call({
 List<PurchaseReceipt> receipts, Map<int, ProductInfo> products, Map<int, CategoryInfo> categories, Map<int, StoreInfo> stores
});




}
/// @nodoc
class __$PurchaseHistoryCopyWithImpl<$Res>
    implements _$PurchaseHistoryCopyWith<$Res> {
  __$PurchaseHistoryCopyWithImpl(this._self, this._then);

  final _PurchaseHistory _self;
  final $Res Function(_PurchaseHistory) _then;

/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receipts = null,Object? products = null,Object? categories = null,Object? stores = null,}) {
  return _then(_PurchaseHistory(
receipts: null == receipts ? _self._receipts : receipts // ignore: cast_nullable_to_non_nullable
as List<PurchaseReceipt>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as Map<int, ProductInfo>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as Map<int, CategoryInfo>,stores: null == stores ? _self._stores : stores // ignore: cast_nullable_to_non_nullable
as Map<int, StoreInfo>,
  ));
}


}

/// @nodoc
mixin _$PurchaseReceipt {

 int get id;/// Instant of purchase. The database stores UTC; use
/// [DateRange.contains] or `toLocal()` before bucketing by day.
 DateTime get purchaseDate;/// Amount paid as printed on the receipt. M1 trusts this rather than the
/// sum of the items.
 int get totalCents;/// Discount not tied to any item (e.g. a basket coupon), positive.
 int get discountCents; int? get storeId; List<PurchaseItem> get items;
/// Create a copy of PurchaseReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseReceiptCopyWith<PurchaseReceipt> get copyWith => _$PurchaseReceiptCopyWithImpl<PurchaseReceipt>(this as PurchaseReceipt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseReceipt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.purchaseDate, _this.purchaseDate) || other.purchaseDate == _this.purchaseDate)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.discountCents, _this.discountCents) || other.discountCents == _this.discountCents)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as PurchaseReceipt;
  return Object.hash(runtimeType,_this.id,_this.purchaseDate,_this.totalCents,_this.discountCents,_this.storeId,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as PurchaseReceipt;
  return 'PurchaseReceipt(id: ${_this.id}, purchaseDate: ${_this.purchaseDate}, totalCents: ${_this.totalCents}, discountCents: ${_this.discountCents}, storeId: ${_this.storeId}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $PurchaseReceiptCopyWith<$Res>  {
  factory $PurchaseReceiptCopyWith(PurchaseReceipt value, $Res Function(PurchaseReceipt) _then) = _$PurchaseReceiptCopyWithImpl;
@useResult
$Res call({
 int id, DateTime purchaseDate, int totalCents, int discountCents, int? storeId, List<PurchaseItem> items
});




}
/// @nodoc
class _$PurchaseReceiptCopyWithImpl<$Res>
    implements $PurchaseReceiptCopyWith<$Res> {
  _$PurchaseReceiptCopyWithImpl(this._self, this._then);

  final PurchaseReceipt _self;
  final $Res Function(PurchaseReceipt) _then;

/// Create a copy of PurchaseReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? purchaseDate = null,Object? totalCents = null,Object? discountCents = null,Object? storeId = freezed,Object? items = null,}) {
  return _then(PurchaseReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PurchaseItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseReceipt].
extension PurchaseReceiptPatterns on PurchaseReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseReceipt value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime purchaseDate,  int totalCents,  int discountCents,  int? storeId,  List<PurchaseItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseReceipt() when $default != null:
return $default(_that.id,_that.purchaseDate,_that.totalCents,_that.discountCents,_that.storeId,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime purchaseDate,  int totalCents,  int discountCents,  int? storeId,  List<PurchaseItem> items)  $default,) {final _that = this;
switch (_that) {
case _PurchaseReceipt():
return $default(_that.id,_that.purchaseDate,_that.totalCents,_that.discountCents,_that.storeId,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime purchaseDate,  int totalCents,  int discountCents,  int? storeId,  List<PurchaseItem> items)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseReceipt() when $default != null:
return $default(_that.id,_that.purchaseDate,_that.totalCents,_that.discountCents,_that.storeId,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseReceipt extends PurchaseReceipt {
  const _PurchaseReceipt({required this.id, required this.purchaseDate, required this.totalCents, this.discountCents = 0, this.storeId,  List<PurchaseItem> items = const <PurchaseItem>[]}): _items = items,super._();
  

@override final  int id;
/// Instant of purchase. The database stores UTC; use
/// [DateRange.contains] or `toLocal()` before bucketing by day.
@override final  DateTime purchaseDate;
/// Amount paid as printed on the receipt. M1 trusts this rather than the
/// sum of the items.
@override final  int totalCents;
/// Discount not tied to any item (e.g. a basket coupon), positive.
@override@JsonKey() final  int discountCents;
@override final  int? storeId;
 final  List<PurchaseItem> _items;
@override@JsonKey() List<PurchaseItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of PurchaseReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseReceiptCopyWith<_PurchaseReceipt> get copyWith => __$PurchaseReceiptCopyWithImpl<_PurchaseReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.discountCents, discountCents) || other.discountCents == discountCents)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,purchaseDate,totalCents,discountCents,storeId,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'PurchaseReceipt(id: $id, purchaseDate: $purchaseDate, totalCents: $totalCents, discountCents: $discountCents, storeId: $storeId, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PurchaseReceiptCopyWith<$Res> implements $PurchaseReceiptCopyWith<$Res> {
  factory _$PurchaseReceiptCopyWith(_PurchaseReceipt value, $Res Function(_PurchaseReceipt) _then) = __$PurchaseReceiptCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime purchaseDate, int totalCents, int discountCents, int? storeId, List<PurchaseItem> items
});




}
/// @nodoc
class __$PurchaseReceiptCopyWithImpl<$Res>
    implements _$PurchaseReceiptCopyWith<$Res> {
  __$PurchaseReceiptCopyWithImpl(this._self, this._then);

  final _PurchaseReceipt _self;
  final $Res Function(_PurchaseReceipt) _then;

/// Create a copy of PurchaseReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? purchaseDate = null,Object? totalCents = null,Object? discountCents = null,Object? storeId = freezed,Object? items = null,}) {
  return _then(_PurchaseReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PurchaseItem>,
  ));
}


}

/// @nodoc
mixin _$PurchaseItem {

 int get id;/// Name as printed on the receipt.
 String get rawName;/// Unit price as printed (full price, before discounts).
 int get unitPriceCents;/// Line amount before [discountCents]. Negative for returns and deposit
/// refunds.
 int get lineTotalCents;/// Pieces, or kg/l for weighed items.
 double get quantity;/// Discount attached to this line, positive.
 int get discountCents;/// Canonical product; `null` when the line was never matched. Such items
/// count towards spending and categories but not prices or frequency.
 int? get productId;/// Resolved category: the item's own, else the product's. `null` means
/// "Uncategorised". The DAO applies the fallback.
 int? get categoryId;
/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseItemCopyWith<PurchaseItem> get copyWith => _$PurchaseItemCopyWithImpl<PurchaseItem>(this as PurchaseItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rawName, _this.rawName) || other.rawName == _this.rawName)&&(identical(other.unitPriceCents, _this.unitPriceCents) || other.unitPriceCents == _this.unitPriceCents)&&(identical(other.lineTotalCents, _this.lineTotalCents) || other.lineTotalCents == _this.lineTotalCents)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.discountCents, _this.discountCents) || other.discountCents == _this.discountCents)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId));
}


@override
int get hashCode {
  final _this = this as PurchaseItem;
  return Object.hash(runtimeType,_this.id,_this.rawName,_this.unitPriceCents,_this.lineTotalCents,_this.quantity,_this.discountCents,_this.productId,_this.categoryId);
}

@override
String toString() {
  final _this = this as PurchaseItem;
  return 'PurchaseItem(id: ${_this.id}, rawName: ${_this.rawName}, unitPriceCents: ${_this.unitPriceCents}, lineTotalCents: ${_this.lineTotalCents}, quantity: ${_this.quantity}, discountCents: ${_this.discountCents}, productId: ${_this.productId}, categoryId: ${_this.categoryId})';
}


}

/// @nodoc
abstract mixin class $PurchaseItemCopyWith<$Res>  {
  factory $PurchaseItemCopyWith(PurchaseItem value, $Res Function(PurchaseItem) _then) = _$PurchaseItemCopyWithImpl;
@useResult
$Res call({
 int id, String rawName, int unitPriceCents, int lineTotalCents, double quantity, int discountCents, int? productId, int? categoryId
});




}
/// @nodoc
class _$PurchaseItemCopyWithImpl<$Res>
    implements $PurchaseItemCopyWith<$Res> {
  _$PurchaseItemCopyWithImpl(this._self, this._then);

  final PurchaseItem _self;
  final $Res Function(PurchaseItem) _then;

/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rawName = null,Object? unitPriceCents = null,Object? lineTotalCents = null,Object? quantity = null,Object? discountCents = null,Object? productId = freezed,Object? categoryId = freezed,}) {
  return _then(PurchaseItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,unitPriceCents: null == unitPriceCents ? _self.unitPriceCents : unitPriceCents // ignore: cast_nullable_to_non_nullable
as int,lineTotalCents: null == lineTotalCents ? _self.lineTotalCents : lineTotalCents // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseItem].
extension PurchaseItemPatterns on PurchaseItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String rawName,  int unitPriceCents,  int lineTotalCents,  double quantity,  int discountCents,  int? productId,  int? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
return $default(_that.id,_that.rawName,_that.unitPriceCents,_that.lineTotalCents,_that.quantity,_that.discountCents,_that.productId,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String rawName,  int unitPriceCents,  int lineTotalCents,  double quantity,  int discountCents,  int? productId,  int? categoryId)  $default,) {final _that = this;
switch (_that) {
case _PurchaseItem():
return $default(_that.id,_that.rawName,_that.unitPriceCents,_that.lineTotalCents,_that.quantity,_that.discountCents,_that.productId,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String rawName,  int unitPriceCents,  int lineTotalCents,  double quantity,  int discountCents,  int? productId,  int? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
return $default(_that.id,_that.rawName,_that.unitPriceCents,_that.lineTotalCents,_that.quantity,_that.discountCents,_that.productId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseItem extends PurchaseItem {
  const _PurchaseItem({required this.id, required this.rawName, required this.unitPriceCents, required this.lineTotalCents, this.quantity = 1, this.discountCents = 0, this.productId, this.categoryId}): super._();
  

@override final  int id;
/// Name as printed on the receipt.
@override final  String rawName;
/// Unit price as printed (full price, before discounts).
@override final  int unitPriceCents;
/// Line amount before [discountCents]. Negative for returns and deposit
/// refunds.
@override final  int lineTotalCents;
/// Pieces, or kg/l for weighed items.
@override@JsonKey() final  double quantity;
/// Discount attached to this line, positive.
@override@JsonKey() final  int discountCents;
/// Canonical product; `null` when the line was never matched. Such items
/// count towards spending and categories but not prices or frequency.
@override final  int? productId;
/// Resolved category: the item's own, else the product's. `null` means
/// "Uncategorised". The DAO applies the fallback.
@override final  int? categoryId;

/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseItemCopyWith<_PurchaseItem> get copyWith => __$PurchaseItemCopyWithImpl<_PurchaseItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.unitPriceCents, unitPriceCents) || other.unitPriceCents == unitPriceCents)&&(identical(other.lineTotalCents, lineTotalCents) || other.lineTotalCents == lineTotalCents)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.discountCents, discountCents) || other.discountCents == discountCents)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,rawName,unitPriceCents,lineTotalCents,quantity,discountCents,productId,categoryId);
}

@override
String toString() {
    return 'PurchaseItem(id: $id, rawName: $rawName, unitPriceCents: $unitPriceCents, lineTotalCents: $lineTotalCents, quantity: $quantity, discountCents: $discountCents, productId: $productId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$PurchaseItemCopyWith<$Res> implements $PurchaseItemCopyWith<$Res> {
  factory _$PurchaseItemCopyWith(_PurchaseItem value, $Res Function(_PurchaseItem) _then) = __$PurchaseItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String rawName, int unitPriceCents, int lineTotalCents, double quantity, int discountCents, int? productId, int? categoryId
});




}
/// @nodoc
class __$PurchaseItemCopyWithImpl<$Res>
    implements _$PurchaseItemCopyWith<$Res> {
  __$PurchaseItemCopyWithImpl(this._self, this._then);

  final _PurchaseItem _self;
  final $Res Function(_PurchaseItem) _then;

/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rawName = null,Object? unitPriceCents = null,Object? lineTotalCents = null,Object? quantity = null,Object? discountCents = null,Object? productId = freezed,Object? categoryId = freezed,}) {
  return _then(_PurchaseItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,unitPriceCents: null == unitPriceCents ? _self.unitPriceCents : unitPriceCents // ignore: cast_nullable_to_non_nullable
as int,lineTotalCents: null == lineTotalCents ? _self.lineTotalCents : lineTotalCents // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$ProductInfo {

 int get id; String get name; int? get categoryId;/// `null` when the unit is unknown; such products are compared only with
/// themselves.
 ProductUnit? get unit;
/// Create a copy of ProductInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductInfoCopyWith<ProductInfo> get copyWith => _$ProductInfoCopyWithImpl<ProductInfo>(this as ProductInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as ProductInfo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.categoryId,_this.unit);
}

@override
String toString() {
  final _this = this as ProductInfo;
  return 'ProductInfo(id: ${_this.id}, name: ${_this.name}, categoryId: ${_this.categoryId}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $ProductInfoCopyWith<$Res>  {
  factory $ProductInfoCopyWith(ProductInfo value, $Res Function(ProductInfo) _then) = _$ProductInfoCopyWithImpl;
@useResult
$Res call({
 int id, String name, int? categoryId, ProductUnit? unit
});




}
/// @nodoc
class _$ProductInfoCopyWithImpl<$Res>
    implements $ProductInfoCopyWith<$Res> {
  _$ProductInfoCopyWithImpl(this._self, this._then);

  final ProductInfo _self;
  final $Res Function(ProductInfo) _then;

/// Create a copy of ProductInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? categoryId = freezed,Object? unit = freezed,}) {
  return _then(ProductInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductInfo].
extension ProductInfoPatterns on ProductInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductInfo value)  $default,){
final _that = this;
switch (_that) {
case _ProductInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ProductInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int? categoryId,  ProductUnit? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductInfo() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int? categoryId,  ProductUnit? unit)  $default,) {final _that = this;
switch (_that) {
case _ProductInfo():
return $default(_that.id,_that.name,_that.categoryId,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int? categoryId,  ProductUnit? unit)?  $default,) {final _that = this;
switch (_that) {
case _ProductInfo() when $default != null:
return $default(_that.id,_that.name,_that.categoryId,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _ProductInfo implements ProductInfo {
  const _ProductInfo({required this.id, required this.name, this.categoryId, this.unit});
  

@override final  int id;
@override final  String name;
@override final  int? categoryId;
/// `null` when the unit is unknown; such products are compared only with
/// themselves.
@override final  ProductUnit? unit;

/// Create a copy of ProductInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductInfoCopyWith<_ProductInfo> get copyWith => __$ProductInfoCopyWithImpl<_ProductInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,categoryId,unit);
}

@override
String toString() {
    return 'ProductInfo(id: $id, name: $name, categoryId: $categoryId, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$ProductInfoCopyWith<$Res> implements $ProductInfoCopyWith<$Res> {
  factory _$ProductInfoCopyWith(_ProductInfo value, $Res Function(_ProductInfo) _then) = __$ProductInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int? categoryId, ProductUnit? unit
});




}
/// @nodoc
class __$ProductInfoCopyWithImpl<$Res>
    implements _$ProductInfoCopyWith<$Res> {
  __$ProductInfoCopyWithImpl(this._self, this._then);

  final _ProductInfo _self;
  final $Res Function(_ProductInfo) _then;

/// Create a copy of ProductInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? categoryId = freezed,Object? unit = freezed,}) {
  return _then(_ProductInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit?,
  ));
}


}

/// @nodoc
mixin _$CategoryInfo {

 int get id; String get name;/// Material icon name, resolved in the UI.
 String get icon;/// ARGB colour.
 int get color; int? get parentId;
/// Create a copy of CategoryInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryInfoCopyWith<CategoryInfo> get copyWith => _$CategoryInfoCopyWithImpl<CategoryInfo>(this as CategoryInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId));
}


@override
int get hashCode {
  final _this = this as CategoryInfo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.icon,_this.color,_this.parentId);
}

@override
String toString() {
  final _this = this as CategoryInfo;
  return 'CategoryInfo(id: ${_this.id}, name: ${_this.name}, icon: ${_this.icon}, color: ${_this.color}, parentId: ${_this.parentId})';
}


}

/// @nodoc
abstract mixin class $CategoryInfoCopyWith<$Res>  {
  factory $CategoryInfoCopyWith(CategoryInfo value, $Res Function(CategoryInfo) _then) = _$CategoryInfoCopyWithImpl;
@useResult
$Res call({
 int id, String name, String icon, int color, int? parentId
});




}
/// @nodoc
class _$CategoryInfoCopyWithImpl<$Res>
    implements $CategoryInfoCopyWith<$Res> {
  _$CategoryInfoCopyWithImpl(this._self, this._then);

  final CategoryInfo _self;
  final $Res Function(CategoryInfo) _then;

/// Create a copy of CategoryInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,Object? parentId = freezed,}) {
  return _then(CategoryInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryInfo].
extension CategoryInfoPatterns on CategoryInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryInfo value)  $default,){
final _that = this;
switch (_that) {
case _CategoryInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String icon,  int color,  int? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryInfo() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String icon,  int color,  int? parentId)  $default,) {final _that = this;
switch (_that) {
case _CategoryInfo():
return $default(_that.id,_that.name,_that.icon,_that.color,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String icon,  int color,  int? parentId)?  $default,) {final _that = this;
switch (_that) {
case _CategoryInfo() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryInfo implements CategoryInfo {
  const _CategoryInfo({required this.id, required this.name, required this.icon, required this.color, this.parentId});
  

@override final  int id;
@override final  String name;
/// Material icon name, resolved in the UI.
@override final  String icon;
/// ARGB colour.
@override final  int color;
@override final  int? parentId;

/// Create a copy of CategoryInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryInfoCopyWith<_CategoryInfo> get copyWith => __$CategoryInfoCopyWithImpl<_CategoryInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,icon,color,parentId);
}

@override
String toString() {
    return 'CategoryInfo(id: $id, name: $name, icon: $icon, color: $color, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$CategoryInfoCopyWith<$Res> implements $CategoryInfoCopyWith<$Res> {
  factory _$CategoryInfoCopyWith(_CategoryInfo value, $Res Function(_CategoryInfo) _then) = __$CategoryInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String icon, int color, int? parentId
});




}
/// @nodoc
class __$CategoryInfoCopyWithImpl<$Res>
    implements _$CategoryInfoCopyWith<$Res> {
  __$CategoryInfoCopyWithImpl(this._self, this._then);

  final _CategoryInfo _self;
  final $Res Function(_CategoryInfo) _then;

/// Create a copy of CategoryInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,Object? parentId = freezed,}) {
  return _then(_CategoryInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$StoreInfo {

 int get id; String get name; String? get vatNumber;
/// Create a copy of StoreInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreInfoCopyWith<StoreInfo> get copyWith => _$StoreInfoCopyWithImpl<StoreInfo>(this as StoreInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoreInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.vatNumber, _this.vatNumber) || other.vatNumber == _this.vatNumber));
}


@override
int get hashCode {
  final _this = this as StoreInfo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.vatNumber);
}

@override
String toString() {
  final _this = this as StoreInfo;
  return 'StoreInfo(id: ${_this.id}, name: ${_this.name}, vatNumber: ${_this.vatNumber})';
}


}

/// @nodoc
abstract mixin class $StoreInfoCopyWith<$Res>  {
  factory $StoreInfoCopyWith(StoreInfo value, $Res Function(StoreInfo) _then) = _$StoreInfoCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? vatNumber
});




}
/// @nodoc
class _$StoreInfoCopyWithImpl<$Res>
    implements $StoreInfoCopyWith<$Res> {
  _$StoreInfoCopyWithImpl(this._self, this._then);

  final StoreInfo _self;
  final $Res Function(StoreInfo) _then;

/// Create a copy of StoreInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? vatNumber = freezed,}) {
  return _then(StoreInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreInfo].
extension StoreInfoPatterns on StoreInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreInfo value)  $default,){
final _that = this;
switch (_that) {
case _StoreInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreInfo value)?  $default,){
final _that = this;
switch (_that) {
case _StoreInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? vatNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreInfo() when $default != null:
return $default(_that.id,_that.name,_that.vatNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? vatNumber)  $default,) {final _that = this;
switch (_that) {
case _StoreInfo():
return $default(_that.id,_that.name,_that.vatNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? vatNumber)?  $default,) {final _that = this;
switch (_that) {
case _StoreInfo() when $default != null:
return $default(_that.id,_that.name,_that.vatNumber);case _:
  return null;

}
}

}

/// @nodoc


class _StoreInfo implements StoreInfo {
  const _StoreInfo({required this.id, required this.name, this.vatNumber});
  

@override final  int id;
@override final  String name;
@override final  String? vatNumber;

/// Create a copy of StoreInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreInfoCopyWith<_StoreInfo> get copyWith => __$StoreInfoCopyWithImpl<_StoreInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,vatNumber);
}

@override
String toString() {
    return 'StoreInfo(id: $id, name: $name, vatNumber: $vatNumber)';
}


}

/// @nodoc
abstract mixin class _$StoreInfoCopyWith<$Res> implements $StoreInfoCopyWith<$Res> {
  factory _$StoreInfoCopyWith(_StoreInfo value, $Res Function(_StoreInfo) _then) = __$StoreInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? vatNumber
});




}
/// @nodoc
class __$StoreInfoCopyWithImpl<$Res>
    implements _$StoreInfoCopyWith<$Res> {
  __$StoreInfoCopyWithImpl(this._self, this._then);

  final _StoreInfo _self;
  final $Res Function(_StoreInfo) _then;

/// Create a copy of StoreInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? vatNumber = freezed,}) {
  return _then(_StoreInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
