import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [f] of [a]'s value, keeping the last value while [a] reloads (a pull to
/// refresh), so screens built on it never flash back to a spinner.
AsyncValue<R> mapAsync<A, R>(AsyncValue<A> a, R Function(A) f) {
  if (a.hasValue) return AsyncData(f(a.requireValue));
  if (a case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  return const AsyncLoading();
}

/// [f] of both values, with the same rule as [mapAsync]; an error in either
/// wins over waiting for the other.
AsyncValue<R> combineAsync<A, B, R>(
  AsyncValue<A> a,
  AsyncValue<B> b,
  R Function(A, B) f,
) {
  if (a.hasValue && b.hasValue) {
    return AsyncData(f(a.requireValue, b.requireValue));
  }
  for (final v in [a, b]) {
    if (v case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  return const AsyncLoading();
}
