/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used to render shadow maps
*/
#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#import "AAPLShaderTypes.h"

typedef struct ShadowOutput
{
    float4 position [[position]];
} ShadowOutput;

vertex ShadowOutput shadow_vertex(device AAPLShadowVertex * positions [[ buffer(AAPLBufferIndexMeshPositions) ]],
                                  constant AAPLUniforms   & uniforms  [[ buffer(AAPLBufferIndexUniforms) ]],
                                  uint                      vid       [[ vertex_id ]])
{
    ShadowOutput out;

    // Add vertex pos to fairy position and project to clip-space
    out.position = uniforms.shadow_mvp_matrix * float4(positions[vid].position, 1.0);

    return out;
}
