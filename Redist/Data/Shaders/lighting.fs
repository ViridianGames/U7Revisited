#version 330

// Texture map for model.
uniform sampler2D texture0;

// Direction of directional light.
uniform vec3 lightDir;

// Ambient light color for non-illuminated parts of the model.
uniform vec3 ambient;

// View position in world space.
uniform vec3 viewPos;

in vec3 fragPosition;
in vec2 fragTexCoord;
in vec3 fragNormal;

out vec4 finalColor;

void main() {
    vec3 normal = normalize(fragNormal);
    vec3 lightDirNorm = normalize(-lightDir);

    // Diffuse color
    float diff = max(dot(normal, lightDirNorm), 0.0);
    vec3 diffuse = diff * vec3(1.0, 1.0, 1.0);

    // Specular color
    vec3 viewDir = normalize(viewPos - fragPosition);
    vec3 reflectDir = reflect(-lightDirNorm, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    vec3 specular = 0.5 * spec * vec3(1.0, 1.0, 1.0);

    vec3 result = (diffuse + specular + ambient) * texture(texture0, fragTexCoord).rgb;
    finalColor = vec4(result, 1.0);
}
