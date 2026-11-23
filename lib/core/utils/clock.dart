import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. Overridden in tests so screens that depend on "today"
/// are deterministic.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
