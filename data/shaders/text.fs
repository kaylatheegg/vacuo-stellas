#version 330 core
in vec2 Texcoords;
out vec4 color;

uniform sampler2D text;
//uniform vec3 textColor;

void main()
{    
    vec4 sampled = texture(text, Texcoords);
    color = vec4(1.0, 1.0, 1.0, 1.0) * sampled;
}  
