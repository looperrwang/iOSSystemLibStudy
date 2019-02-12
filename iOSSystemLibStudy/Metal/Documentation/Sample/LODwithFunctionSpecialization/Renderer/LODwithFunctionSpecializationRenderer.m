/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/

#if TARGET_OS_IPHONE

@import simd;
@import ModelIO;
@import MetalKit;

#import "LODwithFunctionSpecializationRenderer.h"
#import "LODwithFunctionSpecializationMesh.h"
#import "AAPLMathUtilities.h"

// Include header shared between C code here, which executes Metal API commands, and .metal files
#import "LODwithFunctionSpecializationShaderTypes.h"

// The max number of command buffers in flight
static const NSUInteger AAPLMaxBuffersInFlight = 3;

// Main class performing the rendering
@implementation LODwithFunctionSpecializationRenderer
{
    dispatch_semaphore_t _inFlightSemaphore;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;

    // Metal objects
    id<MTLBuffer> _uniformBuffers[AAPLMaxBuffersInFlight][AAPLNumViewports];
    id<MTLRenderPipelineState> _pipelineStates[AAPLNumQualityLevels];
    id<MTLDepthStencilState> _depthState;

    // Metal vertex descriptor specifying how vertices will by laid out for input into our render
    //   pipeline and how we'll layout our Model I/O vertices
    MTLVertexDescriptor *_mtlVertexDescriptor;

    // Current set of buffers to fill with dynamic uniform data and set for the current frame
    //   This is the current frame number modulo AAPLMaxBuffersInFlight
    uint8_t _uniformBufferIndex;

    // Projection matrix calculated as a function of view size
    matrix_float4x4 _projectionMatrix;

    // Current rotation of our object in radians
    float _rotation;

    // Increments by 1.0 per frame
    float _time;

    // Array of App-Specific mesh objects in our scene
    NSArray<LODwithFunctionSpecializationMesh *> *_meshes;

    // Irradiance map which would be applied for all objects in the scene
    id<MTLTexture> _irradianceMap;

    // Dispatch group used to create pipelines on a seperate thread during initialization
    dispatch_group_t _pipelineCreationGroup;

    // Flag indicating that initialization operations occuring on a seperate thread are
    //   complete and objects created on that thread can be used
    BOOL _safeToDraw;

    // Current quality level.  Higher levels use more detailed textures consuming more bandwidth
    AAPLQualityLevel _currentQualityLevel;

    // Amount of blending blending between the texture and scalar material values used for each
    //   material type if there is any transition between the two for the current LOD
    float _globalMapWeight;

    //
    id<MTLFunction> _fragmentFunctions[AAPLNumQualityLevels];
    id<MTLFunction> _vertexFunctions[AAPLNumQualityLevels];
}

/// Initialize with the MetalKit view from which we'll obtain our Metal device.  We'll also use this
/// mtkView object to set the pixel format and other properties of our drawable
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        _inFlightSemaphore = dispatch_semaphore_create(AAPLMaxBuffersInFlight);
        _pipelineCreationGroup = dispatch_group_create();
        _safeToDraw = false;
        _currentQualityLevel = AAPLQualityLevelHigh;
        [self loadMetal:mtkView];
        [self loadAssets];
    }

    return self;
}

- (MTLFunctionConstantValues *)functionConstantsForQualityLevel:(AAPLQualityLevel)quality
{
    BOOL hasBaseColorMap = [LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantBaseColorMapIndex atQualityLevel:quality];
    BOOL has_normal_map = [LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantNormalMapIndex atQualityLevel:quality];;
    BOOL has_metallic_map = [LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantMetallicMapIndex atQualityLevel:quality];;
    BOOL has_roughness_map = [LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantRoughnessMapIndex atQualityLevel:quality];;
    BOOL has_ambient_occlusion_map = [LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantAmbientOcclusionMapIndex atQualityLevel:quality];;
    BOOL has_irradiance_map = [LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantIrradianceMapIndex atQualityLevel:quality];;

    MTLFunctionConstantValues* constantValues = [MTLFunctionConstantValues new];
    [constantValues setConstantValue:&has_normal_map type:MTLDataTypeBool atIndex:AAPLFunctionConstantNormalMapIndex];
    [constantValues setConstantValue:&hasBaseColorMap type:MTLDataTypeBool atIndex:AAPLFunctionConstantBaseColorMapIndex];
    [constantValues setConstantValue:&has_metallic_map type:MTLDataTypeBool atIndex:AAPLFunctionConstantMetallicMapIndex];
    [constantValues setConstantValue:&has_ambient_occlusion_map type:MTLDataTypeBool atIndex:AAPLFunctionConstantAmbientOcclusionMapIndex];
    [constantValues setConstantValue:&has_roughness_map type:MTLDataTypeBool atIndex:AAPLFunctionConstantRoughnessMapIndex];
    [constantValues setConstantValue:&has_irradiance_map type:MTLDataTypeBool atIndex:AAPLFunctionConstantIrradianceMapIndex];

    return constantValues;
}

