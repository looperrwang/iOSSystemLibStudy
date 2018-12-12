  /*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/
#import "AAPLBufferExamination.h"

#if SUPPORT_BUFFER_EXAMINATION_MODE

#import "AAPLShaderTypes.h"
#import "AAPLRenderer.h"

@import simd;
@import MetalKit;

#if TARGET_MACOS
#define ColorClass NSColor
#define MakeRect NSMakeRect
#else
#define ColorClass UIColor
#define MakeRect CGRectMake
#endif

@implementation AAPLBufferExamination
{
    MTKView *_view;
    id<MTLDevice> _device;

    // Pipeline state used to visualize the point light volume coverage and stencil
    // culled light volume coverage
    id <MTLRenderPipelineState> _lightVolumeVisualizationPipelineState;
    id <MTLRenderPipelineState> _textureDepthPipelineState;
    id <MTLRenderPipelineState> _textureRGBPipelineState;
    id <MTLRenderPipelineState> _textureAlphaPipelineState;
    id <MTLDepthStencilState> _depthTestOnlyDepthStencilState;

    // Texture to visualize full light volume coverage
    id <MTLTexture> _fullLightVolumeCoverageTexture;

    // Texture to visualize culled light volume coverage
    id<MTLTexture> _maskedLightVolumeCoverageTexture;

    __weak AAPLRenderer * _renderer;

    BOOL _labelsNeedUpdate;

#if TARGET_MACOS
    NSTextField *_bufferLabel[AAPLExaminationModeAll];
#else
    UILabel  *_bufferLabel[AAPLExaminationModeAll];
#endif
}

- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)mtkView
                               renderer:(nonnull AAPLRenderer*)renderer;
{
    self = [super init];
    if(self)
    {
        _view = mtkView;
        _device = _view.device;
        _renderer = renderer;
        [self loadMetalState];

        _bufferLabel[AAPLExaminationModeDisabled] = [self newLabel:@"Final Frame"];
        _bufferLabel[AAPLExaminationModeAlbedo] = [self newLabel:@"G-Buffer Albedo"];
        _bufferLabel[AAPLExaminationModeNormals] = [self newLabel:@"G-Buffer Normals"];
        _bufferLabel[AAPLExaminationModeSpecular] = [self newLabel:@"G-Buffer Specular"];
        _bufferLabel[AAPLExaminationModeDepth] = [self newLabel:@"G-Buffer Depth"];
        _bufferLabel[AAPLExaminationModeShadowGBuffer] = [self newLabel:@"G-Buffer Shadow"];
        _bufferLabel[AAPLExaminationModeShadowMap] = [self newLabel:@"Shadow Map"];
        _bufferLabel[AAPLExaminationModeMaskedLightVolumes] = [self newLabel:@"Masked Light Volume Coverage"];
        _bufferLabel[AAPLExaminationModeFullLightVolumes] = [self newLabel:@"Full Light Volume Coverage"];

        // Change colors to make them more visible
        _bufferLabel[AAPLExaminationModeShadowGBuffer].textColor = [ColorClass redColor];
        _bufferLabel[AAPLExaminationModeShadowMap] .textColor = [ColorClass redColor];
        _bufferLabel[AAPLExaminationModeSpecular].textColor = [ColorClass blackColor];

    }
    return self;
}

#if TARGET_MACOS
- (NSTextField *)newLabel:(NSString*)string
{
    NSTextField * label = [NSTextField new];
    label.textColor = [NSColor whiteColor];
    label.stringValue = string;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.selectable = NO;
    label.hidden = YES;
    label.font = [NSFont boldSystemFontOfSize:14];
    [_view addSubview:label];

    return label;
}
#else // TARGET_MACOS
- (UILabel *)newLabel:(NSString*)string
{
    UILabel * label = [UILabel new];
    label.text = string;
    label.textColor = [UIColor whiteColor];
    label.hidden = YES;
    [_view addSubview:label];

    return label;
}
#endif

- (void) loadMetalState
{
    NSError *error;

    id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    // Set up pipeline to render lightVolumes
    {
        id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"light_volume_visualization_vertex"];
        id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"light_volume_visualization_fragment"];

        MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];

        renderPipelineDescriptor.label = @"Light Volume Visualization";
        renderPipelineDescriptor.vertexDescriptor = nil;
        renderPipelineDescriptor.vertexFunction = vertexFunction;
        renderPipelineDescriptor.fragmentFunction = fragmentFunction;
        renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat =  _view.colorPixelFormat;
        renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
        renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

        _lightVolumeVisualizationPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                                         error:&error];

        if (!_lightVolumeVisualizationPipelineState) {
            NSLog(@"Failed to create light volume visualization render pipeline state, error %@", error);
        }
    }

    // Set up pipelines to display raw GBuffers
    {
        id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"texture_values_vertex"];
        id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"texture_rgb_fragment"];

        // Create simple pipelines that either render RGB or Alpha component of a texture
        MTLRenderPipelineDescriptor *renderPipelineDescriptor = [MTLRenderPipelineDescriptor new];

        renderPipelineDescriptor.label = @"Light Volume Visualization";
        renderPipelineDescriptor.vertexDescriptor = nil;
        renderPipelineDescriptor.vertexFunction = vertexFunction;
        renderPipelineDescriptor.fragmentFunction = fragmentFunction;
        renderPipelineDescriptor.colorAttachments[AAPLRenderTargetLighting].pixelFormat = _view.colorPixelFormat;
        renderPipelineDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
        renderPipelineDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

        // Pipeline to render RGB components of a texture
        _textureRGBPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                             error:&error];

        if (!_textureRGBPipelineState)
        {
            NSLog(@"Failed to create texture RGB render pipeline state, error %@", error);
        }

        // Pipeline to render Alpha components of a texture (in RGB as grayscale)
        fragmentFunction = [defaultLibrary newFunctionWithName:@"texture_alpha_fragment"];
        renderPipelineDescriptor.fragmentFunction = fragmentFunction;
        _textureAlphaPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                               error:&error];

        if (!_textureAlphaPipelineState)
        {
            NSLog(@"Failed to create texture alpha render pipeline state, error %@", error);
        }

        // Pipeline to render Alpha components of a texture (in RGB as grayscale), but with the
        // ability to apply a range with which to divide the alpha value by so that grayscale value
        // is normalized from 0-1
        fragmentFunction = [defaultLibrary newFunctionWithName:@"texture_depth_fragment"];
        renderPipelineDescriptor.fragmentFunction = fragmentFunction;
        _textureDepthPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor
                                                                             error:&error];

        if (!_textureDepthPipelineState)
        {
            NSLog(@"Failed to create texture depth render pipeline state, error %@", error);
        }
    }

    {
        MTLDepthStencilDescriptor *depthStateDesc = [MTLDepthStencilDescriptor new];
        depthStateDesc.depthWriteEnabled = NO;
        depthStateDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
        depthStateDesc.label = @"Depth Test Only";

        _depthTestOnlyDepthStencilState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    }
}

- (nonnull MTLRenderPassDescriptor*)bufferExaminationDescriptor
{
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].texture = _view.currentDrawable.texture;
    renderPassDescriptor.depthAttachment.texture = _view.depthStencilTexture;
    renderPassDescriptor.stencilAttachment.texture = _view.depthStencilTexture;
    return renderPassDescriptor;
}

- (void)toggleMode:(AAPLExaminationMode)mode
{

    if(_mode == mode ||
       AAPLExaminationModeDisabled == mode)
    {
        _mode = AAPLExaminationModeDisabled;

        _offscreenDrawable = nil;
        _fullLightVolumeCoverageTexture = nil;
        _maskedLightVolumeCoverageTexture = nil;
    }
    else
    {
        _mode = mode;

        _labelsNeedUpdate = YES;

        [self drawableSizeWillChange:_view.drawableSize];
    }

    // Hide all labels since mode is changing.  Labels that need to be visible will be unhidden
    // when drawBuffersForExamination is called
    for(NSUInteger labelIdx = 0; labelIdx < AAPLExaminationModeAll; labelIdx++)
    {
        _bufferLabel[labelIdx].hidden = YES;
    }

    if(_view.paused)
    {
        [_view draw];
    }
}

- (void) drawableSizeWillChange:(CGSize)size
{
    MTLTextureDescriptor *finalTextureDesc =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:_view.colorPixelFormat
                                                           width:size.width
                                                          height:size.height
                                                       mipmapped:NO];

    finalTextureDesc.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;

    _offscreenDrawable = [_device newTextureWithDescriptor:finalTextureDesc];
    _offscreenDrawable.label = @"Offscreen Drawable";

    _fullLightVolumeCoverageTexture  = [_device newTextureWithDescriptor:finalTextureDesc];
    _fullLightVolumeCoverageTexture.label = @"Full Light Volume Coverage";

    _maskedLightVolumeCoverageTexture  = [_device newTextureWithDescriptor:finalTextureDesc];
    _maskedLightVolumeCoverageTexture.label = @"Stencil Masked Light Volume Coverage";

    _labelsNeedUpdate = YES;
}

/// Draws icosahedrons encapsulating the pointLight volumes in *red*. This shows the fragments the
/// point light fragment shader would need to execute if culling were not enabled.  If light
/// culling is enabled. the fragments drawn when culling enabled are colored *green* allowing
/// user to compare the coverage
- (void)renderFullLightVolumeExaminationWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
{
    // Set texture to render and eventually render to the drawable
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionDontCare;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].texture = _fullLightVolumeCoverageTexture;
    renderPassDescriptor.depthAttachment.texture = _view.depthStencilTexture;
    renderPassDescriptor.stencilAttachment.texture = _view.depthStencilTexture;
    renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionLoad;
    renderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionLoad;

    id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

    // First draw the final fully composited scene as the background
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_offscreenDrawable atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];

    // Set simple pipeline which just draws a single color
    [renderEncoder setRenderPipelineState:_lightVolumeVisualizationPipelineState];
    [renderEncoder setCullMode:MTLCullModeBack];

    // Set depth stencil state that won't use stencil test
    [renderEncoder setDepthStencilState:_depthTestOnlyDepthStencilState];;
    [renderEncoder setVertexBuffer:_renderer.uniformBuffers[_renderer.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setVertexBuffer:_renderer.lightsData offset:0 atIndex:AAPLBufferIndexLightsData];
    [renderEncoder setVertexBuffer:_renderer.lightPositions[_renderer.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexLightsPosition];

    MTKMeshBuffer *vertexBuffer = _renderer.icosahedronMesh.vertexBuffers[AAPLBufferIndexMeshPositions];
    [renderEncoder setVertexBuffer:vertexBuffer.buffer offset:vertexBuffer.offset atIndex:AAPLBufferIndexMeshPositions];

    MTKSubmesh *icosahedronSubmesh = _renderer.icosahedronMesh.submeshes[0];

    // Set red color to output in fragment function
    vector_float4 redColor = { 1, 0, 0, 1 };
    [renderEncoder setFragmentBytes:&redColor length:sizeof(redColor) atIndex:AAPLBufferIndexFlatColor];

    [renderEncoder drawIndexedPrimitives:icosahedronSubmesh.primitiveType
                              indexCount:icosahedronSubmesh.indexCount
                               indexType:icosahedronSubmesh.indexType
                             indexBuffer:icosahedronSubmesh.indexBuffer.buffer
                       indexBufferOffset:icosahedronSubmesh.indexBuffer.offset
                           instanceCount:AAPLNumLights];

#if LIGHT_STENCIL_CULLING
    // Setup stencil culling state
    [renderEncoder setDepthStencilState:_renderer.pointLightDepthStencilState];
    [renderEncoder setStencilReferenceValue:128];

    // Set green color to output in fragment function
    vector_float4 greenColor = { 0, 1, 0, 1 };
    [renderEncoder setFragmentBytes:&greenColor length:sizeof(greenColor) atIndex:AAPLBufferIndexFlatColor];

    // Draw volumes a second time with stencil mask enabled (in green)
    [renderEncoder drawIndexedPrimitives:icosahedronSubmesh.primitiveType
                              indexCount:icosahedronSubmesh.indexCount
                               indexType:icosahedronSubmesh.indexType
                             indexBuffer:icosahedronSubmesh.indexBuffer.buffer
                       indexBufferOffset:icosahedronSubmesh.indexBuffer.offset
                           instanceCount:AAPLNumLights];
#endif // LIGHT_STENCIL_CULLING

    [renderEncoder endEncoding];
}

- (void) renderPointLightMaskExaminationWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
{
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].texture = _maskedLightVolumeCoverageTexture;
    renderPassDescriptor.depthAttachment.texture = _view.depthStencilTexture;
    renderPassDescriptor.stencilAttachment.texture = _view.depthStencilTexture;
    renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionLoad;
    renderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionLoad;

    id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

#if LIGHT_STENCIL_CULLING

    // First draw the final fully composited scene as the background
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_offscreenDrawable atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];

    // Set simple pipeline which just draws a single color
    [renderEncoder setRenderPipelineState:_lightVolumeVisualizationPipelineState];
    [renderEncoder setCullMode:MTLCullModeBack];
    // Set green color to output in fragment function
    vector_float4 greenColor = { 0, 1, 0, 1 };
    [renderEncoder setFragmentBytes:&greenColor length:sizeof(greenColor) atIndex:AAPLBufferIndexFlatColor];
    [renderEncoder setVertexBuffer:_renderer.uniformBuffers[_renderer.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexUniforms];
    [renderEncoder setVertexBuffer:_renderer.lightsData offset:0 atIndex:AAPLBufferIndexLightsData];
    [renderEncoder setVertexBuffer:_renderer.lightPositions[_renderer.currentBufferIndex] offset:0 atIndex:AAPLBufferIndexLightsPosition];
    MTKMeshBuffer *vertexBuffer = _renderer.icosahedronMesh.vertexBuffers[AAPLBufferIndexMeshPositions];
    [renderEncoder setVertexBuffer:vertexBuffer.buffer offset:vertexBuffer.offset atIndex:AAPLBufferIndexMeshPositions];

    MTKSubmesh *icosahedronSubmesh = _renderer.icosahedronMesh.submeshes[0];

    // Set depth stencil state that uses stencil test to cull fragments
    [renderEncoder setDepthStencilState:_renderer.pointLightDepthStencilState];

    [renderEncoder setStencilReferenceValue:128];

    // Draw volumes with stencil mask enabled (in green)
    [renderEncoder drawIndexedPrimitives:icosahedronSubmesh.primitiveType
                              indexCount:icosahedronSubmesh.indexCount
                               indexType:icosahedronSubmesh.indexType
                             indexBuffer:icosahedronSubmesh.indexBuffer.buffer
                       indexBufferOffset:icosahedronSubmesh.indexBuffer.offset
                           instanceCount:AAPLNumLights];
#endif // END LIGHT_STENCIL_CULLING

    [renderEncoder endEncoding];

}

- (void)drawAlbedoGBufferWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_renderer.albedo_specular_GBuffer atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawNormalGBufferWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_renderer.normal_shadow_GBuffer atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawDepthGBufferWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureDepthPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_renderer.depth_GBuffer atIndex:AAPLTextureIndexBaseColor];
#if USE_EYE_DEPTH
    float depthRange = AAPLFarPlane - AAPLNearPlane;
#else
    float depthRange = 1.0;
#endif
    [renderEncoder setFragmentBytes:&depthRange length:sizeof(depthRange) atIndex:AAPLBufferIndexDepthRange];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawShadowGBufferWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureAlphaPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_renderer.normal_shadow_GBuffer atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawFinalRenderWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_offscreenDrawable atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawSpecularGBufferWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureAlphaPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_renderer.albedo_specular_GBuffer atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawShadowMapWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    float depthRange = 1.0;
    [renderEncoder setFragmentBytes:&depthRange length:sizeof(depthRange) atIndex:AAPLBufferIndexDepthRange];
    [renderEncoder setRenderPipelineState:_textureDepthPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_renderer.shadowMap atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawMaskedLightBufferWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_maskedLightVolumeCoverageTexture atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void)drawFullLightVolumesWithRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    [renderEncoder setRenderPipelineState:_textureRGBPipelineState];
    [renderEncoder setVertexBuffer:_renderer.quadVertexBuffer offset:0 atIndex:AAPLBufferIndexMeshPositions];
    [renderEncoder setFragmentTexture:_fullLightVolumeCoverageTexture atIndex:AAPLTextureIndexBaseColor];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
}

- (void) drawBuffersForExamination:(id<MTLCommandBuffer>)commandBuffer
{
    assert(_offscreenDrawable);

    if(_view.currentDrawable.texture == nil)
    {
        return;
    }

    if(_mode == AAPLExaminationModeFullLightVolumes ||
       _mode == AAPLExaminationModeAll)
    {
        [self renderFullLightVolumeExaminationWithCommandBuffer:commandBuffer];
    }

    if(_mode == AAPLExaminationModeMaskedLightVolumes ||
       _mode == AAPLExaminationModeAll)
    {
        [self renderPointLightMaskExaminationWithCommandBuffer:commandBuffer];
    }

    // Create an encoder to draw the buffer (or buffers) on top of the rendering
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].texture = _view.currentDrawable.texture;
    renderPassDescriptor.depthAttachment.texture = _view.depthStencilTexture;
    renderPassDescriptor.stencilAttachment.texture = _view.depthStencilTexture;

    id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

    switch(_mode)
    {
        case AAPLExaminationModeAll:
        {
            // Use viewport and a quad that's already in NDC coordinates with a passthrough
            // vertex shader to place the 9 buffers on the drawable

            MTLViewport viewport = {0, 0, 0, 0, 0, 1};

            // Width & Height in *pixels* divided by 3
            float pixWidthDiv3 = _view.drawableSize.width / 3.0;
            float pixHeightDiv3 = _view.drawableSize.height / 3.0;

            // Top Left Pane: GBuffer Albedo
            viewport = (MTLViewport){0, 0, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawAlbedoGBufferWithRenderEncoder:renderEncoder];

            // Top Center Pane: GBuffer Normal
            viewport = (MTLViewport){pixWidthDiv3, 0, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];;
            [self drawNormalGBufferWithRenderEncoder:renderEncoder];

            // Top Right Pane: GBuffer Depth
            viewport = (MTLViewport){2*pixWidthDiv3, 0, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawDepthGBufferWithRenderEncoder:renderEncoder];

            // Center Left Pane: GBuffer Shadow
            viewport = (MTLViewport){0, pixHeightDiv3, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawShadowGBufferWithRenderEncoder:renderEncoder];

            // Direct Center Pane: Final Render
            viewport = (MTLViewport){pixWidthDiv3, pixHeightDiv3, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawFinalRenderWithRenderEncoder:renderEncoder];

            // Center Right Pane: GBuffer Specular
            viewport = (MTLViewport){2*pixWidthDiv3, pixHeightDiv3, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawSpecularGBufferWithRenderEncoder:renderEncoder];

            // Bottom Left Pane: GBuffer ShadowMap

            // Make viewport square since shadow map is always square regardless of the drawable
            // dimensions
            float squareDimension = MIN(pixWidthDiv3, pixHeightDiv3);
            float pixOffset_x = (pixWidthDiv3 - squareDimension)/2.0 ;
            float pixOffset_y = (pixHeightDiv3 - squareDimension)/2.0 + 2*pixHeightDiv3;
            viewport = (MTLViewport){pixOffset_x, pixOffset_y, squareDimension, squareDimension};
            [renderEncoder setViewport:viewport];
            [self drawShadowMapWithRenderEncoder:renderEncoder];

            // Bottom Center Pane: Masked Light Volumes
            viewport = (MTLViewport){pixWidthDiv3, 2*pixHeightDiv3, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawMaskedLightBufferWithRenderEncoder:renderEncoder];

            // Bottom Right Pane: Full (unmasked) Light Volumes
            viewport = (MTLViewport){2*pixWidthDiv3, 2*pixHeightDiv3, pixWidthDiv3, pixHeightDiv3};
            [renderEncoder setViewport:viewport];
            [self drawFullLightVolumesWithRenderEncoder:renderEncoder];

            // If the mode has changed or drawable has been resized unhide labels and place them
            // on the buffers
            if(_labelsNeedUpdate)
            {
                // Coordinates in *points* not pixels.
                float width = _view.frame.size.width;
                float height = _view.frame.size.height;
                float widthDiv3 = width / 3.0;
                float heightDiv3 = height / 3.0;
                float offset = 0;
#ifdef TARGET_MACOS
                heightDiv3 = -heightDiv3;
#else
                const float labelHeight = _bufferLabel[AAPLExaminationModeAlbedo].font.pointSize;
                offset = -(height-labelHeight)/2.0;
#endif

                for(NSUInteger labelIdx = 0; labelIdx < AAPLExaminationModeAll; labelIdx++)
                {
                    _bufferLabel[labelIdx].hidden = NO;
                }

                _bufferLabel[AAPLExaminationModeDisabled].frame = MakeRect(widthDiv3, offset+heightDiv3,  width,  height);
                _bufferLabel[AAPLExaminationModeAlbedo].frame = MakeRect(0, offset, width, height);
                _bufferLabel[AAPLExaminationModeNormals].frame = MakeRect(widthDiv3, offset, width,  height);
                _bufferLabel[AAPLExaminationModeSpecular].frame = MakeRect(2*widthDiv3, offset+heightDiv3, width,  height);
                _bufferLabel[AAPLExaminationModeDepth].frame = MakeRect(2*widthDiv3, offset, width, height);
                _bufferLabel[AAPLExaminationModeShadowGBuffer].frame = MakeRect(0, offset+heightDiv3, width, height);
                _bufferLabel[AAPLExaminationModeShadowMap].frame = MakeRect(0, offset+2*heightDiv3, width, height);
                _bufferLabel[AAPLExaminationModeMaskedLightVolumes].frame = MakeRect(widthDiv3, offset+2*heightDiv3, width, height);
                _bufferLabel[AAPLExaminationModeFullLightVolumes].frame = MakeRect(2*widthDiv3, offset+2*heightDiv3,  width,  height);
            }

            break;
        }
        case AAPLExaminationModeAlbedo:
            [self drawAlbedoGBufferWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeNormals:
            [self drawNormalGBufferWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeDepth:
            [self drawDepthGBufferWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeSpecular:
            [self drawSpecularGBufferWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeShadowGBuffer:
            [self drawShadowGBufferWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeShadowMap:
        {
            // Shadow map is always square so make viewport square and put it in the center of
            // the drawable
            float squaredDimension = MIN(_view.drawableSize.width, _view.drawableSize.height);

            float offset_x = (_view.drawableSize.width - squaredDimension) / 2.0;
            float offset_y = (_view.drawableSize.height - squaredDimension) / 2.0;

            [renderEncoder setViewport:(MTLViewport){offset_x, offset_y, squaredDimension, squaredDimension, 0, 1}];

            [self drawShadowMapWithRenderEncoder:renderEncoder];
            break;
        }
        case AAPLExaminationModeMaskedLightVolumes:
            [self drawMaskedLightBufferWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeFullLightVolumes:
            [self drawFullLightVolumesWithRenderEncoder:renderEncoder];
            break;
        case AAPLExaminationModeDisabled:
            assert(!"this method should not be called when Examination Mode is Disabled");
            break;
    }

    // If the label needs update and the mode is one where only one buffer is presented
    // place the label for the buffer in the upper left corner and un hide it.
    // (This operation works differently when all buffers are shown and handled in the case for
    // AAPLExaminationModeAll above)
    if(_labelsNeedUpdate && _mode != AAPLExaminationModeAll)
    {
        _bufferLabel[_mode].frame = MakeRect(0, 0, _view.frame.size.width, _view.frame.size.height);
        _bufferLabel[_mode].hidden = NO;
    }

    [renderEncoder endEncoding];

    _labelsNeedUpdate = NO;
}

@end

#endif // END SUPPORT_BUFFER_EXAMINATION_MODE
