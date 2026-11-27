import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:scontrini/core/tilt/plate_motion.dart';

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

/// Knobs of the paper shader (`shaders/receipt_paper.frag`): the folded
/// sheet, the camera looking at it and the lamp lighting it. Distances are
/// in logical pixels (about 0.16 mm each).
///
/// The defaults are the look the app ships with; the shader lab (debug
/// builds) tunes them on the phone.
@immutable
class PaperParams implements TiltKnobs {
  const new({
    this.seed = 1,
    this.creases = 1,
    this.crumple = 1,
    this.sharpness = 0.85,
    this.depth = 0.5,
    this.lightDistance = 1500,
    this.cameraDistance = 1800,
    this.cameraTilt = 0.3,
    this.cameraTurn = math.pi / 2,
    this.ambient = 0.3,
    this.occlusion = 0.8,
    this.shadow = 0.8,
    this.softness = 1,
    this.sheen = 0.08,
    this.roughness = 0.6,
    this.fibres = 1,
    this.edge = 0.45,
    this.levels = 0,
    this.pixel = 2,
    this.ink = PaperInk.thermal,
    this.inkFade = 0.05,
    this.lines = 0.2,
    this.dropout = 0.1,
    this.torn = 6,
    this.corner = 0,
    this.dropShadow = 0.22,
    this.dropBlur = 8,
    this.hover = 3,
    this.tilt = 0.14,
    this.perspective = 900,
    this.stiffness = 220,
    this.damping = 14,
    this.lift = 1.03,
    this.debugView = PaperDebugView.result,
  });

  /// Reads [toJson]'s output. Missing or malformed knobs (an older save,
  /// a knob added later) keep their defaults.
  factory fromJson(Map<String, Object?> json) {
    const d = PaperParams();
    double n(String key, double fallback) {
      final value = json[key];
      return value is num && value.isFinite ? value.toDouble() : fallback;
    }

    return PaperParams(
      seed: n('seed', d.seed),
      creases: n('creases', d.creases),
      crumple: n('crumple', d.crumple),
      sharpness: n('sharpness', d.sharpness),
      depth: n('depth', d.depth),
      lightDistance: n('lightDistance', d.lightDistance),
      cameraDistance: n('cameraDistance', d.cameraDistance),
      cameraTilt: n('cameraTilt', d.cameraTilt),
      cameraTurn: n('cameraTurn', d.cameraTurn),
      ambient: n('ambient', d.ambient),
      occlusion: n('occlusion', d.occlusion),
      shadow: n('shadow', d.shadow),
      softness: n('softness', d.softness),
      sheen: n('sheen', d.sheen),
      roughness: n('roughness', d.roughness),
      fibres: n('fibres', d.fibres),
      edge: n('edge', d.edge),
      levels: n('levels', d.levels),
      pixel: n('pixel', d.pixel),
      ink: PaperInk.values.asNameMap()[json['ink']] ?? d.ink,
      inkFade: n('inkFade', d.inkFade),
      lines: n('lines', d.lines),
      dropout: n('dropout', d.dropout),
      torn: n('torn', d.torn),
      corner: n('corner', d.corner),
      dropShadow: n('dropShadow', d.dropShadow),
      dropBlur: n('dropBlur', d.dropBlur),
      hover: n('hover', d.hover),
      tilt: n('tilt', d.tilt),
      perspective: n('perspective', d.perspective),
      stiffness: n('stiffness', d.stiffness),
      damping: n('damping', d.damping),
      lift: n('lift', d.lift),
    );
  }

  /// Which crumple: the same seed always gives the same creases.
  final double seed;

  /// Long folds across the sheet (folded to fit a pocket).
  final double creases;

  /// Short creases in every direction (balled up, flattened again).
  final double crumple;

  /// How knife-edged the creases are: 0 rounded, 1 sharp.
  final double sharpness;

  /// Relief of the sheet: scales every height and slope of the folds.
  final double depth;

  /// How far the lamp is from the bubble's centre: close gives a pool of
  /// light that fades towards the edges, far an even light.
  final double lightDistance;

  /// How far the eye is from the sheet: closer means stronger perspective.
  final double cameraDistance;

  /// Angle between the eye and straight above, radians: tilted, the print
  /// slides and foreshortens over the folds and hides behind steep ridges.
  final double cameraTilt;

  /// Which side the eye leans to, radians (x right, y down): π/2 = from the
  /// bottom edge, like a phone held in the hand.
  final double cameraTurn;

