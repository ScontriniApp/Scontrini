import 'package:flutter/foundation.dart';

/// What the recess shader shows: the result, or one of its inputs (lab
/// only).
enum RecessDebugView { result, normals, depth, light }

/// Knobs of the recessed well (`shaders/recessed_well.frag`): a drawer
/// carved into the app's background, with walls, a floor, the rim's shadow
/// on them, and content floating above the floor that casts its own
/// shadow. Distances are in logical pixels.
///
/// The defaults are the look the app ships with; the pantry lab (debug
/// builds) tunes them on the phone.
@immutable
class RecessParams {
  const new({
    this.depth = 22,
    this.closedDepth = 9,
    this.radius = 12,
    this.bevel = 3,
    this.eyeDistance = 900,
    this.eyeX = 0.5,
    this.eyeY = 0.45,
    this.ambient = 0.5,
    this.floorShade = 0.93,
    this.wallShade = 0.88,
    this.shadow = 0.6,
    this.softness = 0.35,
    this.occlusion = 0.3,
    this.highlight = 0.25,
    this.lift = 6,
    this.textShadow = 0.28,
    this.textBlur = 2,
    this.debugView = RecessDebugView.result,
  });

  /// Reads [toJson]'s output. Missing or malformed knobs (an older save,
  /// a knob added later) keep their defaults.
  factory fromJson(Map<String, Object?> json) {
    const d = RecessParams();
    double n(String key, double fallback) {
      final value = json[key];
      return value is num && value.isFinite ? value.toDouble() : fallback;
    }

    return RecessParams(
      depth: n('depth', d.depth),
      closedDepth: n('closedDepth', d.closedDepth),
      radius: n('radius', d.radius),
      bevel: n('bevel', d.bevel),
      eyeDistance: n('eyeDistance', d.eyeDistance),
      eyeX: n('eyeX', d.eyeX),
      eyeY: n('eyeY', d.eyeY),
      ambient: n('ambient', d.ambient),
      floorShade: n('floorShade', d.floorShade),
      wallShade: n('wallShade', d.wallShade),
      shadow: n('shadow', d.shadow),
      softness: n('softness', d.softness),
      occlusion: n('occlusion', d.occlusion),
      highlight: n('highlight', d.highlight),
      lift: n('lift', d.lift),
      textShadow: n('textShadow', d.textShadow),
      textBlur: n('textBlur', d.textBlur),
    );
  }

  /// How deep an open drawer goes below the background.
  final double depth;

  /// Depth of a closed drawer (a shallow tray holding its title).
  final double closedDepth;

  /// Corner radius of the opening.
  final double radius;

  /// Width of the rounded edge from the background down into the walls.
  final double bevel;

  /// Distance of the eye above the screen: smaller shows more of the walls
  /// (stronger perspective), very large looks straight down.
  final double eyeDistance;

  /// Where the eye is over the screen, as a share of its width (0 left).
  final double eyeX;

  /// Where the eye is over the screen, as a share of its height (0 top).
  final double eyeY;

  /// Light that reaches every point from all around (0 = only the lamp).
  final double ambient;

  /// Floor brightness against the background (1 = same colour).
  final double floorShade;

  /// Wall brightness against the background, before the lamp.
  final double wallShade;

  /// Strength of the shadow the rim casts into the drawer.
  final double shadow;

  /// Softness of that shadow (penumbra per pixel of depth).
  final double softness;

  /// Darkening where the floor meets the walls and down the walls.
  final double occlusion;

  /// Brightness of the edge that faces the lamp.
  final double highlight;

  /// Height of the content (text, icons) above the floor.
  final double lift;

  /// Opacity of the content's shadow on the floor.
  final double textShadow;

  /// Blur of the content's shadow.
  final double textBlur;

  /// Lab only: show an input of the shader instead of the result.
  final RecessDebugView debugView;

  RecessParams copyWith({
    double? depth,
    double? closedDepth,
    double? radius,
    double? bevel,
    double? eyeDistance,
    double? eyeX,
    double? eyeY,
    double? ambient,
    double? floorShade,
    double? wallShade,
    double? shadow,
    double? softness,
    double? occlusion,
    double? highlight,
    double? lift,
    double? textShadow,
    double? textBlur,
    RecessDebugView? debugView,
  }) => RecessParams(
    depth: depth ?? this.depth,
    closedDepth: closedDepth ?? this.closedDepth,
    radius: radius ?? this.radius,
    bevel: bevel ?? this.bevel,
    eyeDistance: eyeDistance ?? this.eyeDistance,
    eyeX: eyeX ?? this.eyeX,
    eyeY: eyeY ?? this.eyeY,
    ambient: ambient ?? this.ambient,
    floorShade: floorShade ?? this.floorShade,
    wallShade: wallShade ?? this.wallShade,
    shadow: shadow ?? this.shadow,
    softness: softness ?? this.softness,
    occlusion: occlusion ?? this.occlusion,
    highlight: highlight ?? this.highlight,
    lift: lift ?? this.lift,
    textShadow: textShadow ?? this.textShadow,
    textBlur: textBlur ?? this.textBlur,
    debugView: debugView ?? this.debugView,
  );

  /// The knobs by name (no debug view), for JSON and the lab's copy.
  Map<String, double> get _knobs => {
    'depth': depth,
    'closedDepth': closedDepth,
    'radius': radius,
    'bevel': bevel,
    'eyeDistance': eyeDistance,
    'eyeX': eyeX,
    'eyeY': eyeY,
    'ambient': ambient,
    'floorShade': floorShade,
    'wallShade': wallShade,
    'shadow': shadow,
    'softness': softness,
    'occlusion': occlusion,
    'highlight': highlight,
    'lift': lift,
    'textShadow': textShadow,
    'textBlur': textBlur,
  };

  /// The knobs as JSON, for saving. [debugView] is not saved.
  Map<String, Object> toJson() => Map.of(_knobs);

  /// Dart source for these values, to paste back as the new defaults.
  String toDart() {
    final fields = _knobs.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(2)}')
        .join(', ');
    return 'RecessParams($fields)';
  }

  List<Object> get _fields => [..._knobs.values, debugView];

  @override
  bool operator ==(Object other) =>
      other is RecessParams && listEquals(other._fields, _fields);

  @override
  int get hashCode => Object.hashAll(_fields);
}
