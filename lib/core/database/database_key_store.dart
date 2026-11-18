import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Generates the database encryption key on first launch and keeps it in the
/// platform keystore (Android Keystore / iOS Keychain).
class DatabaseKeyStore {
  new([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _storageKey = 'db_encryption_key';

  final FlutterSecureStorage _storage;

  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _storageKey);
    if (existing != null) return existing;

    final key = _generateHexKey();
    await _storage.write(key: _storageKey, value: key);
    return key;
  }

  static String _generateHexKey({int bytes = 32}) {
    final random = Random.secure();
    return List.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
