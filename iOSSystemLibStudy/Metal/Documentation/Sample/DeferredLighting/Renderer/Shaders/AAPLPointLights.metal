/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used to render deferred point lighting
*/
#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "AAPLShaderTypes.h"

// Include header shared between all Metal shader code files
#import "AAPLShaderCommon.h"

#pragma mark LIGHT MASK

#if LIGHT_STENCIL_CULLING
typedef struct LightMaskOut
{
    float4 position [[position]];
} LightMaskOut;

vertex LightMaskOut
light_mask_vertex(device float4         * vertices        [[ buffer(AAPLBufferIndexMeshPositions) ]],
                  device AAPLPointLight * light_data      [[ buffer(AAPLBufferIndexLightsData) ]],
                  device vector_float4  * light_positions [[ buffer(AAPLBufferIndexLightsPosition) ]],
                  constant AAPLUniforms & uniforms        [[ buffer(AAPLBufferIndexUniforms) ]],
                  uint                    iid             [[ instance_id ]],
                  uint                    vid             [[ vertex_id ]])
{
    LightMaskOut out;

    // Transform light to position relative to the temple
    float4 vertex_eye_position = float4(vertices[vid].xyz * light_data[iid].light_radius + light_positions[iid].xyz, 1);

    out.position = uniforms.projection_matrix * vertex_eye_position;

    return out;
}
#endif // END LIGHT_STENCIL_CULLING

#if SUPPORT_BUFFER_EXAMINATION_MODE
fragment float4
light_mask_info_rendering(constant float4 & color [[ buffer(0) ]])
{
    return color;
}
#endif

#pragma mark POINT LIGHTING

typedef struct
{
    float4 position [[position]];
    float3 eye_position;
    uint   iid [[flat]];
} LightInOut;

vertex LightInOut
deferred_point_lighting_vertex(device float4         * vertices        [[ buffer(AAPLBufferIndexMeshPositions) ]],
                               device AAPLPointLight * light_data      [[ buffer(AAPLBufferIndexLightsData) ]],
                               device vector_float4  * light_positions [[ buffer(AAPLBufferIndexLightsPosition) ]],
                               constant AAPLUniforms & uniforms        [[ buffer(AAPLBufferIndexUniforms) ]],
                               uint                    iid             [[ instance_id ]],
                               uint                    vid             [[ vertex_id ]])
{
    LightInOut out;

    // Transform light to position relative to the temple
    float3 vertex_eye_position = vertices[vid].xyz * light_data[iid].light_radius + light_positions[iid].xyz;

    out.position = uniforms.projection_matrix * float4(vertex_eye_position, 1);

    // Sending light position in view space to next stage
    out.eye_position = vertex_eye_position;

    out.iid = iid;

    return out;
}

