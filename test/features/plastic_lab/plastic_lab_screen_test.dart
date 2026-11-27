import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_plate.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/core/utils/settings_store.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shelf_label.dart';
import 'package:scontrini/features/plastic_lab/presentation/plastic_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  testWidgets('the lab shows the label as a plate that tilts under a finger', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final store = MemorySettingsStore(const PlasticParams());
    final container = ProviderContainer(
      overrides: [plasticSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlasticLabScreen(),
        ),
      ),
    );
    // The shader asset compiles and loads.
    await tester.runAsync(() => container.read(plasticProgramProvider.future));
    await tester.pump();
    expect(container.read(plasticProgramProvider).hasValue, isTrue);
    expect(find.byType(ShelfLabel), findsOneWidget);
    expect(find.text('SPESO A NOVEMBRE'), findsOneWidget);

    Matrix4 face() => tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(PlasticPlate),
            matching: find.byType(Transform),
          ),
        )
        .last
        .transform;

    // A finger on the right edge tilts the plate; letting go flattens it.
    final plate = tester.getRect(find.byType(PlasticPlate));
    final gesture = await tester.startGesture(
      plate.centerRight - const Offset(4, 0),
    );
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 500));
    final tilted = depthOf(face(), 100, 0);
    expect(tilted, greaterThan(1), reason: 'the right edge goes away');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(depthOf(face(), 100, 0), closeTo(0, 1e-3));

    // Knobs save, the debug view doesn't.
    await tester.tap(find.text('normals'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('rim'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    tester
        .widget<Slider>(
          find.descendant(
            of: find.ancestor(of: find.text('rim'), matching: find.byType(Row)),
            matching: find.byType(Slider),
          ),
        )
        .onChanged!(6);
    await tester.pump();
    expect(store.saved.rim, 6);
    expect(store.saved.debugView, PlasticDebugView.result);
    expect(tester.takeException(), isNull);
  });
}

/// Depth (+z = away from the eye) of the point x, y after [m].
double depthOf(Matrix4 m, double x, double y) =>
    m.entry(2, 0) * x + m.entry(2, 1) * y + m.entry(2, 3);
