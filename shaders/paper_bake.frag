// Bakes a folded sheet's MATERIAL once, for paper_print.frag to light on
// every frame. The scene is the one of receipt_paper.frag (height field from
// the fold map, perspective camera ray-marched into it, rough paper, fibres,
// ageing), computed for the whole sheet when the paper or the sheet change.
// Nothing here depends on the lamp: the print shader lights the sheet per
// frame, so a moving lamp (the tilt light, a tilted sheet) never re-bakes.
//
// Drawn four times into opaque images covering the sheet plus its bleed, in
// logical px (uBakeScale image px each), all for the point the camera ray
// through this pixel hits:
// - pass 0 (surface): R, G the normal's x, y (-1..1 -> 0..1); B the fibre
//   noise (-0.5..0.5 -> 0..1); A how aged the paper is (sides, top,
//   blotches);
// - pass 1 (offset): R, G where the ray lands, relative to the point
//   (-uReach..uReach -> 0..1); B the thermal ink's strength there (banding,
//   missing dots, fading); A the height hit (-top..top -> 0..1);
// - pass 2, 3 (horizon, half resolution): how high the relief rises around
//   the point, in six directions 60 degrees apart (pass 2: 0, 60, 120;
//   pass 3: 180, 240, 300), as an elevation angle (0..pi/2 -> 0..1). A lamp
//   lower than that horizon is hidden: the cast shadow. Pass 2's A is the
//   ambient occlusion (0 open .. 1 enclosed).
//
// Simplifications that make a bake possible: the bottom edge's ageing is
// left to the print shader (the sheet's end moves as the content grows),
// and on a scrolling sheet (uRowEye = 1) the eye follows each row instead of
// the viewport's middle, so a row looks the same wherever it is on screen.

#include <flutter/runtime_effect.glsl>

uniform float uBakeScale; // image px per logical px
uniform vec2 uOrigin;     // paper point of the image's top-left corner
uniform vec2 uPaper;      // the fold map's sheet, logical px
uniform float uRowEye;    // 1 = the eye follows the row (scrolling)
uniform float uPass;      // 0 surface, 1 offset + ink, 2 / 3 horizon
uniform float uReach;     // largest offset the pass-1 encoding holds
uniform float uSeed;
uniform float uDepth;     // relief multiplier
uniform float uHeight;    // map height 1.0 (before uDepth)
uniform vec3 uCamera;     // eye relative to the centre (z > 0)
uniform float uRoughness;
uniform float uEdge;
uniform float uPixel;     // print dot
uniform float uInkFade;
uniform float uLines;
uniform float uDropout;

uniform sampler2D uMap;

out vec4 fragColor;

const int kViewSteps = 20;
const int kHorizonSteps = 14;
const float kHorizonReach = 400.0;
const float kHalfPi = 1.5707963;

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

vec2 slopeOf(vec2 p) {
  const float e = 0.5;
  return vec2(valueNoise(p + vec2(e, 0.0)) - valueNoise(p - vec2(e, 0.0)),
              valueNoise(p + vec2(0.0, e)) - valueNoise(p - vec2(0.0, e)));
}

vec3 mapAt(vec2 paper) {
  return texture(uMap, clamp(paper / uPaper, 0.0, 1.0)).rgb * 2.0 - 1.0;
}

float heightAt(vec2 paper) {
  return mapAt(paper).z * uHeight * uDepth;
}

// Elevation angle of the relief seen from `point` along `dir`, 0..1.
float horizon(vec3 point, vec2 dir, float top) {
  float best = 0.0;
  if (top > 0.0) {
    for (int i = 1; i <= kHorizonSteps; i++) {
      float s = float(i) / float(kHorizonSteps);
      // Denser near the point: small ridges matter there.
      float t = 1.5 + kHorizonReach * s * s;
      float rise = heightAt(point.xy + dir * t) - point.z;
      best = max(best, atan(rise, t));
    }
  }
  return clamp(best / kHalfPi, 0.0, 1.0);
}

