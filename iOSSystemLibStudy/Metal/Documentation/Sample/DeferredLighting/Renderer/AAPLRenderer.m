  /*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/

@import simd;
@import ModelIO;
@import MetalKit;

#include <stdlib.h>

#import "AAPLBufferExamination.h"
#import "AAPLRenderer.h"
#import "AAPLMesh.h"
#import "AAPLMathUtilities.h"

// Include header shared between C code here, which executes Metal API commands, and .metal files
#import "AAPLShaderTypes.h"

// The max number of command buffers in flight
static const NSUInteger AAPLMaxBuffersInFlight = 3;

// Number of vertices in our 2D fairy model
static const NSUInteger AAPLNumFairyVertices = 7;

// 30% of lights are around the tree
// 40% of lights are on the ground inside the columns
// 30% of lights are around the outside of the columns
static const NSUInteger AAPLTreeLights    = 0                 + 0.30 * AAPLNumLights;
static const NSUInteger AAPLGroundLights  = AAPLTreeLights    + 0.40 * AAPLNumLights;
static const NSUInteger AAPLColumnLights = AAPLGroundLights  + 0.30 * AAPLNumLights;

// Main class performing the rendering
@implementation AAPLRenderer
{
    dispatch_semaphore_t _inFlightSemaphore;
    id <MTLCommandQueue> _commandQueue;

    // Vertex descriptor for models loaded with MetalKit
    MTLVertexDescriptor *_defaultVertexDescriptor;

    // Pipeline states
    id <MTLRenderPipelineState> _GBufferPipelineState;
    id <MTLRenderPipelineState> _fairyPipelineState;
    id <MTLRenderPipelineState> _skyboxPipelineState;
    id <MTLRenderPipelineState> _shadowGenPipelineState;
    id <MTLRenderPipelineState> _lightMaskPipelineState;
    id <MTLRenderPipelineState> _directionalLightPipelineState;

    id <MTLDepthStencilState> _lightMaskDepthStencilState;
    id <MTLDepthStencilState> _directionLightDepthStencilState;
    id <MTLDepthStencilState> _GBufferDepthStencilState;
    id <MTLDepthStencilState> _shadowDepthStencilState;

    MTLRenderPassDescriptor *_shadowRenderPassDescriptor;

    // Texture to create smooth round particles
    id<MTLTexture> _fairyMap;

    // Projection matrix calculated as a function of view size
    matrix_float4x4 _projection_matrix;

    matrix_float4x4 _shadowProjectionMatrix;

    // Current frame number rendering
    NSUInteger _frameNumber;

	// Array of meshes loaded from our model file
    NSArray<AAPLMesh *> *_meshes;

    // Mesh for sphere use to render the skybox
    MTKMesh *_skyMesh;

    // Vertex descriptor for models loaded with MetalKit
    MTLVertexDescriptor *_skyVertexDescriptor;

    // Texture for skybox
    id <MTLTexture> _skyMap;

    // Mesh buffer for fairies
    id<MTLBuffer> _fairy;

    // Light positions before transformation to positions in current frame
    NSData *_originalLightPositions;

#if SUPPORT_BUFFER_EXAMINATION_MODE
    AAPLBufferExamination *_bufferExamination;
#endif
}

/// Init common assets and Metal objects
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view
{
    self = [super init];
    if(self)
    {
        _device = view.device;
        _view = view;

        _inFlightSemaphore = dispatch_semaphore_create(AAPLMaxBuffersInFlight);
    }

    return self;
}

/// Create Metal render state objects
- (void)loadMetal
{
    // Create and load our basic Metal state objects
    NSError* error;

    NSLog(@"Selected Device: %@", _view.device.name);

    // Load all the shader files with a metal file extension in the project
    id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    id<MTLBuffer> uniformBuffersCArray[AAPLMaxBuffersInFlight];
    id<MTLBuffer> lightPositionsCArray[AAPLMaxBuffersInFlight];

    // Create and allocate our uniform buffer objects.
    for(NSUInteger i = 0; i < AAPLMaxBuffersInFlight; i++)
    {
        // Indicate shared storage so that both the  CPU can access the buffers
        const MTLResourceOptions storageMode = MTLResourceStorageModeShared;

        uniformBuffersCArray[i] = [_device newBufferWithLength:sizeof(AAPLUniforms)
                                                  options:storageMode];

        uniformBuffersCArray[i].label = [NSString stringWithFormat:@"UniformBuffer%lu", i];

        lightPositionsCArray[i] = [_device newBufferWithLength:sizeof(vector_float4)*AAPLNumLights
                                                  options:storageMode];

        lightPositionsCArray[i].label = [NSString stringWithFormat:@"LightPositions%lu", i];
    }

    _uniformBuffers = [[NSArray alloc] initWithObjects:uniformBuffersCArray count:AAPLMaxBuffersInFlight];

    _lightPositions = [[NSArray alloc] initWithObjects:lightPositionsCArray count:AAPLMaxBuffersInFlight];

    _defaultVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    // Positions.
    _defaultVertexDescriptor.attributes[AAPLVertexAttributePosition].format = MTLVertexFormatFloat3;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributePosition].offset = 0;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributePosition].bufferIndex = AAPLBufferIndexMeshPositions;

    // Texture coordinates.
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].format = MTLVertexFormatFloat2;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].offset = 0;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Normals.
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeNormal].format = MTLVertexFormatHalf4;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeNormal].offset = 8;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeNormal].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Tangents
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeTangent].format = MTLVertexFormatHalf4;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeTangent].offset = 16;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeTangent].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Bitangents
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeBitangent].format = MTLVertexFormatHalf4;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeBitangent].offset = 24;
    _defaultVertexDescriptor.attributes[AAPLVertexAttributeBitangent].bufferIndex = AAPLBufferIndexMeshGenerics;

    // Position Buffer Layout
    _defaultVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stride = 12;
    _defaultVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stepRate = 1;
    _defaultVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;

    // Generic Attribute Buffer Layout
    _defaultVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stride = 32;
    _defaultVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stepRate = 1;
    _defaultVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stepFunction = MTLVertexStepFunctionPerVertex;

    _view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    _view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;;

    _albedo_specular_GBufferFormat = MTLPixelFormatRGBA8Unorm_sRGB;
    _normal_shadow_GBufferFormat = MTLPixelFormatRGBA8Snorm;
    _depth_GBufferFormat  = MTLPixelFormatR32Float;

    // Setup pipeline to draw GBuffers
    {
        {
            id <MTLFunction> GBufferVertexFunction = [defaultLibrary newFunctionWithName:@"gbuffer_vertex"];
            id <MTLFunction> GBufferFragmentFunction = [defaultLibrary newFunctionWithName:@"gbuffer_fragment"];

            MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];

            renderPipelineDescriptor.label = @"G-buffer Creation";
            renderPipelineDescriptor.vertexDescriptor = _defaultVertexDescriptor;
#if !DEFER_ALL_LIGHTING || TARGET_IOS
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = _view.colorPixelFormat;
#else
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = MTLPixelFormatInvalid;
#endif
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetAlbedo].pixelFormat = _albedo_specular_GBufferFormat;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetNormal].pixelFormat = _normal_shadow_GBufferFormat;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetDepth].pixelFormat = _depth_GBufferFormat;
            renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
            renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

            renderPipelineDescriptor.vertexFunction = GBufferVertexFunction;
            renderPipelineDescriptor.fragmentFunction = GBufferFragmentFunction;
            _GBufferPipelineState = [self.device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                                error:&error];
            if (!_GBufferPipelineState)
            {
                NSLog(@"Failed to create render pipeline state, error %@", error);
            }
        }

        // Create depth state with depth write enabled
        {
#if LIGHT_STENCIL_CULLING
            MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
            stencilStateDesc.stencilCompareFunction = MTLCompareFunctionAlways;
            stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
            stencilStateDesc.depthFailureOperation = MTLStencilOperationKeep;
            stencilStateDesc.depthStencilPassOperation = MTLStencilOperationReplace;
            stencilStateDesc.readMask = 0x0;
            stencilStateDesc.writeMask = 0xFF;
#else
            MTLStencilDescriptor *stencilStateDesc = nil;
#endif
            MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
            depthStateDesc.label =  @"G-buffer Creation";
            depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
            depthStateDesc.depthWriteEnabled = YES;
            depthStateDesc.frontFaceStencil = stencilStateDesc;
            depthStateDesc.backFaceStencil = stencilStateDesc;

            _GBufferDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
        }
    }

#if DEFER_ALL_LIGHTING
    // Setup render state to apply directional light and shadow in final pass
    {
        // Set up pipeline to render direction light
        {
            id <MTLFunction> directionalVertexFunction = [defaultLibrary newFunctionWithName:@"deferred_direction_lighting_vertex"];
            id <MTLFunction> directionalFragmentFunction = [defaultLibrary newFunctionWithName:@"deferred_directional_lighting_fragment"];

            MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];

            renderPipelineDescriptor.label = @"Deferred Directional Lighting";
            renderPipelineDescriptor.vertexDescriptor = nil;
            renderPipelineDescriptor.vertexFunction = directionalVertexFunction;
            renderPipelineDescriptor.fragmentFunction = directionalFragmentFunction;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = _view.colorPixelFormat;

            if(_GBuffersAttachedInFinalPass)
            {
                renderPipelineDescriptor.colorAttachments[AAPLRenderTargetAlbedo].pixelFormat = _albedo_specular_GBufferFormat;
                renderPipelineDescriptor.colorAttachments[AAPLRenderTargetNormal].pixelFormat = _normal_shadow_GBufferFormat;
                renderPipelineDescriptor.colorAttachments[AAPLRenderTargetDepth].pixelFormat = _depth_GBufferFormat;
            }

            renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
            renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

            _directionalLightPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                                     error:&error];
            if (!_directionalLightPipelineState) {
                NSLog(@"Failed to create render pipeline state, error %@", error);
            }
        }

        // Create stencil state to apply directional lighting only to pixels drawn to in GBUffer stage
        {
#if LIGHT_STENCIL_CULLING
            MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
            stencilStateDesc.stencilCompareFunction = MTLCompareFunctionEqual;
            stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
            stencilStateDesc.depthFailureOperation = MTLStencilOperationKeep;
            stencilStateDesc.depthStencilPassOperation = MTLStencilOperationKeep;
            stencilStateDesc.readMask = 0xFF;
            stencilStateDesc.writeMask = 0x0;
#else
            MTLStencilDescriptor *stencilStateDesc = nil;
#endif
            MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
            depthStateDesc.label = @"Deferred Directional Lighting";
            depthStateDesc.depthWriteEnabled = NO;
            depthStateDesc.depthCompareFunction = MTLCompareFunctionAlways;
            depthStateDesc.frontFaceStencil = stencilStateDesc;
            depthStateDesc.backFaceStencil = stencilStateDesc;

            _directionLightDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
        }
    }
#endif // END DEFER_ALL_LIGHTING

    // Setup pipeline to draw fairies
    {
        id <MTLFunction> fairyVertexFunction = [defaultLibrary newFunctionWithName:@"fairy_vertex"];
        id <MTLFunction> fairyFragmentFunction = [defaultLibrary newFunctionWithName:@"fairy_fragment"];

        MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];

        renderPipelineDescriptor.label = @"Fairy Drawing";
        renderPipelineDescriptor.vertexDescriptor = nil;
        renderPipelineDescriptor.vertexFunction = fairyVertexFunction;
        renderPipelineDescriptor.fragmentFunction = fairyFragmentFunction;
        renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = _view.colorPixelFormat;

        if(_GBuffersAttachedInFinalPass)
        {
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetAlbedo].pixelFormat = _albedo_specular_GBufferFormat;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetNormal].pixelFormat = _normal_shadow_GBufferFormat;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetDepth].pixelFormat = _depth_GBufferFormat;
        }

        renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
        renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;
        renderPipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor  = MTLBlendFactorSourceAlpha;
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOne;
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOne;

        _fairyPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                      error:&error];
        if (!_fairyPipelineState) {
            NSLog(@"Failed to create render pipeline state, error %@", error);
        }
    }

    // Setup pipeline to draw sky
    {
        _skyVertexDescriptor = [[MTLVertexDescriptor alloc] init];
        _skyVertexDescriptor.attributes[AAPLVertexAttributePosition].format = MTLVertexFormatFloat3;
        _skyVertexDescriptor.attributes[AAPLVertexAttributePosition].offset = 0;
        _skyVertexDescriptor.attributes[AAPLVertexAttributePosition].bufferIndex = AAPLBufferIndexMeshPositions;
        _skyVertexDescriptor.layouts[AAPLBufferIndexMeshPositions].stride = 12;
        _skyVertexDescriptor.attributes[AAPLVertexAttributeNormal].format = MTLVertexFormatFloat3;
        _skyVertexDescriptor.attributes[AAPLVertexAttributeNormal].offset = 0;
        _skyVertexDescriptor.attributes[AAPLVertexAttributeNormal].bufferIndex = AAPLBufferIndexMeshGenerics;
        _skyVertexDescriptor.layouts[AAPLBufferIndexMeshGenerics].stride = 12;

        id <MTLFunction> skyboxVertexFunction = [defaultLibrary newFunctionWithName:@"skybox_vertex"];
        id <MTLFunction> skyboxFragmentFunction = [defaultLibrary newFunctionWithName:@"skybox_fragment"];

        MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];
        renderPipelineDescriptor.label = @"Sky";
        renderPipelineDescriptor.vertexDescriptor = _skyVertexDescriptor;
        renderPipelineDescriptor.vertexFunction = skyboxVertexFunction;
        renderPipelineDescriptor.fragmentFunction = skyboxFragmentFunction;
        renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = _view.colorPixelFormat;

        if(_GBuffersAttachedInFinalPass)
        {
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetAlbedo].pixelFormat = _albedo_specular_GBufferFormat;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetNormal].pixelFormat = _normal_shadow_GBufferFormat;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetDepth].pixelFormat = _depth_GBufferFormat;
        }

        renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
        renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

        _skyboxPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                      error:&error];
        if (!_skyboxPipelineState) {
            NSLog(@"Failed to create render pipeline state, error %@", error);
        }
    }

    // Create depth state for post lighting operations
    {
        MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
        depthStateDesc.label = @"Less -Writes";
        depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
        depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
        depthStateDesc.depthWriteEnabled = NO;

        _dontWriteDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    }

    // Setup objects for shadow pass
    {
        // Create render state pipeline for shadow pass
        {
            id <MTLFunction> shadowVertexFunction = [defaultLibrary newFunctionWithName:@"shadow_vertex"];

            MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];
            renderPipelineDescriptor.label = @"Shadow Gen";
            renderPipelineDescriptor.vertexDescriptor = nil;
            renderPipelineDescriptor.vertexFunction = shadowVertexFunction;
            renderPipelineDescriptor.fragmentFunction = nil;
            renderPipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

            _shadowGenPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                              error:&error];

        }

        // Create depth state for shadow pass
        {
            MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
            depthStateDesc.label = @"Shadow Gen";
#if REVERSE_DEPTH
            depthStateDesc.depthCompareFunction = MTLCompareFunctionGreaterEqual;
#else
            depthStateDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
#endif
            depthStateDesc.depthWriteEnabled = YES;
            _shadowDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
        }

        // Create depth texture for shadow pass
        {
            MTLTextureDescriptor *shadowTextureDesc =
                [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                   width:2048
                                                                  height:2048
                                                               mipmapped:NO];

            shadowTextureDesc.resourceOptions = MTLResourceStorageModePrivate;
            shadowTextureDesc.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;

            _shadowMap = [_device newTextureWithDescriptor:shadowTextureDesc];
            _shadowMap.label = @"Shadow Map";
        }

        // Create render pass descriptor to reuse for shadow pass
        {
            _shadowRenderPassDescriptor = [MTLRenderPassDescriptor new];
            _shadowRenderPassDescriptor.depthAttachment.texture = _shadowMap;
            _shadowRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
            _shadowRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
            _shadowRenderPassDescriptor.depthAttachment.clearDepth = 1.0;
        }

        // Calculate projection matrix to render shadows
        {
            _shadowProjectionMatrix = matrix_ortho_left_hand(-53, 53, -33, 53, -53, 53);
        }
    }

#if LIGHT_STENCIL_CULLING
    // Setup objects for point light mask rendering
    {
        // Setup pipeline for light mask rendering
        {
            id <MTLFunction> lightMaskVertex = [defaultLibrary newFunctionWithName:@"light_mask_vertex"];

            MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];
            renderPipelineDescriptor.label = @"Point Light Mask";
            renderPipelineDescriptor.vertexDescriptor = nil;
            renderPipelineDescriptor.vertexFunction = lightMaskVertex;
            renderPipelineDescriptor.fragmentFunction = nil;
            renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = _view.colorPixelFormat;

            if(_GBuffersAttachedInFinalPass)
            {
                renderPipelineDescriptor.colorAttachments[AAPLRenderTargetAlbedo].pixelFormat = _albedo_specular_GBufferFormat;
                renderPipelineDescriptor.colorAttachments[AAPLRenderTargetNormal].pixelFormat = _normal_shadow_GBufferFormat;
                renderPipelineDescriptor.colorAttachments[AAPLRenderTargetDepth].pixelFormat = _depth_GBufferFormat;
            }

            renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
            renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

            renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
            renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;
            _lightMaskPipelineState =
                [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                        error:&error];
        }

        // Create depth state for light mask operations
        {
            MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
            stencilStateDesc.stencilCompareFunction = MTLCompareFunctionAlways;
            stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
            stencilStateDesc.depthFailureOperation = MTLStencilOperationIncrementClamp;
            stencilStateDesc.depthStencilPassOperation = MTLStencilOperationKeep;
            stencilStateDesc.readMask = 0x0;
            stencilStateDesc.writeMask = 0xFF;
            MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
            depthStateDesc.label = @"Point Light Mask";
            depthStateDesc.depthWriteEnabled = NO;
            depthStateDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
            depthStateDesc.frontFaceStencil = stencilStateDesc;
            depthStateDesc.backFaceStencil = stencilStateDesc;

            _lightMaskDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
        }
    }
#endif // END LIGHT_STENCIL_CULLING

    // Create depth state for point light rendering
    {
#if LIGHT_STENCIL_CULLING
        MTLStencilDescriptor *stencilStateDesc = [MTLStencilDescriptor new];
        stencilStateDesc.stencilCompareFunction = MTLCompareFunctionLess;
        stencilStateDesc.stencilFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthFailureOperation = MTLStencilOperationKeep;
        stencilStateDesc.depthStencilPassOperation = MTLStencilOperationKeep;
        stencilStateDesc.readMask = 0xFF;
        stencilStateDesc.writeMask = 0x0;
#else  // IF NOT LIGHT_STENCIL_CULLING
        MTLStencilDescriptor *stencilStateDesc = nil;
#endif // END NOT LIGHT_STENCIL_CULLING
        MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
        depthStateDesc.depthWriteEnabled = NO;
        depthStateDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
        depthStateDesc.frontFaceStencil = stencilStateDesc;
        depthStateDesc.backFaceStencil = stencilStateDesc;
        depthStateDesc.label = @"Point Light";

        _pointLightDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    }

#if SUPPORT_BUFFER_EXAMINATION_MODE
    _bufferExamination =  [[AAPLBufferExamination alloc] initWithMTKView:_view
                                                                renderer:self];
#endif

    // Create the command queue
    _commandQueue = [_device newCommandQueue];
}

- (void)loadScene
{
    [self loadAssets];
    [self populateLights];
}

/// Load models/textures, etc.
- (void)loadAssets
{
	// Create and load our assets into Metal objects including meshes and textures
	NSError *error = nil;

    // Create a ModelIO vertexDescriptor so that we format/layout our ModelIO mesh vertices to
    //   fit our Metal render pipeline's vertex descriptor layout
    MDLVertexDescriptor *modelIOVertexDescriptor =
        MTKModelIOVertexDescriptorFromMetal(_defaultVertexDescriptor);

    // Indicate how each Metal vertex descriptor attribute maps to each ModelIO  attribute
    modelIOVertexDescriptor.attributes[AAPLVertexAttributePosition].name  = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeTexcoord].name  = MDLVertexAttributeTextureCoordinate;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeNormal].name    = MDLVertexAttributeNormal;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeTangent].name   = MDLVertexAttributeTangent;
    modelIOVertexDescriptor.attributes[AAPLVertexAttributeBitangent].name = MDLVertexAttributeBitangent;

    NSURL *modelFileURL = [[NSBundle mainBundle] URLForResource:@"Meshes/Temple.obj" withExtension:nil];

    if(!modelFileURL)
    {
        NSLog(@"Could not find model (%@) file in bundle",
              modelFileURL.absoluteString);
    }

    _meshes = [AAPLMesh newMeshesFromURL:modelFileURL
                 modelIOVertexDescriptor:modelIOVertexDescriptor
                             metalDevice:_device
                                   error:&error];
    if(!_meshes || error)
    {
        NSLog(@"Could not create meshes from model file %@", modelFileURL.absoluteString);
    }

    _lightsData = [_device newBufferWithLength:sizeof(AAPLPointLight)*AAPLNumLights options:0];
    _lightsData.label = @"LightData";
    if(!_lightsData)
    {
        NSLog(@"Could not create lights data buffer");
    }

    // Create quad for fullscreen composition drawing
    {
        static const AAPLSimpleVertex QuadVertices[] =
        {
            { { -1.0f,  -1.0f, } },
            { { -1.0f,   1.0f, } },
            { {  1.0f,  -1.0f, } },

            { {  1.0f,  -1.0f, } },
            { { -1.0f,   1.0f, } },
            { {  1.0f,   1.0f, } },
        };

        _quadVertexBuffer = [_device newBufferWithBytes:QuadVertices
                                                 length:sizeof(QuadVertices)
                                               options:0];
    }

    // Create a simple 2D triangle strip circle mesh for fairies
    {
        AAPLSimpleVertex fairyVertices[AAPLNumFairyVertices];
        const float angle = 2*M_PI/(float)AAPLNumFairyVertices;
        for(int vtx = 0; vtx < AAPLNumFairyVertices; vtx++)
        {
            int point = (vtx%2) ? (vtx+1)/2 : -vtx/2;
            vector_float2 position = {sin(point*angle), cos(point*angle)};
            fairyVertices[vtx].position = position;
        }

        _fairy = [_device newBufferWithBytes:fairyVertices length:sizeof(fairyVertices) options:0];
    }

    // Create an icosahedron mesh for fairy light volumes
    {
        MTKMeshBufferAllocator *bufferAllocator =
            [[MTKMeshBufferAllocator alloc] initWithDevice:_device];

        const double unitInscribe = sqrtf(3.0) / 12.0 * (3.0 + sqrtf(5.0));

        MDLMesh *icosahedronMDLMesh = [MDLMesh newIcosahedronWithRadius:1/unitInscribe inwardNormals:NO allocator:bufferAllocator];

        MDLVertexDescriptor *icosahedronDescriptor = [[MDLVertexDescriptor alloc] init];
        icosahedronDescriptor.attributes[AAPLVertexAttributePosition].name = MDLVertexAttributePosition;
        icosahedronDescriptor.attributes[AAPLVertexAttributePosition].format = MDLVertexFormatFloat4;
        icosahedronDescriptor.attributes[AAPLVertexAttributePosition].offset = 0;
        icosahedronDescriptor.attributes[AAPLVertexAttributePosition].bufferIndex = AAPLBufferIndexMeshPositions;

        icosahedronDescriptor.layouts[AAPLBufferIndexMeshPositions].stride = sizeof(vector_float4);

        // Set our vertex descriptor to relayout vertices
        icosahedronMDLMesh.vertexDescriptor = icosahedronDescriptor;

        _icosahedronMesh = [[MTKMesh alloc] initWithMesh:icosahedronMDLMesh
                                                 device:_device
                                                  error:&error];

        if(!_icosahedronMesh) {
            NSLog(@"Could not create mesh %@", error);
        }
    }

    // Create a sphere for the skybox
    {
        MTKMeshBufferAllocator *bufferAllocator =
            [[MTKMeshBufferAllocator alloc] initWithDevice:_device];

        MDLMesh *sphereMDLMesh = [MDLMesh newEllipsoidWithRadii:150
                                                 radialSegments:20
                                               verticalSegments:20
                                                   geometryType:MDLGeometryTypeTriangles
                                                  inwardNormals:NO
                                                     hemisphere:NO
                                                      allocator:bufferAllocator];

        MDLVertexDescriptor *sphereDescriptor = MTKModelIOVertexDescriptorFromMetal(_skyVertexDescriptor);
        sphereDescriptor.attributes[AAPLVertexAttributePosition].name = MDLVertexAttributePosition;
        sphereDescriptor.attributes[AAPLVertexAttributeNormal].name   = MDLVertexAttributeNormal;

        // Set our vertex descriptor to relayout vertices
        sphereMDLMesh.vertexDescriptor = sphereDescriptor;

        _skyMesh = [[MTKMesh alloc] initWithMesh:sphereMDLMesh
                                             device:_device
                                              error:&error];

        if(!_skyMesh) {
            NSLog(@"Could not create mesh %@", error);
        }
    }

    // Load textures for non mesh assets
    {
        MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];

        NSDictionary *textureLoaderOptions =
        @{
          MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
          MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate),
          };

        _skyMap = [textureLoader newTextureWithName:@"SkyMap"
                                        scaleFactor:1.0
                                             bundle:nil
                                            options:textureLoaderOptions
                                              error:&error];

        if(!_skyMap) {
            NSLog(@"Could not load sky texture %@", error);
        }

        _skyMap.label = @"Sky Map";

        _fairyMap = [textureLoader newTextureWithName:@"FairyMap"
                                          scaleFactor:1.0
                                               bundle:nil
                                              options:textureLoaderOptions
                                                error:&error];

        if(!_fairyMap || error)
        {
            NSLog(@"Could not load fairy texture %@", error);
        }

        _fairyMap.label = @"Fairy Map";
    }
}

/// Initialize light positions and colors
- (void)populateLights
{
    AAPLPointLight *light_data = (AAPLPointLight*)[_lightsData contents];

    NSMutableData * originalLightPositions =  [[NSMutableData alloc] initWithLength:_lightPositions[0].length];

    _originalLightPositions = originalLightPositions;

    vector_float4 *light_position = (vector_float4*)originalLightPositions.mutableBytes;

    srand(0x134e5348);

    for(NSUInteger lightId = 0; lightId < AAPLNumLights; lightId++)
    {
        float distance = 0;
        float height = 0;
        float angle = 0;
        float speed = 0;

        if(lightId < AAPLTreeLights)
        {
            distance = random_float(38,42);
            height = random_float(0,1);
            angle = random_float(0, M_PI*2);
            speed = random_float(0.003,0.014);
        }
        else if(lightId < AAPLGroundLights)
        {
            distance = random_float(140,260);
            height = random_float(140,150);
            angle = random_float(0, M_PI*2);
            speed = random_float(0.006,0.027);
            speed *= (rand()%2)*2-1;
        }
        else if(lightId < AAPLColumnLights)
        {
            distance = random_float(365,380);
            height = random_float(150,190);
            angle = random_float(0, M_PI*2);
            speed = random_float(0.004,0.014);
            speed *= (rand()%2)*2-1;
        }

        speed *= .5;
        *light_position = (vector_float4){ distance*sinf(angle),height,distance*cosf(angle),1};
        light_data->light_radius = random_float(25,35)/10.0;
        light_data->light_speed  = speed;

        int colorId = rand()%3;
        if( colorId == 0) {
            light_data->light_color = (vector_float3){random_float(4,6),random_float(0,4),random_float(0,4)};
        } else if ( colorId == 1) {
            light_data->light_color = (vector_float3){random_float(0,4),random_float(4,6),random_float(0,4)};
        } else {
            light_data->light_color = (vector_float3){random_float(0,4),random_float(0,4),random_float(4,6)};
        }

        light_data++;
        light_position++;
    }
}

/// Update light positions
- (void)updateLights:(matrix_float4x4)modelViewMatrix
{
    AAPLPointLight *lightData = (AAPLPointLight*)((char*)[_lightsData contents]);

    vector_float4 *currentBuffer =
        (vector_float4*) _lightPositions[_currentBufferIndex].contents;

    vector_float4 *originalLightPositions =  (vector_float4 *)_originalLightPositions.bytes;

    for(int i = 0; i < AAPLNumLights; i++)
    {
        vector_float4 currentPosition;

        if(i < AAPLTreeLights)
        {
            double lightPeriod = lightData[i].light_speed  * _frameNumber;
            lightPeriod += originalLightPositions[i].y;
            lightPeriod -= floor(lightPeriod);  // Get fractional part

            // Use pow to slowly move the light outward as it reaches the branches of the tree
            float r = 1.2 + 10.0 * powf(lightPeriod, 5.0);

            currentPosition.x = originalLightPositions[i].x * r;
            currentPosition.y = 200.0f + lightPeriod * 400.0f;
            currentPosition.z = originalLightPositions[i].z * r;
            currentPosition.w = 1;
        }
        else
        {
            float rotationRadians = lightData[i].light_speed * _frameNumber;
            matrix_float4x4 rotation = matrix4x4_rotation(rotationRadians, 0, 1, 0);
            currentPosition = matrix_multiply(rotation, originalLightPositions[i]);
        }

        currentPosition = matrix_multiply(modelViewMatrix, currentPosition);
        currentBuffer[i] = currentPosition;
    }
}

/// Update application state for the current frame
- (void)updateWorldState
{
    if(!_view.paused)
    {
        _frameNumber++;
    }
    _currentBufferIndex = (_currentBufferIndex+1) % AAPLMaxBuffersInFlight;

    AAPLUniforms * uniforms = (AAPLUniforms*)_uniformBuffers[_currentBufferIndex].contents;

    // Set projection matrix and calculate inverted projection matrix
    uniforms->projection_matrix = _projection_matrix;
    uniforms->projection_matrix_inverse = matrix_invert(_projection_matrix);

    // Set screen dimensions
    uniforms->framebuffer_width = (uint)[_albedo_specular_GBuffer width];
    uniforms->framebuffer_height = (uint)[_albedo_specular_GBuffer height];

    uniforms->shininess_factor = 1;
    uniforms->fairy_specular_intensity = 32;

    float cameraRotationRadians = _frameNumber * 0.0025f + M_PI;

    vector_float3 cameraRotationAxis = {0, 1, 0};
    matrix_float4x4 cameraRotationMatrix = matrix4x4_rotation(cameraRotationRadians, cameraRotationAxis);

    matrix_float4x4 view_matrix = matrix_look_at_left_hand(0, 18, -50,
                                                          0, 5, 0,
                                                          0, 1, 0);

    view_matrix = matrix_multiply(view_matrix, cameraRotationMatrix);

    uniforms->view_matrix = view_matrix;

    matrix_float4x4 templeScaleMatrix = matrix4x4_scale(0.1, 0.1, 0.1);
    matrix_float4x4 templeTranslateMatrix = matrix4x4_translation(0, -10, 0);
    matrix_float4x4 templeModelMatrix = matrix_multiply(templeTranslateMatrix, templeScaleMatrix);
    uniforms->temple_model_matrix = templeModelMatrix;
    uniforms->temple_modelview_matrix = matrix_multiply(uniforms->view_matrix, templeModelMatrix);
    uniforms->temple_normal_matrix = matrix3x3_upper_left(uniforms->temple_model_matrix);

    float skyRotation = _frameNumber * 0.005f - (M_PI_4*3);

    vector_float3 skyRotationAxis = {0, 1, 0};
    matrix_float4x4 skyModelMatrix = matrix4x4_rotation(skyRotation, skyRotationAxis);
    uniforms->sky_modelview_matrix = matrix_multiply(cameraRotationMatrix, skyModelMatrix);

    // Update directional light color
    vector_float4 sun_color = {0.5, 0.5, 0.5, 1.0};
    uniforms->sun_color = sun_color;
    uniforms->sun_specular_intensity = 1;

    // Update sun direction in view space
    vector_float4 sunModelPosition = {-0.25, -0.5, 1.0, 0.0};

    vector_float4 sunWorldPosition = matrix_multiply(skyModelMatrix, sunModelPosition);

    vector_float4 sunWorldDirection = -sunWorldPosition;

    uniforms->sun_eye_direction = matrix_multiply(view_matrix, sunWorldDirection);

    {
        vector_float4 directionalLightUpVector = {0.0, 1.0, 1.0, 1.0};

        directionalLightUpVector = matrix_multiply(skyModelMatrix, directionalLightUpVector);
        directionalLightUpVector.xyz = vector_normalize(directionalLightUpVector.xyz);

        matrix_float4x4 shadowViewMatrix = matrix_look_at_left_hand(sunWorldDirection.xyz / 10,
                                                                    (vector_float3){0,0,0},
                                                                    directionalLightUpVector.xyz);

        matrix_float4x4 shadowModelViewMatrix = matrix_multiply(shadowViewMatrix, templeModelMatrix);

        uniforms->shadow_mvp_matrix = matrix_multiply(_shadowProjectionMatrix, shadowModelViewMatrix);
    }

    {
        // When calculating texture coordinates to sample from shadow map, flip the y/t coordinate and
        // convert from the [-1, 1] range of clip coordinates to [0, 1] range of
        // used for texture sampling
        matrix_float4x4 shadowScale = matrix4x4_scale(0.5f, -0.5f, 1.0);
        matrix_float4x4 shadowTranslate = matrix4x4_translation(0.5, 0.5, 0);
        matrix_float4x4 shadowTransform = matrix_multiply(shadowTranslate, shadowScale);

        uniforms->shadow_mvp_xform_matrix = matrix_multiply(shadowTransform, uniforms->shadow_mvp_matrix);
    }

    uniforms->fairy_size = .4;

    [self updateLights:uniforms->temple_modelview_matrix];
}

/// Called whenever view changes orientation or layout is changed
- (void)drawableSizeWillChange:(CGSize)size withGBufferStorageMode:(MTLStorageMode)storageMode
{
#if SUPPORT_BUFFER_EXAMINATION_MODE
    if(_bufferExamination.mode != AAPLExaminationModeDisabled)
    {
        storageMode = MTLStorageModePrivate;
        [_bufferExamination drawableSizeWillChange:size];
    }
#endif

    // When reshape is called, update the aspect ratio and projection matrix since the view
    //   orientation or size has changed
	float aspect = size.width / (float)size.height;
    _projection_matrix = matrix_perspective_left_hand(65.0f * (M_PI / 180.0f), aspect, AAPLNearPlane, AAPLFarPlane);

    MTLTextureDescriptor *GBufferTextureDesc =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm_sRGB
                                                           width:size.width
                                                          height:size.height
                                                       mipmapped:NO];

    GBufferTextureDesc.textureType = MTLTextureType2D;
    GBufferTextureDesc.usage |= MTLTextureUsageRenderTarget;
    GBufferTextureDesc.storageMode = storageMode;

    GBufferTextureDesc.pixelFormat = _albedo_specular_GBufferFormat;
    _albedo_specular_GBuffer = [_device newTextureWithDescriptor:GBufferTextureDesc];

    GBufferTextureDesc.pixelFormat = _normal_shadow_GBufferFormat;
    _normal_shadow_GBuffer = [_device newTextureWithDescriptor:GBufferTextureDesc];

    GBufferTextureDesc.pixelFormat = _depth_GBufferFormat;
    _depth_GBuffer = [_device newTextureWithDescriptor:GBufferTextureDesc];

    _albedo_specular_GBuffer.label   = @"Albedo + Shadow GBuffer";
    _normal_shadow_GBuffer.label = @"Normal + Specular GBuffer";
    _depth_GBuffer.label           = @"Depth GBuffer";
}

#pragma mark Common Rendering Code

/// Draw our AAPLMesh objects with the given renderEncoder
- (void) drawMeshes:(nonnull id<MTLRenderCommandEncoder>)renderEncoder
{
    for (__unsafe_unretained AAPLMesh *mesh in _meshes)
    {
        __unsafe_unretained MTKMesh *metalKitMesh = mesh.metalKitMesh;

        // Set mesh's vertex buffers
        for (NSUInteger bufferIndex = 0; bufferIndex < metalKitMesh.vertexBuffers.count; bufferIndex++)
        {
            __unsafe_unretained MTKMeshBuffer *vertexBuffer = metalKitMesh.vertexBuffers[bufferIndex];
            if((NSNull*)vertexBuffer != [NSNull null])
            {
                [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                        offset:vertexBuffer.offset
                                       atIndex:bufferIndex];
            }
        }

        // Draw each submesh of our mesh
        for(__unsafe_unretained AAPLSubmesh *submesh in mesh.submeshes)
        {
            // Set any textures read/sampled from our render pipeline
            [renderEncoder setFragmentTexture:submesh.textures[AAPLTextureIndexBaseColor]
                                      atIndex:AAPLTextureIndexBaseColor];

            [renderEncoder setFragmentTexture:submesh.textures[AAPLTextureIndexNormal]
                                      atIndex:AAPLTextureIndexNormal];

            [renderEncoder setFragmentTexture:submesh.textures[AAPLTextureIndexSpecular]
                                      atIndex:AAPLTextureIndexSpecular];

            MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

            [renderEncoder drawIndexedPrimitives:metalKitSubmesh.primitiveType
                                      indexCount:metalKitSubmesh.indexCount
                                       indexType:metalKitSubmesh.indexType
                                     indexBuffer:metalKitSubmesh.indexBuffer.buffer
                               indexBufferOffset:metalKitSubmesh.indexBuffer.offset];
        }
    }
}

/// Get a drawable from the view (or hand back an offscreen drawable for buffer examination mode)
- (nullable id <MTLTexture>) currentDrawableTexture
{
    id <MTLTexture> drawableTexture =  _view.currentDrawable.texture;

#if SUPPORT_BUFFER_EXAMINATION_MODE
    if(self.bufferExaminationMode)
    {
        drawableTexture = _bufferExamination.offscreenDrawable;;
    }
#endif // SUPPORT_BUFFER_EXAMINATION_MODE

    return drawableTexture;
}

/// Perform operation necessary at the beginning of the frame.  Wait on the in flight semaphore,
/// Get a command buffer and add a completion handler to signal completion of command buffer on GPU
- (nonnull id <MTLCommandBuffer>)beginFrame
{
    // Wait to ensure only AAPLMaxBuffersInFlight are getting processed by any stage in the Metal
    //   pipeline (App, Metal, Drivers, GPU, etc)
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    // Create a new command buffer for each render pass to the current drawable
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    // Add completion hander which signal _inFlightSemaphore when Metal and the GPU has fully
    //   finished processing the commands we're encoding this frame.  This indicates when the
    //   dynamic buffers, that we're writing to this frame, will no longer be needed by Metal
    //   and the GPU.
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
     {
         dispatch_semaphore_signal(block_sema);
     }];

    [self updateWorldState];

    return commandBuffer;
}

/// Perform cleanup operations including presenting the drawable and committing the command buffer
/// for the current frame.  Also, when enabled, draw buffer examination elements before all this.
- (void)endFrame:(nonnull id <MTLCommandBuffer>) commandBuffer{
#if SUPPORT_BUFFER_EXAMINATION_MODE
    // If buffer examination mode is enabled...
    if(_bufferExamination.mode != AAPLExaminationModeDisabled)
    {
        [_bufferExamination drawBuffersForExamination:commandBuffer];
    }
#endif

    // Schedule a present once the framebuffer is complete using the current drawable
    if(_view.currentDrawable)
    {
        [commandBuffer presentDrawable:_view.currentDrawable];
    }

    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
}

/// Draw to the depth texture from the directional lights point of view to generate the shadow map
- (void)drawShadow:(nonnull id <MTLCommandBuffer>)commandBuffer
{
    id<MTLRenderCommandEncoder> encoder =
        [commandBuffer renderCommandEncoderWithDescriptor:_shadowRenderPassDescriptor];

    encoder.label = @"Shadow Map Pass";

    [encoder setRenderPipelineState:_shadowGenPipelineState];
    [encoder setDepthStencilState:_shadowDepthStencilState];
    [encoder setCullMode: MTLCullModeBack];
    [encoder setDepthBias:0.015 slopeScale:7 clamp:0.02];

    [encoder setVertexBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [encoder setVertexBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];

    [self drawMeshes:encoder];

    [encoder endEncoding];
}

/// Draw to the three textures which compose the GBuffer
- (void)drawGBuffer:(nonnull id <MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder pushDebugGroup:@"Draw G-Buffer"];
    [renderEncoder setCullMode:MTLCullModeBack];
    [renderEncoder setRenderPipelineState:_GBufferPipelineState];
    [renderEncoder setDepthStencilState:_GBufferDepthStencilState];
    [renderEncoder setStencilReferenceValue:128];
    [renderEncoder setVertexBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setFragmentBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setFragmentTexture:_shadowMap atIndex:AAPLTextureIndexShadow];

    [self drawMeshes:renderEncoder];
    [renderEncoder popDebugGroup];
}

/// Draw the directional ("sun") light in deferred pass.  Use stencil buffer to limit execution
/// of the shader to only those pixels that should be lit
- (void)drawDirectionalLightCommon:(nonnull id <MTLRenderCommandEncoder>)renderEncoder
{
#if DEFER_ALL_LIGHTING
    [renderEncoder setCullMode:MTLCullModeBack];
    [renderEncoder setStencilReferenceValue:128];

    [renderEncoder setRenderPipelineState:_directionalLightPipelineState];
    [renderEncoder setDepthStencilState:_directionLightDepthStencilState];
    [renderEncoder setVertexBuffer:_quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setVertexBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setFragmentBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];

    // Draw full screen quad
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
#endif // END DEFER_ALL_LIGHTING
}

/// Render to stencil buffer only to increment stencil on that fragments in front
/// of the backside of each light volume
-(void)drawPointLightMask:(nonnull id<MTLRenderCommandEncoder>)renderEncoder
{
#if LIGHT_STENCIL_CULLING
    [renderEncoder pushDebugGroup:@"Draw Light Mask"];
    [renderEncoder setRenderPipelineState:_lightMaskPipelineState];
    [renderEncoder setDepthStencilState:_lightMaskDepthStencilState];

    [renderEncoder setStencilReferenceValue:128];
    [renderEncoder setCullMode:MTLCullModeFront];

    [renderEncoder setVertexBuffer:self.uniformBuffers[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setFragmentBuffer:self.uniformBuffers[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setVertexBuffer:self.lightsData offset:0 atIndex:AAPLBufferIndexLightsData];
    [renderEncoder setVertexBuffer:self.lightPositions[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexLightsPosition];

    MTKMeshBuffer *vertexBuffer = self.icosahedronMesh.vertexBuffers[AAPLBufferIndexMeshPositions];
    [renderEncoder setVertexBuffer:vertexBuffer.buffer offset:vertexBuffer.offset atIndex:AAPLBufferIndexMeshPositions];

    MTKSubmesh *icosahedronSubmesh = self.icosahedronMesh.submeshes[0];
    [renderEncoder drawIndexedPrimitives:icosahedronSubmesh.primitiveType
                              indexCount:icosahedronSubmesh.indexCount
                               indexType:icosahedronSubmesh.indexType
                             indexBuffer:icosahedronSubmesh.indexBuffer.buffer
                       indexBufferOffset:icosahedronSubmesh.indexBuffer.offset
                           instanceCount:AAPLNumLights];

    [renderEncoder popDebugGroup];
#endif
}

/// Performs operations common to both iOS and macOS renders for drawing point lights.  Called
/// by these platform specific renderers after they have set up any platform specific state
/// (such as setting GBuffer textures on macOS which are not needed for iOS)
- (void)drawPointLightsCommon:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setDepthStencilState:_pointLightDepthStencilState];

    [renderEncoder setStencilReferenceValue:128];
    [renderEncoder setCullMode:MTLCullModeBack];

    [renderEncoder setVertexBuffer:self.uniformBuffers[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setVertexBuffer:self.lightsData offset:0 atIndex:AAPLBufferIndexLightsData];
    [renderEncoder setVertexBuffer:self.lightPositions[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexLightsPosition];

    [renderEncoder setFragmentBuffer:self.uniformBuffers[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setFragmentBuffer:self.lightsData offset:0 atIndex:AAPLBufferIndexLightsData];
    [renderEncoder setFragmentBuffer:self.lightPositions[self.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexLightsPosition];

    MTKMeshBuffer *vertexBuffer = self.icosahedronMesh.vertexBuffers[AAPLBufferIndexMeshPositions];
    [renderEncoder setVertexBuffer:vertexBuffer.buffer offset:vertexBuffer.offset atIndex:AAPLBufferIndexMeshPositions];

    MTKSubmesh *icosahedronSubmesh = self.icosahedronMesh.submeshes[0];
    [renderEncoder drawIndexedPrimitives:icosahedronSubmesh.primitiveType
                              indexCount:icosahedronSubmesh.indexCount
                               indexType:icosahedronSubmesh.indexType
                             indexBuffer:icosahedronSubmesh.indexBuffer.buffer
                       indexBufferOffset:icosahedronSubmesh.indexBuffer.offset
                           instanceCount:AAPLNumLights];
}

/// Draw the "fairies" at the center of the point lights with a 2D disk using a texture to perform
/// smooth alpha blending on the edges
- (void)drawFairies:(nonnull id <MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder pushDebugGroup:@"Draw Fairies"];
    [renderEncoder setRenderPipelineState:_fairyPipelineState];
    [renderEncoder setDepthStencilState:_dontWriteDepthStencilState];
    [renderEncoder setCullMode:MTLCullModeBack];
    [renderEncoder setVertexBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setVertexBuffer:_fairy offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setVertexBuffer:_lightsData offset:0 atIndex:AAPLBufferIndexLightsData];
    [renderEncoder setVertexBuffer:_lightPositions[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexLightsPosition];
    [renderEncoder setFragmentTexture:_fairyMap atIndex:AAPLTextureIndexAlpha];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:AAPLNumFairyVertices instanceCount:AAPLNumLights];
    [renderEncoder popDebugGroup];
}

/// Draw the sky dome behind all other geometry (testing against depth buffer generated in
///  GBuffer pass)
- (void)drawSky:(nonnull id <MTLRenderCommandEncoder>)renderEncoder;
{
    [renderEncoder pushDebugGroup:@"Draw Sky"];
    [renderEncoder setRenderPipelineState:_skyboxPipelineState];
    [renderEncoder setDepthStencilState:_dontWriteDepthStencilState];
    [renderEncoder setCullMode:MTLCullModeFront];

    [renderEncoder setVertexBuffer:_uniformBuffers[_currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setFragmentTexture:_skyMap atIndex:AAPLTextureIndexBaseColor];

    // Set mesh's vertex buffers
    for (NSUInteger bufferIndex = 0; bufferIndex < _skyMesh.vertexBuffers.count; bufferIndex++)
    {
        __unsafe_unretained MTKMeshBuffer *vertexBuffer = _skyMesh.vertexBuffers[bufferIndex];
        if((NSNull*)vertexBuffer != [NSNull null])
        {
            [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                    offset:vertexBuffer.offset
                                   atIndex:bufferIndex];
        }
    }

    MTKSubmesh *sphereSubmesh = _skyMesh.submeshes[0];
    [renderEncoder drawIndexedPrimitives:sphereSubmesh.primitiveType
                              indexCount:sphereSubmesh.indexCount
                               indexType:sphereSubmesh.indexType
                             indexBuffer:sphereSubmesh.indexBuffer.buffer
                       indexBufferOffset:sphereSubmesh.indexBuffer.offset];

    [renderEncoder popDebugGroup];
}

#if SUPPORT_BUFFER_EXAMINATION_MODE

- (void)toggleBufferExaminationMode:(AAPLExaminationMode)mode
{
    [_bufferExamination toggleMode:mode];
}

- (AAPLExaminationMode)bufferExaminationMode
{
    return _bufferExamination.mode;
}

#endif // END SUPPORT_BUFFER_EXAMINATION_MODE

@end
