import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_box.freezed.dart';
part 'text_box.g.dart';

/// Axis-aligned bounding box of a piece of text, in page pixels with the
/// origin at the top-left corner.
///
/// Kept free of Flutter types (no `Rect`) so the domain layer stays pure Dart.
@freezed
abstract class TextBox with _$TextBox {
  const factory({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) = _TextBox;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$TextBoxFromJson(json);

  double get width => right - left;
  double get height => bottom - top;
  double get centerY => (top + bottom) / 2;

  /// Fraction of the shorter box's height that overlaps [other] vertically,
  /// from 0 (no overlap) to 1. Used to decide whether two pieces of text sit
  /// on the same printed row.
  double verticalOverlap(TextBox other) {
    final overlap =
        (bottom < other.bottom ? bottom : other.bottom) -
        (top > other.top ? top : other.top);
    final shorter = height < other.height ? height : other.height;
    if (overlap <= 0 || shorter <= 0) return 0;
    return overlap / shorter;
  }
}
