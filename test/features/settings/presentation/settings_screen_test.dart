import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/data/glm_ocr.dart';
import 'package:scontrini/features/extraction/data/model_downloader.dart';
import 'package:scontrini/features/settings/presentation/settings_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class _FakeDownloader implements ModelDownloader {
  bool isInstalled = false;
  int downloaded = 0;
  StreamController<DownloadProgress>? controller;
  bool deleted = false;

  @override
  List<ModelDownloadFile> get files => const [];

  @override
  Duration get stallTimeout => Duration.zero;

  @override
  int get totalBytes => 1430000000;

  @override
  Future<bool> installed(String directory) async => isInstalled;

  @override
  Future<int> downloadedBytes(String directory) async => downloaded;

  @override
  Future<void> delete(String directory) async {
    deleted = true;
    isInstalled = false;
    downloaded = 0;
  }

  @override
  Stream<DownloadProgress> download(String directory) =>
      // An onCancel of our own: the default cancel future lives outside the
      // test's fake clock and never completes during pumps.
      (controller = StreamController<DownloadProgress>(
        onCancel: () async {},
      )).stream;
}

void main() {
  late _FakeDownloader downloader;
  late int glmBuilds;

  setUp(() {
    downloader = _FakeDownloader();
    glmBuilds = 0;
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          glmOcrDownloaderProvider.overrideWithValue(downloader),
          glmOcrModelDirectoryProvider.overrideWithValue(Future.value('/m')),
          glmOcrProvider.overrideWith((ref) {
            glmBuilds++;
            return Future<GlmOcr?>.value();
          }),
        ],
        child: const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('downloads the model after confirming', (tester) async {
    await open(tester);
    expect(find.textContaining('Non installato'), findsOneWidget);
    expect(find.textContaining('1,4 GB'), findsOneWidget);

    await tester.tap(find.text('Scarica'));
    await tester.pumpAndSettle();
    expect(find.text('Scaricare il modello?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Scarica'),
      ),
    );
    await tester.pumpAndSettle();

    downloader.controller!.add((received: 715000000, total: 1430000000));
    await tester.pumpAndSettle();
    expect(find.text('Download: 715 MB di 1,4 GB'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    await container.read(glmOcrProvider);
    final builds = glmBuilds;
    await downloader.controller!.close();
    await tester.pumpAndSettle();
    expect(find.textContaining('Installato (1,4 GB)'), findsOneWidget);
    // Photos switch to GLM-OCR: its provider is built again.
    await container.read(glmOcrProvider);
    expect(glmBuilds, builds + 1);
  });

  testWidgets('a cancelled download can be resumed', (tester) async {
    await open(tester);
    await tester.tap(find.text('Scarica'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Scarica'),
      ),
    );
    await tester.pumpAndSettle();
    downloader.controller!.add((received: 300000000, total: 1430000000));
    await tester.pumpAndSettle();

    downloader.downloaded = 300000000;
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('Download interrotto: 300 MB di 1,4 GB.'), findsOneWidget);
    expect(find.text('Riprendi'), findsOneWidget);
  });

  testWidgets('a failed download shows why', (tester) async {
    await open(tester);
    await tester.tap(find.text('Scarica'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Scarica'),
      ),
    );
    await tester.pumpAndSettle();
    downloader.controller!.addError(
      const ModelDownloadException(ModelDownloadError.storage),
    );
    await tester.pumpAndSettle();
    expect(find.text('Spazio insufficiente sul telefono.'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);
  });

  testWidgets('an installed model can be deleted', (tester) async {
    downloader.isInstalled = true;
    await open(tester);
    expect(find.textContaining('Installato'), findsOneWidget);

    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Elimina'),
      ),
    );
    await tester.pumpAndSettle();
    expect(downloader.deleted, isTrue);
    expect(find.textContaining('Non installato'), findsOneWidget);
  });
}
