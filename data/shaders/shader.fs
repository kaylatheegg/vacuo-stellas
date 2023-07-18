#version 330 core

in vec2 Texcoord;

out vec4 FragColor;

uniform sampler2D tex;

void main() {
   FragColor = vec4(0.5, 0.3, 0.2, 1); //texture(tex, Texcoord);
}
