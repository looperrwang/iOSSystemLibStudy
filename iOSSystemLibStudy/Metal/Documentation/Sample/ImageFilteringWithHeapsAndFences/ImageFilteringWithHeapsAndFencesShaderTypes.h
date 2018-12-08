/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header containing types and enum constants shared between Metal shaders and C/ObjC source
*/
#ifndef ImageFilteringWithHeapsAndFencesShaderTypes_h
#define ImageFilteringWithHeapsAndFencesShaderTypes_h

#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum AAPLBlurBufferIndex
{
    AAPLBlurBufferIndexLOD = 0,
} AAPLBlurBufferIndex;

typedef enum AAPLVertexBufferIndex
{
    AAPLVertexBufferIndexVertices = 0,
    AAPLVertexBufferIndexScale    = 1,
} AAPLVertexBufferIndex;

typedef enum AAPLFragmentBufferIndex
{
    AAPLFragmentBufferIndexMipBias,
} AAPLFragmentBufferIndex;

// Texture index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum AAPLBlurTextureIndex
{
    AAPLBlurTextureIndexInput  = 0,
    AAPLBlurTextureIndexOutput = 1,
} AAPLBlurTextureIndex;

typedef enum AAPLFragmentTextureIndex
{
    AAPLFragmentTextureIndexImage
} AAPLFragmentTextureIndex;

// Defines the layout of each vertex in the array of vertices set as an input to the vertex shader
typedef struct AAPLVertex {
    vector_float2 position;
    vector_float2 texCoord;
} AAPLVertex;

#endif // ImageFilteringWithHeapsAndFencesShaderTypes_h
