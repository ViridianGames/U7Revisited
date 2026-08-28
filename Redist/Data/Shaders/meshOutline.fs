#version 330

// Screen-space outline: distance-to-ID-edge with soft coverage so fractional
// thicknesses (1.0 / 1.5 / 1.75 / 2.0) actually look different.
// texture0 = scene color, texture1 = mesh ID mask (RGB packed id, 0 = no mesh).

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform vec4 colDiffuse;
uniform vec2 resolution;
uniform float outlineThickness; // pixels at render-target resolution

out vec4 finalColor;

ivec3 idAt(vec2 uv)
{
	vec3 c = texture(texture1, uv).rgb;
	return ivec3(c * 255.0 + 0.5);
}

// Distance in pixels to the nearest texel with a different object ID.
float edgeDistance(vec2 uv, float radius)
{
	ivec3 center = idAt(uv);
	vec2 texel = 1.0 / resolution;
	float r = max(radius, 0.5);
	float best = 1e6;

	// Half-pixel steps so fractional widths aren't quantized to {1, √2, 2, …}.
	for (float dy = -r; dy <= r + 0.001; dy += 0.5)
	{
		for (float dx = -r; dx <= r + 0.001; dx += 0.5)
		{
			float dist = length(vec2(dx, dy));
			if (dist < 0.001 || dist > r + 0.001)
				continue;
			ivec3 n = idAt(uv + vec2(dx, dy) * texel);
			if (n != center)
				best = min(best, dist);
		}
	}
	return best;
}

void main()
{
	vec4 scene = texture(texture0, fragTexCoord) * fragColor * colDiffuse;
	float thickness = max(outlineThickness, 0.5);
	float d = edgeDistance(fragTexCoord, thickness + 1.0);

	// Soft 1px ramp around the thickness boundary — enables fractional control.
	float cover = 1.0 - smoothstep(thickness - 0.5, thickness + 0.5, d);
	finalColor = mix(scene, vec4(0.0, 0.0, 0.0, 1.0), clamp(cover, 0.0, 1.0));
}