half4
deferred_point_lighting_fragment_common(LightInOut              in,
                                        device AAPLPointLight * light_data,
                                        device vector_float4  * light_positions,
                                        constant AAPLUniforms & uniforms,
                                        half4                   lighting,
                                        float                   depth,
                                        half4                   normal_shadow,
                                        half4                   albedo_specular)
{

#if USE_EYE_DEPTH

    // Used eye_space depth to determine the position of the fragment in eye_space
    float3 eye_space_fragment_pos = in.eye_position * (depth / in.eye_position.z);

#else // IF NOT USE_EYE_DEPTH

    // Use screen space position and depth with the inverse projection matrix to determine
    // the position of the fragment in eye space
    uint2 screen_space_position = uint2(in.position.xy);

    float2 normalized_screen_position;

    normalized_screen_position.x = 2.0  * ((screen_space_position.x/(float)uniforms.framebuffer_width) - 0.5);
    normalized_screen_position.y = 2.0  * ((1.0 - (screen_space_position.y/(float)uniforms.framebuffer_height)) - 0.5);

    float4 ndc_fragment_pos = float4 (normalized_screen_position.x,
                                      normalized_screen_position.y,
                                      depth,
                                      1.0f);

    ndc_fragment_pos = uniforms.projection_matrix_inverse * ndc_fragment_pos;

    float3 eye_space_fragment_pos = ndc_fragment_pos.xyz / ndc_fragment_pos.w;

#endif // END not USE_EYE_DEPTH

    float3 light_eye_position = light_positions[in.iid].xyz;
    float light_distance = length(light_eye_position - eye_space_fragment_pos);
    float light_radius = light_data[in.iid].light_radius;

    if (light_distance < light_radius)
    {
        float4 eye_space_light_pos = float4(light_eye_position,1);

        float3 eye_space_fragment_to_light = eye_space_light_pos.xyz - eye_space_fragment_pos;

        float3 light_direction = normalize(eye_space_fragment_to_light);

        half3 light_color = half3(light_data[in.iid].light_color);

        // Diffuse contribution
        half4 diffuse_contribution = half4(float4(albedo_specular)*max(dot(float3(normal_shadow.xyz), light_direction),0.0f))*half4(light_color,1);

        // Specular Contribution
        float3 halfway_vector = normalize(eye_space_fragment_to_light - eye_space_fragment_pos);

        half specular_intensity = half(uniforms.fairy_specular_intensity);

        half specular_shininess = normal_shadow.w * half(uniforms.shininess_factor);

        half specular_factor = powr(max(dot(half3(normal_shadow.xyz),half3(halfway_vector)),0.0h), specular_intensity);

        half3 specular_contribution = specular_factor * half3(albedo_specular.xyz) * specular_shininess * light_color;

        // Light falloff
        float attenuation = 1.0 - (light_distance / light_radius);
        attenuation *= attenuation;

        lighting += (diffuse_contribution + half4(specular_contribution, 0)) * attenuation;
    }

    return lighting;
}

#ifdef __METAL_IOS__

fragment AccumLightBuffer
deferred_point_lighting_fragment(LightInOut              in              [[ stage_in ]],
                                 constant AAPLUniforms & uniforms        [[ buffer(AAPLBufferIndexUniforms) ]],
                                 device AAPLPointLight * light_data      [[ buffer(AAPLBufferIndexLightsData) ]],
                                 device vector_float4  * light_positions [[ buffer(AAPLBufferIndexLightsPosition) ]],
                                 GBufferData             GBuffer)
{
    AccumLightBuffer output;
    output.lighting =
        deferred_point_lighting_fragment_common(in, light_data, light_positions, uniforms,
                                                GBuffer.lighting, GBuffer.depth, GBuffer.normal_shadow, GBuffer.albedo_specular);

    return output;
}

#else // END iOS / BEGIN macOS

fragment half4
deferred_point_lighting_fragment(LightInOut              in                      [[ stage_in ]],
                                 constant AAPLUniforms & uniforms                [[ buffer(AAPLBufferIndexUniforms) ]],
                                 device AAPLPointLight * light_data              [[ buffer(AAPLBufferIndexLightsData) ]],
                                 device vector_float4  * light_positions         [[ buffer(AAPLBufferIndexLightsPosition) ]],
                                 texture2d<half>         albedo_specular_GBuffer [[ texture(AAPLRenderTargetAlbedo) ]],
                                 texture2d<half>         normal_shadow_GBuffer   [[ texture(AAPLRenderTargetNormal) ]],
                                 texture2d<float>        depth_GBuffer           [[ texture(AAPLRenderTargetDepth) ]])
{
    uint2 position = uint2(in.position.xy);

    half4 lighting = half4(0);
    float depth = depth_GBuffer.read(position.xy).x;
    half4 normal_shadow = normal_shadow_GBuffer.read(position.xy);
    half4 albedo_spacular = albedo_specular_GBuffer.read(position.xy);

    return deferred_point_lighting_fragment_common(in, light_data, light_positions, uniforms,
                                                   lighting, depth, normal_shadow, albedo_spacular);
}

#endif  // END macOS point light shader

