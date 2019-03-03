#version 300 es

precision mediump float;

in vec3 FragPos;
in vec2 TextCoord;
in vec3 FragNormal;

out vec4 color;

//材质属性 - 通过材质属性可以做到，光照相同情况下，不同物体的不同MaterialAttr导致不同的效果
struct MaterialAttr
{
    sampler2D diffuseMap; //漫反射
    sampler2D specularMap ;//镜面高光
    float shininess; //高光系数
};

//光源属性- 为光源的不同成分指定不同的强度
struct LightAttr
{
    vec3 direction;
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
    vec3 ambient = light.ambient * vec3(texture(material.diffuseMap, TextCoord));
    
    //Diffuse
    vec3 lightDir = normalize(-light.direction);
    vec3 normal = normalize(FragNormal);
    float diffFactor = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diffFactor * light.diffuse * vec3(texture(material.diffuseMap, TextCoord)); //环境光一般和漫反射光相同，只是强度不同，因此计算环境光和漫反射光都使用diffuseMap
    
    //Specular
    vec3 reflectDir = normalize(reflect(-lightDir, normal));
    vec3 viewDir = normalize(viewPos - FragPos);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), material.shininess);
    vec3 specular = specFactor * light.specular * vec3(texture(material.specularMap, TextCoord));
    
    vec3 result = ambient + diffuse + specular;
    
    color = vec4(result, 1.0f);
}
