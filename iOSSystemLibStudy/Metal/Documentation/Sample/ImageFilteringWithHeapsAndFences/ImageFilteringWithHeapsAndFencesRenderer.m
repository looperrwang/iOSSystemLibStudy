/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/

#import <math.h>
#import "ImageFilteringWithHeapsAndFencesShaderTypes.h"
#import "ImageFilteringWithHeapsAndFencesRenderer.h"
#import "ImageFilteringWithHeapsAndFencesFilter.h"

@import simd;
@import MetalKit;

// Returns a size of the 'inSize' aligned to 'align' as long as align is a power of 2
static NSUInteger alignUp(NSUInteger inSize, NSUInteger align)
{
    // Asset if align is not a power of 2
    assert(((align-1) & align) == 0);

    const NSUInteger alignmentMask = align - 1;

    return ((inSize + alignmentMask) & (~alignmentMask));
}

static const NSTimeInterval AAPLTimeoutSeconds = 7.0;

static const uint32_t AAPLNumImages = 6;

@implementation ImageFilteringWithHeapsAndFencesRenderer
{
    MTKView *_view;

    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLRenderPipelineState> _pipelineState;

    // Application filter classes
    ImageFilteringWithHeapsAndFencesGaussianBlurFilter *_gaussianBlur;
    ImageFilteringWithHeapsAndFencesDownsampleFilter   *_downsample;

    // Texture sampled for rendering fully filtered image
    id<MTLTexture> _displayTexture;

    // Texture with source images loaded from files
    id<MTLTexture> _imageTextures[AAPLNumImages];

    // Current image processed
    NSUInteger _currentImageIndex;

    // Heap containing image
    id<MTLHeap> _imageHeap;

    // Heap with temporary textures used for intermediate texture results
    id<MTLHeap> _scratchHeap;

    // Fence controlling access to _scratchHeap, preventing GPU race-conditions
    id<MTLFence> _fence;

    // Buffer with quad geometry to render texture to display
    id<MTLBuffer> _vertexBuffer;

    // Scale vectors to property resize rendered quad
    vector_float2 _displayScale;
    vector_float2 _quadScale;

    // Timers for blur animation
    NSDate *_start;
    NSTimeInterval _blurStartTime;
}

/// Initialize with the MetalKit view from which we'll obtain our Metal device.  We'll also use this
/// mtkView object to set the pixel format and other properties of our drawable
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    _view = mtkView;
    _device = mtkView.device;

    // Create a new command queue
    _commandQueue = [_device newCommandQueue];

    // Set up a MTLBuffer for vertices with textures coordinates
    static const AAPLVertex vertexData[] =
    {
        //     Vertex     |  Texture    |
        //   Positions    | Coordinates |
        { {  1.f,  -1.f }, { 1.f, 1.f } },
        { { -1.f,  -1.f }, { 0.f, 1.f } },
        { { -1.f,   1.f }, { 0.f, 0.f } },
        { {  1.f,  -1.f }, { 1.f, 1.f } },
        { { -1.f,   1.f }, { 0.f, 0.f } },
        { {  1.f,   1.f }, { 1.f, 0.f } }
    };

    // Create a vertex buffer, and initialize it with our generics array
    _vertexBuffer = [_device newBufferWithBytes:vertexData
                                         length:sizeof(vertexData)
                                        options:MTLResourceStorageModeShared];

    _vertexBuffer.label = @"Vertices";

    id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    // Load the fragment program into the library
    id <MTLFunction> fragmentProgram = [defaultLibrary newFunctionWithName:@"imageFilteringWithHeapsAndFencesTexturedQuadFragment"];

    // Load the vertex program into the library
    id <MTLFunction> vertexProgram = [defaultLibrary newFunctionWithName:@"imageFilteringWithHeapsAndFencesTexturedQuadVertex"];

    // Create a reusable pipeline state
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.sampleCount = _view.sampleCount;
    pipelineStateDescriptor.vertexFunction = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = _view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = _view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = _view.depthStencilPixelFormat;

    NSError *error = nil;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }

    // Create fence
    _fence = [_device newFence];

    // Initialize our filters
    _gaussianBlur = [[ImageFilteringWithHeapsAndFencesGaussianBlurFilter alloc] initWithDevice:_device];
    _downsample = [[ImageFilteringWithHeapsAndFencesDownsampleFilter alloc] initWithDevice:_device];

    [self loadImages];

    [self createImageHeap];

    [self moveImagesToHeap];

    // Set up timer
    _start = [NSDate date];
    _blurStartTime = [_start timeIntervalSinceNow];

    return self;
}

