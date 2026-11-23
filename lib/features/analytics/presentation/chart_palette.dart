import 'package:material_ui/material_ui.dart';

/// Colours for categorical charts: eight hues in a fixed order, checked for
/// colour-blind separation and contrast against light and dark surfaces.
///
/// The seeded `categories.color` values are not used for charts: their red
/// and green are almost the same for deuteranopes and their yellow is nearly
/// invisible on white. Charts always pair colour with a text label.
abstract final class ChartPalette {
  static const _light = [
    Color(0xFF2A78D6), // blue
    Color(0xFFEB6834), // orange
    Color(0xFF1BAF7A), // aqua
    Color(0xFFEDA100), // yellow
    Color(0xFFE87BA4), // magenta
    Color(0xFF008300), // green
    Color(0xFF6250D6), // violet
    Color(0xFFE34948), // red
  ];

  static const _dark = [
    Color(0xFF3987E5),
    Color(0xFFD95926),
    Color(0xFF199E70),
    Color(0xFFC98500),
    Color(0xFFD55181),
    Color(0xFF0CA30C),
    Color(0xFF9085E9),
    Color(0xFFE66767),
  ];

  /// The colour of [slot] (a stable index per entity, never its rank). Slots
  /// past the eighth, and `null` (the "rest" group), get the neutral colour.
  static Color series(BuildContext context, int? slot) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? _dark
        : _light;
    if (slot == null || slot < 0 || slot >= colors.length) {
      return neutral(context);
    }
    return colors[slot];
  }

  static Color neutral(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
}
