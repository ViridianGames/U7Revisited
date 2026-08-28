#version 330

// Flat object-ID output for screen-space mesh outlines.
// Ignores texture RGB; keeps alpha discard so cutout meshes keep correct silhouettes.

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main()
{
	vec4 texel = texture(texture0, fragTexCoord);
	if (texel.a < 0.5)
		discard;
	// ID is carried in colDiffuse / vertex tint — do not multiply by texel RGB.
	finalColor = fragColor * colDiffuse;
}