- (void) loadImages
{
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];

    NSError *error;

    for(uint32_t i = 0; i < AAPLNumImages; i++)
    {
        NSString *imageString = [[NSString alloc] initWithFormat:@"ImageFilteringWithHeapsAndFencesImages/Image%i", i];

        NSURL * imageURL = [[NSBundle mainBundle] URLForResource:imageString
                                                   withExtension:@"jpg"];


        // Some GPU families cannot perform compute texture writes to textures using a SRGB
        // format. The filter graph executed by this sample creates a scratch texture using
        // the format of textures loaded here. Because the filter graph writes to this scratch
        // texture from a compute kernel, load the image into a non-sRGB texture.
        BOOL supports_sRGB_writes = NO;

#if TARGET_IOS
        supports_sRGB_writes = [_device supportsFeatureSet:MTLFeatureSet_iOS_GPUFamily3_v1];
#elif TARGET_TVOS
        supports_sRGB_writes = [_device supportsFeatureSet:MTLFeatureSet_tvOS_GPUFamily1_v2];
#endif

        NSDictionary * options = nil;

        if(!supports_sRGB_writes)
        {
            options = @{MTKTextureLoaderOptionSRGB: @NO };
        }

        _imageTextures[i] = [textureLoader newTextureWithContentsOfURL:imageURL
                                                               options:options
                                                                 error:&error];

        if(!_imageTextures[i])
        {
            [NSException raise:NSGenericException
                        format:@"Could not load texture with name %@: %@", imageString, error.localizedDescription];
        }
    }
}

- (void) createImageHeap
{
    MTLHeapDescriptor *heapDescriptor = [MTLHeapDescriptor new];

    heapDescriptor.storageMode = MTLStorageModePrivate;
    heapDescriptor.size =  0;

    // Build a descriptor for each texture and calculate size needed to put the texture in the heap

    // This method of calculating the heap size is only guaranteed to be large enough for all the
    // textures if we also create the textures in the same order we're getting the sizeAndAlign
    // information.  (i.e. If textures have different alignment requirements and we allocate in a
    // different order there may not be enough space for all textures)

    for(uint32_t i = 0; i < AAPLNumImages; i++)
    {
        // Create a descriptor using the texture's properties
        MTLTextureDescriptor *descriptor = [ImageFilteringWithHeapsAndFencesRenderer newDescriptorFromTexture:_imageTextures[i]
                                                                      storageMode:heapDescriptor.storageMode];

        // Determine the size needed for the heap from the given descriptor
        MTLSizeAndAlign sizeAndAlign = [_device heapTextureSizeAndAlignWithDescriptor:descriptor];

        // Align the size so that more resources will fit after this texture
        sizeAndAlign.size = alignUp(sizeAndAlign.size, sizeAndAlign.align);

        // Accumulate the size required for the heap to hold this texture
        heapDescriptor.size += sizeAndAlign.size;
    }

    // Create a heap large enough to hold all resources
    _imageHeap = [_device newHeapWithDescriptor:heapDescriptor];
}

+ (nonnull MTLTextureDescriptor*) newDescriptorFromTexture:(nonnull id<MTLTexture>)texture
                                               storageMode:(MTLStorageMode)storageMode
{
    MTLTextureDescriptor * descriptor = [MTLTextureDescriptor new];

    descriptor.textureType      = texture.textureType;
    descriptor.pixelFormat      = texture.pixelFormat;
    descriptor.width            = texture.width;
    descriptor.height           = texture.height;
    descriptor.depth            = texture.depth;
    descriptor.mipmapLevelCount = texture.mipmapLevelCount;
    descriptor.arrayLength      = texture.arrayLength;
    descriptor.sampleCount      = texture.sampleCount;
    descriptor.storageMode      = storageMode;

    return descriptor;
}

- (void) moveImagesToHeap
{
    // Create a command buffer and blit encoder to upload date from original resources to newly created
    // resources from the heap

    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"Heap Upload Command Buffer";

    id<MTLBlitCommandEncoder> blitEncoder = commandBuffer.blitCommandEncoder;

    // Create new textures from the heap and copy contents of existing textures into the new textures
    for(uint32_t i = 0; i < AAPLNumImages; i++)
    {
        // Create descriptor using the texture's properties
        MTLTextureDescriptor *descriptor = [ImageFilteringWithHeapsAndFencesRenderer newDescriptorFromTexture:_imageTextures[i]
                                                                      storageMode:_imageHeap.storageMode];

        // Create a texture from the heap
        id<MTLTexture> heapTexture = [_imageHeap newTextureWithDescriptor:descriptor];

        // Blit every slice of every level from the original texture to the texture created from the heap
        MTLRegion region = MTLRegionMake2D(0, 0, _imageTextures[i].width, _imageTextures[i].height);

        for(NSUInteger level = 0; level < _imageTextures[i].mipmapLevelCount;  level++)
        {
            for(NSUInteger slice = 0; slice < _imageTextures[i].arrayLength; slice++)
            {
                [blitEncoder copyFromTexture:_imageTextures[i]
                                 sourceSlice:slice
                                 sourceLevel:level
                                sourceOrigin:region.origin
                                  sourceSize:region.size
                                   toTexture:heapTexture
                            destinationSlice:slice
                            destinationLevel:level
                           destinationOrigin:region.origin];
            }

            region.size.width /= 2;
            region.size.height /= 2;
            if(region.size.width == 0) region.size.width = 1;
            if(region.size.height == 0) region.size.height = 1;
        }

        // Replace the original texture with new texture from the heap
        _imageTextures[i] = heapTexture;
    }

    [blitEncoder endEncoding];

    [commandBuffer commit];
}

