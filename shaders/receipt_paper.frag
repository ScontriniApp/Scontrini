// Crumpled thermal-receipt paper, with the text "printed" on it.
//
// Two uses, one file:
// - ImageFilter.shader over the real text widgets (uInk = 1): the engine
//   binds the rendered child (dark text on white) to uTexture and its size to
//   uSize. The text becomes ink that follows the creases.
// - CustomPaint behind the text (uInk = 0), where shader image filters are
//   not supported (Skia): paper only, uTexture is a dummy.
//
// Creases: two layers of short straight folds (ridges and valleys), big and
// small, summed into a slope that is lit from one side (a sheet balled up
// and flattened again). Everything is deterministic for a given uSeed.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;        // set by the engine for image filters
uniform float uSeed;
uniform float uCells;      // big folds across the width
uniform float uDepth;      // how deep the folds are (light contrast)
uniform float uFine;       // weight of the small wrinkle layer
uniform float uLightAngle; // radians, direction the light comes from
uniform float uFibres;     // paper fibre noise
uniform float uEdge;       // darker, yellowed edges
uniform float uLevels;     // 0 = smooth; else grey levels, Bayer dithered
uniform float uPixel;      // dither / quantise cell size, physical px
uniform float uInk;        // 0 = paper only, 1 = composite the text
uniform float uWarp;       // text displacement along the folds, px
uniform float uInkFade;    // 0 = fresh print, 1 = very faded
uniform float uLines;      // thermal print-head row banding
uniform float uDropout;    // missing dots and vertical head streaks
uniform float uRound;      // crease rounding, in big-fold cells (0 = sharp)

uniform sampler2D uTexture;

out vec4 fragColor;

const vec3 kPaper = vec3(0.985, 0.972, 0.935);
const vec3 kAged = vec3(0.90, 0.85, 0.72);
const vec3 kInk = vec3(0.13, 0.12, 0.16);

vec2 hash2(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p + uSeed * 17.13) * 43758.5453);
}

float hash1(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233)) + uSeed * 3.7) * 43758.5453);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash1(i);
  float b = hash1(i + vec2(1.0, 0.0));
  float c = hash1(i + vec2(0.0, 1.0));
  float d = hash1(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float sum = 0.0;
  float amp = 0.5;
  for (int i = 0; i < 4; i++) {
    sum += amp * valueNoise(p);
    p *= 2.03;
    amp *= 0.5;
  }
  return sum;
}

// One layer of folds. Every grid cell holds one straight fold: a line with a
// random direction through a random point, a ridge or a valley, fading out
// along its length and away from it. Height of one fold:
//   h = s * r(across) * w,  w = exp(-along^2 / A - across^2 / B)
// where r is a rounded |x|: sqrt(x^2 + R^2) - R (R = 0 gives a sharp crease).
// Returns the slope of the summed height (xy) and how close the point is to
// a crease line (z, 0..1).
vec3 folds(vec2 q, float R) {
  vec2 cell = floor(q);
  vec2 slope = vec2(0.0);
  float crease = 0.0;
  const float A = 0.55; // length of a fold, cells^2
  const float B = 0.35; // reach of a fold's slope, cells^2
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 id = cell + vec2(float(x), float(y));
      vec2 local = q - (id + hash2(id));
      float angle = hash1(id + 3.1) * 6.2831853;
      vec2 t = vec2(cos(angle), sin(angle));
      vec2 n = vec2(-t.y, t.x);
      float along = dot(local, t);
      float across = dot(local, n);
      float w = exp(-along * along / A - across * across / B);
      float s = hash1(id + 7.7) * 2.0 - 1.0;
      vec2 gradW = w * (-2.0 * along / A * t - 2.0 * across / B * n);
      float bend = sqrt(across * across + R * R);
      slope += s * (across / max(bend, 1e-4) * n * w + (bend - R) * gradW);
      // The pinch line widens and fades as the crease gets rounder.
      float line = 1.0 - smoothstep(0.0, 0.03 + R, abs(across));
      crease = max(crease, w * abs(s) * line * (0.03 / (0.03 + R)));
    }
  }
  return vec3(slope, crease);
}

