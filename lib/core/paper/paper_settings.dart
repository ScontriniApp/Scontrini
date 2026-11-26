import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/core/paper/paper_params.dart';

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
abstract class PaperSettingsStore {
  /// What was saved, read at start-up (defaults if nothing was).
  PaperSettings get initial;

  /// Saves [settings]; may batch quick successive calls.
  void save(PaperSettings settings);

  /// Writes anything still pending.
  Future<void> flush();
}

/// Keeps the settings in memory only (tests, and before `main` swaps in the
/// file store).
class MemoryPaperSettingsStore implements PaperSettingsStore {
  new([this.initial = const PaperSettings()]) : saved = initial;

  @override
  final PaperSettings initial;

  /// The last settings saved.
  PaperSettings saved;

  @override
  void save(PaperSettings settings) => saved = settings;

  @override
  Future<void> flush() async {}
}

/// A JSON file in the app's private storage. Writes are batched while a
/// slider is dragged and flushed when the app goes to the background, so
/// closing the app keeps the last change.
class FilePaperSettingsStore implements PaperSettingsStore {
  new _(this.file, this.initial, this.delay);

  /// Reads [file] (default: `paper_settings.json` in the app support
  /// folder). A missing or unreadable file gives the defaults.
  static Future<FilePaperSettingsStore> open({
    File? file,
    Duration delay = const Duration(milliseconds: 400),
  }) async {
    final target =
        file ??
        File(
          p.join(
            (await getApplicationSupportDirectory()).path,
            'paper_settings.json',
          ),
        );
    var initial = const PaperSettings();
    try {
      if (target.existsSync()) {
        final json = jsonDecode(await target.readAsString());
        if (json is Map<String, Object?>) {
          initial = PaperSettings.fromJson(json);
        }
      }
    } on Object catch (error) {
      // A broken file must not stop the app: start from the defaults.
      debugPrint('Paper settings not read: $error');
    }
    return FilePaperSettingsStore._(target, initial, delay);
  }

  final File file;

  @override
  final PaperSettings initial;

  final Duration delay;

  PaperSettings? _pending;
  Timer? _timer;
  Future<void> _writing = Future.value();
  AppLifecycleListener? _lifecycle;

  /// Flushes whenever the app leaves the foreground (needs the binding).
  void flushOnPause() {
    _lifecycle ??= AppLifecycleListener(
      onInactive: () => unawaited(flush()),
      onHide: () => unawaited(flush()),
      onPause: () => unawaited(flush()),
      onDetach: () => unawaited(flush()),
    );
  }

  @override
  void save(PaperSettings settings) {
    _pending = settings;
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  @override
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    final settings = _pending;
    _pending = null;
    if (settings != null) {
      // One write at a time, in order: the newest always lands last.
      _writing = _writing.then((_) => _write(settings));
    }
    return _writing;
  }

  Future<void> _write(PaperSettings settings) async {
    try {
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(settings.toJson()), flush: true);
      await temp.rename(file.path);
    } on Object catch (error) {
      debugPrint('Paper settings not saved: $error');
    }
  }

  void dispose() {
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}

/// Where the paper settings are saved; `main` overrides it with the file
/// store, tests get an in-memory one.
final paperSettingsStoreProvider = Provider<PaperSettingsStore>(
  (ref) => MemoryPaperSettingsStore(),
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
