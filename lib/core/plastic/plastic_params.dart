import 'package:flutter/foundation.dart';

/// What the plastic shader shows: the result, or one of its inputs (lab
/// only).
enum PlasticDebugView { result, normals, height, light }

/// Knobs of the plastic shader (`shaders/plastic_plate.frag`) and of the
/// plate's touch tilt: a hard PVC shelf label with a raised rim around a
/// glossy, recessed screen. Distances are in logical pixels.
///
/// The defaults are the look the app ships with; the plastic lab (debug
/// builds) tunes them on the phone.
@immutable
class PlasticParams {
  const new({
    this.rim = 3,
    this.bevel = 7,
    this.lip = 3,
    this.recess = 2.5,
    this.thickness = 5,
    this.ambient = 0.35,
    this.gloss = 0.3,
    this.shininess = 24,
    this.screenGloss = 0.55,
    this.screenShininess = 140,
    this.fresnel = 0.2,
    this.reflection = 0.25,
    this.grain = 0.25,
    this.shadow = 0.6,
    this.dropShadow = 0.28,
    this.dropBlur = 10,
    this.tilt = 0.14,
    this.perspective = 900,
    this.stiffness = 220,
    this.damping = 14,
    this.lift = 1.03,
    this.debugView = PlasticDebugView.result,
  });

  /// Reads [toJson]'s output. Missing or malformed knobs (an older save,
  /// a knob added later) keep their defaults.
  factory fromJson(Map<String, Object?> json) {
    const d = PlasticParams();
    double n(String key, double fallback) {
      final value = json[key];
      return value is num && value.isFinite ? value.toDouble() : fallback;
    }

    return PlasticParams(
      rim: n('rim', d.rim),
      bevel: n('bevel', d.bevel),
      lip: n('lip', d.lip),
      recess: n('recess', d.recess),
      thickness: n('thickness', d.thickness),
      ambient: n('ambient', d.ambient),
      gloss: n('gloss', d.gloss),
      shininess: n('shininess', d.shininess),
      screenGloss: n('screenGloss', d.screenGloss),
      screenShininess: n('screenShininess', d.screenShininess),
      fresnel: n('fresnel', d.fresnel),
      reflection: n('reflection', d.reflection),
      grain: n('grain', d.grain),
      shadow: n('shadow', d.shadow),
      dropShadow: n('dropShadow', d.dropShadow),
      dropBlur: n('dropBlur', d.dropBlur),
      tilt: n('tilt', d.tilt),
      perspective: n('perspective', d.perspective),
      stiffness: n('stiffness', d.stiffness),
      damping: n('damping', d.damping),
      lift: n('lift', d.lift),
    );
  }

  /// Height of the frame's rim above the table.
  final double rim;

  /// Width of the rounded outer edge, from the table up to the rim's top.
  final double bevel;

  /// Width of the inner slope from the rim down to the screen.
  final double lip;

  /// How far the screen sits below the rim.
  final double recess;

  /// Thickness of the plate's side wall, seen when it tilts.
  final double thickness;

  /// Light that reaches every point from all around (0 = only the lamp).
  final double ambient;

  /// Highlight strength on the frame's plastic.
  final double gloss;

  /// Highlight tightness on the frame (higher = smaller, harder plastic).
  final double shininess;

  /// Highlight strength on the screen's glossy cover.
  final double screenGloss;

  /// Highlight tightness on the screen's cover.
  final double screenShininess;

  /// Extra reflection at grazing angles (edges of the rim, tilted plate).
  final double fresnel;

  /// Soft reflection of the room (a bright window) that slides across the
  /// screen as the plate tilts.
  final double reflection;

  /// Orange-peel texture of moulded plastic.
  final double grain;

  /// Shadow the rim casts onto the recessed screen.
  final double shadow;

  /// Opacity of the shadow on the surface under the plate.
  final double dropShadow;

  /// Blur of that shadow.
  final double dropBlur;

  /// Most the plate tilts under a finger, radians.
  final double tilt;

  /// Eye distance for the tilt's perspective (smaller = stronger).
  final double perspective;

  /// Spring stiffness of the tilt: higher follows the finger faster.
  final double stiffness;

  /// Spring damping: low wobbles after release, high settles flat.
  final double damping;

  /// Scale while touched (Balatro-style lift).
  final double lift;

  /// Lab only: show an input of the shader instead of the result.
  final PlasticDebugView debugView;

  PlasticParams copyWith({
    double? rim,
    double? bevel,
    double? lip,
    double? recess,
    double? thickness,
    double? ambient,
    double? gloss,
    double? shininess,
    double? screenGloss,
    double? screenShininess,
    double? fresnel,
    double? reflection,
    double? grain,
    double? shadow,
    double? dropShadow,
    double? dropBlur,
    double? tilt,
    double? perspective,
    double? stiffness,
    double? damping,
    double? lift,
    PlasticDebugView? debugView,
  }) => PlasticParams(
    rim: rim ?? this.rim,
    bevel: bevel ?? this.bevel,
    lip: lip ?? this.lip,
    recess: recess ?? this.recess,
    thickness: thickness ?? this.thickness,
    ambient: ambient ?? this.ambient,
    gloss: gloss ?? this.gloss,
    shininess: shininess ?? this.shininess,
    screenGloss: screenGloss ?? this.screenGloss,
    screenShininess: screenShininess ?? this.screenShininess,
    fresnel: fresnel ?? this.fresnel,
    reflection: reflection ?? this.reflection,
    grain: grain ?? this.grain,
    shadow: shadow ?? this.shadow,
    dropShadow: dropShadow ?? this.dropShadow,
    dropBlur: dropBlur ?? this.dropBlur,
    tilt: tilt ?? this.tilt,
    perspective: perspective ?? this.perspective,
    stiffness: stiffness ?? this.stiffness,
    damping: damping ?? this.damping,
    lift: lift ?? this.lift,
    debugView: debugView ?? this.debugView,
  );

  /// The knobs by name (no debug view), for JSON and the lab's copy.
  Map<String, double> get _knobs => {
    'rim': rim,
    'bevel': bevel,
    'lip': lip,
    'recess': recess,
    'thickness': thickness,
    'ambient': ambient,
    'gloss': gloss,
    'shininess': shininess,
    'screenGloss': screenGloss,
    'screenShininess': screenShininess,
    'fresnel': fresnel,
    'reflection': reflection,
    'grain': grain,
    'shadow': shadow,
    'dropShadow': dropShadow,
    'dropBlur': dropBlur,
    'tilt': tilt,
    'perspective': perspective,
    'stiffness': stiffness,
    'damping': damping,
    'lift': lift,
  };

  /// The knobs as JSON, for saving. [debugView] is not saved.
  Map<String, Object> toJson() => Map.of(_knobs);

  /// Dart source for these values, to paste back as the new defaults.
  String toDart() {
    final fields = _knobs.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(2)}')
        .join(', ');
    return 'PlasticParams($fields)';
  }

  List<Object> get _fields => [..._knobs.values, debugView];

  @override
  bool operator ==(Object other) =>
      other is PlasticParams && listEquals(other._fields, _fields);

  @override
  int get hashCode => Object.hashAll(_fields);
}
