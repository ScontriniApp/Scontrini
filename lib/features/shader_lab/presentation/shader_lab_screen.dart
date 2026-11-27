import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/paper/tilt_light.dart';
import 'package:scontrini/features/analytics/presentation/chart_palette.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Debug-only screen to tune the paper shader on the phone: a long receipt
/// or a gallery of UI components printed on paper on top, one slider per
/// knob below. Every change is saved ([paperSettingsProvider]) and used by
/// all paper UI in the app.
class ShaderLabScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ShaderLabScreen> createState() => _ShaderLabScreenState();
}

enum _Sample { receipt, components }

class _ShaderLabScreenState extends ConsumerState<ShaderLabScreen> {
  _Sample _sample = _Sample.receipt;

  /// Lab-only view of a shader input: never saved.
  PaperDebugView _debugView = PaperDebugView.result;
  bool _controls = true;
  final _random = math.Random();
  final _receiptScroll = ScrollController();

  /// Test: light from the real "up", following the phone's tilt.
  late final TiltLight _tilt = TiltLight(
    onLight: (light) => ref.read(paperLightProvider.notifier).set(light),
  );

  // Captured up front: `ref` can't be used in dispose.
  late final PaperSettingsNotifier _settings;
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(paperSettingsProvider.notifier);
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    unawaited(_tilt.stop());
    // Back to the saved light, and the last change on disk.
    _container.invalidate(paperLightProvider);
    unawaited(_settings.flush());
    _receiptScroll.dispose();
    super.dispose();
  }

  /// The saved knobs, with the lab's debug view.
  PaperParams get _params =>
      ref.read(paperSettingsProvider).params.copyWith(debugView: _debugView);

  void _update(PaperParams params) =>
      _settings.setParams(params.copyWith(debugView: PaperDebugView.result));

  // Each sample has its own print: thermal receipt, colour components.
  PaperInk get _ink => _sample == _Sample.receipt
      ? ref.read(paperSettingsProvider).params.ink
      : ref.read(paperSettingsProvider).componentInk;

  set _ink(PaperInk ink) => _sample == _Sample.receipt
      ? _settings.setReceiptInk(ink)
      : _settings.setComponentInk(ink);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final settings = ref.watch(paperSettingsProvider);
    final light = ref.watch(paperLightProvider);
    final setLight = _settings.setLight;

    final preview = switch (_sample) {
      // The side padding is the room the paper bleeds into.
      _Sample.receipt => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: PaperBubble(
              params: settings.receipt.copyWith(debugView: _debugView),
              controller: _receiptScroll,
              tilt: true,
              child: _SampleReceipt(controller: _receiptScroll),
            ),
          ),
        ),
      ),
      _Sample.components => _ComponentGallery(
        params: settings.component.copyWith(debugView: _debugView),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shaderLabTitle),
        actions: [
          IconButton(
            tooltip: l10n.shaderLabHideControls,
            icon: Icon(_controls ? Icons.fullscreen : Icons.tune),
            onPressed: () => setState(() => _controls = !_controls),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF5B5550),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<_Sample>(
                segments: [
                  ButtonSegment(
                    value: _Sample.receipt,
                    label: Text(l10n.shaderLabReceipt),
                  ),
                  ButtonSegment(
                    value: _Sample.components,
                    label: Text(l10n.shaderLabComponents),
                  ),
                ],
                selected: {_sample},
                onSelectionChanged: (s) => setState(() => _sample = s.single),
              ),
            ),
            Expanded(child: preview),
            if (_controls)
              Material(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (!PaperBubble.canPrint)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.info_outline),
                          title: Text(l10n.shaderLabInkUnsupported),
                        ),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.tonal(
                            onPressed: () => _update(
                              _params.copyWith(
                                seed: _random.nextInt(999) + 1.0,
                              ),
                            ),
                            child: Text(l10n.shaderLabNewSeed),
                          ),
                          OutlinedButton(
                            onPressed: _settings.reset,
                            child: Text(l10n.shaderLabReset),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: _params.copyWith(ink: _ink).toDart(),
                                ),
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
                      Center(
                        child: SegmentedButton<PaperInk>(
                          segments: [
                            ButtonSegment(
                              value: PaperInk.off,
                              label: Text(l10n.shaderLabInkOff),
                            ),
                            ButtonSegment(
                              value: PaperInk.thermal,
                              label: Text(l10n.shaderLabInkThermal),
                            ),
                            ButtonSegment(
                              value: PaperInk.colour,
                              label: Text(l10n.shaderLabInkColour),
                            ),
                          ],
                          selected: {_ink},
                          onSelectionChanged: (s) => _ink = s.single,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Shader inputs: developer names, not translated.
                      Center(
                        child: SegmentedButton<PaperDebugView>(
                          segments: [
                            for (final v in PaperDebugView.values)
                              ButtonSegment(value: v, label: Text(v.name)),
                          ],
                          selected: {_params.debugView},
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
                            // Back to the saved light.
                            ref.invalidate(paperLightProvider);
                          }
                          if (mounted) setState(() {});
                        },
                      ),
                      // Knob names match the shader uniforms (developer
                      // tool), so they aren't translated.
                      _knob('lightDir', light.azimuth, 0, 2 * math.pi, (v) {
                        setLight(light.copyWith(azimuth: v));
                      }),
                      _knob('lightUp', light.elevation, 0.1, math.pi / 2, (v) {
                        setLight(light.copyWith(elevation: v));
                      }),
                      _knob('lightDist', _params.lightDistance, 150, 5000, (v) {
                        _update(_params.copyWith(lightDistance: v));
                      }),
                      _knob('camDist', _params.cameraDistance, 300, 5000, (v) {
                        _update(_params.copyWith(cameraDistance: v));
                      }),
                      _knob('camTilt', _params.cameraTilt, 0, 1.2, (v) {
                        _update(_params.copyWith(cameraTilt: v));
                      }),
                      _knob('camTurn', _params.cameraTurn, 0, 2 * math.pi, (v) {
                        _update(_params.copyWith(cameraTurn: v));
                      }),
                      _knob('creases', _params.creases, 0, 3, (v) {
                        _update(_params.copyWith(creases: v));
                      }),
                      _knob('crumple', _params.crumple, 0, 3, (v) {
                        _update(_params.copyWith(crumple: v));
                      }),
                      _knob('sharpness', _params.sharpness, 0, 1, (v) {
                        _update(_params.copyWith(sharpness: v));
                      }),
                      _knob('depth', _params.depth, 0, 2, (v) {
                        _update(_params.copyWith(depth: v));
                      }),

                      _knob('ambient', _params.ambient, 0, 1, (v) {
                        _update(_params.copyWith(ambient: v));
                      }),
                      _knob('occlusion', _params.occlusion, 0, 1.5, (v) {
                        _update(_params.copyWith(occlusion: v));
                      }),
                      _knob('shadow', _params.shadow, 0, 1, (v) {
                        _update(_params.copyWith(shadow: v));
                      }),
                      _knob('softness', _params.softness, 0, 5, (v) {
                        _update(_params.copyWith(softness: v));
                      }),
                      _knob('sheen', _params.sheen, 0, 1, (v) {
                        _update(_params.copyWith(sheen: v));
                      }),
                      _knob('roughness', _params.roughness, 0, 1, (v) {
                        _update(_params.copyWith(roughness: v));
                      }),
                      _knob('fibres', _params.fibres, 0, 3, (v) {
                        _update(_params.copyWith(fibres: v));
                      }),
                      _knob('edge', _params.edge, 0, 1.5, (v) {
                        _update(_params.copyWith(edge: v));
                      }),
                      _knob('levels', _params.levels, 0, 8, divisions: 8, (v) {
                        _update(_params.copyWith(levels: v));
                      }),
                      _knob('pixel', _params.pixel, 1, 4, divisions: 6, (v) {
                        _update(_params.copyWith(pixel: v));
                      }),
                      _knob('inkFade', _params.inkFade, 0, 1, (v) {
                        _update(_params.copyWith(inkFade: v));
                      }),
                      _knob('lines', _params.lines, 0, 1, (v) {
                        _update(_params.copyWith(lines: v));
                      }),
                      _knob('dropout', _params.dropout, 0, 1, (v) {
                        _update(_params.copyWith(dropout: v));
                      }),
                      _knob('torn', _params.torn, 0, 16, (v) {
                        _update(_params.copyWith(torn: v));
                      }),
                      _knob('corner', _params.corner, 0, 24, (v) {
                        _update(_params.copyWith(corner: v));
                      }),
                      _knob('dropShadow', _params.dropShadow, 0, 1, (v) {
                        _update(_params.copyWith(dropShadow: v));
                      }),
                      _knob('dropBlur', _params.dropBlur, 0, 40, (v) {
                        _update(_params.copyWith(dropBlur: v));
                      }),
                      _knob('hover', _params.hover, 0, 40, (v) {
                        _update(_params.copyWith(hover: v));
                      }),
                      _knob('tilt', _params.tilt, 0, 0.4, (v) {
                        _update(_params.copyWith(tilt: v));
                      }),
                      _knob('perspective', _params.perspective, 200, 3000, (v) {
                        _update(_params.copyWith(perspective: v));
                      }),
                      _knob('stiffness', _params.stiffness, 40, 600, (v) {
                        _update(_params.copyWith(stiffness: v));
                      }),
                      _knob('damping', _params.damping, 2, 40, (v) {
                        _update(_params.copyWith(damping: v));
                      }),
                      _knob('lift', _params.lift, 1, 1.15, (v) {
                        _update(_params.copyWith(lift: v));
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

  Widget _knob(
    String name,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        SizedBox(width: 84, child: Text(name)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end),
        ),
      ],
    ),
  );
}

