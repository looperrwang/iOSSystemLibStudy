/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header containing types and enum constants shared between Metal shaders and C/ObjC source
*/

#if TARGET_OS_IPHONE

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

// Constants shared between shader and C code
#define AAPLNumObjects    65536

#define AAPLGridWidth     256

#define AAPLGridHeight    ((AAPLNumObjects+AAPLGridWidth-1)/AAPLGridWidth)

// Scale of each object when drawn
#define AAPLViewScale    0.25

// Because the objects are centered at origin, the scale appliced
#define AAPLObjectSize    2.0

// Distance between each object
#define AAPLObjecDistance 2.1

#define USE_SINGLE_BUFFER_FOR_ALL_MESHES 1
#if TARGET_IOS
// iOS GPUs can only access a limited number of buffers in an so all meshes are paced into a single
// buffer.
// macOS GPUs, however, can access a much larger number of buffers, so by default, this is not set.
// While this must be set to 1 for iOS, this can be set to any value on macOS.
#define USE_SINGLE_BUFFER_FOR_ALL_MESHES 1
#endif


#if USE_SINGLE_BUFFER_FOR_ALL_MESHES

#define AAPLNumVertexBuffers 1

#else // ELSE IF !USE_SINGLE_BUFFER_FOR_ALL_MESHES

#define AAPLNumVertexBuffers AAPLNumObjects

#endif  // END !USE_SINGLE_BUFFER_FOR_ALL_MESHES

// Structure defining the layout of each vertex.  Shared between C code filling in the vertex data
//   and Metal vertex shader consuming the vertices
typedef struct
{
    packed_float2 position;
    packed_float2 texcoord;
} AAPLVertex;

// Structure defining the layout of variable changing once (or less) per frame
typedef struct AAPLFrameState
{
    vector_float2 translation;
    vector_float2 aspectScale;
} AAPLFrameState;

// Structure defining parameters for each rendered object
typedef struct AAPLObjectPerameters
{
    packed_float2 position;
    float boundingRadius;
    uint32_t numVertices;
    uint32_t startVertex;
} AAPLObjectPerameters;

// Buffer index values shared between the vertex shader and C code
typedef enum AAPLVertexBufferIndex
{
    AAPLVertexBufferIndexVertices,
    AAPLVertexBufferIndexObjectParams,
    AAPLVertexBufferIndexFrameState
} AAPLVertexBufferIndex;

// Buffer index values shared between the compute kernel and C code
typedef enum AAPLKernelBufferIndex
{
    AAPLKernelBufferIndexFrameState,
    AAPLKernelBufferIndexObjectParams,
    AAPLKernelBufferIndexVertices,
    AAPLKernelBufferIndexCommandBufferContainer
} AAPLKernelBufferIndex;

typedef enum AAPLArgumentBufferBufferID
{
    AAPLArgumentBufferIDCommandBuffer,
} AAPLArgumentBufferBufferID;

#endif /* ShaderTypes_h */

#endif
