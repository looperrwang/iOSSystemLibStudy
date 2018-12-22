/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation for Mesh and Submesh objects
*/
@import MetalKit;
@import ModelIO;

#import "LODwithFunctionSpecializationMesh.h"
#import "AAPLMathUtilities.h"

@implementation LODwithFunctionSpecializationSubmesh
{
    NSMutableArray<id<MTLTexture>> *_textures;
    AAPLMaterialUniforms *_uniforms;
    id<MTLBuffer> _materialUniforms;
}

@synthesize textures = _textures;
@synthesize materialUniforms = _materialUniforms;

/// Create a metal texture with the given semantic in the given Model I/O material object
+ (nonnull id<MTLTexture>) createMetalTextureFromMaterial:(nonnull MDLMaterial *)material
                                  modelIOMaterialSemantic:(MDLMaterialSemantic)materialSemantic
                                      modelIOMaterialType:(MDLMaterialPropertyType)defaultPropertyType
                                    metalKitTextureLoader:(nonnull MTKTextureLoader *)textureLoader
                                          materialUniform:(nullable void *)uniform
{
    id<MTLTexture> texture = nil;

    NSArray<MDLMaterialProperty *> *propertiesWithSemantic
        = [material propertiesWithSemantic:materialSemantic];

    for (MDLMaterialProperty *property in propertiesWithSemantic)
    {
        assert(property.semantic == materialSemantic);

        if(property.type == MDLMaterialPropertyTypeString)
        {
            // Load our textures with TextureUsageShaderRead and StorageModePrivate
            NSDictionary *textureLoaderOptions =
            @{
              MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
              MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate)
              };
            
            // First will interpret the string as a file path and attempt to load it with
            //    -[MTKTextureLoader newTextureWithContentsOfURL:options:error:]
            NSMutableString *URLString = [[NSMutableString alloc] initWithString:@"file://"];
            [URLString appendString:property.stringValue];
            NSURL *textureURL = [NSURL URLWithString:URLString];

            // Attempt to load the texture from the file system
            texture = [textureLoader newTextureWithContentsOfURL:textureURL
                                                         options:textureLoaderOptions
                                                           error:nil];

            // If we found a texture using the string as a file path name...
            if(texture)
            {
                continue;
            }

            // If we did not find a texture by interpreting the URL as a path, we'll interpret
            //   the last component of the URL as an asset catalog name and attempt to load it
            //   with -[MTKTextureLoader newTextureWithName:scaleFactor:bundle:options::error:]

            NSString *lastComponent =
                [[property.stringValue componentsSeparatedByString:@"/"] lastObject];

            texture = [textureLoader newTextureWithName:lastComponent
                                            scaleFactor:1.0
                                                 bundle:nil
                                                options:textureLoaderOptions
                                                  error:nil];

            // If we found a texture with the string in our asset catalog...
            if(texture) {
                continue;
            }

            // If we did not find the texture by interpreting the strung as a file path or as an
            //   asset name in our asset catalog, something went wrong (Perhaps the file was missing
            //   or  misnamed in the asset catalog, model/material file, or file system)

            // Depending on how the Metal render pipeline used with this submesh is implemented,
            //   this condition could be handled more gracefully.  The app could load a dummy texture
            //   that will look okay when set with the pipeline or ensure that the pipeline rendering
            //   this submesh does not require a material with this property.ty.
           
            [NSException raise:@"Texture data for material property not found"
                        format:@"Requested material property semantic: %lu string: %@",
                                materialSemantic, property.stringValue];
        }
        else if (uniform && defaultPropertyType !=  MDLMaterialPropertyTypeNone && property.type == defaultPropertyType)
        {
            switch (defaultPropertyType)
            {
                case MDLMaterialPropertyTypeFloat:
                    *(float *)uniform = property.floatValue;
                    break;
                case MDLMaterialPropertyTypeFloat3:
                    *(vector_float3 *)uniform = property.float3Value;
                    break;
                default:
                    [NSException raise:@"Invalid MDLMaterialPropertyType for semantic"
                            format:@"Requested MDLMaterialPropertyType(%lu) for material property semantic(%lu)",
                                    defaultPropertyType, materialSemantic];
            }
        }
    }

    if (!texture)
    {
        [NSException raise:@"No appropriate material property from which to create texture"
                format:@"Requested material property semantic: %lu", materialSemantic];
    }

    return texture;
}

