#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;
// Default 0.5 for cutouts. Glass opaque pass uses ~0.98 so mid-alpha panes
// (e.g. window 438) are left for the wash shader.
uniform float alphaCutoff;

out vec4 finalColor;

void main()
{
	vec4 texelColor = texture(texture0, fragTexCoord);
	float cutoff = alphaCutoff > 0.0 ? alphaCutoff : 0.5;
	if (texelColor.a < cutoff)
		discard;
	finalColor = texelColor * fragColor * colDiffuse;
}
