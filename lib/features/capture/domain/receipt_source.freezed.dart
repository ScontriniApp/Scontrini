// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReceiptSource {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReceiptSource()';
}


}

/// @nodoc
class $ReceiptSourceCopyWith<$Res>  {
$ReceiptSourceCopyWith(ReceiptSource _, $Res Function(ReceiptSource) __);
}


/// Adds pattern-matching-related methods to [ReceiptSource].
extension ReceiptSourcePatterns on ReceiptSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImageReceiptSource value)?  images,TResult Function( PdfReceiptSource value)?  pdf,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImageReceiptSource() when images != null:
return images(_that);case PdfReceiptSource() when pdf != null:
return pdf(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImageReceiptSource value)  images,required TResult Function( PdfReceiptSource value)  pdf,}){
final _that = this;
switch (_that) {
case ImageReceiptSource():
return images(_that);case PdfReceiptSource():
return pdf(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImageReceiptSource value)?  images,TResult? Function( PdfReceiptSource value)?  pdf,}){
final _that = this;
switch (_that) {
case ImageReceiptSource() when images != null:
return images(_that);case PdfReceiptSource() when pdf != null:
return pdf(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> imagePaths)?  images,TResult Function( String pdfPath)?  pdf,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImageReceiptSource() when images != null:
return images(_that.imagePaths);case PdfReceiptSource() when pdf != null:
return pdf(_that.pdfPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> imagePaths)  images,required TResult Function( String pdfPath)  pdf,}) {final _that = this;
switch (_that) {
case ImageReceiptSource():
return images(_that.imagePaths);case PdfReceiptSource():
return pdf(_that.pdfPath);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> imagePaths)?  images,TResult? Function( String pdfPath)?  pdf,}) {final _that = this;
switch (_that) {
case ImageReceiptSource() when images != null:
return images(_that.imagePaths);case PdfReceiptSource() when pdf != null:
return pdf(_that.pdfPath);case _:
  return null;

}
}

}

/// @nodoc


class ImageReceiptSource extends ReceiptSource {
  const ImageReceiptSource( List<String> imagePaths): _imagePaths = imagePaths,super._();
  

 final  List<String> _imagePaths;
 List<String> get imagePaths {
  if (_imagePaths is EqualUnmodifiableListView) return _imagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagePaths);
}


/// Create a copy of ReceiptSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageReceiptSourceCopyWith<ImageReceiptSource> get copyWith => _$ImageReceiptSourceCopyWithImpl<ImageReceiptSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageReceiptSource&&const DeepCollectionEquality().equals(other.imagePaths, _imagePaths));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_imagePaths));
}

@override
String toString() {
    return 'ReceiptSource.images(imagePaths: $imagePaths)';
}


}

/// @nodoc
abstract mixin class $ImageReceiptSourceCopyWith<$Res> implements $ReceiptSourceCopyWith<$Res> {
  factory $ImageReceiptSourceCopyWith(ImageReceiptSource value, $Res Function(ImageReceiptSource) _then) = _$ImageReceiptSourceCopyWithImpl;
@useResult
$Res call({
 List<String> imagePaths
});




}
/// @nodoc
class _$ImageReceiptSourceCopyWithImpl<$Res>
    implements $ImageReceiptSourceCopyWith<$Res> {
  _$ImageReceiptSourceCopyWithImpl(this._self, this._then);

  final ImageReceiptSource _self;
  final $Res Function(ImageReceiptSource) _then;

/// Create a copy of ReceiptSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagePaths = null,}) {
  return _then(ImageReceiptSource(
null == imagePaths ? _self._imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class PdfReceiptSource extends ReceiptSource {
  const PdfReceiptSource(this.pdfPath): super._();
  

 final  String pdfPath;

/// Create a copy of ReceiptSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfReceiptSourceCopyWith<PdfReceiptSource> get copyWith => _$PdfReceiptSourceCopyWithImpl<PdfReceiptSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfReceiptSource&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pdfPath);
}

@override
String toString() {
    return 'ReceiptSource.pdf(pdfPath: $pdfPath)';
}


}

/// @nodoc
abstract mixin class $PdfReceiptSourceCopyWith<$Res> implements $ReceiptSourceCopyWith<$Res> {
  factory $PdfReceiptSourceCopyWith(PdfReceiptSource value, $Res Function(PdfReceiptSource) _then) = _$PdfReceiptSourceCopyWithImpl;
@useResult
$Res call({
 String pdfPath
});




}
/// @nodoc
class _$PdfReceiptSourceCopyWithImpl<$Res>
    implements $PdfReceiptSourceCopyWith<$Res> {
  _$PdfReceiptSourceCopyWithImpl(this._self, this._then);

  final PdfReceiptSource _self;
  final $Res Function(PdfReceiptSource) _then;

/// Create a copy of ReceiptSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pdfPath = null,}) {
  return _then(PdfReceiptSource(
null == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