/// Made-up receipt to look at (no real store), long enough to scroll.
class _SampleReceipt extends StatelessWidget {
  const new({required this.controller});

  final ScrollController controller;

  static const _items = [
    ('LATTE INTERO 1L', '1,29'),
    ('PANE COMUNE', '2,10'),
    ('MELE GOLDEN KG 1,250', '2,48'),
    ('PASTA PENNE 500G', '0,89'),
    ('YOGURT BIANCO X2', '1,58'),
    ('SCONTO FEDELTA', '-0,30'),
    ('MOZZARELLA 125G', '0,99'),
    ('POMODORI PELATI 400G', '0,79'),
    ('OLIO EXTRA VERGINE 1L', '7,49'),
    ('CAFFE MACINATO 250G', '3,19'),
    ('BISCOTTI FROLLINI', '1,99'),
    ('ZUCCHINE KG 0,640', '1,53'),
    ('BANANE KG 1,120', '2,01'),
    ('PROSCIUTTO COTTO 100G', '2,35'),
    ('ACQUA NATURALE 6X1,5L', '1,74'),
    ('DETERSIVO PIATTI', '1,29'),
    ('CARTA IGIENICA X4', '2,49'),
    ('UOVA FRESCHE X6', '1,89'),
    ('BURRO 250G', '2,59'),
    ('PARMIGIANO 200G', '4,90'),
    ('INSALATA MISTA', '1,49'),
    ('SCONTO 3X2', '-0,79'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final body = text.titleMedium;
    Widget row(String left, String right, {TextStyle? style}) => Row(
      children: [
        Expanded(child: Text(left, style: style ?? body)),
        Text(right, style: style ?? body),
      ],
    );
    Widget centred(String line, [TextStyle? style]) =>
        Text(line, textAlign: TextAlign.center, style: style ?? body);
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          centred('MERCATO DEL CORSO', text.headlineSmall),
          centred('VIA ROMA 12 - TORINO'),
          centred('P.IVA 01234567890'),
          const SizedBox(height: 12),
          centred('DOCUMENTO COMMERCIALE'),
          centred('di vendita o prestazione'),
          const SizedBox(height: 12),
          row('DESCRIZIONE', 'EURO'),
          for (final (name, price) in _items) row(name, price),
          const SizedBox(height: 8),
          Text('-' * 40, maxLines: 1, overflow: TextOverflow.clip, style: body),
          row('TOTALE COMPLESSIVO', '47,98', style: text.titleLarge),
          row('PAGAMENTO CONTANTE', '50,00'),
          row('RESTO', '2,02'),
          const SizedBox(height: 12),
          centred('26-11-2026 18:42   DOC.N. 0042-0117'),
          centred('GRAZIE E ARRIVEDERCI'),
        ],
      ),
    );
  }
}

