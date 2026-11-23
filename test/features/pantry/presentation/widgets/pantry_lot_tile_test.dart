import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/widgets/pantry_lot_tile.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  late List<double> set;

  Future<void> pump(WidgetTester tester, {required double remaining}) async {
    set = [];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PantryLotTile(
            lot: PantryLot(
              id: 1,
              name: 'MELE GOLDEN',
              unit: 'kg',
              source: PantrySource.manualPurchase,
              initialQuantity: 2,
              remainingQuantity: remaining,
              status: PantryLotStatus.active,
              addedAt: DateTime(2026, 11, 24),
            ),
            color: Colors.green,
            onSetRemaining: set.add,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('the slider shows the share left, 0-100 %', (tester) async {
    await pump(tester, remaining: 1.5);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect((slider.value, slider.max, slider.divisions), (75, 100, 20));
    expect(find.text('75%'), findsOneWidget);
    expect(
      find.text('Comprato, senza scontrino · 1,5 kg di 2 kg'),
      findsOneWidget,
    );
  });

  testWidgets('releasing at a percent sets that share of the quantity', (
    tester,
  ) async {
    await pump(tester, remaining: 2);
    tester.widget<Slider>(find.byType(Slider)).onChangeEnd!(25);
    expect(set, [0.5]);
  });

  testWidgets('items show initials, never the category sprite', (tester) async {
    await pump(tester, remaining: 2);
    expect(find.text('MG'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