float bayer2(vec2 a) {
  a = floor(a);
  return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

float bayer4(vec2 a) {
  return bayer2(0.5 * a) * 0.25 + bayer2(a);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;
#ifdef IMPELLER_TARGET_OPENGLES
  if (uInk > 0.5) {
    uv.y = 1.0 - uv.y;
  }
#endif
  // Aspect-correct paper coordinates: 1.0 = the width.
  vec2 p = vec2(uv.x, uv.y * uSize.y / uSize.x);

  // --- Creases -----------------------------------------------------------
  vec3 big = folds(p * uCells, uRound);
  vec3 small = folds(p * uCells * 3.3 + 11.0, uRound);
  // Slope of the paper, in "height per cell of the big layer".
  vec2 tilt = (big.xy + small.xy * uFine * 0.5) * uDepth;
  vec3 normal = normalize(vec3(-tilt, 1.0));

  // Low, raking light so small slopes show.
  vec3 light = normalize(vec3(cos(uLightAngle), sin(uLightAngle), 0.9));
  float diffuse = dot(normal, light);
  // Flat paper faces the light at light.z: that is the base shade, a little
  // under 1 so lit slopes still have room before white.
  float shade = 0.94 + (diffuse - light.z) * 1.1;

  // A thin line along each crease, where the paper was pinched.
  shade -= (big.z * 0.07 + small.z * 0.04 * uFine) * min(uDepth, 1.0);

  // --- Paper -------------------------------------------------------------
  float fibres = fbm(vec2(p.x * 220.0, p.y * 40.0)) - 0.5;
  shade += fibres * 0.06 * uFibres;

  vec2 centred = uv - 0.5;
  float edge = smoothstep(0.25, 0.75, length(centred * vec2(1.6, 1.0)));
  float blotch = fbm(p * 3.0 + 5.0);
  vec3 paper = mix(kPaper, kAged, clamp(edge * uEdge + blotch * 0.25 * uEdge, 0.0, 1.0));

  if (uLevels > 0.5) {
    vec2 cell = floor(frag / max(uPixel, 1.0));
    float threshold = bayer4(cell) - 0.5;
    shade = floor(shade * uLevels + threshold + 0.5) / uLevels;
  }

  vec3 color = paper * clamp(shade, 0.0, 1.2);

  // --- Ink ---------------------------------------------------------------
  if (uInk > 0.5) {
    // Text follows the slope it sits on, so it breaks slightly at creases.
    // Flat paper (depth 0) means straight text.
    vec2 shift = tilt * uWarp / uSize;
#ifdef IMPELLER_TARGET_OPENGLES
    shift.y = -shift.y;
#endif
    vec3 src = texture(uTexture, uv + shift).rgb;
    float ink = clamp(1.0 - dot(src, vec3(0.299, 0.587, 0.114)), 0.0, 1.0);
    // Thermal dots bleed: push antialiased edges to full ink (bolder text).
    ink = clamp(ink * 1.8, 0.0, 1.0);

    // Thermal head prints rows of dots: faint banding every other row.
    float row = mod(floor(frag.y / max(uPixel, 1.0)), 2.0);
    ink *= 1.0 - row * 0.25 * uLines;

    // Dirty head: vertical streaks, plus random missing dots.
    float streak = valueNoise(vec2(frag.x * 0.35, uSeed));
    float dots = hash1(floor(frag / max(uPixel, 1.0)));
    ink *= 1.0 - uDropout * (smoothstep(0.75, 0.95, streak) * 0.7 +
                             step(1.0 - 0.25 * uDropout, dots));

    // Fading: overall, and unevenly over the sheet.
    float fade = 0.7 * uInkFade * (0.55 + 0.45 * fbm(p * 4.0 + 2.0));
    ink *= 1.0 - fade;

    // Ink is darker in the shadows of the creases, like the paper.
    vec3 inkColor = kInk * clamp(shade, 0.6, 1.1);
    color = mix(color, inkColor, ink);
  }

  fragColor = vec4(color, 1.0);
}
