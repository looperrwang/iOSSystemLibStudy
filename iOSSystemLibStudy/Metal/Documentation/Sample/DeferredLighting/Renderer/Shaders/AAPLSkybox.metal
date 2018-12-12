/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used to render skybox
*/
#import <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "AAPLShaderTypes.h"

// Per-vertex inputs fed by vertex buffer laid out with MTLVertexDescriptor in Metal API
typedef struct
{
    float4 position [[attribute(AAPLVertexAttributePosition)]];
    float3 normal    [[attribute(AAPLVertexAttributeNormal)]];
} SkyboxVertex;

typedef struct
{
    float4 position [[position]];
    float3 texcoord;
} SkyboxInOut;

vertex SkyboxInOut skybox_vertex(SkyboxVertex            in       [[ stage_in ]],
                                 constant AAPLUniforms & uniforms [[ buffer(AAPLBufferIndexUniforms) ]])
{
    SkyboxInOut out;

    // Add vertex pos to fairy position and project to clip-space
    out.position = uniforms.projection_matrix * uniforms.sky_modelview_matrix * in.position;

    // Pass position through as texcoord
    out.texcoord = in.normal;

    return out;
}

fragment half4 skybox_fragment(SkyboxInOut        in             [[ stage_in ]],
                               texturecube<float> skybox_texture [[ texture(AAPLTextureIndexBaseColor) ]])
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

    float4 color = skybox_texture.sample(linearSampler, in.texcoord);

    return half4(color);
}