  /// Light that reaches every point from all around (0 = only the lamp).
  final double ambient;

  /// How much valleys and the foot of ridges block that ambient light.
  final double occlusion;

  /// Strength of the shadows ridges cast away from the lamp.
  final double shadow;

  /// Width of the shadows' soft edge.
  final double softness;

  /// Glossy highlight of thermal paper.
  final double sheen;

  /// Paper grain: 0 smooth and glossy, 1 coarse and matte (bumpier
  /// normals, wider and fainter highlight).
  final double roughness;

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

  /// Opacity of the shadow the sheet casts on the surface under it.
  final double dropShadow;

  /// Blur of that shadow.
  final double dropBlur;

  /// How high the sheet sits above that surface, logical px: how far the
  /// shadow falls from it (more while lifted).
  final double hover;

  /// Most the sheet tilts under a finger, radians (bubbles with
  /// `PaperBubble.tilt` only; 0 = never).
  @override
  final double tilt;

  @override
  final double perspective;

  @override
  final double stiffness;

  @override
  final double damping;

  @override
  final double lift;

  /// Lab only: show an input of the shader instead of the result.
  final PaperDebugView debugView;

  /// Seed of the fold surface.
  int get surfaceSeed => seed.round();

  /// The eye relative to the bubble's centre, logical px (x right, y down,
  /// z towards the viewer).
  (double, double, double) get camera {
    final lean = cameraDistance * math.sin(cameraTilt);
    return (
      lean * math.cos(cameraTurn),
      lean * math.sin(cameraTurn),
      cameraDistance * math.cos(cameraTilt),
    );
  }

  PaperParams copyWith({
    double? seed,
    double? creases,
    double? crumple,
    double? sharpness,
    double? depth,
    double? lightDistance,
    double? cameraDistance,
    double? cameraTilt,
    double? cameraTurn,
    double? ambient,
    double? occlusion,
    double? shadow,
    double? softness,
    double? sheen,
    double? roughness,
    double? fibres,
    double? edge,
    double? levels,
    double? pixel,
    PaperInk? ink,
    double? inkFade,
    double? lines,
    double? dropout,
    double? torn,
    double? corner,
    double? dropShadow,
    double? dropBlur,
    double? hover,
    double? tilt,
    double? perspective,
    double? stiffness,
    double? damping,
    double? lift,
    PaperDebugView? debugView,
  }) => PaperParams(
    seed: seed ?? this.seed,
    creases: creases ?? this.creases,
    crumple: crumple ?? this.crumple,
    sharpness: sharpness ?? this.sharpness,
    depth: depth ?? this.depth,
    lightDistance: lightDistance ?? this.lightDistance,
    cameraDistance: cameraDistance ?? this.cameraDistance,
    cameraTilt: cameraTilt ?? this.cameraTilt,
    cameraTurn: cameraTurn ?? this.cameraTurn,
    ambient: ambient ?? this.ambient,
    occlusion: occlusion ?? this.occlusion,
    shadow: shadow ?? this.shadow,
    softness: softness ?? this.softness,
    sheen: sheen ?? this.sheen,
    roughness: roughness ?? this.roughness,
    fibres: fibres ?? this.fibres,
    edge: edge ?? this.edge,
    levels: levels ?? this.levels,
    pixel: pixel ?? this.pixel,
    ink: ink ?? this.ink,
    inkFade: inkFade ?? this.inkFade,
    lines: lines ?? this.lines,
    dropout: dropout ?? this.dropout,
    torn: torn ?? this.torn,
    corner: corner ?? this.corner,
    dropShadow: dropShadow ?? this.dropShadow,
    dropBlur: dropBlur ?? this.dropBlur,
    hover: hover ?? this.hover,
    tilt: tilt ?? this.tilt,
    perspective: perspective ?? this.perspective,
    stiffness: stiffness ?? this.stiffness,
    damping: damping ?? this.damping,
    lift: lift ?? this.lift,
    debugView: debugView ?? this.debugView,
  );

  List<Object> get _fields => [
    seed,
    creases,
    crumple,
    sharpness,
    depth,
    lightDistance,
    cameraDistance,
    cameraTilt,
    cameraTurn,
    ambient,
    occlusion,
    shadow,
    softness,
    sheen,
    roughness,
    fibres,
    edge,
    levels,
    pixel,
    ink,
    inkFade,
    lines,
    dropout,
    torn,
    corner,
    dropShadow,
    dropBlur,
    hover,
    tilt,
    perspective,
    stiffness,
    damping,
    lift,
    debugView,
  ];

