// A folded sheet of paper as a small 3D scene, with content printed on it.
//
// Geometry: the sheet is a height field from a map computed in Dart
// (lib/core/paper/fold_surface.dart): per point the slope (R, G) and the
// height (B, scaled by uHeight). x right, y down along the sheet (the whole
// scrolled content), z towards the viewer; z = 0 is the flat sheet.
//
// Camera: a perspective eye above the bubble (uCamera, relative to its
// centre). Each pixel shoots a ray through its point of the z = 0 plane and
// marches it into the height field: what the ray hits is what this pixel
// shows, so print and paper foreshorten on tilted faces and hide behind
// steep ridges by geometry, not by a fake shift.
//
// Light: a point light at uLightDist along uLight from the bubble's centre.
// Lambert with inverse-square falloff, shadows cast by ridges (a second ray
// towards the light), ambient light reduced where the surface is enclosed
// (occlusion from the height field). Nothing darkens the creases except
// light: with the light straight above they almost vanish, as on paper.
//
// Two uses, one file:
// - ImageFilter.shader over the real widgets (uFilter = 1): the engine binds
//   the rendered content (on white) to uTexture and its size to uSize.
// - CustomPaint behind the widgets (uFilter = 0), where shader image filters
//   are not supported (Skia) or the print is off: paper only.
//
// Units: physical px in filter mode, logical in paint mode; uScale is the
// device pixel ratio in filter mode and 1 in paint mode.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;       // the bubble (set by the engine in filter mode)
uniform vec2 uPaper;      // whole sheet (the scrolled content), px
uniform float uScroll;    // paper y at the top of the bubble, px
uniform float uScale;     // px per logical px
uniform float uSeed;
uniform float uDepth;     // relief multiplier
uniform float uHeight;    // map height 1.0 in px (before uDepth)
uniform vec3 uLight;      // direction towards the light
uniform float uLightDist; // light distance from the bubble's centre, px
uniform vec3 uCamera;     // eye relative to the bubble's centre, px (z > 0)
uniform float uAmbient;
uniform float uOcclusion; // ambient occlusion strength
uniform float uShadow;    // cast shadow strength
uniform float uSoftness;  // penumbra width
uniform float uSheen;
uniform float uRoughness; // 0 smooth and glossy, 1 coarse and matte
uniform float uFibres;
uniform float uEdge;
uniform float uLevels;    // 0 = smooth; else grey levels, Bayer dithered
uniform float uPixel;     // print dot / dither cell, px
uniform float uMode;      // 0 = paper only, 1 = thermal print, 2 = colour print
uniform float uInkFade;
uniform float uLines;
uniform float uDropout;
uniform float uTorn;      // tooth width of the torn ends, px (0 = straight)
uniform float uCorner;    // corner radius, px
uniform float uDebug;     // 0 result, 1 normals, 2 height, 3 light
uniform float uFilter;    // 1 = image filter (uTexture is the content)

uniform sampler2D uTexture;
uniform sampler2D uMap;

out vec4 fragColor;

const vec3 kPaper = vec3(0.985, 0.972, 0.935);
const vec3 kAged = vec3(0.90, 0.85, 0.72);
const vec3 kInk = vec3(0.13, 0.12, 0.16);
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

// Slope of value noise at p (central differences, one cell apart).
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

// Height of the sheet at a paper point, px.
float heightAt(vec2 paper) {
  return mapAt(paper).z * uHeight * uDepth;
}

// Signed distance to the sheet's outline: rounded corners, torn ends.
float outline(vec2 paper) {
  vec2 halfSize = uPaper * 0.5;
  vec2 q = abs(paper - halfSize) - (halfSize - vec2(uCorner));
  float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - uCorner;
  if (uTorn > 0.0) {
    float tri = abs(fract(paper.x / uTorn) - 0.5) * 2.0;
    float tooth = uTorn * 0.5 * tri;
    d = max(d, tooth - paper.y);
    d = max(d, paper.y - (uPaper.y - tooth));
  }
  return d;
}

