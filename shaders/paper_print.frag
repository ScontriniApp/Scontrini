// A folded sheet of paper on every frame, from the material paper_bake.frag
// baked: the content is printed where the camera ray landed, and the sheet
// is LIT HERE, per frame, from the baked normal, height, occlusion and
// horizon: four texture reads for the paper, one for the content. The lamp
// can move every frame (the tilt light, a sheet tilted under a finger)
// without re-baking anything.
//
// Drawn on a canvas in the bubble's own coordinates (FlutterFragCoord is
// local, logical px), two uses:
// - print (uFilter = 1): uTexture is a snapshot of the content (on white)
//   that PaperBubble renders itself, so clips around the bubble never cut
//   what the shader reads (an ImageFilter only got the visible part);
// - paper only (uFilter = 0): the content is painted on top.
//
// Light, eye and lamp are in the sheet's own frame (x right, y down along
// the sheet, z towards the viewer): a tilted sheet gets them rotated.
// uScale (device pixels per logical px) only sharpens the outline.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;       // bubble + 2 * uMargin, logical px
uniform float uScale;     // px per logical px
uniform vec2 uMargin;     // bleed around the bubble on each side
uniform vec2 uSheet;      // the sheet (the scrolled content)
uniform float uScroll;    // paper y at the top of the bubble
uniform vec2 uBakeOrigin; // paper point of the baked images' top-left corner
uniform vec2 uBakeSize;   // paper area the baked images cover
uniform float uReach;     // largest offset the baked offsets hold
uniform float uMode;      // 0 = paper only, 1 = thermal print, 2 = colour print
uniform float uEdge;      // ageing strength
uniform float uTorn;      // tooth width of the torn ends (0 = straight)
uniform float uCorner;    // corner radius
uniform float uFilter;    // 1 = print (uTexture is the content)
uniform vec2 uPaper;      // the fold map's sheet (the bake's), logical px
uniform float uRowEye;    // 1 = eye and lamp follow the row (scrolling)
uniform float uTop;       // relief height (map height x depth)
uniform vec3 uLight;      // direction towards the light, sheet frame
uniform float uLightDist; // light distance from the centre
uniform vec3 uCamera;     // eye relative to the centre, sheet frame
uniform float uExposure;  // 1 / the room light's height (screen frame)
uniform float uAmbient;
uniform float uOcclusion;
uniform float uShadow;
uniform float uSoftness;
uniform float uSheen;
uniform float uRoughness;
uniform float uFibres;
uniform float uLevels;    // 0 = smooth; else grey levels, Bayer dithered
uniform float uPixel;     // dither cell

uniform sampler2D uTexture;
uniform sampler2D uSurface;  // baked pass 0: normal, fibres, age
uniform sampler2D uOffset;   // baked pass 1: ray offset, ink, height
uniform sampler2D uHorizonA; // baked pass 2: horizon 0/60/120, occlusion
uniform sampler2D uHorizonB; // baked pass 3: horizon 180/240/300

out vec4 fragColor;

const vec3 kPaper = vec3(0.985, 0.972, 0.935);
const vec3 kAged = vec3(0.90, 0.85, 0.72);
const vec3 kInk = vec3(0.13, 0.12, 0.16);
const float kPi = 3.1415927;
const float kSixth = 1.0471976;

float outline(vec2 paper) {
  vec2 halfSize = uSheet * 0.5;
  vec2 q = abs(paper - halfSize) - (halfSize - vec2(uCorner));
  float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - uCorner;
  if (uTorn > 0.0) {
    float tri = abs(fract(paper.x / uTorn) - 0.5) * 2.0;
    float tooth = uTorn * 0.5 * tri;
    d = max(d, tooth - paper.y);
    d = max(d, paper.y - (uSheet.y - tooth));
  }
  return d;
}

