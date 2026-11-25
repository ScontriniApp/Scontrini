import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_suggestion.freezed.dart';

/// Why a product is on the next-shopping list.
enum ShoppingReason {
  /// The pantry says none is left.
  finished,

  /// The pantry says what is left runs out soon, at the usual pace.
  runningLow,

  /// No pantry data to trust: it is about time, going by how often it is
  /// bought.
  usualInterval,
}

/// A product to buy on the next shopping trip.
@freezed
abstract class ShoppingSuggestion with _$ShoppingSuggestion {
  const factory({
    required int productId,
    required String name,
    required ShoppingReason reason,

    /// Local day it is needed by (today or earlier when it is overdue).
    required DateTime dueDay,

    /// Last purchase (UTC).
    required DateTime lastPurchase,

    /// Typical days between purchases (median), when bought often enough.
    int? intervalDays,

    /// What the pantry has left, for [ShoppingReason.runningLow].
    double? remaining,

    /// `pz`, `kg` or `l` of [remaining].
    String? unit,
  }) = _ShoppingSuggestion;
}
