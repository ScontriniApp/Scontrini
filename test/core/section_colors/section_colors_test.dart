import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/app/theme.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/section_colors/section_colors.dart';
import 'package:scontrini/core/section_colors/section_colors_provider.dart';
import 'package:scontrini/core/section_colors/section_colors_store.dart';
import 'package:scontrini/core/section_colors/section_surface.dart';
import 'package:scontrini/features/settings/presentation/color_picker_dialog.dart';
import 'package:scontrini/features/settings/presentation/section_colors_tile.dart';
import 'package:scontrini/l10n/app_localizations.dart';

const _navy = Color(0xFF1A237E);
const _amber = Color(0xFFFFB000);

Future<void> _pump(
  WidgetTester tester,
  SectionColorsStore store,
  Widget child,
) => tester.pumpWidget(
  ProviderScope(
    overrides: [sectionColorsStoreProvider.overrideWithValue(store)],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('it'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ListView(children: [child])),
    ),
  ),
);

/// A section like the dashboard cards: reads the theme in its own build.
class _Section extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          Text('titolo', style: theme.textTheme.titleMedium),
          Text(
            'intestazione',
            style: TextStyle(color: SectionSurface.headingColor(context)),
          ),
        ],
      ),
    );
  }
}

Color? _textColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

Color? _cardColor(WidgetTester tester) {
  final material = tester.widget<Material>(
    find.descendant(of: find.byType(Card), matching: find.byType(Material)),
  );
  return material.color;
}

