/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used to render buffer examination mode
*/
#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "AAPLShaderTypes.h"

#if SUPPORT_BUFFER_EXAMINATION_MODE

// Include header shared between all Metal shader code files
#import "AAPLShaderCommon.h"

typedef struct LightInfoData
{
    float4 position [[position]];
} LightInfoData;

vertex LightInfoData
light_volume_visualization_vertex(device float4           *vertices        [[ buffer(AAPLBufferIndexMeshPositions) ]],
                                  device AAPLPointLight   *light_data      [[ buffer(AAPLBufferIndexLightsData) ]],
                                  device vector_float4    *light_positions [[ buffer(AAPLBufferIndexLightsPosition) ]],
                                  uint                     iid             [[ instance_id ]],
                                  uint                     vid             [[ vertex_id ]],
                                  constant AAPLUniforms &  uniforms        [[ buffer(AAPLBufferIndexUniforms) ]])
{
    LightInfoData out;

    // Transform light to position relative to the temple
    float4 vertex_view_position = float4(vertices[vid].xyz * light_data[iid].light_radius + light_positions[iid].xyz, 1);

    out.position = uniforms.projection_matrix * vertex_view_position;

    return out;
}

fragment float4
light_volume_visualization_fragment(constant float4 & color [[ buffer(AAPLBufferIndexFlatColor) ]])
{
    return color;
}

typedef struct RenderTextureData
{
    float4 position [[position]];
    float2 tex_coord;
} RenderTextureData;

vertex RenderTextureData
texture_values_vertex(device AAPLSimpleVertex *vertices [[ buffer(AAPLBufferIndexMeshPositions) ]],
                      uint                     vid             [[ vertex_id ]])
{
    RenderTextureData out;

    out.position = float4(vertices[vid].position, 0, 1);
    out.tex_coord = (out.position.xy + 1) * .5;
    out.tex_coord.y = 1-out.tex_coord.y;

    return out;
}

fragment half4
texture_rgb_fragment(RenderTextureData in      [[ stage_in ]],
                     texture2d<half>   texture [[ texture(AAPLTextureIndexBaseColor) ]])
{
    constexpr sampler linearSampler(mip_filter::none,
                                    mag_filter::linear,
                                    min_filter::linear);

    half4 sample = texture.sample(linearSampler, in.tex_coord);

    return sample;
}

fragment half4
texture_alpha_fragment(RenderTextureData in      [[ stage_in ]],
                       texture2d<float>   texture [[ texture(AAPLTextureIndexBaseColor) ]])
{
    constexpr sampler linearSampler(mip_filter::none,
                                    mag_filter::linear,
                                    min_filter::linear);

    float4 sample = texture.sample(linearSampler, in.tex_coord);

    return half4(sample.wwww);
}

// Used to visualize the linear depth buffer

fragment half4
texture_depth_fragment(RenderTextureData   in         [[ stage_in ]],
                       texture2d<float>    texture    [[ texture(AAPLTextureIndexBaseColor) ]],
                       constant float    & depthRange [[ buffer(AAPLBufferIndexDepthRange) ]])
{
    constexpr sampler linearSampler(mip_filter::none,
                                    mag_filter::linear,
                                    min_filter::linear);

    float sample = texture.sample(linearSampler, in.tex_coord).x;

    return sample / depthRange;
}

#endif