- (void) createScratchHeap:(nonnull id <MTLTexture>)inTexture
{
    MTLStorageMode heapStorageMode = MTLStorageModePrivate;

    MTLTextureDescriptor *descriptor = [ImageFilteringWithHeapsAndFencesRenderer newDescriptorFromTexture:inTexture
                                                                  storageMode:heapStorageMode];
    descriptor.storageMode = MTLStorageModePrivate;

    MTLSizeAndAlign downsampleSizeAndAlignRequirement = [_downsample heapSizeAndAlignWithInputTextureDescriptor:descriptor];
    MTLSizeAndAlign gaussianBlurSizeAndAlignRequirement = [_gaussianBlur heapSizeAndAlignWithInputTextureDescriptor:descriptor];

    NSUInteger requiredAlignment = MAX(gaussianBlurSizeAndAlignRequirement.align, downsampleSizeAndAlignRequirement.align);
    NSUInteger gaussianBlurSizeAligned = alignUp(gaussianBlurSizeAndAlignRequirement.size, requiredAlignment);
    NSUInteger downsampleSizeAligned = alignUp(downsampleSizeAndAlignRequirement.size, requiredAlignment);
    NSUInteger requiredSize = gaussianBlurSizeAligned + downsampleSizeAligned;

    if(!_scratchHeap || requiredSize > [_scratchHeap maxAvailableSizeWithAlignment:requiredAlignment])
    {
        MTLHeapDescriptor *heapDesc = [[MTLHeapDescriptor alloc] init];

        heapDesc.size        = requiredSize;
        heapDesc.storageMode = heapStorageMode;

        _scratchHeap = [_device newHeapWithDescriptor:heapDesc];
    }
}

- (nonnull id <MTLTexture>) executeFilterGraph:(nonnull id <MTLTexture>)inTexture
{
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    id <MTLTexture> resultTexture;

    resultTexture = [_downsample executeWithCommandBuffer:commandBuffer
                                             inputTexture:inTexture
                                                     heap:_scratchHeap
                                                    fence:_fence];

    resultTexture = [_gaussianBlur executeWithCommandBuffer:commandBuffer
                                               inputTexture:resultTexture
                                                       heap:_scratchHeap
                                                      fence:_fence];

    [commandBuffer commit];

    return resultTexture;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    NSTimeInterval currentTime = [_start timeIntervalSinceNow];
    NSTimeInterval elapsedTime = _blurStartTime - currentTime;
    float blurryness = elapsedTime / AAPLTimeoutSeconds;

    if(!_displayTexture || elapsedTime >= AAPLTimeoutSeconds)
    {
        _blurStartTime = currentTime;

        // Make memory of the display texture usable by by new objects so that our filter operations
        // can temporarily use the memory until the renderer actually needs it
        [_displayTexture makeAliasable];

        id<MTLTexture> inTexture = _imageTextures[_currentImageIndex];

        [self createScratchHeap:inTexture];

        _displayTexture = [self executeFilterGraph:inTexture];
        
        _currentImageIndex = (_currentImageIndex + 1) % AAPLNumImages;
    }

    // Scale quad to maintain the images aspect ration and fit it within the display

    if(_displayTexture.width < _displayTexture.height)
    {
        _quadScale.x = _displayScale.x  * ((float)_displayTexture.width / (float)_displayTexture.height);
        _quadScale.y = _displayScale.y;
    }
    else
    {
        _quadScale.x = _displayScale.x;
        _quadScale.y = _displayScale.y * ((float)_displayTexture.height/ (float)_displayTexture.width);
    }

    // Create a new command buffer for each render pass to the current drawable
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor* renderPassDescriptor = _view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil)
    {
        // Create a render command encoder so we can render into something
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";

        [renderEncoder pushDebugGroup:@"DrawQuad"];

        [renderEncoder setRenderPipelineState:_pipelineState];

        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:AAPLVertexBufferIndexVertices ];
        [renderEncoder setVertexBytes:&_quadScale length:sizeof(_quadScale) atIndex:(NSUInteger)AAPLVertexBufferIndexScale];

        [renderEncoder setFragmentTexture:_displayTexture
                                  atIndex:0];

        float lod = blurryness * _displayTexture.mipmapLevelCount;

        [renderEncoder setFragmentBytes:&lod
                                 length:sizeof(float)
                                atIndex:0];

        // Wait for compute to finish before executing the fragment stage (which occurs during
        // the next draw
        [renderEncoder waitForFence:_fence
                       beforeStages:MTLRenderStageFragment];

        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:6];

        [renderEncoder updateFence:_fence
                       afterStages:MTLRenderStageFragment];

        [renderEncoder popDebugGroup];

        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:_view.currentDrawable];
    }

    [commandBuffer commit];
}

/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    if(size.width < size.height)
    {
        _displayScale.x = 1.0;
        _displayScale.y = (float)size.width / (float)size.height;
    }
    else
    {
        _displayScale.x = (float)size.height / (float)size.width;
        _displayScale.y = 1.0;
    }
}

@end
