import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/paper/tilt_light.dart';
import 'package:scontrini/core/recess/recess_params.dart';
import 'package:scontrini/core/recess/recess_settings.dart';
import 'package:scontrini/core/recess/recessed_panel.dart';
import 'package:scontrini/core/section_colors/section_colors.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/category_sprites.dart';
import 'package:scontrini/features/pantry/presentation/pantry_colors.dart';
import 'package:scontrini/features/pantry/presentation/widgets/category_drawer.dart';
import 'package:scontrini/features/pantry/presentation/widgets/pantry_lot_tile.dart';
import 'package:scontrini/features/settings/presentation/section_colors_tile.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Debug-only screen to tune the pantry's drawers on the phone: the real
/// [CategoryDrawer]s with made-up lots on top (tap one to open it), one
/// slider per knob below. Every change is saved ([recessSettingsProvider])
/// and shows in the pantry tab; the lamp is shared with paper and plastic.
class PantryLabScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PantryLabScreen> createState() => _PantryLabScreenState();
}

class _PantryLabScreenState extends ConsumerState<PantryLabScreen> {
  /// Lab-only view of a shader input: never saved.
  RecessDebugView _debugView = RecessDebugView.result;
  bool _controls = true;

  /// Open drawers, by index in [_shelves]. The first starts open.
  final _open = <int>{0};

  // Captured up front: `ref` can't be used in dispose.
  late final RecessSettingsNotifier _settings;
  late final PaperSettingsNotifier _paper;
  late final ProviderContainer _container;

  /// Light from the real "up", following the phone's tilt.
  late final TiltLight _tilt = TiltLight(
    onLight: (light) => ref.read(paperLightProvider.notifier).set(light),
  );

  @override
  void initState() {
    super.initState();
    _settings = ref.read(recessSettingsProvider.notifier);
    _paper = ref.read(paperSettingsProvider.notifier);
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    unawaited(_tilt.stop());
    // Back to the saved light, and the last change on disk.
    _container.invalidate(paperLightProvider);
    unawaited(_settings.flush());
    unawaited(_paper.flush());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final params = ref.watch(recessSettingsProvider);
    final light = ref.watch(paperLightProvider);
    final shown = params.copyWith(debugView: _debugView);
    void update(RecessParams value) => _settings.set(value);

    // The pantry's own colours, as the tab shows them.
    final preview = PantryColors(
      params: shown,
      child: Builder(builder: (context) => _preview(context, l10n, shown)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pantryLabTitle),
        actions: [
          IconButton(
            tooltip: l10n.shaderLabHideControls,
            icon: Icon(_controls ? Icons.fullscreen : Icons.tune),
            onPressed: () => setState(() => _controls = !_controls),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: preview),
            if (_controls)
              Material(
                elevation: 4,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.42,
                  child: _controlsList(l10n, messenger, params, light, update),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _preview(
    BuildContext context,
    AppLocalizations l10n,
    RecessParams shown,
  ) => ListView(
    padding: const EdgeInsets.symmetric(vertical: 12),
    children: [
      for (final (i, shelf) in _shelves.indexed)
        CategoryDrawer(
          title: shelf.title,
          sprite: categorySprite(shelf.category),
          trailing: '${shelf.lots.length}',
          open: _open.contains(i),
          onTap: () => setState(
            () => _open.contains(i) ? _open.remove(i) : _open.add(i),
          ),
          params: shown,
          children: [
            for (final lot in shelf.lots)
              PantryLotTile(
                key: ValueKey(lot.id),
                lot: lot,
                onSetRemaining: (_) {},
                onTap: () {},
              ),
          ],
        ),
      const SizedBox(height: 8),
      Text(
        l10n.pantryLabTapHint,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );

  /// A pantry colour: the swatch opens the picker, reset goes back to
  /// [fallback] ([onChanged] null).
  Widget _colorRow(
    String label,
    Color? value,
    Color fallback,
    ValueChanged<Color?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ColorRow(
      label: label,
      color: value,
      fallback: fallback,
      shortcuts: const [RecessParams.defaultAccent, ...SectionColors.texts],
      onChanged: onChanged,
    ),
  );

  Widget _controlsList(
    AppLocalizations l10n,
    ScaffoldMessengerState messenger,
    RecessParams params,
    PaperLight light,
    void Function(RecessParams) update,
  ) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (!RecessedPanel.canShade)
          ListTile(
            dense: true,
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.pantryLabUnsupported),
          ),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _settings.reset,
              child: Text(l10n.shaderLabReset),
            ),
            OutlinedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: params.toDart()));
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.shaderLabCopied)));
              },
              child: Text(l10n.shaderLabCopy),
            ),
          ],
        ),
        // The pantry's own colours (the tab reads only these).
        _section(l10n.pantryLabColors),
        _colorRow(
          l10n.pantryLabAccent,
          params.accent,
          RecessParams.defaultAccent,
          (c) =>
              update(params.copyWith(accent: c ?? RecessParams.defaultAccent)),
        ),
        _colorRow(
          l10n.pantryLabTitleColor,
          params.titleColor,
          RecessParams.defaultAccent,
          (c) => update(
            params.copyWith(titleColor: c ?? RecessParams.defaultAccent),
          ),
        ),
        _colorRow(
          l10n.pantryLabTextColor,
          params.textColor,
          theme.colorScheme.onSurface,
          (c) => update(params.copyWith(textColor: c)),
        ),
        _colorRow(
          l10n.pantryLabIconColor,
          params.iconColor,
          theme.colorScheme.onSurfaceVariant,
          (c) => update(params.copyWith(iconColor: c)),
        ),
        const SizedBox(height: 8),
        // Shader inputs: developer names, not translated.
        Center(
          child: SegmentedButton<RecessDebugView>(
            segments: [
              for (final v in RecessDebugView.values)
                ButtonSegment(value: v, label: Text(v.name)),
            ],
            selected: {_debugView},
            onSelectionChanged: (s) => setState(() => _debugView = s.single),
          ),
        ),
        SwitchListTile(
          dense: true,
          secondary: const Icon(Icons.screen_rotation),
          title: Text(l10n.shaderLabTiltLight),
          subtitle: Text(l10n.shaderLabTiltLightHint),
          value: _tilt.running,
          onChanged: (on) async {
            if (on) {
              _tilt.start();
            } else {
              await _tilt.stop();
              ref.invalidate(paperLightProvider);
            }
            if (mounted) setState(() {});
          },
        ),
        // Knob names match the params (developer tool), so
        // they aren't translated. The lamp is the paper's.
        _knob('lightDir', light.azimuth, 0, 2 * math.pi, (v) {
          _paper.setLight(light.copyWith(azimuth: v));
        }),
        _knob('lightUp', light.elevation, 0.1, math.pi / 2, (v) {
          _paper.setLight(light.copyWith(elevation: v));
        }),
        _section('drawer'),
        _knob('depth', params.depth, 0, 60, (v) {
          update(params.copyWith(depth: v));
        }),
        _knob('closedDepth', params.closedDepth, 0, 40, (v) {
          update(params.copyWith(closedDepth: v));
        }),
        _knob('radius', params.radius, 0, 32, (v) {
          update(params.copyWith(radius: v));
        }),
        _knob('bevel', params.bevel, 0, 12, (v) {
          update(params.copyWith(bevel: v));
        }),
        _section('perspective'),
        _knob('eyeDistance', params.eyeDistance, 150, 4000, (v) {
          update(params.copyWith(eyeDistance: v));
        }),
        _knob('eyeX', params.eyeX, 0, 1, (v) {
          update(params.copyWith(eyeX: v));
        }),
        _knob('eyeY', params.eyeY, 0, 1, (v) {
          update(params.copyWith(eyeY: v));
        }),
        _section('shading'),
        _knob('ambient', params.ambient, 0, 1, (v) {
          update(params.copyWith(ambient: v));
        }),
        _knob('floorShade', params.floorShade, 0.5, 1.2, (v) {
          update(params.copyWith(floorShade: v));
        }),
        _knob('wallShade', params.wallShade, 0.3, 1.2, (v) {
          update(params.copyWith(wallShade: v));
        }),
        _knob('shadow', params.shadow, 0, 1, (v) {
          update(params.copyWith(shadow: v));
        }),
        _knob('softness', params.softness, 0, 1.5, (v) {
          update(params.copyWith(softness: v));
        }),
        _knob('occlusion', params.occlusion, 0, 1, (v) {
          update(params.copyWith(occlusion: v));
        }),
        _knob('highlight', params.highlight, 0, 1, (v) {
          update(params.copyWith(highlight: v));
        }),
        _section('content'),
        _knob('lift', params.lift, 0, 30, (v) {
          update(params.copyWith(lift: v));
        }),
        _knob('textShadow', params.textShadow, 0, 1, (v) {
          update(params.copyWith(textShadow: v));
        }),
        _knob('textBlur', params.textBlur, 0, 12, (v) {
          update(params.copyWith(textBlur: v));
        }),
      ],
    );
  }

  Widget _section(String name) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Text(name, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _knob(
    String name,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        SizedBox(width: 100, child: Text(name)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end),
        ),
      ],
    ),
  );
}

