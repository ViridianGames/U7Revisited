#version 330

// Index map in texture0 (R = palette index 0-255, A = opacity).
// 256x1 palette LUT in texture1 (raylib MATERIAL_MAP_SPECULAR / SHADER_LOC_MAP_SPECULAR).

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main()
{
	vec4 indexSample = texture(texture0, fragTexCoord);
	if (indexSample.a < 0.5)
		discard;

	// R channel holds the palette index (0-255) as normalized UNORM.
	float idxF = indexSample.r * 255.0;
	int idx = int(idxF + 0.5);
	// Sample center of the 1-pixel-wide palette entry
	vec4 texelColor = texture(texture1, vec2((float(idx) + 0.5) / 256.0, 0.5));
	if (texelColor.a < 0.01)
		discard;

	finalColor = texelColor * colDiffuse * fragColor;
}
