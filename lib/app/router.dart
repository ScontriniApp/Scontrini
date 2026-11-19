import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/analytics/presentation/analytics_screen.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_screen.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/capture/presentation/capture_screen.dart';
import 'package:scontrini/features/extraction/presentation/extraction_screen.dart';
import 'package:scontrini/features/insights/presentation/insights_screen.dart';
import 'package:scontrini/features/receipts/presentation/receipts_screen.dart';
import 'package:scontrini/features/settings/presentation/settings_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

abstract final class Routes {
  static const dashboard = '/';
  static const receipts = '/receipts';
  static const analytics = '/analytics';
  static const insights = '/insights';
  static const capture = '/capture';

  /// Needs the captured `ReceiptSource` as `extra`.
  static const extraction = '/extraction';
  static const settings = '/settings';
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
              path: Routes.insights,
              builder: (_, _) => const InsightsScreen(),
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
    GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
  ],
);

class _AppShell extends StatelessWidget {
  const new({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.capture),
        icon: const Icon(Icons.document_scanner_outlined),
        label: Text(l10n.addReceipt),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
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
            icon: const Icon(Icons.lightbulb_outline),
            selectedIcon: const Icon(Icons.lightbulb),
            label: l10n.navInsights,
          ),
        ],
      ),
    );
  }
}
