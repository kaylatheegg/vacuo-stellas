#version 330 core
in vec2 position;

in vec2 texcoord;

uniform float zoomLevel;

uniform vec2 cameraPos;

uniform mat4 rotMat;

out vec2 Texcoord;

void main()
{

    gl_Position = vec4((position - cameraPos) * zoomLevel, -0.5, 1.0);

    Texcoord = texcoord;
}