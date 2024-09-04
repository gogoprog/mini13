#version 300 es
void main() {
    float angle = float(gl_VertexID) * 3.1415 * 0.1;
    float radius = 0.9;
    vec2 pos = vec2(cos(angle), sin(angle)) * radius;
    gl_Position = vec4(pos, 0.0, 1.0);
    gl_PointSize = 3.0;
}