- (nonnull instancetype) initWithModelIOSubmesh:(nonnull MDLSubmesh *)modelIOSubmesh
                                metalKitSubmesh:(nonnull MTKSubmesh *)metalKitSubmesh
                          metalKitTextureLoader:(nonnull MTKTextureLoader *)textureLoader
{
    self = [super init];
    if(self)
    {
        _metalKitSubmmesh = metalKitSubmesh;

        _textures = [[NSMutableArray alloc] initWithCapacity:AAPLNumMeshTextureIndices];

        // Fill up our texture array with null objects so that we can fill it by indexing into it
        for(NSUInteger shaderIndex = 0; shaderIndex < AAPLNumMeshTextureIndices; shaderIndex++) {
            [_textures addObject:(id<MTLTexture>)[NSNull null]];
        }

        //create the uniform buffer
        _materialUniforms = [textureLoader.device newBufferWithLength:sizeof(AAPLMaterialUniforms)
                                                              options:0];

        if (!_materialUniforms)
        {
            [NSException raise:@"Could not create uniform buffer"
                        format:@""];
        }

        _uniforms = (AAPLMaterialUniforms *)_materialUniforms.contents;

        // Set default material uniforms
        _uniforms->baseColor = (vector_float3){0.3, 0.0, 0.0};
        _uniforms->roughness = 0.2f;
        _uniforms->metalness = 0;
        _uniforms->ambientOcclusion = 0.5f;
        _uniforms->irradiatedColor = (vector_float3){1.0, 1.0, 1.0};

        // Set each index in our array with the appropriate material semantic specified in the
        //   submesh's material property

        _textures[AAPLTextureIndexBaseColor] =
            [LODwithFunctionSpecializationSubmesh createMetalTextureFromMaterial:modelIOSubmesh.material
                                modelIOMaterialSemantic:MDLMaterialSemanticBaseColor
                                    modelIOMaterialType:MDLMaterialPropertyTypeFloat3
                                  metalKitTextureLoader:textureLoader
                                     materialUniform:&(_uniforms->baseColor)];

        _textures[AAPLTextureIndexMetallic] =
            [LODwithFunctionSpecializationSubmesh createMetalTextureFromMaterial:modelIOSubmesh.material
                                modelIOMaterialSemantic:MDLMaterialSemanticMetallic
                                    modelIOMaterialType:MDLMaterialPropertyTypeFloat3
                                  metalKitTextureLoader:textureLoader
                                        materialUniform:&(_uniforms->metalness)];

        _textures[AAPLTextureIndexRoughness] =
        [LODwithFunctionSpecializationSubmesh createMetalTextureFromMaterial:modelIOSubmesh.material
                            modelIOMaterialSemantic:MDLMaterialSemanticRoughness
                                modelIOMaterialType:MDLMaterialPropertyTypeFloat3
                              metalKitTextureLoader:textureLoader
                                    materialUniform:&(_uniforms->roughness)];
        
        _textures[AAPLTextureIndexNormal] =
        [LODwithFunctionSpecializationSubmesh createMetalTextureFromMaterial:modelIOSubmesh.material
                            modelIOMaterialSemantic:MDLMaterialSemanticTangentSpaceNormal
                                modelIOMaterialType:MDLMaterialPropertyTypeNone
                              metalKitTextureLoader:textureLoader
                                    materialUniform:nil];
        
        _textures[AAPLTextureIndexAmbientOcclusion] =
            [LODwithFunctionSpecializationSubmesh createMetalTextureFromMaterial:modelIOSubmesh.material
                            modelIOMaterialSemantic:MDLMaterialSemanticAmbientOcclusion
                                    modelIOMaterialType:MDLMaterialPropertyTypeNone
                                  metalKitTextureLoader:textureLoader
                                        materialUniform:nil];
    }
    return self;
}

- (AAPLFunctionConstant)mapTextureBindPointToFunctionConstantIndex:(AAPLTextureIndex)textureIndex
{
    switch (textureIndex)
    {
        case AAPLTextureIndexBaseColor:
            return AAPLFunctionConstantBaseColorMapIndex;
        case AAPLTextureIndexNormal:
            return AAPLFunctionConstantNormalMapIndex;
        case AAPLTextureIndexMetallic:
            return AAPLFunctionConstantMetallicMapIndex;
        case AAPLTextureIndexAmbientOcclusion:
            return AAPLFunctionConstantAmbientOcclusionMapIndex;
        case AAPLTextureIndexRoughness:
            return AAPLFunctionConstantRoughnessMapIndex;
        default:
            assert(false);
    }
}

