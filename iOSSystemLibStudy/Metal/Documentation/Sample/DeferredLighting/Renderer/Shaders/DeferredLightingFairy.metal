/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used to render fairies
*/

#if TARGET_OS_IPHONE

#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "DeferredLightingShaderTypes.h"

// Include header shared between all Metal shader code files
#import "DeferredLightingShaderCommon.h"

typedef struct
{
    float4 position [[position]];
    half3 color;
    half2 tex_coord;
} FairyInOut;

vertex FairyInOut fairy_vertex(constant AAPLSimpleVertex * vertices        [[ buffer(AAPLBufferIndexMeshPositions) ]],
                               device AAPLPointLight     * light_data      [[ buffer(AAPLBufferIndexLightsData) ]],
                               device vector_float4      * light_positions [[ buffer(AAPLBufferIndexLightsPosition) ]],
                               constant AAPLUniforms     & uniforms        [[ buffer(AAPLBufferIndexUniforms) ]],
                               uint                        iid             [[ instance_id ]],
                               uint                        vid             [[ vertex_id ]])
{
    FairyInOut out;

    float3 vertex_position = float3(vertices[vid].position.xy,0);

    float4 fairy_eye_pos = light_positions[iid];

    float4 vertex_eye_position = float4(uniforms.fairy_size * vertex_position + fairy_eye_pos.xyz, 1);

    out.position = uniforms.projection_matrix * vertex_eye_position;

    // Pass fairy color through
    out.color = half3(light_data[iid].light_color.xyz);

    // Convert model position which ranges from [-1, 1] to texture coordinates which ranges
    // from [0-1]
    out.tex_coord = 0.5 * (half2(vertices[vid].position.xy) + 1);

    return out;
}

fragment half4 fairy_fragment(FairyInOut      in       [[ stage_in ]],
                              texture2d<half> colorMap [[ texture(AAPLTextureIndexAlpha) ]])
{
    constexpr sampler linearSampler (mip_filter::linear,
                                     mag_filter::linear,
                                     min_filter::linear);

    half4 c = colorMap.sample(linearSampler, float2(in.tex_coord));

    half3 fragColor = in.color * c.x;

    return half4(fragColor, c.x);
}

#endif

