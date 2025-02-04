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
    vec3 position; //聚光灯位置
    vec3 direction; //聚光灯光线方向
    float cutoff; //聚光灯张角范围余弦值
    
    vec3 ambient; //环境光
    vec3 diffuse; //漫反射光
    vec3 specular; //镜面高光
    
    //衰减
    float constant;
    float linear;
    float quadratic;
};

uniform MaterialAttr material;
uniform LightAttr light;
uniform vec3 viewPos;

void main()
{
    //Phong Reflection Model - Ambient(环境光) + Diffuse(漫反射光) + Specular(镜面高光) = Phong Reflection
    
    //Ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 lightDir = normalize(light.position - FragPos);
    float theta = dot(lightDir, normalize(-light.direction));
    
    if (theta > light.cutoff) {
        //在张角范围之内
        //Diffuse
        vec3 normal = normalize(FragNormal);
        float diffFactor = max(dot(lightDir, normal), 0.0);
        vec3 diffuse = diffFactor * light.diffuse * vec3(texture(material.diffuseMap, TextCoord));
        //Specular
        vec3 reflectDir = normalize(reflect(-lightDir, normal));
        vec3 viewDir = normalize(viewPos - FragPos);
        float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), material.shininess);
        vec3 specular = specFactor * light.specular * vec3(texture(material.specularMap, TextCoord));
        
        //衰减
        float dis = length(light.position - FragPos);
        float attenuation = 1.0f / (light.constant + light.linear * dis + light.quadratic * dis * dis);
        
        vec3 result = (ambient + diffuse + specular) * attenuation;
        
        color = vec4(result, 1.0f);
    } else {
        //不在张角范围之内
        vec3 result = ambient;
        color = vec4(result, 1.0f);
    }
}
