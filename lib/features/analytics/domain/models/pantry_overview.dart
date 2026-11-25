import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

part 'pantry_overview.freezed.dart';

/// What the analytics tab's "Dispensa" sub-tab shows for one period.
@freezed
abstract class PantryOverview with _$PantryOverview {
  const factory({
    /// Whether the pantry has any lot at all; false shows the empty state.
    required bool hasPantry,

    /// Euros thrown away in the period (by the day of the discard), against
    /// the compared period. A discarded share of a lot is worth that share
    /// of its price.
    required PeriodAmount wasted,

    /// Wasted ÷ (wasted + used) in the period, in euros, as a fraction;
    /// null when nothing left the pantry.
    required double? wasteRate,

    /// Lots with no price that had something thrown away in the period:
    /// counted here, not in [wasted].
    required int unpricedDiscards,

    /// [wasted] by reason, largest first.
    required List<WasteByReason> reasons,

    /// [wasted] by category, largest first.
    required List<WasteByCategory> categories,

    /// [wasted] by product, largest first.
    required List<WastedProduct> products,

    /// Where the money spent in the period went.
    required SpendingFate fate,
  }) = _PantryOverview;
}

@freezed
abstract class WasteByReason with _$WasteByReason {
  const factory({required PantryEventReason reason, required int cents}) =
      _WasteByReason;
}

@freezed
abstract class WasteByCategory with _$WasteByCategory {
  const factory({
    required int cents,

    /// Null for lots with no category.
    CategoryInfo? category,

    /// Same slot as the spending charts (position among category ids).
    int? colorSlot,
  }) = _WasteByCategory;
}

@freezed
abstract class WastedProduct with _$WastedProduct {
  const factory({
    required String name,
    required int cents,

    /// How many lots of it had something thrown away.
    required int lotCount,

    /// Null for lots matched to no product (grouped by name).
    int? productId,
  }) = _WastedProduct;
}

/// The receipts of a period, split by what happened to each euro: used,
/// thrown away, still in the pantry, or never in the pantry (products not
/// tracked, basket coupons, rows the receipt total holds but no lot does).
///
/// The first three come from the lots of those receipts, each lot's price
/// split by what its ledger says happened to it; they add up exactly.
@freezed
abstract class SpendingFate with _$SpendingFate {
  const factory({
    /// Printed totals of the period's receipts (M1), or the lots' prices if
    /// those are larger.
    required int totalCents,
    required int usedCents,
    required int wastedCents,
    required int inPantryCents,
    required int notInPantryCents,

    /// Lots of the period's receipts.
    required int lotCount,

    /// How many of them were never moved (no use, discard or recount): they
    /// count as still in the pantry.
    required int untouchedLotCount,
  }) = _SpendingFate;

  const new _();

  bool get isEmpty => totalCents == 0;
}
