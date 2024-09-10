#version 300 es
precision highp float;
in vec3 vVertex;
out vec4 fragColor;
void main() {

    vec4 green = vec4(0.1, 0.8, 0.1, 1.0);
    vec4 brown = vec4(0.6, 0.3, 0, 1.0);

    if (vVertex.y > sin((vVertex.x + vVertex.z) * 50.0) * 0.1)
        fragColor = green;
    else
        fragColor = brown;
}
