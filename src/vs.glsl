#version 300 es
precision highp float;

out vec3 vVertex;
out vec3 vNormal;

layout(std140) uniform CubeData {
    ivec4 uData[4096];
};

uniform vec2 uResolution;
uniform vec3 uCameraPosition;
uniform float uCameraYaw;
uniform float uCameraPitch;
uniform float uGlobalYaw;
uniform float uGlobalPitch;
uniform bool uUseCamera;
uniform bool uSphere;
uniform float uScale;

const float fov = radians(60.0);
const float near = 0.1;
const float far = 1000.0;
const vec3 cameraUp = vec3(0.0, 1.0, 0.0);

const vec3 cubeVertices[8] =
    vec3[8](vec3(-0.5, -0.5, -0.5), vec3(0.5, -0.5, -0.5), vec3(0.5, 0.5, -0.5), vec3(-0.5, 0.5, -0.5),
            vec3(-0.5, -0.5, 0.5), vec3(0.5, -0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(-0.5, 0.5, 0.5));

const int cubeIndices[36] =
    int[36](0, 1, 2, 2, 3, 0, 1, 5, 6, 6, 2, 1, 5, 4, 7, 7, 6, 5, 4, 0, 3, 3, 7, 4, 3, 2, 6, 6, 7, 3, 4, 5, 1, 1, 0, 4);

const vec3 cubeNormals[6] = vec3[6](vec3(0.0, 0.0, -1.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0),
                                    vec3(-1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, -1.0, 0.0));

// New sphere data
const vec3 sphereVertices[36] = vec3[36](
    vec3(0.0, -0.5, 0.0), vec3(0.4330127, -0.25, 0.0), vec3(-0.2165064, -0.25, 0.3750001),
    vec3(-0.2165064, -0.25, -0.3750001), vec3(0.2165064, 0.25, 0.3750001), vec3(0.2165064, 0.25, -0.3750001),
    vec3(-0.4330127, 0.25, 0.0), vec3(0.0, 0.5, 0.0), vec3(0.4330127, -0.25, 0.0), vec3(0.2165064, 0.25, 0.3750001),
    vec3(-0.2165064, -0.25, 0.3750001), vec3(-0.4330127, 0.25, 0.0), vec3(-0.2165064, -0.25, -0.3750001),
    vec3(0.2165064, 0.25, -0.3750001), vec3(0.0, 0.5, 0.0), vec3(0.0, -0.5, 0.0), vec3(-0.2165064, -0.25, 0.3750001),
    vec3(-0.2165064, -0.25, -0.3750001), vec3(0.4330127, -0.25, 0.0), vec3(0.2165064, 0.25, -0.3750001),
    vec3(0.2165064, 0.25, 0.3750001), vec3(-0.4330127, 0.25, 0.0), vec3(0.0, 0.5, 0.0),
    vec3(0.2165064, 0.25, -0.3750001), vec3(0.4330127, -0.25, 0.0), vec3(-0.2165064, -0.25, -0.3750001),
    vec3(-0.4330127, 0.25, 0.0), vec3(-0.2165064, -0.25, 0.3750001), vec3(0.2165064, 0.25, 0.3750001),
    vec3(0.0, 0.5, 0.0), vec3(0.0, -0.5, 0.0), vec3(0.4330127, -0.25, 0.0), vec3(-0.2165064, -0.25, 0.3750001),
    vec3(-0.2165064, -0.25, -0.3750001), vec3(0.2165064, 0.25, 0.3750001), vec3(0.2165064, 0.25, -0.3750001));

const int sphereIndices[72] =
    int[72](0, 1, 2, 0, 2, 3, 0, 3, 1, 4, 5, 6, 4, 6, 7, 4, 7, 5, 8, 9, 10, 8, 10, 11, 8, 11, 9, 12, 13, 14, 12, 14, 15,
            12, 15, 13, 16, 17, 18, 16, 18, 19, 16, 19, 17, 20, 21, 22, 20, 22, 23, 20, 23, 21, 24, 25, 26, 24, 26, 27,
            24, 27, 25, 28, 29, 30, 28, 30, 31, 28, 31, 29);

// New sphere normals
const vec3 sphereNormals[36] = vec3[36](
    vec3(0.0, -1.0, 0.0), vec3(0.8660254, -0.5, 0.0), vec3(-0.4330127, -0.5, 0.75), vec3(-0.4330127, -0.5, -0.75),
    vec3(0.4330127, 0.5, 0.75), vec3(0.4330127, 0.5, -0.75), vec3(-0.8660254, 0.5, 0.0), vec3(0.0, 1.0, 0.0),
    vec3(0.8660254, -0.5, 0.0), vec3(0.4330127, 0.5, 0.75), vec3(-0.4330127, -0.5, 0.75), vec3(-0.8660254, 0.5, 0.0),
    vec3(-0.4330127, -0.5, -0.75), vec3(0.4330127, 0.5, -0.75), vec3(0.0, 1.0, 0.0), vec3(0.0, -1.0, 0.0),
    vec3(-0.4330127, -0.5, 0.75), vec3(-0.4330127, -0.5, -0.75), vec3(0.8660254, -0.5, 0.0),
    vec3(0.4330127, 0.5, -0.75), vec3(0.4330127, 0.5, 0.75), vec3(-0.8660254, 0.5, 0.0), vec3(0.0, 1.0, 0.0),
    vec3(0.4330127, 0.5, -0.75), vec3(0.8660254, -0.5, 0.0), vec3(-0.4330127, -0.5, -0.75), vec3(-0.8660254, 0.5, 0.0),
    vec3(-0.4330127, -0.5, 0.75), vec3(0.4330127, 0.5, 0.75), vec3(0.0, 1.0, 0.0), vec3(0.0, -1.0, 0.0),
    vec3(0.8660254, -0.5, 0.0), vec3(-0.4330127, -0.5, 0.75), vec3(-0.4330127, -0.5, -0.75), vec3(0.4330127, 0.5, 0.75),
    vec3(0.4330127, 0.5, -0.75));

float random(float seed) {
    return fract(sin(seed) * 43758.5453);
}

mat4 computeProjectionMatrix() {
    float aspect = uResolution.x / uResolution.y;
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

void main() {
    int cubeIndex = int(gl_VertexID / 36);
    int faceIndex = int((gl_VertexID % 36) / 6);
    int vertexIndex = cubeIndices[gl_VertexID % 36];
    vec3 position = cubeVertices[vertexIndex];

    vVertex = position;

    int value = int(uData[int(cubeIndex / 4)][cubeIndex % 4]);
    float x = float(value & 255);
    float y = float((value >> 8) & 255);
    float z = float((value >> 16) & 255);

    position = position + vec3(x, y, z);

    position *= uScale;

    float cosYaw = cos(uGlobalYaw);
    float sinYaw = sin(uGlobalYaw);
    float cosPitch = cos(uGlobalPitch);
    float sinPitch = sin(uGlobalPitch);

    mat3 rotationMatrix = mat3(cosYaw, 0.0, -sinYaw, sinYaw * sinPitch, cosPitch, cosYaw * sinPitch, sinYaw * cosPitch,
                               -sinPitch, cosYaw * cosPitch);

    position = rotationMatrix * position;

    mat4 projection = computeProjectionMatrix();
    mat4 view = computeViewMatrix();

    gl_Position = projection * view * vec4(position, 1.0);
    vNormal = rotationMatrix * cubeNormals[faceIndex];

    if (!uUseCamera) {
        gl_Position = projection * vec4(position, 1.0);
    }
}
