/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering for macOS
*/

#import "AAPLRenderer_macOS.h"

// Include header shared between C code here, which executes Metal API commands, and .metal files
#import "AAPLShaderTypes.h"

@implementation AAPLRenderer_macOS
{
    id <MTLRenderPipelineState> _lightPipelineState;

    id <MTLTexture> _lightGBuffer;

    MTLRenderPassDescriptor *_GBufferRenderPassDescriptor;
    MTLRenderPassDescriptor *_finalRenderPassDescriptor;
}

/// Perform macOS specific renderer initialization
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view
{
    self = [super initWithMetalKitView:view];

    if(self)
    {
        self.GBuffersAttachedInFinalPass = NO;
        [self loadMetal];
        [self loadScene];
    }

    return self;
}

/// Create macOS specific Metal state objects
- (void)loadMetal
{
    [super loadMetal];

    NSError *error;

    id <MTLLibrary> defaultLibrary = [self.device newDefaultLibrary];

    // Create pipeline to render point lights in final pass
    MTLRenderPipelineDescriptor * renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = self.view.colorPixelFormat;

    // Enable additive blending
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].blendingEnabled = YES;
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].rgbBlendOperation = MTLBlendOperationAdd;
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].alphaBlendOperation = MTLBlendOperationAdd;
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].destinationRGBBlendFactor = MTLBlendFactorOne;
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].destinationAlphaBlendFactor = MTLBlendFactorOne;
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].sourceRGBBlendFactor = MTLBlendFactorOne;
    renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].sourceAlphaBlendFactor = MTLBlendFactorOne;

    renderPipelineDescriptor.depthAttachmentPixelFormat = self.view.depthStencilPixelFormat;
    renderPipelineDescriptor.stencilAttachmentPixelFormat = self.view.depthStencilPixelFormat;

    // Setting unique descriptor values for light pipeline state
    {
        id <MTLFunction> lightVertexFunction = [defaultLibrary newFunctionWithName:@"deferred_point_lighting_vertex"];
        id <MTLFunction> lightFragmentFunction = [defaultLibrary newFunctionWithName:@"deferred_point_lighting_fragment"];

        renderPipelineDescriptor.label = @"Light";
        renderPipelineDescriptor.vertexFunction = lightVertexFunction;
        renderPipelineDescriptor.fragmentFunction = lightFragmentFunction;
        _lightPipelineState = [self.device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                      error:&error];
        if (!_lightPipelineState) {
            NSLog(@"Failed to create render pipeline state, error %@", error);
        }
    }

    // Create a render pass descriptor to create an encoder for rendering to the GBuffers.
    // The encoder stores rendered data of each attachment when encoding ends.
    _GBufferRenderPassDescriptor = [MTLRenderPassDescriptor new];

    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetLighting].loadAction = MTLLoadActionDontCare;
#if DEFER_ALL_LIGHTING
    // We don't actually attach anything to the "Lighting" target when we defer all the lighting
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetLighting].storeAction = MTLLoadActionDontCare;
#else
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetLighting].storeAction = MTLStoreActionStore;
#endif
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetAlbedo].loadAction = MTLLoadActionDontCare;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetAlbedo].storeAction = MTLStoreActionStore;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetNormal].loadAction = MTLLoadActionDontCare;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetNormal].storeAction = MTLStoreActionStore;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetDepth].loadAction = MTLLoadActionDontCare;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetDepth].storeAction = MTLStoreActionStore;
    _GBufferRenderPassDescriptor.depthAttachment.clearDepth = 1.0;
    _GBufferRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    _GBufferRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;

    _GBufferRenderPassDescriptor.stencilAttachment.clearStencil = 0;
    _GBufferRenderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionClear;
    _GBufferRenderPassDescriptor.stencilAttachment.storeAction = MTLStoreActionStore;

    // Create a render pass descriptor for our lighting and composition pass
    _finalRenderPassDescriptor = [MTLRenderPassDescriptor new];

    // We'll need to store whatever we render in this pass so it can be displayed
    _finalRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    _finalRenderPassDescriptor.depthAttachment.loadAction = MTLLoadActionLoad;
    _finalRenderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionLoad;

}

/// Set GBuffer textures in render pass descriptor after they have been recreated for resize
- (void) updateGBufferRenderPassDescriptor
{
    // Re-set GBuffer textures in the GBuffer render pass descriptor after they have been
    // reallocated by a resize
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetAlbedo].texture = self.albedo_specular_GBuffer;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetNormal].texture = self.normal_shadow_GBuffer;
    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetDepth].texture = self.depth_GBuffer;

    // Cannot set the depth stencil texture here since MTKView reallocates it *after* the
    // drawableSizeWillChange callback
}

/// MTKViewDelegate Callback: Respond to device orientation change or other view size change
- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Platform independent code allocates all GBuffers >except< lighting GBuffer (since on iOS
    // the lighting buffer is the same as the drawable
    [self drawableSizeWillChange:size withGBufferStorageMode:MTLStorageModePrivate];

    [self updateGBufferRenderPassDescriptor];

    if(view.paused)
    {
        [view draw];
    }
}