void main() {
  vec2 pos = FlutterFragCoord().xy;
#ifdef IMPELLER_TARGET_OPENGLES
  if (uFilter > 0.5) {
    pos.y = uSize.y - pos.y;
  }
#endif
  vec2 scroll = vec2(0.0, uScroll);
  vec3 centre = vec3(uSize * 0.5 + scroll, 0.0);
  vec3 eye = centre + uCamera;
  float top = uHeight * uDepth;

  // --- Camera ray into the height field ----------------------------------
  // The ray from the eye through this pixel's point of the z = 0 plane; at
  // height z it is at through.xy + perZ * z. March z from the highest
  // possible ridge down to the deepest valley and stop at the surface.
  vec3 through = vec3(pos + scroll, 0.0);
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
        // Crossed the surface between the last two samples: interpolate.
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

  float alpha = clamp(0.5 - outline(paper), 0.0, 1.0);
  if (alpha <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  // --- Surface -------------------------------------------------------------
  vec3 m = mapAt(paper);
  // Paper is never polished: fine grain and small crinkles bump the normal.
  vec2 logical = paper / uScale;
  vec2 bump = (slopeOf(logical * 0.9) * 0.25 +
               slopeOf(logical * 0.07 + 13.0) * 0.5) * uRoughness;
  vec3 normal = normalize(vec3(-m.xy * uDepth - bump, 1.0));

  // --- Light ---------------------------------------------------------------
  vec3 lightDir = normalize(uLight);
  vec3 lamp = centre + lightDir * uLightDist;
  vec3 toLamp = lamp - point;
  float lampDist = length(toLamp);
  vec3 l = toLamp / lampDist;
  // Inverse-square falloff, 1 at the bubble's centre.
  float falloff = (uLightDist * uLightDist) / (lampDist * lampDist);
  // Exposure: flat paper at the centre, facing the lamp, comes out white.
  float exposure = 1.0 / max(lightDir.z, 0.12);
  float direct = max(dot(normal, l), 0.0) * falloff * exposure;

  // Shadow: march towards the lamp; a ridge above the ray blocks it. The
  // closest miss gives a soft edge, wider with distance and uSoftness.
  float lit = 1.0;
  if (top > 0.0 && uShadow > 0.0) {
    float reach = min(2.0 * top / max(l.z, 0.05), 400.0 * uScale);
    for (int i = 1; i <= kShadowSteps; i++) {
      float t = reach * float(i) / float(kShadowSteps);
      vec3 q = point + l * t;
      if (q.z > top) {
        break;
      }
      float clearance = q.z - heightAt(q.xy);
      float penumbra = uSoftness * t * 0.05 + 0.5 * uScale;
      lit = min(lit, clamp(clearance / penumbra, 0.0, 1.0));
    }
    lit = mix(1.0, lit, uShadow);
  }

  // Ambient light from the open sky above the point: less inside valleys
  // and at the foot of ridges.
  float occlusion = 0.0;
  if (top > 0.0) {
    for (int i = 0; i < 6; i++) {
      float a = float(i) * 1.0471976;
      vec2 dir = vec2(cos(a), sin(a));
      for (int j = 1; j <= 2; j++) {
        float r = float(j) * 10.0 * uScale;
        float rise = heightAt(paper + dir * r) - point.z;
        occlusion += clamp(rise / r, 0.0, 1.0);
      }
    }
    occlusion /= 12.0;
  }
  float ambient = uAmbient * (1.0 - uOcclusion * occlusion);

  float shade = ambient + (1.0 - uAmbient) * direct * lit;

  // Rough paper scatters: a wide, faint highlight instead of a glint.
  vec3 v = normalize(eye - point);
  vec3 halfway = normalize(l + v);
  float shininess = mix(60.0, 5.0, uRoughness);
  float sheen = pow(max(dot(normal, halfway), 0.0), shininess) * lit *
                falloff * uSheen * (1.0 - 0.75 * uRoughness);

  vec2 dotCell = floor(paper / max(uPixel, 1.0));
  if (uLevels > 0.5) {
    float threshold = bayer4(dotCell) - 0.5;
    shade = floor(shade * uLevels + threshold + 0.5) / uLevels;
  }
  shade = clamp(shade, 0.0, 1.25);

  if (uDebug > 0.5) {
    vec3 debug = uDebug < 1.5 ? normal * 0.5 + 0.5
               : uDebug < 2.5 ? vec3(m.z * 0.5 + 0.5)
               : vec3(shade * 0.8 + sheen);
    fragColor = vec4(debug * alpha, alpha);
    return;
  }

  // --- Paper ---------------------------------------------------------------
  vec2 size = uPaper / uScale;
  vec3 albedo = kPaper;
  float fibres = fbm(vec2(logical.x * 0.6, logical.y * 0.11)) - 0.5;
  albedo *= 1.0 + fibres * 0.06 * uFibres;
  float toEdge = min(min(logical.x, size.x - logical.x),
                     min(logical.y, size.y - logical.y));
  float edge = 1.0 - smoothstep(0.0, 70.0, toEdge);
  float blotch = fbm(logical * 0.008 + 5.0);
  albedo = mix(albedo, kAged,
               clamp((edge * 0.6 + blotch * 0.25) * uEdge, 0.0, 1.0));

  // --- Print ---------------------------------------------------------------
  // The content is printed on the flat sheet: read it at the paper point
  // the camera ray hit, so it bends, foreshortens and hides with the sheet.
  if (uFilter > 0.5 && uMode > 0.5) {
    vec2 content = (paper - scroll) / uSize;
    vec3 src = texture(uTexture, clamp(content, 0.0, 1.0)).rgb;
    if (uMode < 1.5) {
      // Thermal: darkness becomes ink; dots bleed, so edges go bold.
      float ink = clamp((1.0 - dot(src, vec3(0.299, 0.587, 0.114))) * 1.8, 0.0, 1.0);
      ink *= 1.0 - mod(dotCell.y, 2.0) * 0.25 * uLines;
      float streak = valueNoise(vec2(logical.x * 0.35, uSeed));
      float missing = hash1(dotCell);
      ink *= 1.0 - uDropout * (smoothstep(0.75, 0.95, streak) * 0.7 +
                               step(1.0 - 0.25 * uDropout, missing));
      ink *= 1.0 - 0.7 * uInkFade * (0.55 + 0.45 * fbm(logical * 0.01 + 2.0));
      albedo = mix(albedo, kInk, ink);
    } else {
      // Colour: pigment over the paper, white lets the paper through.
      albedo *= src;
    }
  }

  vec3 color = albedo * shade + sheen;
  fragColor = vec4(color * alpha, alpha);
}
