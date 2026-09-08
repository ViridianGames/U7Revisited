#version 330

// Stained-glass pass for non-solid texels (α < opaqueCutoff).
// Opaque body is drawn separately with alphaDiscard.
//
// Standard alpha blend of a saturated pane color — tweakable via uniforms.

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;
uniform float glassSaturation; // >1 pulls chroma away from luminance
uniform float glassCoverage;   // scales authored alpha into blend strength
uniform float glassBrightness; // multiplies pane RGB (>1 = brighter)

out vec4 finalColor;

void main()
{
	vec4 t = texture(texture0, fragTexCoord) * fragColor * colDiffuse;
	const float opaqueCutoff = 0.98;
	if (t.a < 0.02 || t.a >= opaqueCutoff)
		discard;

	vec3 glass = t.rgb;
	float lum = dot(glass, vec3(0.299, 0.587, 0.114));
	glass = clamp(mix(vec3(lum), glass, max(glassSaturation, 1.0)), 0.0, 1.0);
	glass = max(glass, vec3(lum * 0.35));
	glass = clamp(glass * max(glassBrightness, 0.01), 0.0, 1.0);

	float a = clamp(t.a * max(glassCoverage, 0.01), 0.04, 0.45);
	finalColor = vec4(glass, a);
}
