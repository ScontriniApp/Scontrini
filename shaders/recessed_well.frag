// A drawer carved into the app's background: a rounded-rectangle opening,
// straight walls going down, a flat floor.
//
// Painted BEHIND the drawer's content, over the drawer's own rectangle:
// FlutterFragCoord is the drawer's local position. The opening is the whole
// rectangle; everything the shader draws lies below the background plane.
// Logical px: x right, y down, z towards the viewer; z = 0 is the
// background, the floor is at z = -uDepth.
//
// Perspective: the eye hangs uEye.z px above the screen at (uEye.x, uEye.y),
// in the drawer's coordinates. A pixel's ray goes down from the eye through
// it; where it meets a wall or the floor is what the pixel shows. So a
// drawer high on the screen shows its top wall, one on the right its right
// wall, and the walls change as the list scrolls.
//
// Light: uLight points towards the lamp (the room's lamp, shared with paper
// and plastic). The rim casts a shadow into the drawer: a point is lit when
// the ray from it towards the lamp leaves through the opening (the opening
// is convex and the walls are straight, so testing the background plane is
// enough).
// ASCII only: impellerc warns on anything else.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;        // the drawer, logical px
uniform float uRadius;     // corner radius of the opening
uniform float uDepth;      // floor depth below the background
uniform float uBevel;      // rounded edge width at the top of the walls
uniform vec3 uEye;         // eye x, y (drawer coords), height above screen
uniform vec3 uLight;       // towards the light, screen frame
uniform vec3 uBase;        // background colour, linear-ish 0..1
uniform float uAmbient;
uniform float uFloorShade;
uniform float uWallShade;
uniform float uShadow;
uniform float uSoftness;
uniform float uOcclusion;
uniform float uHighlight;
uniform float uDebug;      // 0 result, 1 normals, 2 depth, 3 light

out vec4 fragColor;

const int kWallSteps = 14;
const float kPi = 3.14159265;

// Signed distance to a rounded rectangle centred at the origin.
float roundRect(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - (halfSize - vec2(radius));
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

// Distance to the opening's outline: negative inside the drawer.
float opening(vec2 p) {
  vec2 halfSize = uSize * 0.5;
  float radius = min(uRadius, min(halfSize.x, halfSize.y));
  return roundRect(p - halfSize, halfSize, radius);
}

// Outward direction of the outline at p (towards the background).
vec2 outward(vec2 p) {
  const float e = 0.5;
  vec2 g = vec2(opening(p + vec2(e, 0.0)) - opening(p - vec2(e, 0.0)),
                opening(p + vec2(0.0, e)) - opening(p - vec2(0.0, e)));
  float len = length(g);
  return len > 1e-5 ? g / len : vec2(0.0, -1.0);
}

void main() {
  vec2 s = FlutterFragCoord().xy;
  float edge = opening(s);
  // Coverage of the opening (antialiased outline).
  float mask = 1.0 - smoothstep(-0.5, 0.5, edge);
  // No early return outside the opening: impellerc warns about several
  // returns in main() (flutter#190809); the mask clears those pixels.

  // The pixel's ray below the screen: x(d) = s + (s - eye) * d / D.
  float eyeHeight = max(uEye.z, 1.0);
  vec2 drift = (s - uEye.xy) / eyeHeight;
  float depth = max(uDepth, 0.0);

  // What the ray meets: the floor, unless it leaves the opening first (a
  // wall). The outline is crossed once (convex opening), so bisect.
  float d = depth;
  bool wall = false;
  if (depth > 0.0 && opening(s + drift * depth) > 0.0) {
    wall = true;
    float lo = 0.0;
    float hi = depth;
    for (int i = 0; i < kWallSteps; i++) {
      float mid = 0.5 * (lo + hi);
      if (opening(s + drift * mid) > 0.0) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    d = 0.5 * (lo + hi);
  }
  vec2 hit = s + drift * d;

  // --- Surface --------------------------------------------------------------
  vec3 normal = vec3(0.0, 0.0, 1.0);
  // 0 down on the wall or on the floor, 1 at the top of the rounded edge.
  float onBevel = 0.0;
  if (wall) {
    vec2 inward = -outward(hit);
    // The rounded edge: faces up at the background, inward further down.
    float t = clamp(d / max(uBevel, 0.01), 0.0, 1.0);
    float angle = t * 0.5 * kPi;
    normal = vec3(inward * sin(angle), cos(angle));
    onBevel = 1.0 - t;
  }

  // --- Light ----------------------------------------------------------------
  vec3 l = normalize(uLight);
  float lz = max(l.z, 0.08);
  // Exposure: a flat floor facing the lamp keeps the background's colour.
  float direct = max(dot(normal, l), 0.0) / max(lz, 0.15);

  // The rim's shadow: where the ray towards the lamp crosses the background.
  vec2 exit = hit + l.xy * (d / lz);
  float penumbra = 0.5 + uSoftness * d;
  float lit = 1.0 - smoothstep(-penumbra, penumbra, opening(exit));
  lit = mix(1.0, lit, uShadow);

  // Occlusion: darker near the walls on the floor, darker deeper down.
  float occlusion;
  if (wall) {
    occlusion = 1.0 - uOcclusion * 0.8 * (d / max(depth, 1.0));
  } else {
    float gap = max(-opening(hit), 0.0);
    occlusion = 1.0 - uOcclusion * exp(-gap / max(depth * 0.6, 1.0));
  }

  float shade = uAmbient + (1.0 - uAmbient) * direct * lit;
  shade *= (wall ? uWallShade : uFloorShade) * occlusion;
  vec3 color = uBase * min(shade, 1.4);
  // The edge facing the lamp catches a bright line.
  float facing = clamp(dot(normal.xy, l.xy) * 2.0, 0.0, 1.0);
  color += vec3(uHighlight * onBevel * facing * lit);

  if (uDebug > 0.5) {
    color = uDebug < 1.5 ? normal * 0.5 + 0.5
          : uDebug < 2.5 ? vec3(1.0 - d / max(depth, 1.0))
          : vec3(shade);
  }
  fragColor = vec4(clamp(color, 0.0, 1.0) * mask, mask);
}
