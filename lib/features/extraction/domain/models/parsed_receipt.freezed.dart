// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedReceipt {

 List<ParsedItem> get items; String? get storeName;/// Italian VAT number (P.IVA), 11 digits.
 String? get vatNumber; String? get address;/// Date and time as printed, in local time. Convert to UTC when saving.
 DateTime? get purchaseDate;/// Printed grand total.
 int? get totalCents;/// Discounts not tied to a single item (e.g. a coupon on the subtotal),
/// as a positive amount.
 int get discountCents; List<ParseWarning> get warnings;/// Rows inside the item section that the parser could not interpret.
/// Shown in the review screen in case they hide a missed item.
 List<String> get unparsedLines;
/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedReceiptCopyWith<ParsedReceipt> get copyWith => _$ParsedReceiptCopyWithImpl<ParsedReceipt>(this as ParsedReceipt, _$identity);

  /// Serializes this ParsedReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ParsedReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedReceipt&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.storeName, _this.storeName) || other.storeName == _this.storeName)&&(identical(other.vatNumber, _this.vatNumber) || other.vatNumber == _this.vatNumber)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.purchaseDate, _this.purchaseDate) || other.purchaseDate == _this.purchaseDate)&&(identical(other.totalCents, _this.totalCents) || other.totalCents == _this.totalCents)&&(identical(other.discountCents, _this.discountCents) || other.discountCents == _this.discountCents)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings)&&const DeepCollectionEquality().equals(other.unparsedLines, _this.unparsedLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ParsedReceipt;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.storeName,_this.vatNumber,_this.address,_this.purchaseDate,_this.totalCents,_this.discountCents,const DeepCollectionEquality().hash(_this.warnings),const DeepCollectionEquality().hash(_this.unparsedLines));
}

@override
String toString() {
  final _this = this as ParsedReceipt;
  return 'ParsedReceipt(items: ${_this.items}, storeName: ${_this.storeName}, vatNumber: ${_this.vatNumber}, address: ${_this.address}, purchaseDate: ${_this.purchaseDate}, totalCents: ${_this.totalCents}, discountCents: ${_this.discountCents}, warnings: ${_this.warnings}, unparsedLines: ${_this.unparsedLines})';
}


}

