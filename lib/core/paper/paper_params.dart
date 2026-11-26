import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// How the content of a paper bubble is printed.
enum PaperInk {
  /// Content drawn normally on top of flat-lit paper (no bending).
  off,

  /// Monochrome thermal print: banding, missing dots, fading.
  thermal,

  /// The content's own colours, printed on the paper (multiply).
  colour,
}

/// What the shader shows: the result, or one of its inputs (lab only).
enum PaperDebugView { result, normals, height, light }

/// Knobs of the paper shader (`shaders/receipt_paper.frag`).
///
/// The defaults are the look the app ships with; the shader lab (debug
/// builds) tunes them on the phone.
@immutable
class PaperParams {
  const new({
    this.seed = 1,
    this.creases = 1,
    this.crumple = 1,
    this.depth = 1,
    this.ambient = 0.45,
    this.cavity = 0.6,
    this.sheen = 0.15,
    this.fibres = 1,
    this.edge = 0.45,
    this.levels = 0,
    this.pixel = 2,
    this.ink = PaperInk.thermal,
    this.warp = 2,
    this.inkFade = 0.05,
    this.lines = 0.2,
    this.dropout = 0.1,
    this.torn = 6,
    this.corner = 0,
    this.debugView = PaperDebugView.result,
  });

  /// Which crumple: the same seed always gives the same creases.
  final double seed;

  /// Long folds across the sheet (folded to fit a pocket).
  final double creases;

  /// Short creases in every direction (balled up, flattened again).
  final double crumple;

  /// How strongly the surface normals tilt (light and shadow contrast).
  final double depth;

  /// Light that reaches every face, whatever its tilt (0 = only direct).
  final double ambient;

  /// Darkening inside valleys.
  final double cavity;

  /// Glossy highlight of thermal paper.
  final double sheen;

  /// Paper fibre noise.
  final double fibres;

  /// Darker, yellowed edges and blotches.
  final double edge;

  /// 0 = smooth shading; otherwise that many grey levels, dithered (8-bit).
  final double levels;

  /// Size of a print dot and a dither cell, in logical pixels.
  final double pixel;

  /// How the content is printed. Where the backend can't run shader
  /// filters, it is drawn on top of the paper as [PaperInk.off].
  final PaperInk ink;

  /// How far the content shifts on the highest ridge, in logical pixels.
  final double warp;

  /// 0 = fresh print, 1 = almost gone (thermal).
  final double inkFade;

  /// Thermal print-head row banding.
  final double lines;

  /// Missing dots and vertical streaks from a dirty print head.
  final double dropout;

  /// Width of a tooth of the torn top and bottom edges, logical px (0 = cut
  /// straight).
  final double torn;

  /// Corner radius, logical px.
  final double corner;

  /// Lab only: show an input of the shader instead of the result.
  final PaperDebugView debugView;

  /// Seed of the fold surface.
  int get surfaceSeed => seed.round();

  PaperParams copyWith({
    double? seed,
    double? creases,
    double? crumple,
    double? depth,
    double? ambient,
    double? cavity,
    double? sheen,
    double? fibres,
    double? edge,
    double? levels,
    double? pixel,
    PaperInk? ink,
    double? warp,
    double? inkFade,
    double? lines,
    double? dropout,
    double? torn,
    double? corner,
    PaperDebugView? debugView,
  }) => PaperParams(
    seed: seed ?? this.seed,
    creases: creases ?? this.creases,
    crumple: crumple ?? this.crumple,
    depth: depth ?? this.depth,
    ambient: ambient ?? this.ambient,
    cavity: cavity ?? this.cavity,
    sheen: sheen ?? this.sheen,
    fibres: fibres ?? this.fibres,
    edge: edge ?? this.edge,
    levels: levels ?? this.levels,
    pixel: pixel ?? this.pixel,
    ink: ink ?? this.ink,
    warp: warp ?? this.warp,
    inkFade: inkFade ?? this.inkFade,
    lines: lines ?? this.lines,
    dropout: dropout ?? this.dropout,
    torn: torn ?? this.torn,
    corner: corner ?? this.corner,
    debugView: debugView ?? this.debugView,
  );

  /// Dart source for these values, to paste back as the new defaults.
  String toDart() {
    String n(double v) => v.toStringAsFixed(2);
    return 'PaperParams('
        'seed: ${n(seed)}, creases: ${n(creases)}, crumple: ${n(crumple)}, '
        'depth: ${n(depth)}, ambient: ${n(ambient)}, cavity: ${n(cavity)}, '
        'sheen: ${n(sheen)}, fibres: ${n(fibres)}, edge: ${n(edge)}, '
        'levels: ${n(levels)}, pixel: ${n(pixel)}, ink: PaperInk.${ink.name}, '
        'warp: ${n(warp)}, inkFade: ${n(inkFade)}, lines: ${n(lines)}, '
        'dropout: ${n(dropout)}, torn: ${n(torn)}, corner: ${n(corner)})';
  }

  @override
  bool operator ==(Object other) =>
      other is PaperParams &&
      other.seed == seed &&
      other.creases == creases &&
      other.crumple == crumple &&
      other.depth == depth &&
      other.ambient == ambient &&
      other.cavity == cavity &&
      other.sheen == sheen &&
      other.fibres == fibres &&
      other.edge == edge &&
      other.levels == levels &&
      other.pixel == pixel &&
      other.ink == ink &&
      other.warp == warp &&
      other.inkFade == inkFade &&
      other.lines == lines &&
      other.dropout == dropout &&
      other.torn == torn &&
      other.corner == corner &&
      other.debugView == debugView;

  @override
  int get hashCode => Object.hashAll([
    seed,
    creases,
    crumple,
    depth,
    ambient,
    cavity,
    sheen,
    fibres,
    edge,
    levels,
    pixel,
    ink,
    warp,
    inkFade,
    lines,
    dropout,
    torn,
    corner,
    debugView,
  ]);
}

/// Directional light over the paper, shared by every bubble on screen.
///
/// Today it is set by hand (lab); later it can follow the phone's tilt so
/// the light stays fixed in the room.
@immutable
class PaperLight {
  const new({this.azimuth = 2.2, this.elevation = 0.7});

  /// Where the light comes from in the screen plane, radians
  /// counter-clockwise from the right edge: π/2 = from the top.
  final double azimuth;

  /// Height of the light above the screen, radians (π/2 = straight above).
  final double elevation;

  /// Unit vector towards the light, in screen coordinates (x right, y down,
  /// z towards the viewer).
  (double, double, double) get direction {
    final flat = math.cos(elevation);
    return (
      flat * math.cos(azimuth),
      -flat * math.sin(azimuth),
      math.sin(elevation),
    );
  }

  PaperLight copyWith({double? azimuth, double? elevation}) => PaperLight(
    azimuth: azimuth ?? this.azimuth,
    elevation: elevation ?? this.elevation,
  );

  @override
  bool operator ==(Object other) =>
      other is PaperLight &&
      other.azimuth == azimuth &&
      other.elevation == elevation;

  @override
  int get hashCode => Object.hash(azimuth, elevation);
}
