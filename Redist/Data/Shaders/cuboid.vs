#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform vec2 cuboidTexCoords[72];
// Per-face lighting tint (TOP, FRONT, RIGHT, BOTTOM, BACK, LEFT) — 6 verts/face.
uniform vec4 cuboidFaceLight[6];

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

void main()
{
    fragTexCoord = cuboidTexCoords[gl_VertexID];
    fragColor = cuboidFaceLight[gl_VertexID / 6];

    gl_Position = mvp*vec4(vertexPosition, 1.0);
}