void main() {
  vec3 through = vec3(FlutterFragCoord().xy / uBakeScale + uOrigin, 0.0);
  vec3 centre = vec3(uPaper.x * 0.5,
                     uRowEye > 0.5 ? through.y : uPaper.y * 0.5, 0.0);
  vec3 eye = centre + uCamera;
  float top = uHeight * uDepth;

  // --- Camera ray into the height field ----------------------------------
  vec3 ray = through - eye;
  vec2 perZ = ray.xy / ray.z;
  vec2 hitXY = through.xy;
  float hitZ = 0.0;
  if (top > 0.0) {
    float zPrev = top;
    vec2 xyPrev = through.xy + perZ * top;
    float gapPrev = zPrev - heightAt(xyPrev);
    hitXY = xyPrev;
    hitZ = zPrev;
    for (int i = 1; i <= kViewSteps; i++) {
      float z = top - 2.0 * top * float(i) / float(kViewSteps);
      vec2 xy = through.xy + perZ * z;
      float gap = z - heightAt(xy);
      if (gap <= 0.0) {
        float f = gapPrev / max(gapPrev - gap, 1e-5);
        hitXY = mix(xyPrev, xy, f);
        hitZ = mix(zPrev, z, f);
        break;
      }
      zPrev = z;
      xyPrev = xy;
      gapPrev = gap;
      hitXY = xy;
      hitZ = z;
    }
  }
  vec2 paper = hitXY;
  vec3 point = vec3(paper, hitZ);
  vec2 dotCell = floor(paper / max(uPixel, 1.0));

  vec4 result = vec4(0.0);
  if (uPass < 0.5) {
    // --- Surface: normal, fibres, age --------------------------------------
    vec3 m = mapAt(paper);
    vec2 bump = (slopeOf(paper * 0.9) * 0.25 +
                 slopeOf(paper * 0.07 + 13.0) * 0.5) * uRoughness;
    vec3 normal = normalize(vec3(-m.xy * uDepth - bump, 1.0));
    float fibres = fbm(vec2(paper.x * 0.6, paper.y * 0.11)) - 0.5;
    // The sides and the top; the bottom edge is the print shader's.
    float toEdge = min(min(paper.x, uPaper.x - paper.x), paper.y);
    float edge = 1.0 - smoothstep(0.0, 70.0, toEdge);
    float blotch = fbm(paper * 0.008 + 5.0);
    float aged = clamp((edge * 0.6 + blotch * 0.25) * uEdge, 0.0, 1.0);
    result = vec4(normal.xy * 0.5 + 0.5, clamp(fibres + 0.5, 0.0, 1.0), aged);
  } else if (uPass < 1.5) {
    // --- Where the print lands, its ink, the height ------------------------
    vec2 offset = clamp((paper - through.xy) / max(uReach, 1e-3), -1.0, 1.0);
    float ink = 1.0 - mod(dotCell.y, 2.0) * 0.25 * uLines;
    float streak = valueNoise(vec2(paper.x * 0.35, uSeed));
    float missing = hash1(dotCell);
    ink *= 1.0 - uDropout * (smoothstep(0.75, 0.95, streak) * 0.7 +
                             step(1.0 - 0.25 * uDropout, missing));
    ink *= 1.0 - 0.7 * uInkFade * (0.55 + 0.45 * fbm(paper * 0.01 + 2.0));
    float height = top > 0.0 ? clamp(hitZ / top * 0.5 + 0.5, 0.0, 1.0) : 0.5;
    result = vec4(offset * 0.5 + 0.5, clamp(ink, 0.0, 1.0), height);
  } else {
    // --- Horizon in three directions (+ occlusion on pass 2) ---------------
    float first = uPass < 2.5 ? 0.0 : 3.1415927;
    float a1 = first + 1.0471976;
    float a2 = first + 2.0943951;
    vec3 h = vec3(horizon(point, vec2(cos(first), sin(first)), top),
                  horizon(point, vec2(cos(a1), sin(a1)), top),
                  horizon(point, vec2(cos(a2), sin(a2)), top));
    float occlusion = 0.0;
    if (uPass < 2.5 && top > 0.0) {
      for (int i = 0; i < 6; i++) {
        float a = float(i) * 1.0471976;
        vec2 dir = vec2(cos(a), sin(a));
        for (int j = 1; j <= 2; j++) {
          float r = float(j) * 10.0;
          float rise = heightAt(paper + dir * r) - point.z;
          occlusion += clamp(rise / r, 0.0, 1.0);
        }
      }
      occlusion /= 12.0;
    }
    result = vec4(h, uPass < 2.5 ? occlusion : 1.0);
  }
  fragColor = result;
}
