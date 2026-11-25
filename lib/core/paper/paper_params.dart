import 'package:flutter/foundation.dart';

/// Knobs of the crumpled-receipt shader (`shaders/receipt_paper.frag`).
///
/// The defaults are the look the app ships with; the shader lab (debug
/// builds) tunes them on the phone.
@immutable
class PaperParams {
  const new({
    this.seed = 1,
    this.cells = 5,
    this.depth = 0.55,
    this.fine = 0.35,
    this.lightAngle = 2.3,
    this.fibres = 1,
    this.edge = 0.45,
    this.levels = 0,
    this.pixel = 2,
    this.ink = true,
    this.warp = 1.5,
    this.inkFade = 0.05,
    this.lines = 0.2,
    this.dropout = 0.1,
  });

  /// Which crumple: the same seed always gives the same wrinkles.
  final double seed;

  /// Big facets across the width of the sheet.
  final double cells;

  /// How strongly the facets are tilted (light and shadow contrast).
  final double depth;

  /// Weight of the small wrinkles on top of the big facets.
  final double fine;

  /// Direction the light comes from, in radians.
  final double lightAngle;

  /// Paper fibre noise.
  final double fibres;

  /// Darker, yellowed edges and blotches.
  final double edge;

  /// 0 = smooth shading; otherwise that many grey levels, dithered (8-bit).
  final double levels;

  /// Size of a print dot and a dither cell, in logical pixels.
  final double pixel;

  /// Whether the text is printed by the shader (bent along the folds,
  /// banded, faded). Off, or where the backend can't, the text is drawn
  /// normally on top of the paper.
  final bool ink;

  /// How far the text shifts with the facet it sits on, in logical pixels.
  final double warp;

  /// 0 = fresh print, 1 = almost gone.
  final double inkFade;

  /// Thermal print-head row banding.
  final double lines;

  /// Missing dots and vertical streaks from a dirty print head.
  final double dropout;

  PaperParams copyWith({
    double? seed,
    double? cells,
    double? depth,
    double? fine,
    double? lightAngle,
    double? fibres,
    double? edge,
    double? levels,
    double? pixel,
    bool? ink,
    double? warp,
    double? inkFade,
    double? lines,
    double? dropout,
  }) => PaperParams(
    seed: seed ?? this.seed,
    cells: cells ?? this.cells,
    depth: depth ?? this.depth,
    fine: fine ?? this.fine,
    lightAngle: lightAngle ?? this.lightAngle,
    fibres: fibres ?? this.fibres,
    edge: edge ?? this.edge,
    levels: levels ?? this.levels,
    pixel: pixel ?? this.pixel,
    ink: ink ?? this.ink,
    warp: warp ?? this.warp,
    inkFade: inkFade ?? this.inkFade,
    lines: lines ?? this.lines,
    dropout: dropout ?? this.dropout,
  );

  /// Dart source for these values, to paste back as the new defaults.
  String toDart() {
    String n(double v) => v.toStringAsFixed(2);
    return 'PaperParams('
        'seed: ${n(seed)}, cells: ${n(cells)}, depth: ${n(depth)}, '
        'fine: ${n(fine)}, lightAngle: ${n(lightAngle)}, '
        'fibres: ${n(fibres)}, edge: ${n(edge)}, levels: ${n(levels)}, '
        'pixel: ${n(pixel)}, ink: $ink, warp: ${n(warp)}, '
        'inkFade: ${n(inkFade)}, lines: ${n(lines)}, '
        'dropout: ${n(dropout)})';
  }

  @override
  bool operator ==(Object other) =>
      other is PaperParams &&
      other.seed == seed &&
      other.cells == cells &&
      other.depth == depth &&
      other.fine == fine &&
      other.lightAngle == lightAngle &&
      other.fibres == fibres &&
      other.edge == edge &&
      other.levels == levels &&
      other.pixel == pixel &&
      other.ink == ink &&
      other.warp == warp &&
      other.inkFade == inkFade &&
      other.lines == lines &&
      other.dropout == dropout;

  @override
  int get hashCode => Object.hash(
    seed,
    cells,
    depth,
    fine,
    lightAngle,
    fibres,
    edge,
    levels,
    pixel,
    ink,
    warp,
    inkFade,
    lines,
    dropout,
  );
}
