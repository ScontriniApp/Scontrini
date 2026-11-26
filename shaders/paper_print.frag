// A folded sheet of paper on every frame, from what paper_bake.frag baked:
// two texture reads for the paper, one for the content. The light, shadows,
// relief and grain were computed once; here the content is printed where
// the camera ray landed, the outline is cut and the bottom edge aged.
//
// Two uses, as receipt_paper.frag:
// - ImageFilter.shader over the real widgets (uFilter = 1): the engine binds
//   the rendered content (on white) to uTexture and its size to uSize;
// - CustomPaint behind the widgets (uFilter = 0): paper only.
//
// Positions are logical px; uScale is the device pixel ratio in filter mode
// and 1 in paint mode.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;       // bubble + 2 * uMargin, px (engine-set in filter mode)
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
uniform float uFilter;    // 1 = image filter (uTexture is the content)

uniform sampler2D uTexture;
uniform sampler2D uColour;  // baked pass 0: lit paper
uniform sampler2D uOffset;  // baked pass 1: ray offset (R, G), ink (B)

out vec4 fragColor;

const vec3 kAged = vec3(0.90, 0.85, 0.72);
const vec3 kInk = vec3(0.13, 0.12, 0.16);
// Luminance of the bare paper colour (kPaper of the bake).
const float kPaperLum = 0.971;

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

void main() {
  vec2 pos = FlutterFragCoord().xy;
#ifdef IMPELLER_TARGET_OPENGLES
  if (uFilter > 0.5) {
    pos.y = uSize.y - pos.y;
  }
#endif
  vec2 through = pos / uScale - uMargin + vec2(0.0, uScroll);
  vec2 uv = (through - uBakeOrigin) / uBakeSize;
  vec3 paper = texture(uColour, uv).rgb;
  vec3 baked = texture(uOffset, uv).rgb;
  vec2 hit = through + (baked.xy * 2.0 - 1.0) * uReach;

  // Anti-aliased over one device pixel.
  // Outside it the colour is multiplied away (one return: see the
  // impellerc note on samplers and early returns).
  float alpha = clamp(0.5 - outline(hit) * uScale, 0.0, 1.0);

  // How lit the paper is here, from its colour: tints the ink and the age.
  float shade = dot(paper, vec3(0.299, 0.587, 0.114)) / kPaperLum;
  float edge = 1.0 - smoothstep(0.0, 70.0, uSheet.y - hit.y);
  paper = mix(paper, kAged * shade, clamp(edge * 0.6 * uEdge, 0.0, 1.0));

  if (uFilter > 0.5 && uMode > 0.5) {
    // The content texture covers the bleed area too (white there).
    vec2 content = (hit - vec2(0.0, uScroll) + uMargin) * uScale / uSize;
    vec3 src = texture(uTexture, clamp(content, 0.0, 1.0)).rgb;
    if (uMode < 1.5) {
      float ink = clamp((1.0 - dot(src, vec3(0.299, 0.587, 0.114))) * 1.8,
                        0.0, 1.0) * baked.z;
      paper = mix(paper, kInk * shade, ink);
    } else {
      paper *= src;
    }
  }

  fragColor = vec4(paper * alpha, alpha);
}
