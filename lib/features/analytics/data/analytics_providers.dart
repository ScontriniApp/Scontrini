import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/analytics/data/analytics_dao.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/purchase_history.dart';

final analyticsDaoProvider = Provider<AnalyticsDao>(
  (ref) => AnalyticsDao(ref.watch(appDatabaseProvider)),
);

/// The confirmed purchase history of a loaded window, kept up to date as
/// receipts change. Pass the whole window the metrics need (see
/// [AnalyticsDao]).
final StreamProviderFamily<PurchaseHistory, DateRange> purchaseHistoryProvider =
    StreamProvider.autoDispose.family(
      (ref, range) => ref.watch(analyticsDaoProvider).watchHistory(range),
    );
