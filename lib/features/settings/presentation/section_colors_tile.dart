import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/theme.dart';
import 'package:scontrini/core/section_colors/section_colors.dart';
import 'package:scontrini/core/section_colors/section_colors_provider.dart';
import 'package:scontrini/core/section_colors/section_surface.dart';
import 'package:scontrini/features/settings/presentation/color_picker_dialog.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Settings row that picks the background of the whole app, and the
/// background and text colour of the plain sections (dashboard cards,
/// Analisi cards, history months, pantry categories), each with a free
/// colour picker. Paper and shelf labels keep
/// their own look.
class SectionColorsTile extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = ref.watch(sectionColorsProvider);
    final notifier = ref.read(sectionColorsProvider.notifier);
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l10n.settingsSectionColors),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColorRow(
            label: l10n.settingsAppBackground,
            color: colors.appBackground,
            fallback: theme.scaffoldBackgroundColor,
            shortcuts: SectionColors.backgrounds,
            onChanged: (c) => notifier.select(colors.withAppBackground(c)),
          ),
          ColorRow(
            label: l10n.settingsAccent,
            color: colors.accent,
            fallback: AppTheme.accent,
            shortcuts: const [AppTheme.accent, ...SectionColors.texts],
            onChanged: (c) => notifier.select(colors.withAccent(c)),
          ),
          Text(l10n.settingsAccentHint),
          const Divider(),
          Text(l10n.settingsSectionColorsHint),
          const SizedBox(height: 8),
          ColorRow(
            label: l10n.settingsSectionBackground,
            color: colors.background,
            // Starting point when nothing is chosen: the card colour now.
            fallback: theme.colorScheme.surfaceContainerLow,
            shortcuts: SectionColors.backgrounds,
            onChanged: (c) => notifier.select(colors.withBackground(c)),
          ),
          ColorRow(
            label: l10n.settingsSectionText,
            color: colors.text,
            fallback: theme.colorScheme.onSurface,
            shortcuts: SectionColors.texts,
            onChanged: (c) => notifier.select(colors.withText(c)),
          ),
          const SizedBox(height: 8),
          // A sample section, drawn with the chosen colours.
          SectionSurface(
            child: Card(
              margin: EdgeInsets.zero,
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsSectionPreviewTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          l10n.settingsSectionPreviewBody,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Sfondo  [●] #1A237E   Predefinito": the swatch opens the picker, the
/// button goes back to the theme's colour. Also the pantry lab's colours.
class ColorRow extends StatelessWidget {
  const new({
    required this.label,
    required this.color,
    required this.fallback,
    required this.shortcuts,
    required this.onChanged,
    super.key,
  });

  final String label;

  /// `null`: the theme's colour.
  final Color? color;
  final Color fallback;
  final List<Color> shortcuts;
  final ValueChanged<Color?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showColorPicker(
      context,
      title: label,
      initial: color ?? fallback,
      shortcuts: shortcuts,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = color;
    final value = shown == null
        ? l10n.settingsSectionColorDefault
        : colorHex(shown);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Semantics(
          label: '$label: $value',
          button: true,
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _pick(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                spacing: 8,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: shown ?? scheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline),
                    ),
                    child: shown == null
                        ? Icon(
                            Icons.format_color_reset,
                            size: 18,
                            color: scheme.onSurface,
                          )
                        : null,
                  ),
                  Text(value),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.settingsSectionColorDefault,
          icon: const Icon(Icons.restart_alt),
          onPressed: shown == null ? null : () => onChanged(null),
        ),
      ],
    );
  }
}