/// Draw directional lighting, which, on macOS needs to set GBuffers as textures before executing
/// cross-platform rendering code to draw the light
- (void)drawDirectionalLight:(nonnull id <MTLRenderCommandEncoder>)renderEncoder
{
#if DEFER_ALL_LIGHTING
    [renderEncoder pushDebugGroup:@"Draw Directional Light"];
    [renderEncoder setFragmentTexture:self.albedo_specular_GBuffer atIndex:AAPLRenderTargetAlbedo];
    [renderEncoder setFragmentTexture:self.normal_shadow_GBuffer atIndex:AAPLRenderTargetNormal];
    [renderEncoder setFragmentTexture:self.depth_GBuffer atIndex:AAPLRenderTargetDepth];

    [super drawDirectionalLightCommon:renderEncoder];

    [renderEncoder popDebugGroup];
#endif
}

/// Setup macOS specific pipeline and set GBuffer textures. Then call cross platform code to
/// apply the point lights
- (void) drawPointLights:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder pushDebugGroup:@"Draw Point Lights"];

    [renderEncoder setRenderPipelineState:_lightPipelineState];

    [renderEncoder setFragmentTexture:self.albedo_specular_GBuffer atIndex:AAPLRenderTargetAlbedo];
    [renderEncoder setFragmentTexture:self.normal_shadow_GBuffer atIndex:AAPLRenderTargetNormal];
    [renderEncoder setFragmentTexture:self.depth_GBuffer atIndex:AAPLRenderTargetDepth];

    // Call common renderer after setting platform specific state in renderEncoder
    [super drawPointLightsCommon:renderEncoder];

    [renderEncoder popDebugGroup];
}

/// MTKViewDelegate callback: Called whenever the view needs to render
- (void) drawInMTKView:(nonnull MTKView *)view
{

    id<MTLCommandBuffer> commandBuffer = [self beginFrame];

    [super drawShadow:commandBuffer];

#if !DEFER_ALL_LIGHTING
    id<MTLTexture> drawableTexture = [self currentDrawableTexture];
    if(drawableTexture == nil)
    {
        [commandBuffer commit];
        return;
    }

    _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetLighting].texture = drawableTexture;
#endif

    _GBufferRenderPassDescriptor.depthAttachment.texture = self.view.depthStencilTexture;
    _GBufferRenderPassDescriptor.stencilAttachment.texture = self.view.depthStencilTexture;

    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_GBufferRenderPassDescriptor];

    [super drawGBuffer:renderEncoder];

    [renderEncoder endEncoding];

#if DEFER_ALL_LIGHTING
    // Get drawable as late as possible 
    id<MTLTexture> drawableTexture = self.currentDrawableTexture;
    if(drawableTexture == nil)
    {
        [commandBuffer commit];
        return;
    }
#endif

    // Render the lighting and composition pass
    {
        _finalRenderPassDescriptor.colorAttachments[0].texture = drawableTexture;
        _finalRenderPassDescriptor.depthAttachment.texture = self.view.depthStencilTexture;
        _finalRenderPassDescriptor.stencilAttachment.texture = self.view.depthStencilTexture;

        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_finalRenderPassDescriptor];

        [self drawDirectionalLight:renderEncoder];

        [super drawPointLightMask:renderEncoder];

        [self drawPointLights:renderEncoder];

        [super drawSky:renderEncoder];

        [super drawFairies:renderEncoder];

        [renderEncoder endEncoding];
    }

    [self endFrame:commandBuffer];
}

#if SUPPORT_BUFFER_EXAMINATION_MODE
/// Enable (or disable) buffer examination mode
- (void)toggleBufferExaminationMode:(AAPLExaminationMode)mode
{
    [super toggleBufferExaminationMode:mode];

    if(self.bufferExaminationMode)
    {
        // Clear the background of the GBuffer when examining buffers.  When rendering normally
        // clearing is wasteful, but when examining the buffers, the backgrounds appear corrupt
        // making unclear what's actually rendered to the buffers
        _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetAlbedo].loadAction = MTLLoadActionClear;
        _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetNormal].loadAction = MTLLoadActionClear;
        _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetDepth].loadAction = MTLLoadActionClear;

        // Store depth and stencil buffers after filling then.  This is wasteful when rendering
        // normally, but necessary to present the light mask culling view.
        _finalRenderPassDescriptor.stencilAttachment.storeAction = MTLStoreActionStore;
        _finalRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;
    }
    else
    {
        // When exiting buffer examination mode, return to efficient state settings
        _finalRenderPassDescriptor.stencilAttachment.storeAction = MTLStoreActionDontCare;
        _finalRenderPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
        _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetAlbedo].loadAction = MTLLoadActionDontCare;
        _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetNormal].loadAction = MTLLoadActionDontCare;
        _GBufferRenderPassDescriptor.colorAttachments[AAPLRenderTargetDepth].loadAction = MTLLoadActionDontCare;
    }
}

#endif // END SUPPORT_BUFFER_EXAMINATION_MODE

@end

