import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/export/data/export_providers.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

void main() {
  late AppDatabase db;
  final saved = <({String fileName, Uint8List bytes, String mimeType})>[];
  var cancel = false;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    saved.clear();
    cancel = false;
  });
  tearDown(() => db.close());

  /// Drift works on real async time (see pantry_screen_test.dart).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 12)),
          fileSaverProvider.overrideWithValue(({
            required fileName,
            required bytes,
            required mimeType,
          }) async {
            if (cancel) return false;
            saved.add((fileName: fileName, bytes: bytes, mimeType: mimeType));
            return true;
          }),
        ],
        child: const ScontriniApp(),
      ),
    );
    await settle(tester);
    final context = tester.element(find.byType(Scaffold).first);
    unawaited(
      ProviderScope.containerOf(context)
          .read(routerProvider)
          .push(Routes.settings),
    );
    await settle(tester);
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('with no receipts the entry says so and is disabled', (
    tester,
  ) async {
    await openSettings(tester);
    expect(find.text('Esporta i dati raccolti'), findsOneWidget);
    expect(find.text('Nessuno scontrino da esportare'), findsOneWidget);
    await tester.tap(find.text('Esporta i dati raccolti'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    await closeApp(tester);
  });

  testWidgets('exports after the warning, into the file the user saves', (
    tester,
  ) async {
    await tester.runAsync(
      () => ReceiptRepository(db).saveConfirmed(
        ParsedReceipt(
          storeName: 'CONAD',
          purchaseDate: DateTime(2026, 11, 20, 12),
          totalCents: 278,
          items: const [
            ParsedItem(
              rawName: 'PANE',
              unitPriceCents: 149,
              lineTotalCents: 149,
            ),
            ParsedItem(
              rawName: 'LATTE INTERO',
              unitPriceCents: 129,
              lineTotalCents: 129,
            ),
          ],
        ),
      ),
    );
    await openSettings(tester);
    expect(
      find.text('1 scontrino · 2 articoli, in un file CSV'),
      findsOneWidget,
    );

    // Cancelled at the warning: nothing saved.
    await tester.tap(find.text('Esporta i dati raccolti'));
    await settle(tester);
    expect(find.textContaining('Il file non è cifrato'), findsOneWidget);
    await tester.tap(find.text('Annulla'));
    await settle(tester);
    expect(saved, isEmpty);

    // Cancelled in the save dialog: no message.
    cancel = true;
    await tester.tap(find.text('Esporta i dati raccolti'));
    await settle(tester);
    await tester.tap(find.text('Esporta'));
    await settle(tester);
    expect(find.textContaining('Esportati'), findsNothing);

    cancel = false;
    await tester.tap(find.text('Esporta i dati raccolti'));
    await settle(tester);
    await tester.tap(find.text('Esporta'));
    await settle(tester);

    expect(saved.single.fileName, 'scontrini_2026-11-24.csv');
    expect(saved.single.mimeType, 'text/csv');
    final text = utf8.decode(saved.single.bytes.skip(3).toList());
    final lines = text.trim().split('\r\n');
    expect(lines, hasLength(3));
    expect(
      lines[1],
      startsWith('1;2026-11-20;12:00;CONAD;;2,78;0,00;a mano;PANE;'),
    );
    expect(
      find.text('Esportati 2 articoli in scontrini_2026-11-24.csv'),
      findsOneWidget,
    );
    await closeApp(tester);
  });
}
