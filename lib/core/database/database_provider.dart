import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/database/app_database.dart';

/// The app database. Overridden in `main.dart` once the encryption key has
/// been loaded, and in tests with an in-memory database.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);
