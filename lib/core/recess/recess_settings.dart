import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/utils/settings_store.dart';

/// Opens `recess_settings.json` in the app support folder (or [file]).
Future<FileSettingsStore<RecessParams>> openRecessSettingsFile({File? file}) =>
    FileSettingsStore.open(
      name: 'recess_settings.json',
      defaults: const RecessParams(),
      fromJson: RecessParams.fromJson,
      toJson: (params) => params.toJson(),
      file: file,
    );

/// Where the recess look is saved; `main` overrides it with the file store,
/// tests get an in-memory one.
final recessSettingsStoreProvider = Provider<SettingsStore<RecessParams>>(
  (ref) => MemorySettingsStore(const RecessParams()),
);

/// The saved recess look (pantry drawers), shared by the pantry lab and the
/// pantry tab. The lamp is the paper's (`paperLightProvider`): one light in
/// the room for every material.
final recessSettingsProvider =
    NotifierProvider<RecessSettingsNotifier, RecessParams>(
      RecessSettingsNotifier.new,
    );

class RecessSettingsNotifier extends Notifier<RecessParams> {
  @override
  RecessParams build() => ref.read(recessSettingsStoreProvider).initial;

  /// Saves [params] (without the lab's debug view).
  void set(RecessParams params) {
    final clean = params.copyWith(debugView: RecessDebugView.result);
    if (clean == state) return;
    state = clean;
    ref.read(recessSettingsStoreProvider).save(clean);
  }

  /// Back to the look the app ships with.
  void reset() => set(const RecessParams());

  /// Writes any batched change now (e.g. when the lab closes).
  Future<void> flush() => ref.read(recessSettingsStoreProvider).flush();
}
