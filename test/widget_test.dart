import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';

void main() {
  testWidgets('app starts on the dashboard and opens capture', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const ScontriniApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scontrini'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    expect(find.text('Nuovo scontrino'), findsOneWidget);
  });
}
