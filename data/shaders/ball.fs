#version 330 core

uniform vec3 ballInfo[1000];
uniform int ballCount;
out vec4 FragColor;

void main() {
    float v = 0;

    for (int i = 0; i < ballCount; i++) {
        vec3 mb = ballInfo[i];
        float dx = mb.x - gl_FragCoord.x;
        float dy = mb.y - gl_FragCoord.y;
        float r = mb.z;
        v += r * r / (dx * dx + dy * dy);
    }

    vec3 color = vec3(0.1, 0.78, 0.128);

    if (v > 1.0) {
        if (v > 2) {
            v = 2.0;
        }
        FragColor = vec4(color * (v - 1), 1.0);
    } else {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    
}