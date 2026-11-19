// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OcrDocument {

 TextSource get source; List<OcrPage> get pages;
/// Create a copy of OcrDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrDocumentCopyWith<OcrDocument> get copyWith => _$OcrDocumentCopyWithImpl<OcrDocument>(this as OcrDocument, _$identity);

  /// Serializes this OcrDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OcrDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrDocument&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.pages, _this.pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OcrDocument;
  return Object.hash(runtimeType,_this.source,const DeepCollectionEquality().hash(_this.pages));
}

@override
String toString() {
  final _this = this as OcrDocument;
  return 'OcrDocument(source: ${_this.source}, pages: ${_this.pages})';
}


}

/// @nodoc
abstract mixin class $OcrDocumentCopyWith<$Res>  {
  factory $OcrDocumentCopyWith(OcrDocument value, $Res Function(OcrDocument) _then) = _$OcrDocumentCopyWithImpl;
@useResult
$Res call({
 TextSource source, List<OcrPage> pages
});




}
/// @nodoc
class _$OcrDocumentCopyWithImpl<$Res>
    implements $OcrDocumentCopyWith<$Res> {
  _$OcrDocumentCopyWithImpl(this._self, this._then);

  final OcrDocument _self;
  final $Res Function(OcrDocument) _then;

/// Create a copy of OcrDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? pages = null,}) {
  return _then(OcrDocument(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TextSource,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<OcrPage>,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrDocument].
extension OcrDocumentPatterns on OcrDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrDocument value)  $default,){
final _that = this;
switch (_that) {
case _OcrDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrDocument value)?  $default,){
final _that = this;
switch (_that) {
case _OcrDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TextSource source,  List<OcrPage> pages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrDocument() when $default != null:
return $default(_that.source,_that.pages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TextSource source,  List<OcrPage> pages)  $default,) {final _that = this;
switch (_that) {
case _OcrDocument():
return $default(_that.source,_that.pages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TextSource source,  List<OcrPage> pages)?  $default,) {final _that = this;
switch (_that) {
case _OcrDocument() when $default != null:
return $default(_that.source,_that.pages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OcrDocument extends OcrDocument {
  const _OcrDocument({required this.source, required  List<OcrPage> pages}): _pages = pages,super._();
  factory _OcrDocument.fromJson(Map<String, dynamic> json) => _$OcrDocumentFromJson(json);

@override final  TextSource source;
 final  List<OcrPage> _pages;
@override List<OcrPage> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}


/// Create a copy of OcrDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrDocumentCopyWith<_OcrDocument> get copyWith => __$OcrDocumentCopyWithImpl<_OcrDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OcrDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrDocument&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.pages, _pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,source,const DeepCollectionEquality().hash(_pages));
}

@override
String toString() {
    return 'OcrDocument(source: $source, pages: $pages)';
}


}

/// @nodoc
abstract mixin class _$OcrDocumentCopyWith<$Res> implements $OcrDocumentCopyWith<$Res> {
  factory _$OcrDocumentCopyWith(_OcrDocument value, $Res Function(_OcrDocument) _then) = __$OcrDocumentCopyWithImpl;
@override @useResult
$Res call({
 TextSource source, List<OcrPage> pages
});




}
/// @nodoc
class __$OcrDocumentCopyWithImpl<$Res>
    implements _$OcrDocumentCopyWith<$Res> {
  __$OcrDocumentCopyWithImpl(this._self, this._then);

  final _OcrDocument _self;
  final $Res Function(_OcrDocument) _then;

/// Create a copy of OcrDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? pages = null,}) {
  return _then(_OcrDocument(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TextSource,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<OcrPage>,
  ));
}


}

// dart format on
