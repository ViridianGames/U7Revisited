#version 330

// Dynamic lighting calculation for meshes.

// Model-view-projection matrix, vertex to screen.
uniform mat4 mvp;

// Model space to world space projection, needed for transforming normals.
uniform mat4 matModel;

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;

out vec3 fragPosition;
out vec2 fragTexCoord;
out vec3 fragNormal;

void main() {
    fragPosition = vec3(matModel * vec4(vertexPosition, 1.0));
    fragTexCoord = vertexTexCoord;
    fragNormal = normalize(mat3(matModel) * vertexNormal);
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