- (void)computeTextureWeightsForQualityLevel:(AAPLQualityLevel)quality
                        withGlobalMapWeight:(float)globalWeight
{
    for(AAPLTextureIndex textureIndex = 0; textureIndex < AAPLNumMeshTextureIndices; textureIndex++)
    {
        AAPLFunctionConstant constantIndex =
            [self mapTextureBindPointToFunctionConstantIndex:textureIndex];

        if( [LODwithFunctionSpecializationMesh isTexturedProperty:constantIndex atQualityLevel:quality] &&
           ![LODwithFunctionSpecializationMesh isTexturedProperty:constantIndex atQualityLevel:quality+1])
        {
            _uniforms->mapWeights[textureIndex] = globalWeight;
        }
        else
        {
             _uniforms->mapWeights[textureIndex] = 1.0;
        }
    }
}

@end

@implementation LODwithFunctionSpecializationMesh
{
    NSMutableArray<LODwithFunctionSpecializationSubmesh *> *_submeshes;
}

@synthesize submeshes = _submeshes;

/// Load the Model I/O mesh, including vertex data and submesh data which have index buffers and
///   textures.  Also generate tangent and bitangent vertex attributes
- (nonnull instancetype) initWithModelIOMesh:(nonnull MDLMesh *)modelIOMesh
                     modelIOVertexDescriptor:(nonnull MDLVertexDescriptor *)vertexDescriptor
                       metalKitTextureLoader:(nonnull MTKTextureLoader *)textureLoader
                                 metalDevice:(nonnull id<MTLDevice>)device
                                       error:(NSError * __nullable * __nullable)error
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    [modelIOMesh addNormalsWithAttributeNamed:MDLVertexAttributeNormal
                       creaseThreshold:0.2];
    
    // Have Model I/O create the tangents from mesh texture coordinates and normals
    [modelIOMesh addTangentBasisForTextureCoordinateAttributeNamed:MDLVertexAttributeTextureCoordinate
                                              normalAttributeNamed:MDLVertexAttributeNormal
                                             tangentAttributeNamed:MDLVertexAttributeTangent];

    // Have Model I/O create bitangents from mesh texture coordinates and the newly created tangents
    [modelIOMesh addTangentBasisForTextureCoordinateAttributeNamed:MDLVertexAttributeTextureCoordinate
                                             tangentAttributeNamed:MDLVertexAttributeTangent
                                           bitangentAttributeNamed:MDLVertexAttributeBitangent];

    // Apply the Model I/O vertex descriptor we created to match the Metal vertex descriptor.
    // Assigning a new vertex descriptor to a Model I/O mesh performs a re-layout of the vertex
    //   data.  In this case we created the Model I/O vertex descriptor so that the layout of the
    //   vertices in the Model I/O mesh match the layout of vertices our Metal render pipeline
    //   expects as input into its vertex shader
    // Note that we can only perform this re-layout operation after we have created tangents and
    //   bitangents (as we did above).  This is because Model I/O's addTangentBasis methods only work
    //   with vertex data is all in 32-bit floating-point.  The vertex descriptor we're applying
    //   changes some 32-bit floats into 16-bit floats or other types from which Model I/O cannot
    //   produce tangents

    modelIOMesh.vertexDescriptor = vertexDescriptor;

    // Create the metalKit mesh which will contain the Metal buffer(s) with the mesh's vertex data
    //   and submeshes with info to draw the mesh
    MTKMesh* metalKitMesh = [[MTKMesh alloc] initWithMesh:modelIOMesh
                                                   device:device
                                                    error:error];

    _metalKitMesh = metalKitMesh;

    // There should always be the same number of MetalKit submeshes in the MetalKit mesh as there
    //   are Model I/O submeshes in the Model I/O mesh
    assert(metalKitMesh.submeshes.count == modelIOMesh.submeshes.count);

    // Create an array to hold this LODwithFunctionSpecializationMesh object's LODwithFunctionSpecializationSubmesh objects
    _submeshes = [[NSMutableArray alloc] initWithCapacity:metalKitMesh.submeshes.count];

    // Create an LODwithFunctionSpecializationSubmesh object for each submesh and a add it to our submeshes array
    for(NSUInteger index = 0; index < metalKitMesh.submeshes.count; index++) {
        // Create our own app specific submesh to hold the MetalKit submesh
        LODwithFunctionSpecializationSubmesh *submesh =
        [[LODwithFunctionSpecializationSubmesh alloc] initWithModelIOSubmesh:modelIOMesh.submeshes[index]
                                    metalKitSubmesh:metalKitMesh.submeshes[index]
                              metalKitTextureLoader:textureLoader];

        [_submeshes addObject:submesh];
    }

    return self;
}

