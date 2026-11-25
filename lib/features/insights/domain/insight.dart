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

  const new _();

  /// Euros per month at stake, for ranking: the extra spent so far for a
  /// category spike, the monthly value thrown away for waste.
  int get monthlyImpactCents => switch (this) {
    CategorySpikeInsight(:final cents, :final usualCents) => cents - usualCents,
    FrequentWasteInsight(:final wastedCents, :final days) =>
      (wastedCents * 30 / days).round(),
  };
}
