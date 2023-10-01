#version 330 core
in vec2 position;

in vec2 texcoord;

uniform vec2 cameraPos;

out vec2 Texcoord;

void main()
{

    gl_Position = vec4(position - cameraPos, 0.0, 1.0);

    Texcoord = texcoord;
}