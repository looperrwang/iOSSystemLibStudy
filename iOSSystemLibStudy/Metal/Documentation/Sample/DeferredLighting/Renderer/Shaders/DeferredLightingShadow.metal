/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used to render shadow maps
*/

#if TARGET_OS_IPHONE

#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "DeferredLightingShaderTypes.h"

typedef struct ShadowOutput
{
    float4 position [[position]];
} ShadowOutput;

vertex ShadowOutput shadow_vertex(device DeferredLightingShadowVertex * positions [[ buffer(AAPLBufferIndexMeshPositions) ]],
                                  constant AAPLUniforms   & uniforms  [[ buffer(AAPLBufferIndexUniforms) ]],
                                  uint                      vid       [[ vertex_id ]])
{
    ShadowOutput out;

    // Add vertex pos to fairy position and project to clip-space
    out.position = uniforms.shadow_mvp_matrix * float4(positions[vid].position, 1.0);

    return out;
}

#endif
