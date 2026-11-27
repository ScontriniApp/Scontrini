// Bakes a folded sheet once, for receipt_paper_print.frag to read on every
// frame. The scene is the one of receipt_paper.frag (height field from the
// fold map, perspective camera ray-marched into it, point lamp, cast
// shadows, ambient occlusion, rough paper, fibres, ageing), computed for the
// whole sheet when the paper, lamp or sheet size change, not per frame.
//
// Drawn twice into opaque images covering the sheet plus its bleed, in
// logical px (uBakeScale image px each):
// - pass 0: the lit paper's colour where this point's camera ray lands;
// - pass 1: R, G where the ray lands, relative to the point (-uReach..uReach
//   -> 0..1), and B the thermal ink's strength there (banding, missing dots,
//   fading).
//
// Simplifications that make a bake possible: the bottom edge's ageing is
// left to the print shader (the sheet's end moves as the content grows),
// and on a scrolling sheet (uRowEye = 1) the eye and the lamp follow each
// row instead of the viewport's middle, so a row looks the same wherever it
// is on screen.

#include <flutter/runtime_effect.glsl>

uniform float uBakeScale; // image px per logical px
uniform vec2 uOrigin;     // paper point of the image's top-left corner
uniform vec2 uPaper;      // the fold map's sheet, logical px
uniform float uRowEye;    // 1 = eye and lamp follow the row (scrolling)
uniform float uPass;      // 0 = colour, 1 = offset + ink
uniform float uReach;     // largest offset the pass-1 encoding holds
uniform float uSeed;
uniform float uDepth;     // relief multiplier
uniform float uHeight;    // map height 1.0 (before uDepth)
uniform vec3 uLight;      // direction towards the light
uniform float uLightDist; // light distance from the centre
uniform vec3 uCamera;     // eye relative to the centre (z > 0)
uniform float uAmbient;
uniform float uOcclusion;
uniform float uShadow;
uniform float uSoftness;
uniform float uSheen;
uniform float uRoughness;
uniform float uFibres;
uniform float uEdge;
uniform float uLevels;    // 0 = smooth; else grey levels, Bayer dithered
uniform float uPixel;     // print dot / dither cell
uniform float uInkFade;
uniform float uLines;
uniform float uDropout;

uniform sampler2D uMap;

out vec4 fragColor;

const vec3 kPaper = vec3(0.985, 0.972, 0.935);
const vec3 kAged = vec3(0.90, 0.85, 0.72);
const int kViewSteps = 20;
const int kShadowSteps = 16;

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

float bayer2(vec2 a) {
  a = floor(a);
  return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

float bayer4(vec2 a) {
  return bayer2(0.5 * a) * 0.25 + bayer2(a);
}

vec3 mapAt(vec2 paper) {
  return texture(uMap, clamp(paper / uPaper, 0.0, 1.0)).rgb * 2.0 - 1.0;
}

float heightAt(vec2 paper) {
  return mapAt(paper).z * uHeight * uDepth;
}

// The lit paper's colour at the point the camera ray hit.
vec3 paperColour(vec2 paper, vec3 point, vec3 through, vec3 eye, vec3 centre,
                 float top, vec2 dotCell) {
  // --- Surface -------------------------------------------------------------
  vec3 m = mapAt(paper);
  vec2 bump = (slopeOf(paper * 0.9) * 0.25 +
               slopeOf(paper * 0.07 + 13.0) * 0.5) * uRoughness;
  vec3 normal = normalize(vec3(-m.xy * uDepth - bump, 1.0));

  // --- Light ---------------------------------------------------------------
  vec3 lightDir = normalize(uLight);
  vec3 lamp = centre + lightDir * uLightDist;
  vec3 toLamp = lamp - point;
  float lampDist = length(toLamp);
  vec3 l = toLamp / lampDist;
  float falloff = (uLightDist * uLightDist) / (lampDist * lampDist);
  float exposure = 1.0 / max(lightDir.z, 0.12);
  float direct = max(dot(normal, l), 0.0) * falloff * exposure;

  float lit = 1.0;
  if (top > 0.0 && uShadow > 0.0) {
    float reach = min(2.0 * top / max(l.z, 0.05), 400.0);
    for (int i = 1; i <= kShadowSteps; i++) {
      float t = reach * float(i) / float(kShadowSteps);
      vec3 q = point + l * t;
      if (q.z > top) {
        break;
      }
      float clearance = q.z - heightAt(q.xy);
      float penumbra = uSoftness * t * 0.05 + 0.5;
      lit = min(lit, clamp(clearance / penumbra, 0.0, 1.0));
    }
    lit = mix(1.0, lit, uShadow);
  }

  float occlusion = 0.0;
  if (top > 0.0) {
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
  float ambient = uAmbient * (1.0 - uOcclusion * occlusion);
  float shade = ambient + (1.0 - uAmbient) * direct * lit;

  vec3 v = normalize(eye - point);
  vec3 halfway = normalize(l + v);
  float shininess = mix(60.0, 5.0, uRoughness);
  float sheen = pow(max(dot(normal, halfway), 0.0), shininess) * lit *
                falloff * uSheen * (1.0 - 0.75 * uRoughness);

  if (uLevels > 0.5) {
    float threshold = bayer4(dotCell) - 0.5;
    shade = floor(shade * uLevels + threshold + 0.5) / uLevels;
  }
  shade = clamp(shade, 0.0, 1.25);

  // --- Paper ---------------------------------------------------------------
  vec3 albedo = kPaper;
  float fibres = fbm(vec2(paper.x * 0.6, paper.y * 0.11)) - 0.5;
  albedo *= 1.0 + fibres * 0.06 * uFibres;
  // The sides and the top; the bottom edge is the print shader's.
  float toEdge = min(min(paper.x, uPaper.x - paper.x), paper.y);
  float edge = 1.0 - smoothstep(0.0, 70.0, toEdge);
  float blotch = fbm(paper * 0.008 + 5.0);
  albedo = mix(albedo, kAged,
               clamp((edge * 0.6 + blotch * 0.25) * uEdge, 0.0, 1.0));

  return clamp(albedo * shade + sheen, 0.0, 1.0);
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

  if (uPass > 0.5) {
    // --- Where the print lands, and how strong its ink is ----------------
    vec2 offset = clamp((paper - through.xy) / max(uReach, 1e-3), -1.0, 1.0);
    float ink = 1.0 - mod(dotCell.y, 2.0) * 0.25 * uLines;
    float streak = valueNoise(vec2(paper.x * 0.35, uSeed));
    float missing = hash1(dotCell);
    ink *= 1.0 - uDropout * (smoothstep(0.75, 0.95, streak) * 0.7 +
                             step(1.0 - 0.25 * uDropout, missing));
    ink *= 1.0 - 0.7 * uInkFade * (0.55 + 0.45 * fbm(paper * 0.01 + 2.0));
    fragColor = vec4(offset * 0.5 + 0.5, clamp(ink, 0.0, 1.0), 1.0);
  } else {
    fragColor = vec4(paperColour(paper, point, through, eye, centre, top,
                                 dotCell), 1.0);
  }
}