/// A made-up category for the lab, with its lots.
typedef _Shelf = ({String title, String category, List<PantryLot> lots});

PantryLot _lot(int id, String name, String unit, double initial, double left) =>
    PantryLot(
      id: id,
      name: name,
      unit: unit,
      source: PantrySource.initialStock,
      initialQuantity: initial,
      remainingQuantity: left,
      status: PantryLotStatus.active,
      addedAt: DateTime.utc(2026, 11, 20),
    );

final List<_Shelf> _shelves = [
  (
    title: 'Pane e pasta',
    category: 'Pane e pasta',
    lots: [
      _lot(1, 'SPAGHETTI N.5', 'pz', 2, 1.5),
      _lot(2, 'PANE CASERECCIO', 'kg', 0.5, 0.25),
      _lot(3, 'FUSILLI INTEGRALI', 'pz', 1, 1),
    ],
  ),
  (
    title: 'Latticini e uova',
    category: 'Latticini e uova',
    lots: [
      _lot(4, 'LATTE PS', 'l', 1, 0.5),
      _lot(5, 'UOVA FRESCHE X6', 'pz', 6, 4),
    ],
  ),
  (
    title: 'Frutta e verdura',
    category: 'Frutta e verdura',
    lots: [
      _lot(6, 'MELE GOLDEN', 'kg', 2, 1.5),
      _lot(7, 'ZUCCHINE', 'kg', 1, 0.6),
      _lot(8, 'BANANE', 'kg', 1.2, 0.3),
      _lot(9, 'POMODORI CILIEGINO', 'kg', 0.5, 0.5),
    ],
  ),
  (title: 'Bevande', category: 'Bevande', lots: [_lot(10, 'ACQUA', 'l', 9, 6)]),
];

/// Settings tile that opens the lab (debug builds only).
class PantryLabTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.inventory_2_outlined),
      title: Text(l10n.pantryLabTitle),
      subtitle: Text(l10n.pantryLabHint),
      onTap: () => context.push(Routes.pantryLab),
    );
  }
}
