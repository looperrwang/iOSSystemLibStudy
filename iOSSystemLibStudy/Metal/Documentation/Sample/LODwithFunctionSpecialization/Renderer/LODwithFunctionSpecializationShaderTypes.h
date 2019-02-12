/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header containing types and enum constants shared between Metal shaders and C/ObjC source
*/

#if TARGET_OS_IPHONE

#ifndef LODwithFunctionSpecializationShaderTypes_h
#define LODwithFunctionSpecializationShaderTypes_h

#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum AAPLBufferIndex
{
    AAPLBufferIndexMeshPositions    = 0,
    AAPLBufferIndexMeshGenerics     = 1,
    AAPLBufferIndexUniforms         = 2,
    AAPLBufferIndexMaterialUniforms = 3
} AAPLBufferIndex;

// Attribute index values shared between shader and C code to ensure Metal shader vertex
//   attribute indices match the Metal API vertex descriptor attribute indices
typedef enum AAPLVertexAttribute
{
    AAPLVertexAttributePosition  = 0,
    AAPLVertexAttributeTexcoord  = 1,
    AAPLVertexAttributeNormal    = 2,
    AAPLVertexAttributeTangent   = 3,
    AAPLVertexAttributeBitangent = 4
} AAPLVertexAttribute;

// Texture index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
typedef enum AAPLTextureIndex
{
    AAPLTextureIndexBaseColor        = 0,
    AAPLTextureIndexMetallic         = 1,
    AAPLTextureIndexRoughness        = 2,
    AAPLTextureIndexNormal           = 3,
    AAPLTextureIndexAmbientOcclusion = 4,
    AAPLTextureIndexIrradianceMap    = 5,
    AAPLNumMeshTextureIndices = AAPLTextureIndexAmbientOcclusion+1,
} AAPLTextureIndex;

typedef enum AAPLFunctionConstant
{
    AAPLFunctionConstantBaseColorMapIndex,
    AAPLFunctionConstantNormalMapIndex,
    AAPLFunctionConstantMetallicMapIndex,
    AAPLFunctionConstantRoughnessMapIndex,
    AAPLFunctionConstantAmbientOcclusionMapIndex,
    AAPLFunctionConstantIrradianceMapIndex
} AAPLFunctionConstant;

typedef enum AAPLViewports
{
    AAPLViewportLeft  = 0,
    AAPLViewportRight = 1,
    AAPLNumViewports
} AAPLViewports;

typedef enum AAPLQualityLevel
{
    AAPLQualityLevelHigh   = 0,
    AAPLQualityLevelMedium = 1,
    AAPLQualityLevelLow    = 2,
    AAPLNumQualityLevels
} AAPLQualityLevel;

// Structure shared between shader and C code to ensure the layout of uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct
{
    // Per Frame Uniforms
    vector_float3 cameraPos;
    
    // Per Mesh Uniforms
    matrix_float4x4 modelMatrix;
    matrix_float4x4 modelViewProjectionMatrix;
    matrix_float3x3 normalMatrix;

    // Per Light Properties
    vector_float3 directionalLightInvDirection;
    vector_float3 lightPosition;

    vector_float3 irradiatedColor;
    float irradianceMapWeight;
} AAPLUniforms;

typedef struct
{
    vector_float3 baseColor;
    vector_float3 irradiatedColor;
    vector_float3 roughness;
    vector_float3 metalness;
    float         ambientOcclusion;
    float         mapWeights[AAPLNumMeshTextureIndices];
} AAPLMaterialUniforms;


#endif /* LODwithFunctionSpecializationShaderTypes_h */

#endif
