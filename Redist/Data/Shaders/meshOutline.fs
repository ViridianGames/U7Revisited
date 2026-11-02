#version 330

// Screen-space outline: per-object borders + exterior ring.
// texture0 = scene color
// texture1 = ID mask:
//   a ≈ 0          → true empty (clear / sky / terrain gap)
//   a ≈ 0.5, rgb=0 → flat sprite cover (do NOT outline against these)
//   a > 0, rgb≠0   → outlined custom mesh object ID (a carries FP distance fade)
//
// Edges:
//   mesh ↔ true empty     → outer silhouette (both sides of the stroke)
//   mesh ↔ other mesh ID  → per-object borders (fence posts, props)
//   mesh ↔ flat           → ignored (flats already have baked borders)
//
// Outline ink alpha follows the mesh ID alpha so distant faded props do not
// show a hard black ring before the mesh itself is visible.

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
	// Clear / no ID. Faded meshes keep non-zero RGB so they are not empty.
	return (c.r + c.g + c.b) < 0.001 && c.a < 0.25;
}

bool isFlatCover(vec4 c)
{
	// Flat sentinel is rgb=0, a≈0.5. Require near-black RGB so faded mesh IDs
	// (rgb≠0, mid alpha) are never mistaken for flats.
	return c.a >= 0.25 && c.a < 0.75 && (c.r + c.g + c.b) < 0.004;
}

bool isMesh(vec4 c)
{
	// Any non-black ID with some alpha — includes FP distance-faded meshes.
	return (c.r + c.g + c.b) > 0.001 && c.a >= 0.02;
}

ivec3 meshId(vec4 c)
{
	return ivec3(c.rgb * 255.0 + 0.5);
}

// True outline edge: mesh↔empty or mesh↔different mesh. Never involving flats.
bool isOutlineEdge(vec4 a, vec4 b)
{
	if (isFlatCover(a) || isFlatCover(b))
		return false;

	bool aMesh = isMesh(a);
	bool bMesh = isMesh(b);
	bool aEmpty = isTrueEmpty(a);
	bool bEmpty = isTrueEmpty(b);

	if (aMesh && bEmpty)
		return true;
	if (bMesh && aEmpty)
		return true;
	if (aMesh && bMesh && meshId(a) != meshId(b))
		return true;
	return false;
}

// Mesh-side alpha for an outline edge (drives ink opacity).
float edgeMeshAlpha(vec4 a, vec4 b)
{
	if (isMesh(a) && isMesh(b))
		return min(a.a, b.a);
	if (isMesh(a))
		return a.a;
	if (isMesh(b))
		return b.a;
	return 1.0;
}

// Returns edge distance and (via out param) strongest nearby mesh fade alpha.
float outlineEdgeDistance(vec2 uv, float radius, out float meshFade)
{
	vec4 center = rawAt(uv);
	meshFade = isMesh(center) ? center.a : 0.0;
	if (isFlatCover(center))
		return 1e6;
	if (!isMesh(center) && !isTrueEmpty(center))
		return 1e6;

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
			if (isOutlineEdge(center, n))
			{
				best = min(best, dist);
				meshFade = max(meshFade, edgeMeshAlpha(center, n));
			}
		}
	}
	return best;
}

void main()
{
	vec4 scene = texture(texture0, fragTexCoord) * fragColor * colDiffuse;
	vec4 center = rawAt(fragTexCoord);

	// Never ink flats. Ink mesh rim + true-empty exterior ring.
	if (isFlatCover(center) || (!isMesh(center) && !isTrueEmpty(center)))
	{
		finalColor = scene;
		return;
	}

	float thickness = max(outlineThickness, 0.5);
	float meshFade = 1.0;
	float d = outlineEdgeDistance(fragTexCoord, thickness + 0.5, meshFade);

	float cover = 1.0 - smoothstep(thickness - 0.25, thickness + 0.25, d);
	cover = clamp(cover, 0.0, 1.0) * clamp(meshFade, 0.0, 1.0);
	finalColor = mix(scene, vec4(0.0, 0.0, 0.0, 1.0), cover);
}
