#version 300 es
precision highp float;

in vec3 vVertex;
in vec3 vNormal;
out vec4 fragColor;

uniform vec2 uResolution;
uniform float uScale;
uniform float uCameraYaw;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec3 lightDir = normalize(vec3(1.0, 2.0, 1.0));
    vec3 ambient = vec3(0.3, 0.3, 0.3);
    vec3 brown = vec3(0.6, 0.3, 0);
    float diff = max(dot(normalize(vNormal), lightDir), 0.0);

    vec3 baseColor;

    if(uScale >= 999.0) {
        vec2 uv = gl_FragCoord.xy / uResolution;
        
        float yawOffset = uCameraYaw / (2.0 * 3.14159);
        uv.x = fract(uv.x + yawOffset);
        
        float noise = random(uv);
        
        float gradient = smoothstep(0.0, 1.0, uv.y);
        
        vec3 skyColor = mix(vec3(0.2, 0.4, 0.8), vec3(0.5, 0.7, 1.0), gradient);
        
        float cloudDensity = smoothstep(0.4, 0.6, noise);
        vec3 cloudColor = vec3(1.0, 1.0, 1.0);
        
        fragColor = vec4(mix(skyColor, cloudColor, cloudDensity), 1.0);
    } else {
        if (vVertex.y > sin((vVertex.x + vVertex.z) * 30.0) * 0.1) {
            float squareSize = 0.01;
            vec3 squarePos = floor(vVertex.xyz / squareSize);
            float random = fract(sin(dot(squarePos, vec3(12.9898, 78.233, 37.67))) * 43758.5453);
            vec3 light = vec3(0.1, 0.8, 0.2);
            vec3 dark = vec3(0.1, 0.6, 0.2);
            baseColor = mix(light, dark, step(0.5, random));
        } else {
            float squareSize = 0.1;
            vec3 squarePos = floor(vVertex.xyz / squareSize);
            float random = fract(sin(dot(squarePos, vec3(12.9898, 78.233, 37.67))) * 43758.5453);
            baseColor = brown;
            vec3 light = vec3(0.4, 0.2, 0.0);
            vec3 dark = vec3(0.6, 0.3, 0.0);
            baseColor = mix(light, dark, step(0.5, random));
        }

        vec3 litColor = ambient + baseColor * (diff * 0.6 + 0.4);

        vec2 uv = gl_FragCoord.xy / uResolution;
        vec2 center = vec2(0.5, 0.5);
        float crosshairSize = 0.01;
        float crosshairThickness = 0.002;

        if (abs(uv.x - center.x) < crosshairThickness && abs(uv.y - center.y) < crosshairSize ||
            abs(uv.y - center.y) < crosshairThickness && abs(uv.x - center.x) < crosshairSize) {
            fragColor = vec4(1.0, 0.0, 0.0, 1.0);
        } else {
            fragColor = vec4(litColor, 1.0);
        }
    }
}
