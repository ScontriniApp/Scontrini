// A hard plastic (PVC) shelf label, lit as a small relief.
//
// Drawn as a LIGHT OVERLAY over the real label widget, inside the plate's
// own transform: FlutterFragCoord is the plate's local position, so the
// relief tilts, scrolls and clips with the plate (an ImageFilter ran on the
// screen image after the tilt and the clip, and its rim stayed put).
// The shader never sees the label: it draws the light, the label keeps its
// colours underneath. Two passes over the plate's rectangle:
//   uPass 0 (BlendMode.multiply): shade, the rim's shadow on the screen;
//   uPass 1 (BlendMode.plus): specular, fresnel, room reflection, and the
//            part of the shade above 1 (slopes facing the lamp);
//   uPass 2 (srcOver): debug views, opaque.
// Geometry is analytic (rounded rectangles), in logical px: x right, y down,
// z towards the viewer; z = 0 is the table. Light and view come in the
// plate's own frame, so when the widget tilts the plate (touch), the
// highlights slide across it as on a real object.
// ASCII only: impellerc warns on anything else.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;          // the plate, logical px
uniform float uOuterRadius;  // plate corner radius
uniform vec4 uScreen;        // screen insets: left, top, right, bottom
uniform float uScreenRadius;
uniform float uRim;          // rim height
uniform float uBevel;        // rounded outer edge width
uniform float uLip;          // inner slope width
uniform float uRecess;       // screen depth below the rim
uniform vec3 uLight;         // towards the light, plate frame
uniform vec3 uView;          // towards the eye, plate frame
uniform float uAmbient;
uniform float uGloss;
uniform float uShininess;
uniform float uScreenGloss;
uniform float uScreenShininess;
uniform float uFresnel;
uniform float uReflection;
uniform float uGrain;
uniform float uShadow;
uniform float uDebug;        // 0 result, 1 normals, 2 height, 3 light
uniform float uPass;         // 0 multiply, 1 add, 2 debug

out vec4 fragColor;

const int kShadowSteps = 8;

float hash1(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
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

// Signed distance to a rounded rectangle centred at the origin.
float roundRect(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - (halfSize - vec2(radius));
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

// Quarter-round profile: 0 -> 1 with a vertical start and a flat end.
float roundUp(float t) {
  t = clamp(t, 0.0, 1.0);
  return sqrt(1.0 - (1.0 - t) * (1.0 - t));
}

float outerDistance(vec2 p) {
  return roundRect(p - uSize * 0.5, uSize * 0.5, uOuterRadius);
}

float screenDistance(vec2 p) {
  vec2 topLeft = uScreen.xy;
  vec2 bottomRight = uSize - uScreen.zw;
  vec2 halfSize = max((bottomRight - topLeft) * 0.5, vec2(1.0));
  return roundRect(p - (topLeft + halfSize), halfSize, uScreenRadius);
}

// Height of the plate at p (logical px).
float heightAt(vec2 p) {
  float rim = uRim * roundUp(-outerDistance(p) / max(uBevel, 0.01));
  // 0 inside the screen, 1 once a lip's width outside it.
  float outside = smoothstep(0.0, 1.0, screenDistance(p) / max(uLip, 0.01));
  return rim - uRecess * (1.0 - outside);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  // Coverage of the plate's outline (antialiased edge).
  float mask = 1.0 - smoothstep(-0.5, 0.5, outerDistance(p));

  // --- Surface --------------------------------------------------------------
  const float e = 0.75;
  float h = heightAt(p);
  vec2 slope = vec2(heightAt(p + vec2(e, 0.0)) - heightAt(p - vec2(e, 0.0)),
                    heightAt(p + vec2(0.0, e)) - heightAt(p - vec2(0.0, e))) /
               (2.0 * e);
  // Moulded plastic is never mirror-flat: a faint orange peel.
  vec2 peel = vec2(valueNoise(p * 0.35) - valueNoise(p * 0.35 + 17.0),
                   valueNoise(p * 0.35 + 31.0) - valueNoise(p * 0.35 + 7.0));
  vec3 normal = normalize(vec3(-slope - peel * 0.06 * uGrain, 1.0));

  // 1 on the screen's cover, 0 on the frame.
  float onScreen = 1.0 - smoothstep(-0.5, 0.5, screenDistance(p));

  // --- Light ----------------------------------------------------------------
  vec3 l = normalize(uLight);
  vec3 v = normalize(uView);
  // Exposure: flat plastic facing the lamp keeps the label's own colours.
  float exposure = 1.0 / max(l.z, 0.15);
  float direct = max(dot(normal, l), 0.0) * exposure;

  // The rim's shadow on the screen: march towards the light.
  float lit = 1.0;
  if (uShadow > 0.0 && l.z < 0.999) {
    float reach = 3.0 * (uRim + uRecess) / max(l.z, 0.1);
    for (int i = 1; i <= kShadowSteps; i++) {
      float t = reach * float(i) / float(kShadowSteps);
      vec3 q = vec3(p, h) + l * t;
      float clearance = q.z - heightAt(q.xy);
      lit = min(lit, clamp(0.5 + clearance / (0.4 + 0.08 * t), 0.0, 1.0));
    }
    lit = mix(1.0, lit, uShadow);
  }

  float shade = min(uAmbient + (1.0 - uAmbient) * direct * lit, 1.3);

  // Specular: tight on the cover, broader on the frame.
  vec3 halfway = normalize(l + v);
  float shininess = mix(uShininess, uScreenShininess, onScreen);
  float gloss = mix(uGloss, uScreenGloss, onScreen);
  float specular = pow(max(dot(normal, halfway), 0.0), shininess) * gloss * lit;

  // Fresnel: more reflection at grazing angles.
  float facing = max(dot(normal, v), 0.0);
  float fresnel = uFresnel * pow(1.0 - facing, 5.0);

  // The room in the plastic: a soft bright window around the light's
  // reflection plus a diagonal streak that slides as the plate tilts.
  vec3 r = reflect(-v, normal);
  float window = smoothstep(0.55, 0.98, dot(r, l));
  float streak = exp(-pow((r.x + r.y) * 6.0 - 0.6, 2.0));
  float room = (window * 0.6 + streak * 0.4) * uReflection *
               mix(0.5, 1.0, onScreen);

  vec4 result;
  if (uPass < 0.5) {
    // Multiply: premultiplied, so the edge fades into the untouched label.
    result = vec4(vec3(min(shade, 1.0) * mask), mask);
  } else if (uPass < 1.5) {
    // Plus: light only, alpha untouched. The label's colour can't be read,
    // so a lit slope above 1 brightens towards white (half strength).
    float add = specular + fresnel + room + max(shade - 1.0, 0.0) * 0.5;
    result = vec4(vec3(clamp(add, 0.0, 1.0) * mask), 0.0);
  } else {
    vec3 debug = uDebug < 1.5 ? normal * 0.5 + 0.5
               : uDebug < 2.5 ? vec3(clamp(h / max(uRim, 0.01) * 0.5 + 0.5, 0.0, 1.0))
               : vec3(shade * 0.8 + specular + room);
    result = vec4(debug * mask, mask);
  }
  fragColor = result;
}
