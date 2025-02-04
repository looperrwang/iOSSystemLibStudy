/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for mesh and submesh objects used for managing models
*/

#if TARGET_OS_IPHONE

@import Foundation;
@import MetalKit;
@import simd;

#include "LODwithFunctionSpecializationShaderTypes.h"

// App specific submesh class containing data to draw a submesh
@interface LODwithFunctionSpecializationSubmesh : NSObject

// Sets the weight of values sampled from a texture vs a material uniform for a transition
//   between levels.
- (void)computeTextureWeightsForQualityLevel:(AAPLQualityLevel)quality
                        withGlobalMapWeight:(float)globalWeight;

// A MetalKit submesh mesh containing the primitive type, index buffer, and index count
//   used to draw all or part of its parent LODwithFunctionSpecializationMesh object
@property (nonatomic, readonly, nonnull) MTKSubmesh *metalKitSubmmesh;

// Material textures (indexed by AAPLTextureIndex) to set in the Metal Render Command Encoder
//  before drawing the submesh.  Used for higher LODs
@property (nonatomic, readonly, nonnull) NSArray<id<MTLTexture>> *textures;

// Material uniforms used instead of texture when rendering with lower LODs
@property (nonatomic, readonly, nonnull) id<MTLBuffer> materialUniforms;

@end

// App specific mesh class containing vertex data describing the mesh and submesh object describing
//   how to draw parts of the mesh
@interface LODwithFunctionSpecializationMesh : NSObject

// Constructs an array of meshes from the provided file URL, which indicate the location of a model
//  file in a format supported by Model I/O, such as OBJ, ABC, or USD.  the Model I/O vertex
//  descriptor defines the layout Model I/O will use to arrange the vertex data while the
//  bufferAllocator supplies allocations of Metal buffers to store vertex and index data
+ (nullable NSArray<LODwithFunctionSpecializationMesh *> *) newMeshesFromURL:(nonnull NSURL *)url
                            modelIOVertexDescriptor:(nonnull MDLVertexDescriptor *)vertexDescriptor
                                        metalDevice:(nonnull id<MTLDevice>)device
                                              error:(NSError * __nullable * __nullable)error;

+ (BOOL)isTexturedProperty:(AAPLFunctionConstant)propertyIndex atQualityLevel:(AAPLQualityLevel)quality;

// A MetalKit mesh containing vertex buffers describing the shape of the mesh
@property (nonatomic, readonly, nonnull) MTKMesh *metalKitMesh;

// An array of LODwithFunctionSpecializationSubmesh objects containing buffers and data with which we can make a draw call
//  and material data to set in a Metal render command encoder for that draw call
@property (nonatomic, readonly, nonnull) NSArray<LODwithFunctionSpecializationSubmesh*> *submeshes;

@end

#endif
