#version 330

// Flat object-ID output for screen-space mesh outlines.
// Texture alpha only controls discard (silhouette holes).
// Output alpha comes from fragColor (object tint) so first-person
// distance fade can soft-hide outlines with the mesh. Do not inherit
// material/texture alpha — glTF glass baseColor ~0.3 would look like
// "flat cover" in the outline pass.

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;
uniform float alphaCutoff; // default 0.5; ~0.01 for TFA translucent meshes

out vec4 finalColor;

void main()
{
	vec4 texel = texture(texture0, fragTexCoord);
	float cutoff = alphaCutoff > 0.0 ? alphaCutoff : 0.5;
	if (texel.a < cutoff)
		discard;
	// ID from tint × material RGB; fade lives in fragColor.a.
	vec3 id = fragColor.rgb * colDiffuse.rgb;
	float idAlpha = clamp(fragColor.a * colDiffuse.a, 0.0, 1.0);
	finalColor = vec4(id, idAlpha);
}
