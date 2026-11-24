import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/data/analytics_providers.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/products/domain/product_stats.dart';

/// Everything up to today: a product's statistics cover its whole history.
DateRange allTime(DateTime today) =>
    DateRange(DateTime(2000), DateRange.day(today).end);

/// One product's statistics, kept up to date as receipts and lots change.
final ProviderFamily<AsyncValue<ProductStats>, int> productStatsProvider =
    Provider.autoDispose.family<AsyncValue<ProductStats>, int>((ref, id) {
      final range = allTime(ref.watch(clockProvider)());
      final history = ref.watch(purchaseHistoryProvider(range));
      final lots = ref.watch(pantryAllLotsProvider);
      return switch ((history, lots)) {
        (AsyncError(:final error, :final stackTrace), _) ||
        (
          _,
          AsyncError(:final error, :final stackTrace),
        ) => AsyncError(error, stackTrace),
        (AsyncData(value: final h), AsyncData(value: final l)) => AsyncData(
          ProductStats.from(h, id, range, l),
        ),
        _ => const AsyncLoading(),
      };
    });
