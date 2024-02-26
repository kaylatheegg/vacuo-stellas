#version 330 core
in vec2 position;

uniform vec2 cameraPos;

uniform float zoomLevel;

void main()
{
    gl_Position = vec4((position - cameraPos) * zoomLevel, 0.0, 1.0);
}