import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';

/// One suggestion for the dashboard. Rules return the facts; the UI words
/// them (ARB strings), so the domain stays free of text.
@freezed
sealed class Insight with _$Insight {
  /// A category's spending so far this month is well above the same days of
  /// recent months.
  const factory categorySpike({
    required int categoryId,
    required String categoryName,

    /// Spent in the category, month to date.
    required int cents,

    /// Average of the same days of the months compared.
    required int usualCents,

    /// How many earlier months the average is over.
    required int monthsCompared,
  }) = CategorySpikeInsight;

  /// A product is often partly thrown away.
  const factory frequentWaste({
    required String productName,

    /// Lots of it that had something thrown away, out of `closedLots`.
    required int wastedLots,

    /// Lots of it finished or thrown away in the window.
    required int closedLots,

    /// Value of what was thrown away in the window.
    required int wastedCents,

    /// Length of the window, in days.
    required int days,

    /// Null for lots matched to no product.
    int? productId,
  }) = FrequentWasteInsight;

  /// A product's latest shelf price is well above what it usually cost at
  /// the same store.
  const factory priceRise({
    required int productId,
    required String productName,

    /// Full (shelf) price per piece, kg or l of the latest purchase.
    required int latestCents,

    /// Median full unit price of the earlier purchases at the same store.
    required int usualCents,

    /// How many earlier purchases `usualCents` is the median of.
    required int referenceCount,

    /// How much of it is bought in a month, in `unit` (from the reference
    /// window), for the monthly cost of the rise.
    required double monthlyQuantity,

    /// `pz`, `kg` or `l`; null when unknown.
    String? unit,
    String? storeName,
  }) = PriceRiseInsight;

  const new _();

  /// Euros per month at stake, for ranking: the extra spent so far for a
  /// category spike, the monthly value thrown away for waste, what the
  /// rise costs a month at the usual quantity.
  int get monthlyImpactCents => switch (this) {
    CategorySpikeInsight(:final cents, :final usualCents) => cents - usualCents,
    FrequentWasteInsight(:final wastedCents, :final days) =>
      (wastedCents * 30 / days).round(),
    PriceRiseInsight(
      :final latestCents,
      :final usualCents,
      :final monthlyQuantity,
    ) =>
      ((latestCents - usualCents) * monthlyQuantity).round(),
  };

  /// Change of [PriceRiseInsight.latestCents] against its usual price, as a
  /// fraction (0.12 = +12 %).
  double? get priceChange => switch (this) {
    PriceRiseInsight(:final latestCents, :final usualCents)
        when usualCents > 0 =>
      (latestCents - usualCents) / usualCents,
    _ => null,
  };
}
