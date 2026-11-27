import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/utils/settings_store.dart';

void main() {
  const tuned = PaperSettings(
    params: PaperParams(
      seed: 42,
      depth: 1.3,
      cameraTilt: 0.5,
      ink: PaperInk.colour,
      torn: 9,
      dropShadow: 0.4,
      hover: 7,
      tilt: 0.2,
      lift: 1.05,
    ),
    light: PaperLight(azimuth: 1.1, elevation: 0.9),
    componentInk: PaperInk.off,
  );

  test('settings survive a JSON round trip, debug view left out', () {
    final json = jsonDecode(jsonEncode(tuned.toJson())) as Map<String, Object?>;
    expect(PaperSettings.fromJson(json), tuned);

    final debug = tuned.params.copyWith(debugView: PaperDebugView.normals);
    expect(
      PaperParams.fromJson(debug.toJson()).debugView,
      PaperDebugView.result,
    );
  });

  test('missing or bad values keep the defaults', () {
    final settings = PaperSettings.fromJson(const {
      'params': {'depth': 0.9, 'seed': 'nope', 'ink': 'laser'},
      'light': 'broken',
    });
    expect(settings.params.depth, 0.9);
    expect(settings.params.seed, const PaperParams().seed);
    expect(settings.params.ink, const PaperParams().ink);
    expect(settings.light, const PaperLight());
    expect(settings.componentInk, PaperInk.colour);
  });

  test('receipt and component params differ only by ink', () {
    expect(tuned.receipt.ink, PaperInk.colour);
    expect(tuned.component.ink, PaperInk.off);
    expect(tuned.component.copyWith(ink: PaperInk.colour), tuned.receipt);
  });

  group('file store', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('paper_settings'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('saves and reads back, last change wins', () async {
      final file = File('${dir.path}/paper_settings.json');
      final store = await openPaperSettingsFile(file: file);
      expect(store.initial, const PaperSettings());

      store
        ..save(const PaperSettings(componentInk: PaperInk.thermal))
        ..save(tuned);
      await store.flush();

      final reopened = await openPaperSettingsFile(file: file);
      expect(reopened.initial, tuned);
    });

    test('a broken file gives the defaults', () async {
      final file = File('${dir.path}/paper_settings.json')
        ..writeAsStringSync('{not json');
      final store = await openPaperSettingsFile(file: file);
      expect(store.initial, const PaperSettings());
    });
  });

  test('the provider starts from the store and saves every change', () {
    final store = MemorySettingsStore(tuned);
    final container = ProviderContainer(
      overrides: [paperSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(container.read(paperSettingsProvider), tuned);
    expect(container.read(paperLightProvider), tuned.light);

    final notifier = container.read(paperSettingsProvider.notifier)
      ..setParams(tuned.params.copyWith(depth: 0.2))
      ..setComponentInk(PaperInk.colour);
    expect(store.saved.params.depth, 0.2);
    expect(store.saved.componentInk, PaperInk.colour);

    // A live light (tilt) overrides the saved one until invalidated.
    container
        .read(paperLightProvider.notifier)
        .set(const PaperLight(azimuth: 0.3));
    expect(container.read(paperLightProvider).azimuth, 0.3);
    container.invalidate(paperLightProvider);
    expect(container.read(paperLightProvider), tuned.light);

    notifier.reset();
    expect(store.saved, const PaperSettings());
    expect(container.read(paperLightProvider), const PaperLight());
  });
}
