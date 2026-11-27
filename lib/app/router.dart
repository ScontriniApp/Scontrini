import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/tab_reselect.dart';
import 'package:scontrini/features/analytics/presentation/analytics_screen.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_screen.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/capture/presentation/capture_screen.dart';
import 'package:scontrini/features/extraction/presentation/extraction_screen.dart';
import 'package:scontrini/features/extraction/presentation/receipt_review_screen.dart';
import 'package:scontrini/features/pantry/presentation/pantry_screen.dart';
import 'package:scontrini/features/plastic_lab/presentation/plastic_lab_screen.dart';
import 'package:scontrini/features/products/presentation/product_stats_screen.dart';
import 'package:scontrini/features/receipts/presentation/receipt_detail_screen.dart';
import 'package:scontrini/features/receipts/presentation/receipts_screen.dart';
import 'package:scontrini/features/settings/presentation/settings_screen.dart';
import 'package:scontrini/features/shader_lab/presentation/shader_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

abstract final class Routes {
  static const dashboard = '/';
  static const receipts = '/receipts';

  /// One receipt of the history (inside the history tab). Only for screens
  /// inside the tabs: pushed from a full-screen route (outside the shell)
  /// it would stack a second copy of the shell, and go_router's duplicate
  /// page keys trip a Navigator assertion. Those use [receiptOver].
  static String receipt(int id) => '$receipts/$id';

  /// The same receipt detail as a full-screen route, opened over whatever
  /// is showing (e.g. from a product's statistics); back returns there.
  static String receiptOver(int id) => '/receipt/$id';

  /// One product's statistics (prices paid, purchases, pantry).
  static String product(int id) => '/products/$id';

  /// A receipt typed in by hand; pops with the saved receipt's id.
  static const manualReceipt = '/manual-receipt';
  static const analytics = '/analytics';
  static const pantry = '/pantry';
  static const capture = '/capture';

  /// Needs the captured `ReceiptSource` as `extra`.
  static const extraction = '/extraction';
  static const settings = '/settings';

  /// Receipt paper shader tuning (debug builds only).
  static const shaderLab = '/shader-lab';

  /// Plastic shelf-label shader tuning (debug builds only).
  static const plasticLab = '/plastic-lab';
}

/// One router per `ProviderScope`, so navigation state doesn't leak between
/// app instances (widget tests create a new one each time).
final routerProvider = Provider<GoRouter>((ref) {
  final router = _createRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter _createRouter() => GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.dashboard,
              builder: (_, _) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.receipts,
              builder: (_, _) => const ReceiptsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => ReceiptDetailScreen(
                    receiptId:
                        int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.analytics,
              builder: (_, _) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.pantry,
              builder: (_, _) => const PantryScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: Routes.capture, builder: (_, _) => const CaptureScreen()),
    GoRoute(
      path: Routes.extraction,
      // `extra` is lost on deep links and restarts: go back to capture.
      redirect: (_, state) =>
          state.extra is ReceiptSource ? null : Routes.capture,
      builder: (_, state) => switch (state.extra) {
        final ReceiptSource source => ExtractionScreen(source: source),
        _ => const CaptureScreen(),
      },
    ),
    GoRoute(
      path: '/receipt/:id',
      builder: (_, state) => ReceiptDetailScreen(
        receiptId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
      ),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (_, state) => ProductStatsScreen(
        productId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
      ),
    ),
    GoRoute(
      path: Routes.manualReceipt,
      builder: (_, _) => const ReceiptReviewScreen.manual(),
    ),
    GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    if (kDebugMode)
      GoRoute(
        path: Routes.shaderLab,
        builder: (_, _) => const ShaderLabScreen(),
      ),
    if (kDebugMode)
      GoRoute(
        path: Routes.plasticLab,
        builder: (_, _) => const PlasticLabScreen(),
      ),
  ],
);

class _AppShell extends ConsumerWidget {
  const new({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      // "Aggiungi" lives on the home tab only.
      floatingActionButton: shell.currentIndex == ShellBranch.home
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.capture),
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(l10n.addReceipt),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) {
          final again = index == shell.currentIndex;
          shell.goBranch(index, initialLocation: again);
          // A tap on the open tab also asks its screen to refresh.
          if (again) ref.read(tabReselectProvider.notifier).reselect(index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navReceipts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navAnalytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            selectedIcon: const Icon(Icons.kitchen),
            label: l10n.navPantry,
          ),
        ],
      ),
    );
  }
}
