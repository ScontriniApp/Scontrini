import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where a small settings object of type [T] lives between runs (the paper
/// and plastic looks tuned in the labs).
abstract class SettingsStore<T> {
  /// What was saved, read at start-up (defaults if nothing was).
  T get initial;

  /// Saves [value]; may batch quick successive calls.
  void save(T value);

  /// Writes anything still pending.
  Future<void> flush();
}

/// Keeps the settings in memory only (tests, and the default until `main`
/// swaps in a file store).
class MemorySettingsStore<T> implements SettingsStore<T> {
  new(this.initial) : saved = initial;

  @override
  final T initial;

  /// The last value saved.
  T saved;

  @override
  void save(T value) => saved = value;

  @override
  Future<void> flush() async {}
}

/// A JSON file in the app's private storage. Writes are batched while a
/// slider is dragged and flushed when the app goes to the background, so
/// closing the app keeps the last change.
class FileSettingsStore<T> implements SettingsStore<T> {
  new _(this.file, this.initial, this._toJson, this.delay);

  /// Reads [file] (default: [name] in the app support folder). A missing or
  /// unreadable file gives [defaults].
  static Future<FileSettingsStore<T>> open<T>({
    required String name,
    required T defaults,
    required T Function(Map<String, Object?> json) fromJson,
    required Map<String, Object?> Function(T value) toJson,
    File? file,
    Duration delay = const Duration(milliseconds: 400),
  }) async {
    final target =
        file ??
        File(p.join((await getApplicationSupportDirectory()).path, name));
    var initial = defaults;
    try {
      if (target.existsSync()) {
        final json = jsonDecode(await target.readAsString());
        if (json is Map<String, Object?>) initial = fromJson(json);
      }
    } on Object catch (error) {
      // A broken file must not stop the app: start from the defaults.
      debugPrint('Settings ${target.path} not read: $error');
    }
    return FileSettingsStore._(target, initial, toJson, delay);
  }

  final File file;

  @override
  final T initial;

  final Map<String, Object?> Function(T value) _toJson;

  final Duration delay;

  T? _pending;
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
  void save(T value) {
    _pending = value;
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  @override
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    final value = _pending;
    _pending = null;
    if (value != null) {
      // One write at a time, in order: the newest always lands last.
      _writing = _writing.then((_) => _write(value));
    }
    return _writing;
  }

  Future<void> _write(T value) async {
    try {
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(_toJson(value)), flush: true);
      await temp.rename(file.path);
    } on Object catch (error) {
      debugPrint('Settings ${file.path} not saved: $error');
    }
  }

  void dispose() {
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}