  /// The knobs as JSON, for saving. [debugView] is a lab-only view and is
  /// not saved.
  Map<String, Object> toJson() => {
    'seed': seed,
    'creases': creases,
    'crumple': crumple,
    'sharpness': sharpness,
    'depth': depth,
    'lightDistance': lightDistance,
    'cameraDistance': cameraDistance,
    'cameraTilt': cameraTilt,
    'cameraTurn': cameraTurn,
    'ambient': ambient,
    'occlusion': occlusion,
    'shadow': shadow,
    'softness': softness,
    'sheen': sheen,
    'roughness': roughness,
    'fibres': fibres,
    'edge': edge,
    'levels': levels,
    'pixel': pixel,
    'ink': ink.name,
    'inkFade': inkFade,
    'lines': lines,
    'dropout': dropout,
    'torn': torn,
    'corner': corner,
    'dropShadow': dropShadow,
    'dropBlur': dropBlur,
    'hover': hover,
    'tilt': tilt,
    'perspective': perspective,
    'stiffness': stiffness,
    'damping': damping,
    'lift': lift,
  };

  /// Dart source for these values, to paste back as the new defaults.
  String toDart() {
    String n(double v) => v.toStringAsFixed(2);
    return 'PaperParams('
        'seed: ${n(seed)}, creases: ${n(creases)}, crumple: ${n(crumple)}, '
        'sharpness: ${n(sharpness)}, depth: ${n(depth)}, '
        'lightDistance: ${n(lightDistance)}, '
        'cameraDistance: ${n(cameraDistance)}, '
        'cameraTilt: ${n(cameraTilt)}, cameraTurn: ${n(cameraTurn)}, '
        'ambient: ${n(ambient)}, occlusion: ${n(occlusion)}, '
        'shadow: ${n(shadow)}, softness: ${n(softness)}, '
        'sheen: ${n(sheen)}, roughness: ${n(roughness)}, '
        'fibres: ${n(fibres)}, edge: ${n(edge)}, '
        'levels: ${n(levels)}, pixel: ${n(pixel)}, ink: PaperInk.${ink.name}, '
        'inkFade: ${n(inkFade)}, lines: ${n(lines)}, '
        'dropout: ${n(dropout)}, torn: ${n(torn)}, corner: ${n(corner)}, '
        'dropShadow: ${n(dropShadow)}, dropBlur: ${n(dropBlur)}, '
        'hover: ${n(hover)}, tilt: ${n(tilt)}, '
        'perspective: ${n(perspective)}, stiffness: ${n(stiffness)}, '
        'damping: ${n(damping)}, lift: ${n(lift)})';
  }

  @override
  bool operator ==(Object other) =>
      other is PaperParams && listEquals(other._fields, _fields);

  @override
  int get hashCode => Object.hashAll(_fields);
}

/// Where the lamp over the paper is, shared by every bubble on screen.
///
/// Set by hand in the lab, or by `TiltLight` so the lamp stays above, in
/// the room, while the phone tilts.
@immutable
class PaperLight {
  const new({this.azimuth = 2.2, this.elevation = 0.7});

  /// Reads [toJson]'s output; missing values keep their defaults.
  factory fromJson(Map<String, Object?> json) {
    const d = PaperLight();
    double n(String key, double fallback) {
      final value = json[key];
      return value is num && value.isFinite ? value.toDouble() : fallback;
    }

    return PaperLight(
      azimuth: n('azimuth', d.azimuth),
      elevation: n('elevation', d.elevation),
    );
  }

  /// Light from "up" given in the phone's sensor axes (x right, y towards
  /// the top edge, z out of the screen), e.g. the accelerometer at rest.
  /// The light never drops below [minElevation], so a phone held upright
  /// still lights the sheet. Null for a zero vector (free fall).
  static PaperLight? fromUp(
    double x,
    double y,
    double z, {
    double minElevation = 0.15,
  }) {
    final length = math.sqrt(x * x + y * y + z * z);
    if (length < 1e-6) return null;
    final elevation = math.asin((z / length).clamp(-1.0, 1.0));
    return PaperLight(
      azimuth: math.atan2(y, x),
      elevation: math.max(elevation, minElevation),
    );
  }

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

  Map<String, Object> toJson() => {'azimuth': azimuth, 'elevation': elevation};

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
