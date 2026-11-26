// A sheet of folded paper with content printed on it.
//
// The surface comes from a map computed in Dart (lib/core/paper/
// fold_surface.dart): per point the slope (R, G) and height (B) of the
// folded sheet. Everything is placed in paper coordinates, so creases,
// print and stains move together when the content scrolls.
//
// Two uses, one file:
// - ImageFilter.shader over the real widgets (uFilter = 1): the engine binds
//   the rendered content (on white) to uTexture and its size to uSize. The
//   content is printed on the paper, displaced by the height (parallax) and
//   lit by the same normals as the paper.
// - CustomPaint behind the widgets (uFilter = 0), where shader image filters
//   are not supported (Skia) or the print is off: paper only.
//
// Units: physical pixels in filter mode, logical in paint mode; uScale is
// the device pixel ratio in filter mode and 1 in paint mode, so noise and
// stains have the same size either way.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;     // set by the engine for image filters
uniform vec2 uPaper;    // whole sheet (the scrolled content), px
uniform float uScroll;  // paper y at the top of the bubble, px
uniform float uScale;   // px per logical px
uniform float uSeed;
uniform float uDepth;   // normal strength
uniform vec3 uLight;    // towards the light (x right, y down, z out)
uniform vec2 uView;     // parallax direction, height → screen shift
uniform float uAmbient;
uniform float uCavity;
uniform float uSheen;
uniform float uRoughness; // 0 smooth and glossy, 1 coarse and matte
uniform float uFibres;
uniform float uEdge;
uniform float uLevels;  // 0 = smooth; else grey levels, Bayer dithered
uniform float uPixel;   // print dot / dither cell, px
uniform float uMode;    // 0 = paper only, 1 = thermal print, 2 = colour print
uniform float uWarp;    // shift on the highest ridge, px
uniform float uInkFade;
uniform float uLines;
uniform float uDropout;
uniform float uTorn;    // tooth width of the torn ends, px (0 = straight)
uniform float uCorner;  // corner radius, px
uniform float uDebug;   // 0 result, 1 normals, 2 height, 3 light
uniform float uFilter;  // 1 = image filter (uTexture is the content)

uniform sampler2D uTexture;
uniform sampler2D uMap;

out vec4 fragColor;

const vec3 kPaper = vec3(0.985, 0.972, 0.935);
const vec3 kAged = vec3(0.90, 0.85, 0.72);
const vec3 kInk = vec3(0.13, 0.12, 0.16);

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

vec3 surface(vec2 paper) {
  return texture(uMap, clamp(paper / uPaper, 0.0, 1.0)).rgb * 2.0 - 1.0;
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
  vec2 screen = pos + vec2(0.0, uScroll);

  float alpha = clamp(0.5 - outline(screen), 0.0, 1.0);
  if (alpha <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  // --- Which point of the sheet is seen here ------------------------------
  // A point of height h shows up shifted by uWarp * h * uView; invert that
  // by fixed-point iteration (the shift is small and smooth).
  vec2 paper = screen;
  for (int i = 0; i < 3; i++) {
    paper = screen - uWarp * surface(paper).z * uView;
  }
  vec3 s = surface(paper);

  // Crease lines: where the slope of the fold map jumps (two faces meet).
  float e = 1.5 * uScale;
  float jump = length(surface(paper + vec2(e, 0.0)).xy - surface(paper - vec2(e, 0.0)).xy) +
               length(surface(paper + vec2(0.0, e)).xy - surface(paper - vec2(0.0, e)).xy);
  float crease = smoothstep(0.08, 0.45, jump * uDepth);

  // Paper is never polished: fine grain (fibres pressed into the sheet)
  // and small crinkles bump the normals, more the rougher it is.
  vec2 grainAt = paper / uScale;
  vec2 grain = slopeOf(grainAt * 0.9);
  vec2 crinkle = slopeOf(grainAt * 0.07 + 13.0);
  vec2 bump = (grain * 0.25 + crinkle * 0.5) * uRoughness;
  vec3 normal = normalize(vec3(-s.xy * uDepth - bump, 1.0));

  // --- Light ---------------------------------------------------------------
  vec3 light = normalize(uLight);
  float diffuse = max(dot(normal, light), 0.0);
  // A flat sheet keeps the colour it has: shade 1.
  float shade = uAmbient + (1.0 - uAmbient) * diffuse / max(light.z, 0.15);

  // Valleys get less light: compare with the neighbourhood's height.
  float r = 12.0 * uScale;
  float around = (surface(paper + vec2(r, 0.0)).z + surface(paper - vec2(r, 0.0)).z +
                  surface(paper + vec2(0.0, r)).z + surface(paper - vec2(0.0, r)).z) * 0.25;
  float cavity = clamp((around - s.z) * 3.0, 0.0, 1.0);
  shade *= 1.0 - uCavity * cavity;
  // A thin pinched line along each crease (as in paper-vale).
  shade *= 1.0 - 0.12 * crease * min(uDepth, 1.0);

  vec3 halfway = normalize(light + vec3(0.0, 0.0, 1.0));
  // Rough paper scatters: a wide, faint highlight instead of a glint.
  float shininess = mix(60.0, 5.0, uRoughness);
  float sheen = max(pow(max(dot(normal, halfway), 0.0), shininess) -
                    pow(halfway.z, shininess), 0.0) *
                uSheen * (1.0 - 0.75 * uRoughness);

  vec2 dotCell = floor(paper / max(uPixel, 1.0));
  if (uLevels > 0.5) {
    float threshold = bayer4(dotCell) - 0.5;
    shade = floor(shade * uLevels + threshold + 0.5) / uLevels;
  }
  shade = clamp(shade, 0.0, 1.4);

  if (uDebug > 0.5) {
    vec3 debug = uDebug < 1.5 ? normal * 0.5 + 0.5
               : uDebug < 2.5 ? vec3(s.z * 0.5 + 0.5)
               : vec3(shade * 0.75 + sheen);
    fragColor = vec4(debug * alpha, alpha);
    return;
  }

  // --- Paper ---------------------------------------------------------------
  vec2 logical = paper / uScale;
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
  if (uFilter > 0.5 && uMode > 0.5) {
    vec2 content = (paper - vec2(0.0, uScroll)) / uSize;

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