- (void)loadPipelinesAsync:(nonnull MTKView *)view
{
    dispatch_queue_t pipelineQueue = dispatch_queue_create("pipelineQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t specializationGroup = dispatch_group_create();

    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    for (uint qualityLevel = 0; qualityLevel < AAPLNumQualityLevels; qualityLevel++)
    {
        dispatch_group_enter(specializationGroup);

        MTLFunctionConstantValues* constantValues = [self functionConstantsForQualityLevel:qualityLevel];

        [defaultLibrary newFunctionWithName:@"fragmentLighting" constantValues:constantValues
                          completionHandler:^(id<MTLFunction> newFunction, NSError *error )
         {
             if (!newFunction)
             {
                 NSLog(@"Failed to specialize function, error %@", error);
             }

             self->_fragmentFunctions[qualityLevel] = newFunction;
             dispatch_group_leave(specializationGroup);
         }];

        dispatch_group_enter(specializationGroup);

        [defaultLibrary newFunctionWithName:@"vertexTransform" constantValues:constantValues
                          completionHandler:^(id<MTLFunction> newFunction, NSError *error )
         {
             if (!newFunction)
             {
                 NSLog(@"Failed to specialize function, error %@", error);
             }

             self->_vertexFunctions[qualityLevel] = newFunction;
             dispatch_group_leave(specializationGroup);
         }];
    }

    _mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    // Positions.
    _mtlVertexDescriptor.attributes[AAPLVertexAttributePosition].format = MTLVertexFormatFloat3;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributePosition].offset = 0;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributePosition].bufferIndex = AAPLBufferIndexMeshPositions;

    // Texture coordinates.
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].format = MTLVertexFormatFloat2;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].offset = 0;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Normals.
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeNormal].format = MTLVertexFormatHalf4;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeNormal].offset = 8;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeNormal].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Tangents
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeTangent].format = MTLVertexFormatHalf4;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeTangent].offset = 16;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeTangent].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Bitangents
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeBitangent].format = MTLVertexFormatHalf4;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeBitangent].offset = 24;
    _mtlVertexDescriptor.attributes[AAPLVertexAttributeBitangent].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Position Buffer Layout
    _mtlVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stride = 12;
    _mtlVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stepRate = 1;
    _mtlVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;

    // Generic Attribute Buffer Layout
    _mtlVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stride = 32;
    _mtlVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stepRate = 1;
    _mtlVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stepFunction = MTLVertexStepFunctionPerVertex;

    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.sampleCount = 1;

    // Create a reusable pipeline state
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.sampleCount = view.sampleCount;
    pipelineStateDescriptor.vertexFunction = nil;
    pipelineStateDescriptor.fragmentFunction = nil;
    pipelineStateDescriptor.vertexDescriptor = _mtlVertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;

    dispatch_group_enter(_pipelineCreationGroup);

    void (^notifyBlock)(void) = ^void()
    {
        const id<MTLDevice> device  = self->_device;
        const dispatch_group_t pipelineCreationGroup = self->_pipelineCreationGroup;

        MTLRenderPipelineDescriptor *pipelineStateDescriptors[AAPLNumQualityLevels];

        dispatch_group_wait(specializationGroup, DISPATCH_TIME_FOREVER);

        for (uint qualityLevel = 0; qualityLevel < AAPLNumQualityLevels; qualityLevel++)
        {
            dispatch_group_enter(pipelineCreationGroup);

            pipelineStateDescriptors[qualityLevel] = [pipelineStateDescriptor copy];
            pipelineStateDescriptors[qualityLevel].fragmentFunction = self->_fragmentFunctions[qualityLevel];
            pipelineStateDescriptors[qualityLevel].vertexFunction = self->_vertexFunctions[qualityLevel];

            [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptors[qualityLevel]
                                       completionHandler:^(id<MTLRenderPipelineState> newPipelineState, NSError *error )
             {
                 if (!newPipelineState)
                     NSLog(@"Failed to create pipeline state, error %@", error);

                 self->_pipelineStates[qualityLevel] = newPipelineState;
                 dispatch_group_leave(pipelineCreationGroup);
             }];
        }

        dispatch_group_leave(pipelineCreationGroup);
    };

    dispatch_group_notify(specializationGroup, pipelineQueue, notifyBlock);
}

