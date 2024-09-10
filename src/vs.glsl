#version 300 es
precision highp float;

out vec3 vVertex;
out vec3 vNormal; // Added output for normals

const float aspect = 16.0 / 9.0;
const float fov = radians(60.0);
const float near = 0.1;
const float far = 100.0;
// Removed: const vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
const vec3 cameraUp = vec3(0.0, 1.0, 0.0);

const vec3 cubeVertices[8] =
    vec3[8](vec3(-0.5, -0.5, -0.5), vec3(0.5, -0.5, -0.5), vec3(0.5, 0.5, -0.5), vec3(-0.5, 0.5, -0.5),
            vec3(-0.5, -0.5, 0.5), vec3(0.5, -0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(-0.5, 0.5, 0.5));

const int cubeIndices[36] =
    int[36](0, 1, 2, 2, 3, 0, 1, 5, 6, 6, 2, 1, 5, 4, 7, 7, 6, 5, 4, 0, 3, 3, 7, 4, 3, 2, 6, 6, 7, 3, 4, 5, 1, 1, 0, 4);

float random(float seed) {
    return fract(sin(seed) * 43758.5453);
}

uniform float uTime;
uniform vec3 uData[512];
uniform vec3 uCameraPosition;
uniform float uCameraYaw;   // Added: Camera yaw uniform
uniform float uCameraPitch; // Added: Camera pitch uniform

const vec3 cubeNormals[6] = vec3[6](
    vec3(0.0, 0.0, -1.0),
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 0.0, 1.0),
    vec3(-1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, -1.0, 0.0)
);

mat4 computeProjectionMatrix() {
    float f = 1.0 / tan(fov * 0.5);
    float rangeInv = 1.0 / (near - far);

    return mat4(f / aspect, 0.0, 0.0, 0.0, 0.0, f, 0.0, 0.0, 0.0, 0.0, (near + far) * rangeInv, -1.0, 0.0, 0.0,
                near * far * rangeInv * 2.0, 0.0);
}

mat4 computeViewMatrix() {
    vec3 cameraPosition = uCameraPosition;
    
    // Calculate camera direction based on yaw and pitch
    vec3 cameraDirection;
    cameraDirection.x = cos(uCameraPitch) * sin(uCameraYaw);
    cameraDirection.y = sin(uCameraPitch);
    cameraDirection.z = cos(uCameraPitch) * cos(uCameraYaw);
    
    vec3 zaxis = normalize(cameraDirection);
    vec3 xaxis = normalize(cross(cameraUp, zaxis));
    vec3 yaxis = cross(zaxis, xaxis);

    return mat4(xaxis.x, yaxis.x, zaxis.x, 0.0,
                xaxis.y, yaxis.y, zaxis.y, 0.0,
                xaxis.z, yaxis.z, zaxis.z, 0.0,
                -dot(xaxis, cameraPosition), -dot(yaxis, cameraPosition), -dot(zaxis, cameraPosition), 1.0);
}

void main() {
    int cubeIndex = int(gl_VertexID / 36);
    int faceIndex = int((gl_VertexID % 36) / 6);
    int vertexIndex = cubeIndices[gl_VertexID % 36];
    vec3 position = cubeVertices[vertexIndex];

    float angle = uTime * 0.001;
    mat3 rotationMatrix = mat3(cos(angle), 0.0, sin(angle), 0.0, 1.0, 0.0, -sin(angle), 0.0, cos(angle));

    vVertex = position;

    position = position + uData[cubeIndex];
    //position = rotationMatrix * position + uData[cubeIndex];

    mat4 projection = computeProjectionMatrix();
    mat4 view = computeViewMatrix();
    gl_Position = projection * view * vec4(position, 1.0);

    vNormal = cubeNormals[faceIndex];
}
