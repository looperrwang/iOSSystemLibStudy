#version 300 es

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 textCoord;
layout (location = 2) in vec3 normal;

out vec3 FragPos;
out vec2 TextCoord;
out vec3 FragNormal;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    gl_Position = projection * view * model * vec4(position, 1.0);
    
    //在片段着色器中计算光照，统一变换到世界坐标系中进行
    FragPos = vec3(model * vec4(position, 1.0));
    TextCoord = textCoord;
    
    mat3 normalMatrix = mat3(transpose(inverse(model)));
    FragNormal = normalMatrix * normal;
}
