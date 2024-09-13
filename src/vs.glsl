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

const vec3 sphereVertices[12] = vec3[](
    vec3(0.0, 1.0, 0.0), vec3(0.894427, 0.447214, 0.0), vec3(0.276393, 0.447214, 0.850651),
    vec3(-0.723607, 0.447214, 0.525731), vec3(-0.723607, 0.447214, -0.525731), vec3(0.276393, 0.447214, -0.850651),
    vec3(0.0, -1.0, 0.0), vec3(-0.894427, -0.447214, 0.0), vec3(-0.276393, -0.447214, -0.850651),
    vec3(0.723607, -0.447214, -0.525731), vec3(0.723607, -0.447214, 0.525731), vec3(-0.276393, -0.447214, 0.850651));

const int sphereIndices[60] =
    int[](0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 5, 0, 5, 1, 1, 10, 2, 2, 11, 3, 3, 7, 4, 4, 8, 5, 5, 9, 1, 6, 7, 8, 6, 8, 9,
          6, 9, 10, 6, 10, 11, 6, 11, 7, 1, 9, 10, 2, 10, 11, 3, 11, 7, 4, 7, 8, 5, 8, 9);

void main() {
    vec3 position;
    vec3 normal;

    if (uSphere) {
        int vertexIndex = sphereIndices[gl_VertexID % 60];
        position = sphereVertices[vertexIndex];
        normal = normalize(position);
        position *= uScale;

        position += vec3(10.0, 5.0, 12.0);

        vVertex = position;
    } else {
        int cubeIndex = int(gl_VertexID / 36);
        int faceIndex = int((gl_VertexID % 36) / 6);
        int vertexIndex = cubeIndices[gl_VertexID % 36];
        position = cubeVertices[vertexIndex];

        vVertex = position;

        int value = int(uData[int(cubeIndex / 4)][cubeIndex % 4]);
        float x = float(value & 255);
        float y = float((value >> 8) & 255);
        float z = float((value >> 16) & 255);

        position = position + vec3(x, y, z);

        position *= uScale;

        normal = cubeNormals[faceIndex];
    }

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
    vNormal = rotationMatrix * normal;

    if (!uUseCamera) {
        gl_Position = projection * vec4(position, 1.0);
    }
}
