import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/recess/recess_settings.dart';
import 'package:scontrini/core/recess/recessed_panel.dart';
import 'package:scontrini/core/utils/settings_store.dart';
import 'package:scontrini/features/pantry/presentation/widgets/category_drawer.dart';
import 'package:scontrini/features/pantry_lab/presentation/pantry_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  testWidgets('the lab shows drawers that open, deepen and save knobs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final store = MemorySettingsStore(const RecessParams());
    final container = ProviderContainer(
      overrides: [recessSettingsStoreProvider.overrideWithValue(store)],
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
          home: PantryLabScreen(),
        ),
      ),
    );
    // The shader asset compiles and loads.
    await tester.runAsync(() => container.read(recessProgramProvider.future));
    await tester.pump();
    expect(container.read(recessProgramProvider).hasValue, isTrue);
    // The controls hidden, every drawer fits on the screen.
    await tester.tap(find.byIcon(Icons.fullscreen));
    await tester.pump();
    expect(find.byType(CategoryDrawer), findsNWidgets(4));

    double depthOf(String title) => tester
        .widget<RecessedPanel>(
          find.ancestor(
            of: find.text(title),
            matching: find.byType(RecessedPanel),
          ),
        )
        .depth!;

    // The first drawer starts open and deep; the others are shallow trays.
    expect(find.text('SPAGHETTI N.5'), findsOneWidget);
    expect(depthOf('Pane e pasta'), const RecessParams().depth);
    expect(depthOf('Bevande'), const RecessParams().closedDepth);
    expect(find.text('ACQUA'), findsNothing);

    // A tap opens a drawer: its lots show and it goes deeper.
    await tester.tap(find.text('Bevande'));
    await tester.pumpAndSettle();
    expect(find.text('ACQUA'), findsOneWidget);
    expect(depthOf('Bevande'), const RecessParams().depth);
    // And closes it again.
    await tester.tap(find.text('Pane e pasta'));
    await tester.pumpAndSettle();
    expect(find.text('SPAGHETTI N.5'), findsNothing);
    expect(depthOf('Pane e pasta'), const RecessParams().closedDepth);

    // Text in a drawer casts its shadow on the floor.
    final title = tester.widget<Text>(find.text('Bevande'));
    final style = DefaultTextStyle.of(tester.element(find.text('Bevande')))
        .style
        .merge(title.style);
    expect(style.shadows, isNotEmpty);

    // Knobs save, the debug view doesn't.
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pump();
    await tester.tap(find.text('normals'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('closedDepth'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    tester
        .widget<Slider>(
          find.descendant(
            of: find.ancestor(
              of: find.text('closedDepth'),
              matching: find.byType(Row),
            ),
            matching: find.byType(Slider),
          ),
        )
        .onChanged!(4);
    await tester.pumpAndSettle();
    expect(store.saved.closedDepth, 4);
    expect(store.saved.debugView, RecessDebugView.result);
    expect(depthOf('Pane e pasta'), 4);
    expect(tester.takeException(), isNull);
  });
}
