#version 300 es
precision highp float;

in vec3 vVertex;
in vec3 vNormal;
out vec4 fragColor;

void main() {
    vec3 lightDir = normalize(vec3(-0.1, 10.0, 1.0));
    vec3 ambient = vec3(0.2, 0.2, 0.2);
    vec3 green = vec3(0.1, 0.8, 0.1);
    vec3 brown = vec3(0.6, 0.3, 0);
    float diff = max(dot(vNormal, lightDir), 0.0);
    vec3 baseColor;
    if (vVertex.y > sin((vVertex.x + vVertex.z) * 50.0) * 0.1)
        baseColor = green;
    else
        baseColor = brown;
    vec3 litColor = ambient + baseColor * diff * 0.7;
    fragColor = vec4(litColor, 1.0);
}