void main() {
  testWidgets('without a choice the section keeps the theme', (tester) async {
    await _pump(
      tester,
      MemorySectionColorsStore(),
      const SectionSurface(child: _Section()),
    );
    final scheme = AppTheme.light.colorScheme;
    expect(
      _textColor(tester, 'titolo'),
      AppTheme.light.textTheme.titleMedium!.color,
    );
    expect(_textColor(tester, 'intestazione'), scheme.primary);
    expect(_cardColor(tester), scheme.surfaceContainerLow);
  });

  testWidgets('chosen background and text reach the card and its headings', (
    tester,
  ) async {
    await _pump(
      tester,
      MemorySectionColorsStore(
        const SectionColors(background: _navy, text: _amber),
      ),
      const SectionSurface(child: _Section()),
    );
    expect(_cardColor(tester), _navy);
    expect(_textColor(tester, 'titolo'), _amber);
    expect(_textColor(tester, 'intestazione'), _amber);
  });

  testWidgets('a dark background alone gets white text', (tester) async {
    await _pump(
      tester,
      MemorySectionColorsStore(const SectionColors(background: _navy)),
      const SectionSurface(child: _Section()),
    );
    expect(_textColor(tester, 'titolo'), const Color(0xFFFFFFFF));
  });

  testWidgets('a panel section draws the background behind its rows', (
    tester,
  ) async {
    await _pump(
      tester,
      MemorySectionColorsStore(const SectionColors(background: _navy)),
      const SectionSurface(panel: true, child: Text('riga')),
    );
    final panel = tester.widget<Material>(
      find
          .ancestor(of: find.text('riga'), matching: find.byType(Material))
          .first,
    );
    expect(panel.color, _navy);
  });

  testWidgets('Settings tile: any colour from the picker, then reset', (
    tester,
  ) async {
    final store = MemorySectionColorsStore();
    await _pump(tester, store, const SectionColorsTile());
    expect(find.text('Colori'), findsOneWidget);

    // Background: typed code.
    await tester.tap(find.bySemanticsLabel('Sfondo: Predefinito'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('colorPickerHex')), '123ABC');
    await tester.pump();
    await tester.tap(find.text('Applica'));
    await tester.pumpAndSettle();
    expect(store.read().background, const Color(0xFF123ABC));

    // Text: a shortcut, then cancelled: nothing changes.
    await tester.tap(find.bySemanticsLabel('Testo: Predefinito'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('#FFB000'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('colorPickerHex')))
          .controller!
          .text,
      'FFB000',
    );
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(store.read().text, isNull);

    // Text: dragged in the square, bottom right = full, dark.
    await tester.tap(find.bySemanticsLabel('Testo: Predefinito'));
    await tester.pumpAndSettle();
    final square = find.byKey(const Key('colorPickerSquare'));
    await tester.tapAt(tester.getTopRight(square) + const Offset(-1, 1));
    await tester.pump();
    await tester.tap(find.text('Applica'));
    await tester.pumpAndSettle();
    final text = store.read().text!;
    expect(HSVColor.fromColor(text).saturation, greaterThan(0.95));
    expect(HSVColor.fromColor(text).value, greaterThan(0.95));
    // The preview follows.
    expect(_textColor(tester, 'Anteprima'), text);

    // Rows: app background, accent, section background, text.
    await tester.tap(find.byTooltip('Predefinito').at(2));
    await tester.pump();
    expect(store.read(), SectionColors(text: text));
  });

  testWidgets('Settings tile: app background from the picker', (tester) async {
    final store = MemorySectionColorsStore();
    await _pump(tester, store, const SectionColorsTile());

    await tester.tap(find.bySemanticsLabel("Sfondo dell'app: Predefinito"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('colorPickerHex')), '263238');
    await tester.pump();
    await tester.tap(find.text('Applica'));
    await tester.pumpAndSettle();
    expect(store.read(), const SectionColors(appBackground: Color(0xFF263238)));
  });

  testWidgets('Settings tile: "Testo secondario" from the picker', (
    tester,
  ) async {
    final store = MemorySectionColorsStore();
    await _pump(tester, store, const SectionColorsTile());

    await tester.tap(find.bySemanticsLabel('Testo secondario: Predefinito'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('colorPickerHex')), '1A237E');
    await tester.pump();
    await tester.tap(find.text('Applica'));
    await tester.pumpAndSettle();
    expect(store.read(), const SectionColors(accent: _navy));
  });

  test('the accent replaces the amber: headings, buttons, Aggiungi', () {
    final theme = AppTheme.withAccent(AppTheme.light, _navy);
    expect(theme.colorScheme.primary, _navy);
    expect(theme.colorScheme.onPrimary, AppTheme.onAccent);
    expect(theme.floatingActionButtonTheme.backgroundColor, _navy);
    // A light accent gets dark ink on it.
    final light = AppTheme.withAccent(AppTheme.light, _amber);
    expect(light.colorScheme.onPrimary, const Color(0xFF211F29));
  });

  test('a dark app background gives a dark theme on it', () {
    final dark = AppTheme.onBackground(const Color(0xFF263238));
    expect(dark.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor, const Color(0xFF263238));
    expect(dark.colorScheme.surface, const Color(0xFF263238));
    final light = AppTheme.onBackground(const Color(0xFFFFF8E1));
    expect(light.brightness, Brightness.light);
  });

  testWidgets('the app paints the chosen background behind every screen', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sectionColorsStoreProvider.overrideWithValue(
            MemorySectionColorsStore(const SectionColors(appBackground: _navy)),
          ),
        ],
        child: const ScontriniApp(),
      ),
    );
    await tester.pumpAndSettle();
    final scaffold = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(scaffold).scaffoldBackgroundColor, _navy);
    expect(Theme.of(scaffold).brightness, Brightness.dark);
  });

  testWidgets('the app uses the chosen accent', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sectionColorsStoreProvider.overrideWithValue(
            MemorySectionColorsStore(const SectionColors(accent: _navy)),
          ),
        ],
        child: const ScontriniApp(),
      ),
    );
    await tester.pumpAndSettle();
    final scaffold = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(scaffold).colorScheme.primary, _navy);
    expect(Theme.of(scaffold).floatingActionButtonTheme.backgroundColor, _navy);
  });

  test('hex codes', () {
    expect(parseColorHex('#1a237e'), const Color(0xFF1A237E));
    expect(parseColorHex('12345'), isNull);
    expect(colorHex(const Color(0xFF0000FF)), '#0000FF');
  });
}
