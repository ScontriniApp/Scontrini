import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/paper/receipt_paper.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Debug-only screen to tune the crumpled receipt shader on the phone: a
/// sample receipt on top, one slider per shader knob below.
class ShaderLabScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ShaderLabScreen> createState() => _ShaderLabScreenState();
}

class _ShaderLabScreenState extends State<ShaderLabScreen> {
  PaperParams _params = const PaperParams();
  bool _controls = true;
  final _random = math.Random();

  void _update(PaperParams params) => setState(() => _params = params);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final receipt = ReceiptPaper(
      params: _params,
      child: const _SampleReceipt(),
    );
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: receipt,
                  ),
                ),
              ),
            ),
            if (_controls)
              Material(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (!ReceiptPaper.canPrintInk)
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
                            onPressed: () => _update(const PaperParams()),
                            child: Text(l10n.shaderLabReset),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _params.toDart()),
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
                      SwitchListTile(
                        dense: true,
                        title: Text(l10n.shaderLabInk),
                        value: _params.ink,
                        onChanged: (v) => _update(_params.copyWith(ink: v)),
                      ),
                      // Knob names match the shader uniforms (developer
                      // tool), so they aren't translated.
                      _knob('cells', _params.cells, 1, 14, (v) {
                        _update(_params.copyWith(cells: v));
                      }),
                      _knob('depth', _params.depth, 0, 1.5, (v) {
                        _update(_params.copyWith(depth: v));
                      }),
                      _knob('contrast', _params.contrast, 0, 3, (v) {
                        _update(_params.copyWith(contrast: v));
                      }),
                      _knob('tooth', _params.tooth, 0, 16, (v) {
                        _update(_params.copyWith(tooth: v));
                      }),
                      _knob('round', _params.round, 0, 0.4, (v) {
                        _update(_params.copyWith(round: v));
                      }),
                      _knob('fine', _params.fine, 0, 1, (v) {
                        _update(_params.copyWith(fine: v));
                      }),
                      _knob('light', _params.lightAngle, 0, 2 * math.pi, (v) {
                        _update(_params.copyWith(lightAngle: v));
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
                      _knob('warp', _params.warp, 0, 6, (v) {
                        _update(_params.copyWith(warp: v));
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
        SizedBox(width: 72, child: Text(name)),
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

/// Made-up receipt to look at (no real store).
class _SampleReceipt extends StatelessWidget {
  const new();

  static const _items = [
    ('LATTE INTERO 1L', '1,29'),
    ('PANE COMUNE', '2,10'),
    ('MELE GOLDEN KG 1,250', '2,48'),
    ('PASTA PENNE 500G', '0,89'),
    ('YOGURT BIANCO X2', '1,58'),
    ('SCONTO FEDELTA', '-0,30'),
    ('MOZZARELLA 125G', '0,99'),
    ('BANANE KG 0,980', '1,76'),
    ('UOVA FRESCHE X6', '2,39'),
    ('ACQUA NATURALE 6X1,5L', '1,98'),
    ('CAFFE MACINATO 250G', '3,49'),
    ('BISCOTTI FROLLINI', '1,85'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MERCATO DEL CORSO',
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          Text(
            'VIA ROMA 12 - TORINO',
            textAlign: TextAlign.center,
            style: body,
          ),
          Text('P.IVA 01234567890', textAlign: TextAlign.center, style: body),
          const SizedBox(height: 12),
          Text(
            'DOCUMENTO COMMERCIALE',
            textAlign: TextAlign.center,
            style: body,
          ),
          Text(
            'di vendita o prestazione',
            textAlign: TextAlign.center,
            style: body,
          ),
          const SizedBox(height: 12),
          row('DESCRIZIONE', 'EURO'),
          for (final (name, price) in _items) row(name, price),
          const SizedBox(height: 8),
          Text('-' * 40, maxLines: 1, overflow: TextOverflow.clip, style: body),
          row('TOTALE COMPLESSIVO', '20,50', style: text.titleLarge),
          row('PAGAMENTO CONTANTE', '25,00'),
          row('RESTO', '4,50'),
          const SizedBox(height: 12),
          Text(
            '26-11-2026 18:42   DOC.N. 0042-0117',
            textAlign: TextAlign.center,
            style: body,
          ),
          Text(
            'GRAZIE E ARRIVEDERCI',
            textAlign: TextAlign.center,
            style: body,
          ),
        ],
      ),
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
