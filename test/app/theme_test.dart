import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/theme.dart';

void main() {
  test('every theme uses the amber accent, cream on it', () {
    for (final theme in [
      AppTheme.light,
      AppTheme.dark,
      AppTheme.onBackground(const Color(0xFF263238)),
      AppTheme.onBackground(const Color(0xFFFFF8E1)),
    ]) {
      expect(theme.colorScheme.primary, const Color(0xFFC58003));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFF5DC));
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        const Color(0xFFC58003),
      );
      expect(
        theme.floatingActionButtonTheme.foregroundColor,
        const Color(0xFFFFF5DC),
      );
    }
  });
}