/// UI components (not only text) printed on paper bubbles, each with its
/// own creases.
class _ComponentGallery extends StatelessWidget {
  const new({required this.params});

  final PaperParams params;

  @override
  Widget build(BuildContext context) {
    final bubbles = [
      const _DonutSample(),
      const _PantrySample(),
      const _TotalSample(),
      const _IconSample(),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: bubbles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: PaperBubble(
            params: params.copyWith(seed: params.seed + i * 7),
            tilt: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: bubbles[i],
            ),
          ),
        ),
      ),
    );
  }
}

/// Category donut with percentages, like the dashboard's.
class _DonutSample extends StatelessWidget {
  const new();

  static const _slices = [
    ('Frutta e verdura', 32.0),
    ('Latticini', 21.0),
    ('Pane e pasta', 18.0),
    ('Carne e pesce', 17.0),
    ('Casa', 12.0),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SPESA DI NOVEMBRE', style: text.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                  sections: [
                    for (final (i, (_, share)) in _slices.indexed)
                      PieChartSectionData(
                        value: share,
                        color: ChartPalette.series(context, i),
                        radius: 38,
                        title: '${share.round()}%',
                        titleStyle: text.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              Text('412,30 €', style: text.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final (i, (name, share)) in _slices.indexed)
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: ChartPalette.series(context, i),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: text.titleMedium)),
              Text('${share.round()}%', style: text.titleMedium),
            ],
          ),
      ],
    );
  }
}

