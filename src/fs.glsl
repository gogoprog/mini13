#version 300 es
precision highp float;

in vec3 vVertex;
in vec3 vNormal;
out vec4 fragColor;

void main() {
    // Improve light direction for more realistic lighting
    vec3 lightDir = normalize(vec3(1.0, 2.0, 1.0));
    
    // Increase ambient light slightly for better visibility
    vec3 ambient = vec3(0.3, 0.3, 0.3);
    
    vec3 green = vec3(0.1, 0.8, 0.1);
    vec3 brown = vec3(0.6, 0.3, 0);

    // Improve diffuse lighting calculation
    float diff = max(dot(normalize(vNormal), lightDir), 0.0);
    
    vec3 baseColor;
    if (vVertex.y > sin((vVertex.x + vVertex.z) * 50.0) * 0.1)
        baseColor = green;
    else
        baseColor = brown;

    // Adjust the lighting calculation for more natural look
    vec3 litColor = ambient + baseColor * (diff * 0.6 + 0.4);
    fragColor = vec4(litColor, 1.0);
}