- (void)loadMetal:(nonnull MTKView *)view
{
    for(NSUInteger inFlightIndex = 0; inFlightIndex < AAPLMaxBuffersInFlight; inFlightIndex++)
    {
        for(NSUInteger viewportIndex = 0; viewportIndex < AAPLMaxBuffersInFlight; viewportIndex++)
        {
            _uniformBuffers[inFlightIndex][viewportIndex] = [_device newBufferWithLength:sizeof(AAPLUniforms)
                                                                                 options:MTLResourceStorageModeShared];
        }
    }

    //asynchronously specialize and load all pipelines
    [self loadPipelinesAsync:view];

    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];

    // Create the command queue
    _commandQueue = [_device newCommandQueue];
}

- (void)loadAssets
{
    // Create and load our assets into Metal objects including meshes and textures
    NSError *error;

    // Create a Model I/O vertexDescriptor so that we format/layout our Model I/O mesh vertices to
    //   fit our Metal render pipeline's vertex descriptor layout
    MDLVertexDescriptor *modelIOVertexDescriptor =
        MTKModelIOVertexDescriptorFromMetal(_mtlVertexDescriptor);

    // Indicate how each Metal vertex descriptor attribute maps to each ModelIO  attribute
    modelIOVertexDescriptor.attributes[AAPLVertexAttributePosition].name  = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].name  = MDLVertexAttributeTextureCoordinate;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeNormal].name    = MDLVertexAttributeNormal;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeTangent].name   = MDLVertexAttributeTangent;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeBitangent].name = MDLVertexAttributeBitangent;

    NSURL *modelFileURL = [[NSBundle mainBundle] URLForResource:@"Models/firetruck.obj"
                                                  withExtension:nil];

    if(!modelFileURL)
    {
        NSLog(@"Could not find model (%@) file in bundle creating specular texture",
              modelFileURL.absoluteString);
    }

    _meshes = [LODwithFunctionSpecializationMesh newMeshesFromURL:modelFileURL
                 modelIOVertexDescriptor:modelIOVertexDescriptor
                             metalDevice:_device
                                   error:&error];

    if(!_meshes || error)
    {
        NSLog(@"Could not create meshes from model file %@", modelFileURL.absoluteString);
    }

    NSDictionary *textureLoaderOptions =
    @{
      MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
      MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate)
      };

    MTKTextureLoader* textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];

    _irradianceMap = [textureLoader newTextureWithName:@"IrradianceMap" scaleFactor:1.0 bundle:nil options:textureLoaderOptions error:&error];

    if (!_irradianceMap)
    {
        NSLog(@"Could not load IrradianceMap %@", error);
    }
}

- (float)translationForFrame:(float)frame
{
    float y = 900 * cos(frame / 200.0);
    return -(900-fabs(y));
}

/// Determine the quality level we want given the model's distance from the camera
///   Also, when close to a the bounds of a quality level, calculate a weight to transition between
//    the two quality levels
- (void)calculateQualityAtDistance:(float)distance
{
    static const float MediumQualityDepth     = 150.f;
    static const float LowQualityDepth        = 650.f;
    static const float TransitionDepthAmount  = 50.f;

    assert(distance >= 0.0f);
    if (distance < MediumQualityDepth)
    {
        static const float TransitionDepth = MediumQualityDepth - TransitionDepthAmount;
        if(distance > TransitionDepth)
        {
            _globalMapWeight = distance - TransitionDepth;
            _globalMapWeight /= TransitionDepthAmount;
            _globalMapWeight = 1.0 - _globalMapWeight;
        }
        else
        {
            _globalMapWeight = 1.0;
        }
        _currentQualityLevel = AAPLQualityLevelHigh;
    }
    else if (distance < LowQualityDepth)
    {
        static const float TransitionDepth = LowQualityDepth - TransitionDepthAmount;
        if(distance > TransitionDepth)
        {
            _globalMapWeight = distance - (TransitionDepth);
            _globalMapWeight /= TransitionDepthAmount;
            _globalMapWeight = 1.0 - _globalMapWeight;
        }
        else
        {
            _globalMapWeight = 1.0;
        }
        _currentQualityLevel = AAPLQualityLevelMedium;
    }
    else
    {
        _currentQualityLevel = AAPLQualityLevelLow;
        _globalMapWeight = 0.0;
    }
}