/// A pantry row: initials, name, 0-100 % left slider.
class _PantrySample extends StatefulWidget {
  const new();

  @override
  State<_PantrySample> createState() => _PantrySampleState();
}

class _PantrySampleState extends State<_PantrySample> {
  double _left = 0.6;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: ChartPalette.series(context, 1),
              child: const Text('LI', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Latte intero 1 l', style: text.titleLarge)),
            Text('${(_left * 100).round()} %', style: text.titleLarge),
          ],
        ),
        Slider(value: _left, onChanged: (v) => setState(() => _left = v)),
      ],
    );
  }
}

/// A big figure with a progress bar.
class _TotalSample extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUESTO MESE', style: text.titleMedium),
        Text('412,30 €', style: text.displaySmall),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.68,
          minHeight: 10,
          color: ChartPalette.series(context, 0),
          backgroundColor: Colors.black12,
        ),
        const SizedBox(height: 8),
        Text('+12 % rispetto al solito', style: text.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(onPressed: () {}, child: const Text('Corretto')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () {}, child: const Text('Correggi')),
          ],
        ),
      ],
    );
  }
}

/// Icons and an 8-bit sprite.
class _IconSample extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Image.asset(
          'assets/sprites/categories/pane_e_pasta.png',
          width: 64,
          height: 64,
          filterQuality: FilterQuality.none,
        ),
        const SizedBox(width: 16),
        Expanded(child: Text('Pane e pasta', style: text.titleLarge)),
        const Icon(Icons.shopping_cart, size: 32),
        const SizedBox(width: 8),
        Icon(Icons.eco, size: 32, color: ChartPalette.series(context, 2)),
      ],
    );
  }
}

/// Settings tile that opens the lab (debug builds only).
class ShaderLabTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.texture),
      title: Text(l10n.shaderLabTitle),
      subtitle: Text(l10n.shaderLabHint),
      onTap: () => context.push(Routes.shaderLab),
    );
  }
}
