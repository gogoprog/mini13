#version 300 es
precision highp float;

out vec3 vVertex;
out vec3 vNormal;

const float aspect = 16.0 / 9.0;
const float fov = radians(60.0);
const float near = 0.1;
const float far = 1000.0;
const vec3 cameraUp = vec3(0.0, 1.0, 0.0);

const vec3 cubeVertices[8] =
    vec3[8](vec3(-0.5, -0.5, -0.5), vec3(0.5, -0.5, -0.5), vec3(0.5, 0.5, -0.5), vec3(-0.5, 0.5, -0.5),
            vec3(-0.5, -0.5, 0.5), vec3(0.5, -0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(-0.5, 0.5, 0.5));

const int cubeIndices[36] =
    int[36](0, 1, 2, 2, 3, 0, 1, 5, 6, 6, 2, 1, 5, 4, 7, 7, 6, 5, 4, 0, 3, 3, 7, 4, 3, 2, 6, 6, 7, 3, 4, 5, 1, 1, 0, 4);

float random(float seed) {
    return fract(sin(seed) * 43758.5453);
}

layout(std140) uniform CubeData {
    ivec4 uData[4096];
};

uniform float uTime;
uniform vec3 uCameraPosition;
uniform float uCameraYaw;
uniform float uCameraPitch;

const vec3 cubeNormals[6] = vec3[6](vec3(0.0, 0.0, -1.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0),
                                    vec3(-1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, -1.0, 0.0));

mat4 computeProjectionMatrix() {
    float f = 1.0 / tan(fov * 0.5);
    float rangeInv = 1.0 / (near - far);

    return mat4(f / aspect, 0.0, 0.0, 0.0, 0.0, f, 0.0, 0.0, 0.0, 0.0, (near + far) * rangeInv, -1.0, 0.0, 0.0,
                near * far * rangeInv * 2.0, 0.0);
}

mat4 computeViewMatrix() {
    vec3 cameraPosition = uCameraPosition;

    vec3 cameraDirection;
    cameraDirection.x = cos(uCameraPitch) * sin(uCameraYaw);
    cameraDirection.y = sin(uCameraPitch);
    cameraDirection.z = cos(uCameraPitch) * cos(uCameraYaw);

    vec3 zaxis = normalize(cameraDirection);
    vec3 xaxis = normalize(cross(cameraUp, zaxis));
    vec3 yaxis = cross(zaxis, xaxis);

    return mat4(xaxis.x, yaxis.x, zaxis.x, 0.0, xaxis.y, yaxis.y, zaxis.y, 0.0, xaxis.z, yaxis.z, zaxis.z, 0.0,
                -dot(xaxis, cameraPosition), -dot(yaxis, cameraPosition), -dot(zaxis, cameraPosition), 1.0);
}

uniform float uParticleSize;
uniform vec3 uParticlePosition;
uniform float uParticleLifetime;

void main() {
    int cubeIndex = int(gl_VertexID / 36);
    int faceIndex = int((gl_VertexID % 36) / 6);
    int vertexIndex = cubeIndices[gl_VertexID % 36];
    vec3 position = cubeVertices[vertexIndex];

    float angle = uTime * 0.001;
    mat3 rotationMatrix = mat3(cos(angle), 0.0, sin(angle), 0.0, 1.0, 0.0, -sin(angle), 0.0, cos(angle));

    vVertex = position;

    int value = int(uData[int(cubeIndex / 4)][cubeIndex % 4]);
    float x = float(value & 255);
    float y = float((value >> 8) & 255);
    float z = float((value >> 16) & 255);

    position = position + vec3(x, y, z);

    mat4 projection = computeProjectionMatrix();
    mat4 view = computeViewMatrix();
    gl_Position = projection * view * vec4(position, 1.0);

    vNormal = cubeNormals[faceIndex];

    // Particle rendering for shotgun blast
    if (false && gl_VertexID >= 36 * 4096) {
        int particleIndex = gl_VertexID - 36 * 4096;
        float t = float(particleIndex) / 100.0; // Adjust for desired particle count

        vec3 particlePos = uParticlePosition + vec3(cos(t * 12.9898) * sin(t * 78.233), sin(t * 43.5453),
                                                    cos(t * 39.346) * sin(t * 11.798)) *
                                                   uParticleLifetime;

        gl_Position = projection * view * vec4(particlePos, 1.0);
        gl_PointSize = uParticleSize / gl_Position.w;
    }
}
