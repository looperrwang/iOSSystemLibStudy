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

//平行光
struct DirLightAttr
{
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

//点光源
struct PointLightAttr
{
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    
    float constant;
    float linear;
    float quadratic;
};

struct SpotLightAttr
{
    vec3 position;
    vec3 direction;
    float cutoff;
    float outerCutoff;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    
    float constant;
    float linear;
    float quadratic;
};

uniform MaterialAttr material;
uniform DirLightAttr dirLight;
#define POINT_LIGHT_NUM 4
uniform PointLightAttr pointLights[POINT_LIGHT_NUM];
uniform SpotLightAttr spotLight;
uniform vec3 viewPos;

vec3 calculateDirLight(DirLightAttr light, vec3 fragNormal, vec3 fragPos, vec3 viewPos);
vec3 calculatePointLight(PointLightAttr light, vec3 fragNormal, vec3 fragPos, vec3 viewPos);
vec3 calculateSpotLight(SpotLightAttr light, vec3 fragNormal, vec3 fragPos, vec3 viewPos);

void main()
{
    //Phong Reflection Model - Ambient(环境光) + Diffuse(漫反射光) + Specular(镜面高光) = Phong Reflection
    vec3 result = calculateDirLight(dirLight, FragNormal, FragPos, viewPos);
    for (int i = 0; i < POINT_LIGHT_NUM; ++i) {
        result += calculatePointLight(pointLights[i], FragNormal, FragPos, viewPos);
    }
    result += calculateSpotLight(spotLight, FragNormal, FragPos, viewPos);
    color = vec4(result, 1.0f);
}

vec3 calculateDirLight(DirLightAttr light, vec3 fragNormal, vec3 fragPos, vec3 viewPos)
{
    vec3 ambient = light.ambient * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 normal = normalize(fragNormal);
    vec3 lightDir = normalize(-light.direction);
    float diffFactor = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diffFactor * light.diffuse * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 reflectDir = normalize(reflect(-lightDir, normal));
    vec3 viewDir = normalize(viewPos - fragPos);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), material.shininess);
    vec3 specular = specFactor * light.specular * vec3(texture(material.specularMap, TextCoord));
    
    vec3 result = ambient + diffuse + specular;
    
    return result;
}

vec3 calculatePointLight(PointLightAttr light, vec3 fragNormal, vec3 fragPos, vec3 viewPos)
{
    vec3 ambient = light.ambient * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 lightDir = normalize(light.position - fragPos);
    vec3 normal = normalize(fragNormal);
    float diffFactor = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diffFactor * light.diffuse * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 reflectDir = normalize(reflect(-lightDir, normal));
    vec3 viewDir = normalize(viewPos - fragPos);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), material.shininess);
    vec3 specular = specFactor * light.specular * vec3(texture(material.specularMap, TextCoord));
    
    float dis = length(light.position - FragPos);
    float attenuation = 1.0f / (light.constant
                                + light.linear * dis
                                + light.quadratic * dis * dis);
    
    vec3 result = (ambient + diffuse + specular) * attenuation;
    
    return result;
}

vec3 calculateSpotLight(SpotLightAttr light, vec3 fragNormal, vec3 fragPos, vec3 viewPos)
{
    vec3 ambient = light.ambient * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 lightDir = normalize(light.position - fragPos);
    vec3 normal = normalize(fragNormal);
    
    float diffFactor = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diffFactor * light.diffuse * vec3(texture(material.diffuseMap, TextCoord));
    
    vec3 reflectDir = normalize(reflect(-lightDir, normal));
    vec3 viewDir = normalize(viewPos - fragPos);
    float specFactor = pow(max(dot(reflectDir, viewDir), 0.0), material.shininess);
    vec3 specular = specFactor * light.specular * vec3(texture(material.specularMap, TextCoord));
    
    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = light.cutoff - light.outerCutoff;
    float intensity = clamp((theta - light.outerCutoff) / epsilon, 0.0, 1.0);
    diffuse *= intensity;
    specular *= intensity;
    
    float dis = length(light.position - fragPos);
    float attenuation = 1.0f / (light.constant
                                + light.linear * dis
                                + light.quadratic * dis * dis);
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    
    vec3 result = ambient + diffuse + specular;
    
    return result;
}
