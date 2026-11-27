import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/theme.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/recess/recess_settings.dart';

/// The pantry's own colours around [child]: accent (sliders, buttons, the
/// colour scheme's primary), text and icons from the pantry lab
/// ([recessSettingsProvider]), never from the app's accent (Settings →
/// "Testo secondario"). Category titles take [RecessParams.titleColor]
/// in `CategoryDrawer`.
class PantryColors extends ConsumerWidget {
  const new({required this.child, this.params, super.key});

  final Widget child;

  /// Overrides [recessSettingsProvider] (the lab's preview).
  final RecessParams? params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(recessSettingsProvider);
    final p = params ?? watched;
    return Theme(data: themed(Theme.of(context), p), child: child);
  }

  /// [base] with the pantry colours of [p].
  static ThemeData themed(ThemeData base, RecessParams p) {
    final onAccent = AppTheme.onAccentFor(p.accent);
    var data = base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: p.accent,
        onPrimary: onAccent,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: p.accent,
        foregroundColor: onAccent,
      ),
    );
    if (p.textColor case final text?) {
      final textTheme = data.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      );
      data = data.copyWith(
        textTheme: textTheme,
        appBarTheme: data.appBarTheme.copyWith(
          titleTextStyle: textTheme.titleLarge,
        ),
      );
    }
    if (p.iconColor case final icon?) {
      final icons = data.iconTheme.copyWith(color: icon);
      data = data.copyWith(
        iconTheme: icons,
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: icon),
        ),
        appBarTheme: data.appBarTheme.copyWith(
          iconTheme: icons,
          actionsIconTheme: icons,
        ),
      );
    }
    return data;
  }
}