/// Traverses the Model I/O object hierarchy picking out Model I/O mesh objects and creating Metal
///   vertex buffers, index buffers, and textures from them
+ (NSArray<LODwithFunctionSpecializationMesh*> *) newMeshesFromObject:(nonnull MDLObject*)object
                     modelIOVertexDescriptor:(nonnull MDLVertexDescriptor*)vertexDescriptor
                       metalKitTextureLoader:(nonnull MTKTextureLoader *)textureLoader
                                 metalDevice:(nonnull id<MTLDevice>)device
                                       error:(NSError * __nullable * __nullable)error {

    NSMutableArray<LODwithFunctionSpecializationMesh *> *newMeshes = [[NSMutableArray alloc] init];

    // If this Model I/O  object is a mesh object (not a camera, light, or something else)...
    if ([object isKindOfClass:[MDLMesh class]])
    {
        //...create an app-specific LODwithFunctionSpecializationMesh object from it
        MDLMesh* mesh = (MDLMesh*) object;
        
        LODwithFunctionSpecializationMesh *newMesh = [[LODwithFunctionSpecializationMesh alloc] initWithModelIOMesh:mesh
                                          modelIOVertexDescriptor:vertexDescriptor
                                            metalKitTextureLoader:textureLoader
                                                      metalDevice:device
                                                            error:error];

        [newMeshes addObject:newMesh];
    }

    // Recursively traverse the Model I/O  asset hierarchy to find Model I/O  meshes that are children
    //   of this Model I/O  object and create app-specific LODwithFunctionSpecializationMesh objects from those Model I/O meshes
    for (MDLObject *child in object.children)
    {
        NSArray<LODwithFunctionSpecializationMesh*> *childMeshes;

        childMeshes = [LODwithFunctionSpecializationMesh newMeshesFromObject:child
                            modelIOVertexDescriptor:vertexDescriptor
                              metalKitTextureLoader:textureLoader
                                        metalDevice:device
                                              error:error];

        [newMeshes addObjectsFromArray:childMeshes];
    }

    return newMeshes;
}

/// Uses Model I/O to load a model file at the given URL, create Model I/O vertex buffers, index buffers
///   and textures, applying the given Model I/O vertex descriptor to re-layout vertex attribute data
///   in the way that our Metal vertex shaders expect
+ (nullable NSArray<LODwithFunctionSpecializationMesh *> *) newMeshesFromURL:(nonnull NSURL *)url
                            modelIOVertexDescriptor:(nonnull MDLVertexDescriptor *)vertexDescriptor
                                        metalDevice:(nonnull id<MTLDevice>)device
                                              error:(NSError * __nullable * __nullable)error
{

    // Create a MetalKit mesh buffer allocator so that Model I/O  will load mesh data directly into
    //   Metal buffers accessible by the GPU
    MTKMeshBufferAllocator *bufferAllocator =
    [[MTKMeshBufferAllocator alloc] initWithDevice:device];

    // Use Model I/O to load the model file at the URL.  This returns a Model I/O asset object, which
    //   contains a hierarchy of Model I/O objects composing a "scene" described by the model file.
    //   This hierarchy may include lights, cameras, but, most importantly, mesh and submesh data
    //   that we'll render with Metal
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:url
                                   vertexDescriptor:nil
                                    bufferAllocator:bufferAllocator];

    if (!asset)
    {
        NSLog(@"Failed to open model file with given URL: %@", url.absoluteString);
        return nil;
    }
    
    // Create a MetalKit texture loader to load material textures from files or the asset catalog
    //   into Metal textures
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:device];

    NSMutableArray<LODwithFunctionSpecializationMesh *> *newMeshes = [[NSMutableArray alloc] init];

    // Traverse the Model I/O asset hierarchy to find Model I/O meshes and create app-specific
    //   LODwithFunctionSpecializationMesh objects from those Model I/O meshes
    for(MDLObject* object in asset)
    {
        NSArray<LODwithFunctionSpecializationMesh *> *assetMeshes;

        assetMeshes = [LODwithFunctionSpecializationMesh newMeshesFromObject:object
                            modelIOVertexDescriptor:vertexDescriptor
                              metalKitTextureLoader:textureLoader
                                        metalDevice:device
                                              error:error];

        [newMeshes addObjectsFromArray:assetMeshes];
    }

    return newMeshes;
}

+ (BOOL)isTexturedProperty:(AAPLFunctionConstant)propertyIndex atQualityLevel:(AAPLQualityLevel)quality
{
    AAPLQualityLevel minLevelForProperty = AAPLQualityLevelHigh;
    
    switch(propertyIndex)
    {
        case AAPLFunctionConstantBaseColorMapIndex:
        case AAPLFunctionConstantIrradianceMapIndex:
            minLevelForProperty = AAPLQualityLevelMedium;
            break;
        default:
            break;
    }
    
    return quality <= minLevelForProperty;
}

@end
