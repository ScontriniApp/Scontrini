import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/core/utils/settings_store.dart';

void main() {
  const tuned = PlasticParams(rim: 5, gloss: 0.9, tilt: 0.2, damping: 8);

  test('params survive a JSON round trip, debug view left out', () {
    final json = jsonDecode(
      jsonEncode(tuned.copyWith(debugView: PlasticDebugView.normals).toJson()),
    ) as Map<String, Object?>;
    expect(PlasticParams.fromJson(json), tuned);
  });

  test('missing or bad values keep the defaults', () {
    final params = PlasticParams.fromJson(const {'rim': 6, 'gloss': 'shiny'});
    expect(params.rim, 6);
    expect(params.gloss, const PlasticParams().gloss);
  });

  test('toDart lists every knob', () {
    final dart = tuned.toDart();
    expect(dart, startsWith('PlasticParams(rim: 5.00'));
    expect(dart, contains('damping: 8.00'));
    expect(dart, isNot(contains('debugView')));
  });

  test('the file store saves and reads back', () async {
    final dir = Directory.systemTemp.createTempSync('plastic_settings');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/plastic_settings.json');
    final store = await openPlasticSettingsFile(file: file);
    expect(store.initial, const PlasticParams());
    store.save(tuned);
    await store.flush();
    expect((await openPlasticSettingsFile(file: file)).initial, tuned);
  });

  test('the provider starts from the store and saves clean params', () {
    final store = MemorySettingsStore(tuned);
    final container = ProviderContainer(
      overrides: [plasticSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(container.read(plasticSettingsProvider), tuned);
    container
        .read(plasticSettingsProvider.notifier)
        .set(tuned.copyWith(rim: 1, debugView: PlasticDebugView.height));
    expect(store.saved.rim, 1);
    expect(store.saved.debugView, PlasticDebugView.result);

    container.read(plasticSettingsProvider.notifier).reset();
    expect(store.saved, const PlasticParams());
  });
}
