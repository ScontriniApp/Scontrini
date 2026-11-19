// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReceiptRow {

/// Index of the page in the `OcrDocument`.
 int get page;/// Lines on this row, left to right. Usually the product name and the
/// price, which ML Kit returns separately.
 List<OcrLine> get cells;
/// Create a copy of ReceiptRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptRowCopyWith<ReceiptRow> get copyWith => _$ReceiptRowCopyWithImpl<ReceiptRow>(this as ReceiptRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReceiptRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptRow&&(identical(other.page, _this.page) || other.page == _this.page)&&const DeepCollectionEquality().equals(other.cells, _this.cells));
}


@override
int get hashCode {
  final _this = this as ReceiptRow;
  return Object.hash(runtimeType,_this.page,const DeepCollectionEquality().hash(_this.cells));
}

@override
String toString() {
  final _this = this as ReceiptRow;
  return 'ReceiptRow(page: ${_this.page}, cells: ${_this.cells})';
}


}

/// @nodoc
abstract mixin class $ReceiptRowCopyWith<$Res>  {
  factory $ReceiptRowCopyWith(ReceiptRow value, $Res Function(ReceiptRow) _then) = _$ReceiptRowCopyWithImpl;
@useResult
$Res call({
 int page, List<OcrLine> cells
});




}
/// @nodoc
class _$ReceiptRowCopyWithImpl<$Res>
    implements $ReceiptRowCopyWith<$Res> {
  _$ReceiptRowCopyWithImpl(this._self, this._then);

  final ReceiptRow _self;
  final $Res Function(ReceiptRow) _then;

/// Create a copy of ReceiptRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? cells = null,}) {
  return _then(ReceiptRow(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,cells: null == cells ? _self.cells : cells // ignore: cast_nullable_to_non_nullable
as List<OcrLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptRow].
extension ReceiptRowPatterns on ReceiptRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptRow value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptRow value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  List<OcrLine> cells)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptRow() when $default != null:
return $default(_that.page,_that.cells);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  List<OcrLine> cells)  $default,) {final _that = this;
switch (_that) {
case _ReceiptRow():
return $default(_that.page,_that.cells);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  List<OcrLine> cells)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptRow() when $default != null:
return $default(_that.page,_that.cells);case _:
  return null;

}
}

}

/// @nodoc


class _ReceiptRow extends ReceiptRow {
  const _ReceiptRow({required this.page, required  List<OcrLine> cells}): _cells = cells,super._();
  

/// Index of the page in the `OcrDocument`.
@override final  int page;
/// Lines on this row, left to right. Usually the product name and the
/// price, which ML Kit returns separately.
 final  List<OcrLine> _cells;
/// Lines on this row, left to right. Usually the product name and the
/// price, which ML Kit returns separately.
@override List<OcrLine> get cells {
  if (_cells is EqualUnmodifiableListView) return _cells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cells);
}


/// Create a copy of ReceiptRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptRowCopyWith<_ReceiptRow> get copyWith => __$ReceiptRowCopyWithImpl<_ReceiptRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptRow&&(identical(other.page, page) || other.page == page)&&const DeepCollectionEquality().equals(other.cells, _cells));
}


@override
int get hashCode {
    return Object.hash(runtimeType,page,const DeepCollectionEquality().hash(_cells));
}

@override
String toString() {
    return 'ReceiptRow(page: $page, cells: $cells)';
}


}

/// @nodoc
abstract mixin class _$ReceiptRowCopyWith<$Res> implements $ReceiptRowCopyWith<$Res> {
  factory _$ReceiptRowCopyWith(_ReceiptRow value, $Res Function(_ReceiptRow) _then) = __$ReceiptRowCopyWithImpl;
@override @useResult
$Res call({
 int page, List<OcrLine> cells
});




}
/// @nodoc
class __$ReceiptRowCopyWithImpl<$Res>
    implements _$ReceiptRowCopyWith<$Res> {
  __$ReceiptRowCopyWithImpl(this._self, this._then);

  final _ReceiptRow _self;
  final $Res Function(_ReceiptRow) _then;

/// Create a copy of ReceiptRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? cells = null,}) {
  return _then(_ReceiptRow(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,cells: null == cells ? _self._cells : cells // ignore: cast_nullable_to_non_nullable
as List<OcrLine>,
  ));
}


}

// dart format on
