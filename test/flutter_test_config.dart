import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test file: loads the app's font (VT323), so widget
/// tests lay text out as the phone does. Without it tests draw every letter
/// as a square as wide as the font size, far wider than VT323's narrow
/// letters, and rows that fit on the phone overflow.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = File('assets/fonts/VT323-Regular.ttf').readAsBytesSync();
  await (FontLoader('VT323')
        ..addFont(Future.value(ByteData.sublistView(bytes))))
      .load();
  await testMain();
}
