import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/utils/settings_store.dart';

/// Opens `plastic_settings.json` in the app support folder (or [file]).
Future<FileSettingsStore<PlasticParams>> openPlasticSettingsFile({
  File? file,
}) => FileSettingsStore.open(
  name: 'plastic_settings.json',
  defaults: const PlasticParams(),
  fromJson: PlasticParams.fromJson,
  toJson: (params) => params.toJson(),
  file: file,
);

/// Where the plastic look is saved; `main` overrides it with the file
/// store, tests get an in-memory one.
final plasticSettingsStoreProvider = Provider<SettingsStore<PlasticParams>>(
  (ref) => MemorySettingsStore(const PlasticParams()),
);

/// The saved plastic look (shelf labels), shared by the plastic lab and
/// every plastic UI. The lamp is the paper's (`paperLightProvider`): one
/// light in the room for every material.
final plasticSettingsProvider =
    NotifierProvider<PlasticSettingsNotifier, PlasticParams>(
      PlasticSettingsNotifier.new,
    );

class PlasticSettingsNotifier extends Notifier<PlasticParams> {
  @override
  PlasticParams build() => ref.read(plasticSettingsStoreProvider).initial;

  /// Saves [params] (without the lab's debug view).
  void set(PlasticParams params) {
    final clean = params.copyWith(debugView: PlasticDebugView.result);
    if (clean == state) return;
    state = clean;
    ref.read(plasticSettingsStoreProvider).save(clean);
  }

  /// Back to the look the app ships with.
  void reset() => set(const PlasticParams());

  /// Writes any batched change now (e.g. when the lab closes).
  Future<void> flush() => ref.read(plasticSettingsStoreProvider).flush();
}
