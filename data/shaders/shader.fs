#version 330 core

in vec2 Texcoord;

out vec4 FragColor;

uniform sampler2D tex;

void main() {
   FragColor = texture(tex, Texcoord) * vec4(1, 1, 1, 0.4);
}
