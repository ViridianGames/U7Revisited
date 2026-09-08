#version 330

// Flat object-ID output for screen-space mesh outlines.
// Ignores texture RGB; alphaCutoff controls silhouette holes.
// Translucent/glass shapes use a low cutoff so pane holes don't get
// presence-outlined as black lines through the glass.

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
	// ID is carried in colDiffuse / vertex tint — do not multiply by texel RGB.
	finalColor = fragColor * colDiffuse;
}
