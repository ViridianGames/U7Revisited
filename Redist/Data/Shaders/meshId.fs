#version 330

// Flat object-ID output for screen-space mesh outlines.
// Texture alpha only controls discard (silhouette holes).
// Output alpha is always 1 — glTF glass materials often carry baseColor
// alpha ~0.3; if that leaked into the ID buffer, the outline shader treated
// glass as "flat cover" and only opaque caps got borders.

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
	// ID from tint × material RGB only; never inherit material/texture alpha.
	vec3 id = fragColor.rgb * colDiffuse.rgb;
	finalColor = vec4(id, 1.0);
}