float bayer2(vec2 a) {
  a = floor(a);
  return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

float bayer4(vec2 a) {
  return bayer2(0.5 * a) * 0.25 + bayer2(a);
}

// Weight of the baked direction at `angle` for a lamp at `azimuth`: the two
// nearest directions blend linearly.
float towards(float azimuth, float angle) {
  float d = abs(mod(azimuth - angle + kPi, 2.0 * kPi) - kPi);
  return max(0.0, 1.0 - d / kSixth);
}

void main() {
  vec2 pos = FlutterFragCoord().xy;
  vec2 through = pos - uMargin + vec2(0.0, uScroll);
  vec2 uv = (through - uBakeOrigin) / uBakeSize;
  vec4 surface = texture(uSurface, uv);
  vec4 baked = texture(uOffset, uv);
  vec4 hA = texture(uHorizonA, uv);
  vec4 hB = texture(uHorizonB, uv);
  vec2 hit = through + (baked.xy * 2.0 - 1.0) * uReach;
  vec3 point = vec3(hit, (baked.a * 2.0 - 1.0) * uTop);

  // Anti-aliased over one device pixel.
  // Outside it the colour is multiplied away (one return: see the
  // impellerc note on samplers and early returns).
  float alpha = clamp(0.5 - outline(hit) * uScale, 0.0, 1.0);

  // --- The paper and its print, unlit ---------------------------------------
  vec3 base = kPaper * (1.0 + (surface.b - 0.5) * 0.06 * uFibres);
  base = mix(base, kAged, surface.a);
  float bottom = 1.0 - smoothstep(0.0, 70.0, uSheet.y - hit.y);
  base = mix(base, kAged, clamp(bottom * 0.6 * uEdge, 0.0, 1.0));

  if (uFilter > 0.5 && uMode > 0.5) {
    // The content texture covers the bleed area too (white there); past
    // it, blank paper (a clamped read would smear the edge row into
    // streaks).
    vec2 content = (hit - vec2(0.0, uScroll) + uMargin) / uSize;
    vec3 src = texture(uTexture, clamp(content, 0.0, 1.0)).rgb;
    if (any(lessThan(content, vec2(0.0))) ||
        any(greaterThan(content, vec2(1.0)))) {
      src = vec3(1.0);
    }
    if (uMode < 1.5) {
      float ink = clamp((1.0 - dot(src, vec3(0.299, 0.587, 0.114))) * 1.8,
                        0.0, 1.0) * baked.b;
      base = mix(base, kInk, ink);
    } else {
      base *= src;
    }
  }

  // --- Light ----------------------------------------------------------------
  vec2 nxy = surface.rg * 2.0 - 1.0;
  vec3 normal = vec3(nxy, sqrt(max(1.0 - dot(nxy, nxy), 0.0)));
  vec3 centre = vec3(uPaper.x * 0.5,
                     uRowEye > 0.5 ? through.y : uPaper.y * 0.5, 0.0);
  vec3 lightDir = normalize(uLight);
  vec3 lamp = centre + lightDir * uLightDist;
  vec3 toLamp = lamp - point;
  float lampDist = length(toLamp);
  vec3 l = toLamp / lampDist;
  float falloff = (uLightDist * uLightDist) / (lampDist * lampDist);
  float direct = max(dot(normal, l), 0.0) * falloff * uExposure;

  // Cast shadow: the lamp below the relief's horizon towards it.
  float lit = 1.0;
  if (uTop > 0.0 && uShadow > 0.0) {
    float azimuth = atan(l.y, l.x);
    float horizon = hA.r * towards(azimuth, 0.0) +
                    hA.g * towards(azimuth, kSixth) +
                    hA.b * towards(azimuth, 2.0 * kSixth) +
                    hB.r * towards(azimuth, kPi) +
                    hB.g * towards(azimuth, 4.0 * kSixth) +
                    hB.b * towards(azimuth, 5.0 * kSixth);
    float elevation = asin(clamp(l.z, -1.0, 1.0));
    float penumbra = 0.015 + 0.04 * uSoftness;
    lit = smoothstep(-penumbra, penumbra, elevation - horizon * 0.5 * kPi);
    lit = mix(1.0, lit, uShadow);
  }

  float ambient = uAmbient * (1.0 - uOcclusion * hA.a);
  float shade = ambient + (1.0 - uAmbient) * direct * lit;

  vec3 eye = centre + uCamera;
  vec3 v = normalize(eye - point);
  vec3 halfway = normalize(l + v);
  float shininess = mix(60.0, 5.0, uRoughness);
  float sheen = pow(max(dot(normal, halfway), 0.0), shininess) * lit *
                falloff * uSheen * (1.0 - 0.75 * uRoughness);

  if (uLevels > 0.5) {
    float threshold = bayer4(floor(hit / max(uPixel, 1.0))) - 0.5;
    shade = floor(shade * uLevels + threshold + 0.5) / uLevels;
  }
  shade = clamp(shade, 0.0, 1.25);

  vec3 colour = clamp(base * shade + sheen, 0.0, 1.0);
  fragColor = vec4(colour * alpha, alpha);
}
