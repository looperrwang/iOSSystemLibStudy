#version 300 es

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 textCoord;
layout (location = 2) in vec3 normal;

out vec3 VertColor;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

uniform float ambientStrength; //[0.0 - 1.0]

uniform float diffuseStrength; //控制Diffuse有无
uniform vec3 lightPos;
uniform vec3 lightColor;

uniform float specularStrength; //[0.0 - 1.0]
uniform vec3 viewPos;
uniform float coefficient; //镜面高光系数

uniform vec3 objectColor;

void main()
{
    gl_Position = projection * view * model * vec4(position, 1.0);
    
    vec3 Position = vec3(model * vec4(position, 1.0f));
    mat3 normalMatrix = mat3(transpose(inverse(model)));
    vec3 Normal = normalize(normalMatrix * normal);
    
    //per-vertex shading
    
    //Ambient
    //float ambientStrength = 0.1f;
    vec3 ambient = ambientStrength * lightColor;
    
    //Diffuse
    vec3 lightDir = normalize(lightPos - Position);
    float diffFactor = max(dot(lightDir, Normal), 0.0);
    vec3 diffuse = diffuseStrength * diffFactor * lightColor;
    
    //Specular
    //float specularStrength = 0.5f;
    vec3 reflectDir = normalize(reflect(-lightDir, Normal));
    vec3 viewDir = normalize(viewPos - Position);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), coefficient);
    vec3 specular = specularStrength * specFactor * lightColor;
    
    VertColor = (ambient + diffuse + specular) * objectColor;
}
