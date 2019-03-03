#version 300 es

precision mediump float;

in vec3 FragPos;
in vec2 TextCoord;
in vec3 FragNormal;
in vec3 LightPos;

out vec4 color;

uniform float ambientStrength; //[0.0 - 1.0]

uniform float diffuseStrength; //控制Diffuse有无
uniform vec3 lightColor;

uniform float specularStrength; //[0.0 - 1.0]
uniform float coefficient; //镜面高光系数

uniform vec3 objectColor;

//测试 -
//1. 只有Ambient
//2. 只有Diffuse
//3. 只有Specular - 改变coefficient
//4. 只有Ambient + Diffuse
//5. 只有Ambient + Specular
//6. 只有Diffuse + Specular
//7. Ambient + Diffuse + Specular

void main()
{
    //Phong Reflection Model - Ambient(环境光) + Diffuse(漫反射光) + Specular(镜面高光) = Phong Reflection
    
    //Ambient
    //float ambientStrength = 0.1f;
    vec3 ambient = ambientStrength * lightColor;
    
    //Diffuse
    vec3 lightDir = normalize(LightPos - FragPos);
    vec3 normal = normalize(FragNormal);
    float diffFactor = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diffuseStrength * diffFactor * lightColor;
    
    //Specular
    //float specularStrength = 0.5f;
    vec3 reflectDir = normalize(reflect(-lightDir, normal));
    vec3 viewDir = normalize(-FragPos);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), coefficient);
    vec3 specular = specularStrength * specFactor * lightColor;
    
    vec3 result = (ambient + diffuse + specular) * objectColor;
    
    color = vec4(result, 1.0f);
}