- (void)updateGameState
{
    id<MTLBuffer> leftBuffer = _uniformBuffers[_uniformBufferIndex][AAPLViewportLeft];;
    id<MTLBuffer> rightBuffer = _uniformBuffers[_uniformBufferIndex][AAPLViewportRight];

    // Update any game state (including updating dynamically changing Metal buffer)
    AAPLUniforms * uniformsLeft = (AAPLUniforms*)leftBuffer.contents;
    AAPLUniforms * uniformsRight = (AAPLUniforms*)rightBuffer.contents;

    vector_float3 directionalLightDirection = vector_normalize ((vector_float3){0.f, -6.f, -6.f});

    uniformsLeft->directionalLightInvDirection = -directionalLightDirection;

    uniformsLeft->lightPosition = (vector_float3) {0.f, 60.f, -60.f};

    const vector_float3 cameraTranslation = {0.0, 5.0, 40.0};
    const matrix_float4x4 viewMatrix = matrix4x4_translation (-cameraTranslation);
    const matrix_float4x4 viewProjectionMatrix  = matrix_multiply (_projectionMatrix, viewMatrix);

    uniformsLeft->cameraPos = cameraTranslation;

    *uniformsRight = *uniformsLeft;

    const vector_float3   modelRotationAxis = {0, 1, 0};
    const matrix_float4x4 modelScaleMatrix = matrix4x4_scale((vector_float3){1.0, 1.0, 1.0});
    const matrix_float4x4 modelRotationMatrix = matrix4x4_rotation (_rotation, modelRotationAxis);
    const matrix_float4x4 modelTransMatrixLeft = matrix4x4_translation(0.0f, 0.0f, 0.0f);
    const matrix_float4x4 modelTransMatrixRight = matrix4x4_translation(0.0f, 0.0f, [self translationForFrame:_time]);
    const matrix_float4x4 modelMatrixLeft = matrix_multiply(matrix_multiply(modelTransMatrixLeft, modelRotationMatrix), modelScaleMatrix);
    const matrix_float4x4 modelMatrixRight = matrix_multiply(matrix_multiply(modelTransMatrixRight, modelRotationMatrix), modelScaleMatrix);

    uniformsLeft->modelMatrix = modelMatrixLeft;
    uniformsRight->modelMatrix = modelMatrixRight;

    //   The normal matrix is typically the inverse transpose of a 3x3 matrix created from the
    //   upper-left elements in the 4x4 model matrix.  In this case, we don't need to perform the
    //   expensive inverse and transpose operations since this is only required when scaling is
    //   non-uniform. Thus it's unnecessary to do all of the following:
    //
    //      uniforms->normalMatrix = matrix_invert(matrix_transpose(matrix3x3_upper_left(modelMatrix)))
    //
    //   We can simply take the upper-left 3x3 elements of the model matrix
    uniformsLeft->normalMatrix = matrix3x3_upper_left(modelMatrixLeft);
    uniformsLeft->modelViewProjectionMatrix = matrix_multiply (viewProjectionMatrix, modelMatrixLeft);
    uniformsRight->normalMatrix = matrix3x3_upper_left(modelMatrixRight);
    uniformsRight->modelViewProjectionMatrix = matrix_multiply (viewProjectionMatrix, modelMatrixRight);
    _rotation += .01;

    //set the current quality based on distance from camera
    [self calculateQualityAtDistance:-[self translationForFrame:_time]];

    // Determine if we should use the weight for this transition between levels.  If the current Quality
    //   level uses the irradiance texture, but the next one only uses a uniform, we need to use the
    //   use a weight.
    if ([LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantIrradianceMapIndex atQualityLevel:_currentQualityLevel] &&
        ![LODwithFunctionSpecializationMesh isTexturedProperty:AAPLFunctionConstantIrradianceMapIndex atQualityLevel:_currentQualityLevel+1])
    {
        uniformsLeft->irradianceMapWeight = _globalMapWeight;
        uniformsRight->irradianceMapWeight = _globalMapWeight;
    }
    else
    {
        uniformsLeft->irradianceMapWeight = 1.0;
        uniformsRight->irradianceMapWeight = 1.0;
    }

    // Increment time
    _time += 1.0f;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // When reshape is called, update the aspect ratio and projection matrix since the view
    //   orientation or size has changed
    float aspect = (size.width / AAPLNumViewports) / (float)size.height;
    _projectionMatrix = matrix_perspective_right_hand(65.0f * (M_PI / 180.0f), aspect, 1.0f, 5000.0);

}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    //ensure that our pipelineStates have finished compiling
    if (!_safeToDraw)
    {
        dispatch_group_wait(_pipelineCreationGroup, DISPATCH_TIME_FOREVER);
        _safeToDraw = true;
    }

    // Wait to ensure only AAPLMaxBuffersInFlight are getting proccessed by any stage in the Metal
    //   pipeline (App, Metal, Drivers, GPU, etc)
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    // Create a new command buffer for each render pass to the current drawable
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"FunctionConstantCommand";

    // Add completion hander which signal _inFlightSemaphore when Metal and the GPU has fully
    //   finished processing the commands we're encoding this frame.  This indicates when the
    //   dynamic buffers, that we're writing to this frame, will no longer be needed by Metal
    //   and the GPU.
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
    {
        dispatch_semaphore_signal(block_sema);
    }];

    [self updateGameState];

    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    // If we've gotten a renderPassDescriptor we can render to the drawable, otherwise we'll skip
    //   any rendering this frame because we have no drawable to draw to
    if(renderPassDescriptor != nil)
    {
        // Create a render command encoder so we can render into something
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"FunctionConstantRenderEncoder";

        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool
        [renderEncoder pushDebugGroup:@"DrawMeshes"];

        // Set render command encoder state
        [renderEncoder setCullMode:MTLCullModeFront];
        [renderEncoder setRenderPipelineState:_pipelineStates[_currentQualityLevel]];
        [renderEncoder setDepthStencilState:_depthState];

        [renderEncoder setFragmentTexture:_irradianceMap
                                  atIndex:AAPLTextureIndexIrradianceMap];

        for (LODwithFunctionSpecializationMesh *mesh in _meshes)
        {
            MTKMesh *metalKitMesh = mesh.metalKitMesh;

            // Set mesh's vertex buffers
            for (NSUInteger bufferIndex = 0; bufferIndex < metalKitMesh.vertexBuffers.count; bufferIndex++)
            {
                MTKMeshBuffer *vertexBuffer = metalKitMesh.vertexBuffers[bufferIndex];
                if((NSNull *)vertexBuffer != [NSNull null])
                {
                    [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                            offset:vertexBuffer.offset
                                           atIndex:bufferIndex];
                }
            }

            // Draw each submesh of our mesh
            for(LODwithFunctionSpecializationSubmesh *submesh in mesh.submeshes)
            {
                // Set all textures for the submesh regardless of whether their sampled from
                //   (i.e. we're really saving on the sampling in the shader at low quality levels,
                //   not the setting of the texture in the encoder, so we may as well set all the
                //   texture for this submesh)
                for(AAPLTextureIndex textureIndex = 0; textureIndex < AAPLNumMeshTextureIndices; textureIndex++)
                {
                    [renderEncoder setFragmentTexture:submesh.textures[textureIndex] atIndex:textureIndex];
                }

                // Sets the weight of values sampled from a texture vs value from a material uniform
                //   for a transition between quality levels
                [submesh computeTextureWeightsForQualityLevel:_currentQualityLevel
                                          withGlobalMapWeight:_globalMapWeight];

                // Set the material uniforms
                [renderEncoder setFragmentBuffer:submesh.materialUniforms
                                          offset:0
                                         atIndex:AAPLBufferIndexMaterialUniforms];

                MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

                for (NSUInteger viewportIndex = 0; viewportIndex < AAPLNumViewports; viewportIndex++)
                {
                    MTLViewport currentViewport = {
                        viewportIndex * renderPassDescriptor.colorAttachments[0].texture.width/AAPLNumViewports,
                        0.0,
                        renderPassDescriptor.colorAttachments[0].texture.width/AAPLNumViewports,
                        renderPassDescriptor.colorAttachments[0].texture.height,
                        0.0,
                        1.0 };

                    [renderEncoder setViewport:currentViewport];
                    // Set the buffers fed into our render pipeline

                    [renderEncoder setVertexBuffer:_uniformBuffers[_uniformBufferIndex][viewportIndex]
                                            offset:0
                                           atIndex:AAPLBufferIndexUniforms];

                    [renderEncoder setFragmentBuffer:_uniformBuffers[_uniformBufferIndex][viewportIndex]
                                              offset:0
                                             atIndex:AAPLBufferIndexUniforms];

                    [renderEncoder drawIndexedPrimitives:metalKitSubmesh.primitiveType
                                              indexCount:metalKitSubmesh.indexCount
                                               indexType:metalKitSubmesh.indexType
                                             indexBuffer:metalKitSubmesh.indexBuffer.buffer
                                       indexBufferOffset:metalKitSubmesh.indexBuffer.offset];
                }

            }

        }

        [renderEncoder popDebugGroup];

        // We're done encoding commands
        [renderEncoder endEncoding];

        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
}

@end

#endif
