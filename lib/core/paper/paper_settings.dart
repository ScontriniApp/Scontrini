import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/utils/settings_store.dart';

/// The paper look the whole app shares: tuned in the shader lab, saved on
/// the device, read by any screen that prints on paper
/// (`ref.watch(paperSettingsProvider)`).
@immutable
class PaperSettings {
  const new({
    this.params = const PaperParams(),
    this.light = const PaperLight(),
    this.componentInk = PaperInk.colour,
  });

  /// Reads [toJson]'s output; anything missing keeps its default.
  factory fromJson(Map<String, Object?> json) {
    final params = json['params'];
    final light = json['light'];
    return PaperSettings(
      params: params is Map<String, Object?>
          ? PaperParams.fromJson(params)
          : const PaperParams(),
      light: light is Map<String, Object?>
          ? PaperLight.fromJson(light)
          : const PaperLight(),
      componentInk:
          PaperInk.values.asNameMap()[json['componentInk']] ?? PaperInk.colour,
    );
  }

  /// The sheet, camera and lamp knobs; its ink is how receipts are printed.
  final PaperParams params;

  /// The lamp's direction (unless the tilt light is driving it).
  final PaperLight light;

  /// How UI components (cards, charts, rows) are printed.
  final PaperInk componentInk;

  /// Knobs for a printed receipt.
  PaperParams get receipt => params;

  /// Knobs for a UI component printed on paper.
  PaperParams get component => params.copyWith(ink: componentInk);

  Map<String, Object> toJson() => {
    'version': 1,
    'params': params.toJson(),
    'light': light.toJson(),
    'componentInk': componentInk.name,
  };

  PaperSettings copyWith({
    PaperParams? params,
    PaperLight? light,
    PaperInk? componentInk,
  }) => PaperSettings(
    params: params ?? this.params,
    light: light ?? this.light,
    componentInk: componentInk ?? this.componentInk,
  );

  @override
  bool operator ==(Object other) =>
      other is PaperSettings &&
      other.params == params &&
      other.light == light &&
      other.componentInk == componentInk;

  @override
  int get hashCode => Object.hash(params, light, componentInk);
}

/// Where [PaperSettings] live between runs.
typedef PaperSettingsStore = SettingsStore<PaperSettings>;

/// Opens `paper_settings.json` in the app support folder (or [file]).
Future<FileSettingsStore<PaperSettings>> openPaperSettingsFile({File? file}) =>
    FileSettingsStore.open(
      name: 'paper_settings.json',
      defaults: const PaperSettings(),
      fromJson: PaperSettings.fromJson,
      toJson: (settings) => settings.toJson(),
      file: file,
    );

/// Where the paper settings are saved; `main` overrides it with the file
/// store, tests get an in-memory one.
final paperSettingsStoreProvider = Provider<PaperSettingsStore>(
  (ref) => MemorySettingsStore(const PaperSettings()),
);

/// The saved paper look, shared by the lab and every paper UI.
final paperSettingsProvider =
    NotifierProvider<PaperSettingsNotifier, PaperSettings>(
      PaperSettingsNotifier.new,
    );

class PaperSettingsNotifier extends Notifier<PaperSettings> {
  @override
  PaperSettings build() => ref.read(paperSettingsStoreProvider).initial;

  void _set(PaperSettings settings) {
    if (settings == state) return;
    state = settings;
    ref.read(paperSettingsStoreProvider).save(settings);
  }

  void setParams(PaperParams params) => _set(state.copyWith(params: params));

  void setLight(PaperLight light) => _set(state.copyWith(light: light));

  void setReceiptInk(PaperInk ink) =>
      _set(state.copyWith(params: state.params.copyWith(ink: ink)));

  void setComponentInk(PaperInk ink) => _set(state.copyWith(componentInk: ink));

  /// Back to the look the app ships with.
  void reset() => _set(const PaperSettings());

  /// Writes any batched change now (e.g. when the lab closes).
  Future<void> flush() => ref.read(paperSettingsStoreProvider).flush();
}
