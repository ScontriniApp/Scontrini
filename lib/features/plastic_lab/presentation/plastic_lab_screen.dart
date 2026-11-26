import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/paper/tilt_light.dart';
import 'package:scontrini/core/plastic/plastic_params.dart';
import 'package:scontrini/core/plastic/plastic_plate.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shelf_label.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Debug-only screen to tune the plastic shelf label on the phone: the
/// [ShelfLabel] as a [PlasticPlate] on top (touch it to tilt it), one
/// slider per knob below. Every change is saved
/// ([plasticSettingsProvider]); the lamp is shared with the paper.
class PlasticLabScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PlasticLabScreen> createState() => _PlasticLabScreenState();
}

class _PlasticLabScreenState extends ConsumerState<PlasticLabScreen> {
  /// Lab-only view of a shader input: never saved.
  PlasticDebugView _debugView = PlasticDebugView.result;
  bool _controls = true;

  // Captured up front: `ref` can't be used in dispose.
  late final PlasticSettingsNotifier _settings;
  late final PaperSettingsNotifier _paper;
  late final ProviderContainer _container;

  /// Light from the real "up", following the phone's tilt.
  late final TiltLight _tilt = TiltLight(
    onLight: (light) => ref.read(paperLightProvider.notifier).set(light),
  );

  @override
  void initState() {
    super.initState();
    _settings = ref.read(plasticSettingsProvider.notifier);
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
    final params = ref.watch(plasticSettingsProvider);
    final light = ref.watch(paperLightProvider);
    void update(PlasticParams value) => _settings.set(value);

    final preview = ListView(
      // Room around the plate for its tilt, side wall and shadow.
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: PlasticPlate(
              params: params.copyWith(debugView: _debugView),
              screenInsets: ShelfLabel.screenInsets,
              child: ShelfLabel(
                title: 'Speso a novembre',
                cents: 41230,
                leading: '12 scontrini',
                footer: 'Di solito 368,40 € a questo punto del mese',
                corner: Text('+12%', style: ShelfLabel.smallStyle(context)),
                shadow: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.plasticLabTouchHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plasticLabTitle),
        actions: [
          IconButton(
            tooltip: l10n.shaderLabHideControls,
            icon: Icon(_controls ? Icons.fullscreen : Icons.tune),
            onPressed: () => setState(() => _controls = !_controls),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF6B6A66),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: preview),
            if (_controls)
              Material(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.42,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (!PlasticPlate.canShade)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.info_outline),
                          title: Text(l10n.plasticLabUnsupported),
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
                              await Clipboard.setData(
                                ClipboardData(text: params.toDart()),
                              );
                              messenger
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(content: Text(l10n.shaderLabCopied)),
                                );
                            },
                            child: Text(l10n.shaderLabCopy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Shader inputs: developer names, not translated.
                      Center(
                        child: SegmentedButton<PlasticDebugView>(
                          segments: [
                            for (final v in PlasticDebugView.values)
                              ButtonSegment(value: v, label: Text(v.name)),
                          ],
                          selected: {_debugView},
                          onSelectionChanged: (s) =>
                              setState(() => _debugView = s.single),
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
                      _section('shape'),
                      _knob('rim', params.rim, 0, 10, (v) {
                        update(params.copyWith(rim: v));
                      }),
                      _knob('bevel', params.bevel, 0.5, 16, (v) {
                        update(params.copyWith(bevel: v));
                      }),
                      _knob('lip', params.lip, 0.5, 10, (v) {
                        update(params.copyWith(lip: v));
                      }),
                      _knob('recess', params.recess, 0, 8, (v) {
                        update(params.copyWith(recess: v));
                      }),
                      _knob('thickness', params.thickness, 0, 12, (v) {
                        update(params.copyWith(thickness: v));
                      }),
                      _section('plastic'),
                      _knob('ambient', params.ambient, 0, 1, (v) {
                        update(params.copyWith(ambient: v));
                      }),
                      _knob('gloss', params.gloss, 0, 1.5, (v) {
                        update(params.copyWith(gloss: v));
                      }),
                      _knob('shininess', params.shininess, 2, 120, (v) {
                        update(params.copyWith(shininess: v));
                      }),
                      _knob('scrGloss', params.screenGloss, 0, 1.5, (v) {
                        update(params.copyWith(screenGloss: v));
                      }),
                      _knob('scrShine', params.screenShininess, 10, 400, (v) {
                        update(params.copyWith(screenShininess: v));
                      }),
                      _knob('fresnel', params.fresnel, 0, 1, (v) {
                        update(params.copyWith(fresnel: v));
                      }),
                      _knob('reflection', params.reflection, 0, 1, (v) {
                        update(params.copyWith(reflection: v));
                      }),
                      _knob('grain', params.grain, 0, 2, (v) {
                        update(params.copyWith(grain: v));
                      }),
                      _knob('shadow', params.shadow, 0, 1, (v) {
                        update(params.copyWith(shadow: v));
                      }),
                      _knob('dropShadow', params.dropShadow, 0, 0.8, (v) {
                        update(params.copyWith(dropShadow: v));
                      }),
                      _knob('dropBlur', params.dropBlur, 0, 30, (v) {
                        update(params.copyWith(dropBlur: v));
                      }),
                      _section('touch'),
                      _knob('tilt', params.tilt, 0, 0.5, (v) {
                        update(params.copyWith(tilt: v));
                      }),
                      _knob('perspective', params.perspective, 200, 3000, (v) {
                        update(params.copyWith(perspective: v));
                      }),
                      _knob('stiffness', params.stiffness, 20, 600, (v) {
                        update(params.copyWith(stiffness: v));
                      }),
                      _knob('damping', params.damping, 1, 60, (v) {
                        update(params.copyWith(damping: v));
                      }),
                      _knob('lift', params.lift, 1, 1.15, (v) {
                        update(params.copyWith(lift: v));
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
        SizedBox(width: 92, child: Text(name)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end),
        ),
      ],
    ),
  );
}

/// Settings tile that opens the lab (debug builds only).
class PlasticLabTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.crop_landscape),
      title: Text(l10n.plasticLabTitle),
      subtitle: Text(l10n.plasticLabHint),
      onTap: () => context.push(Routes.plasticLab),
    );
  }
}
