#version 330

// Screen-space outline: presence silhouette on mesh pixels only.
// texture0 = scene color
// texture1 = ID mask:
//   a ≈ 0          → true empty (clear / sky / terrain gap)
//   a ≈ 0.5        → flat sprite cover (do NOT outline against these)
//   a ≈ 1, rgb≠0   → outlined custom mesh object ID
//
// Mesh↔mesh: no outline (lanterns/clusters).
// Mesh↔flat: no outline (flats already have baked U7 borders).
// Mesh↔true empty: outline on BOTH sides of the edge (exterior ring + mesh rim)
// so objects keep their visual size instead of looking "eaten" by an inward stroke.

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform vec4 colDiffuse;
uniform vec2 resolution;
uniform float outlineThickness; // pixels at render-target resolution

out vec4 finalColor;

vec4 rawAt(vec2 uv)
{
	return texture(texture1, uv);
}

bool isTrueEmpty(vec4 c)
{
	return c.a < 0.25;
}

bool isFlatCover(vec4 c)
{
	return c.a >= 0.25 && c.a < 0.75;
}

bool isMesh(vec4 c)
{
	return c.a >= 0.75 && (c.r + c.g + c.b) > 0.001;
}

// Distance to nearest mesh↔true-empty edge (ignores flats and other meshes).
float presenceEdgeDistance(vec2 uv, float radius)
{
	vec4 center = rawAt(uv);
	bool centerMesh = isMesh(center);
	bool centerEmpty = isTrueEmpty(center);
	if (!centerMesh && !centerEmpty)
		return 1e6; // flat cover — never an outline seed

	vec2 texel = 1.0 / resolution;
	float r = max(radius, 0.5);
	float best = 1e6;

	for (float dy = -r; dy <= r + 0.001; dy += 0.5)
	{
		for (float dx = -r; dx <= r + 0.001; dx += 0.5)
		{
			float dist = length(vec2(dx, dy));
			if (dist < 0.001 || dist > r + 0.001)
				continue;
			vec4 n = rawAt(uv + vec2(dx, dy) * texel);
			bool nMesh = isMesh(n);
			bool nEmpty = isTrueEmpty(n);
			if ((centerMesh && nEmpty) || (centerEmpty && nMesh))
				best = min(best, dist);
		}
	}
	return best;
}

void main()
{
	vec4 scene = texture(texture0, fragTexCoord) * fragColor * colDiffuse;
	vec4 center = rawAt(fragTexCoord);

	// Never ink flat sprites (baked borders). Allow true-empty so the ring
	// can sit outside the mesh, and mesh so the inner half of the stroke exists.
	if (isFlatCover(center) || (!isMesh(center) && !isTrueEmpty(center)))
	{
		finalColor = scene;
		return;
	}

	float thickness = max(outlineThickness, 0.5);
	float d = presenceEdgeDistance(fragTexCoord, thickness + 0.5);

	float cover = 1.0 - smoothstep(thickness - 0.25, thickness + 0.25, d);
	finalColor = mix(scene, vec4(0.0, 0.0, 0.0, 1.0), clamp(cover, 0.0, 1.0));
}