/// @nodoc
abstract mixin class $ParsedReceiptCopyWith<$Res>  {
  factory $ParsedReceiptCopyWith(ParsedReceipt value, $Res Function(ParsedReceipt) _then) = _$ParsedReceiptCopyWithImpl;
@useResult
$Res call({
 List<ParsedItem> items, String? storeName, String? vatNumber, String? address, DateTime? purchaseDate, int? totalCents, int discountCents, List<ParseWarning> warnings, List<String> unparsedLines
});




}
/// @nodoc
class _$ParsedReceiptCopyWithImpl<$Res>
    implements $ParsedReceiptCopyWith<$Res> {
  _$ParsedReceiptCopyWithImpl(this._self, this._then);

  final ParsedReceipt _self;
  final $Res Function(ParsedReceipt) _then;

/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? storeName = freezed,Object? vatNumber = freezed,Object? address = freezed,Object? purchaseDate = freezed,Object? totalCents = freezed,Object? discountCents = null,Object? warnings = null,Object? unparsedLines = null,}) {
  return _then(ParsedReceipt(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ParsedItem>,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalCents: freezed == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int?,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ParseWarning>,unparsedLines: null == unparsedLines ? _self.unparsedLines : unparsedLines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedReceipt].
extension ParsedReceiptPatterns on ParsedReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedReceipt value)  $default,){
final _that = this;
switch (_that) {
case _ParsedReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ParsedItem> items,  String? storeName,  String? vatNumber,  String? address,  DateTime? purchaseDate,  int? totalCents,  int discountCents,  List<ParseWarning> warnings,  List<String> unparsedLines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
return $default(_that.items,_that.storeName,_that.vatNumber,_that.address,_that.purchaseDate,_that.totalCents,_that.discountCents,_that.warnings,_that.unparsedLines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ParsedItem> items,  String? storeName,  String? vatNumber,  String? address,  DateTime? purchaseDate,  int? totalCents,  int discountCents,  List<ParseWarning> warnings,  List<String> unparsedLines)  $default,) {final _that = this;
switch (_that) {
case _ParsedReceipt():
return $default(_that.items,_that.storeName,_that.vatNumber,_that.address,_that.purchaseDate,_that.totalCents,_that.discountCents,_that.warnings,_that.unparsedLines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ParsedItem> items,  String? storeName,  String? vatNumber,  String? address,  DateTime? purchaseDate,  int? totalCents,  int discountCents,  List<ParseWarning> warnings,  List<String> unparsedLines)?  $default,) {final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
return $default(_that.items,_that.storeName,_that.vatNumber,_that.address,_that.purchaseDate,_that.totalCents,_that.discountCents,_that.warnings,_that.unparsedLines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedReceipt extends ParsedReceipt {
  const _ParsedReceipt({required  List<ParsedItem> items, this.storeName, this.vatNumber, this.address, this.purchaseDate, this.totalCents, this.discountCents = 0,  List<ParseWarning> warnings = const <ParseWarning>[],  List<String> unparsedLines = const <String>[]}): _items = items,_warnings = warnings,_unparsedLines = unparsedLines,super._();
  factory _ParsedReceipt.fromJson(Map<String, dynamic> json) => _$ParsedReceiptFromJson(json);

 final  List<ParsedItem> _items;
@override List<ParsedItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? storeName;
/// Italian VAT number (P.IVA), 11 digits.
@override final  String? vatNumber;
@override final  String? address;
/// Date and time as printed, in local time. Convert to UTC when saving.
@override final  DateTime? purchaseDate;
/// Printed grand total.
@override final  int? totalCents;
/// Discounts not tied to a single item (e.g. a coupon on the subtotal),
/// as a positive amount.
@override@JsonKey() final  int discountCents;
 final  List<ParseWarning> _warnings;
@override@JsonKey() List<ParseWarning> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}

/// Rows inside the item section that the parser could not interpret.
/// Shown in the review screen in case they hide a missed item.
 final  List<String> _unparsedLines;
/// Rows inside the item section that the parser could not interpret.
/// Shown in the review screen in case they hide a missed item.
@override@JsonKey() List<String> get unparsedLines {
  if (_unparsedLines is EqualUnmodifiableListView) return _unparsedLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unparsedLines);
}


/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedReceiptCopyWith<_ParsedReceipt> get copyWith => __$ParsedReceiptCopyWithImpl<_ParsedReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedReceipt&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents)&&(identical(other.discountCents, discountCents) || other.discountCents == discountCents)&&const DeepCollectionEquality().equals(other.warnings, _warnings)&&const DeepCollectionEquality().equals(other.unparsedLines, _unparsedLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),storeName,vatNumber,address,purchaseDate,totalCents,discountCents,const DeepCollectionEquality().hash(_warnings),const DeepCollectionEquality().hash(_unparsedLines));
}

@override
String toString() {
    return 'ParsedReceipt(items: $items, storeName: $storeName, vatNumber: $vatNumber, address: $address, purchaseDate: $purchaseDate, totalCents: $totalCents, discountCents: $discountCents, warnings: $warnings, unparsedLines: $unparsedLines)';
}


}

/// @nodoc
abstract mixin class _$ParsedReceiptCopyWith<$Res> implements $ParsedReceiptCopyWith<$Res> {
  factory _$ParsedReceiptCopyWith(_ParsedReceipt value, $Res Function(_ParsedReceipt) _then) = __$ParsedReceiptCopyWithImpl;
@override @useResult
$Res call({
 List<ParsedItem> items, String? storeName, String? vatNumber, String? address, DateTime? purchaseDate, int? totalCents, int discountCents, List<ParseWarning> warnings, List<String> unparsedLines
});




}
/// @nodoc
class __$ParsedReceiptCopyWithImpl<$Res>
    implements _$ParsedReceiptCopyWith<$Res> {
  __$ParsedReceiptCopyWithImpl(this._self, this._then);

  final _ParsedReceipt _self;
  final $Res Function(_ParsedReceipt) _then;

/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? storeName = freezed,Object? vatNumber = freezed,Object? address = freezed,Object? purchaseDate = freezed,Object? totalCents = freezed,Object? discountCents = null,Object? warnings = null,Object? unparsedLines = null,}) {
  return _then(_ParsedReceipt(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ParsedItem>,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalCents: freezed == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int?,discountCents: null == discountCents ? _self.discountCents : discountCents // ignore: cast_nullable_to_non_nullable
as int,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ParseWarning>,unparsedLines: null == unparsedLines ? _self._unparsedLines : unparsedLines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
