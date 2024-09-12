#version 300 es
precision highp float;

in vec3 vVertex;
in vec3 vNormal;
out vec4 fragColor;

uniform vec2 uResolution;
uniform float uTime;

void main() {
    vec3 lightDir = normalize(vec3(1.0, 2.0, 1.0));
    vec3 ambient = vec3(0.3, 0.3, 0.3);
    vec3 brown = vec3(0.6, 0.3, 0);
    float diff = max(dot(normalize(vNormal), lightDir), 0.0);

    vec3 baseColor;
    if (vVertex.y > sin((vVertex.x + vVertex.z) * 50.0) * 0.1) {
        float squareSize = 0.01;
        vec2 squarePos = floor(vVertex.xz / squareSize);
        float random = fract(sin(dot(squarePos, vec2(12.9898, 78.233))) * 43758.5453);

        vec3 lightGreen = vec3(0.1, 0.8, 0.2);
        vec3 darkGreen = vec3(0.1, 0.6, 0.2);
        baseColor = mix(lightGreen, darkGreen, step(0.5, random));
    } else {
        baseColor = brown;
    }

    vec3 litColor = ambient + baseColor * (diff * 0.6 + 0.4);

    vec2 uv = gl_FragCoord.xy / uResolution;
    vec2 center = vec2(0.5, 0.5);
    float crosshairSize = 0.01;
    float crosshairThickness = 0.002;

    if (abs(uv.x - center.x) < crosshairThickness && abs(uv.y - center.y) < crosshairSize ||
        abs(uv.y - center.y) < crosshairThickness && abs(uv.x - center.x) < crosshairSize) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0); // Red crosshair
    } else {
        fragColor = vec4(litColor, 1.0);
    }
}
