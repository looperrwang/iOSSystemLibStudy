#version 300 es

precision mediump float;

in vec3 FragPos;
in vec2 TextCoord;
in vec3 FragNormal;

out vec4 color;

//材质属性 - 通过材质属性可以做到，光照相同情况下，不同物体的不同MaterialAttr导致不同的效果
struct MaterialAttr
{
    vec3 ambient; //物体对ambient光各分量的反应
    vec3 diffuse; //物体对diffuse光各分量的反应，eg: 白光(1, 1, 1)照射到diffuse=(1, 0, 0)红色物体表面上，物体呈现红色
    vec3 specular; //物体对specular光各分量的反应
    float shininess; //镜面高光系数
};

//光源属性- 为光源的不同成分指定不同的强度
struct LightAttr
{
    vec3 position;
    vec3 ambient; //环境光
    vec3 diffuse; //漫反射光
    vec3 specular; //镜面高光
};

uniform MaterialAttr material;
uniform LightAttr light;
uniform vec3 viewPos;

void main()
{
    //Phong Reflection Model - Ambient(环境光) + Diffuse(漫反射光) + Specular(镜面高光) = Phong Reflection
    
    //Ambient
    vec3 ambient = light.ambient * material.ambient;
    
    //Diffuse
    vec3 lightDir = normalize(light.position - FragPos);
    vec3 normal = normalize(FragNormal);
    float diffFactor = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diffFactor * light.diffuse * material.diffuse;
    
    //Specular
    vec3 reflectDir = normalize(reflect(-lightDir, normal));
    vec3 viewDir = normalize(viewPos - FragPos);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), material.shininess);
    vec3 specular = specFactor * light.specular * material.specular;
    
    vec3 result = ambient + diffuse + specular;
    
    color = vec4(result, 1.0f);
}
