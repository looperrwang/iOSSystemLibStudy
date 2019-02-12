  /*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of filter classes providing utilities for allocating and manipulating textures allocated as a heap resource.
*/

#if TARGET_OS_IPHONE

#import "ImageFilteringWithHeapsAndFencesFilter.h"
#import "ImageFilteringWithHeapsAndFencesShaderTypes.h"

static const NSUInteger AAPLThreadgroupWidth  = 16;
static const NSUInteger AAPLThreadgroupHeight = 16;
static const NSUInteger AAPLThreadgroupDepth  = 1;

@implementation ImageFilteringWithHeapsAndFencesDownsampleFilter
{
    id <MTLDevice> _device;
}

- (instancetype) initWithDevice:(nonnull id <MTLDevice>)device
{
    self = [super init];

    _device = device;

    return self;
}

- (MTLSizeAndAlign) heapSizeAndAlignWithInputTextureDescriptor:(nonnull MTLTextureDescriptor *)inDescriptor
{
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:inDescriptor.pixelFormat
                                                                                          width:inDescriptor.width
                                                                                         height:inDescriptor.height
                                                                                      mipmapped:YES];

    return [_device heapTextureSizeAndAlignWithDescriptor:descriptor];
}

/// Copy static input image and generate mipmaps
- (nullable id <MTLTexture>) executeWithCommandBuffer:(_Nonnull id <MTLCommandBuffer>)commandBuffer
                                         inputTexture:(_Nonnull id <MTLTexture>)inTexture
                                                 heap:(_Nonnull id <MTLHeap>)heap
                                                fence:(_Nonnull id <MTLFence>)fence
{
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:inTexture.pixelFormat
                                                                                                 width:inTexture.width
                                                                                                height:inTexture.height
                                                                                             mipmapped:YES];
    textureDescriptor.storageMode = heap.storageMode;
    textureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead;

    id <MTLTexture> outTexture = [heap newTextureWithDescriptor:textureDescriptor];
    assert(outTexture && "Failed to allocate on heap, did not request enough resources");

    id <MTLBlitCommandEncoder> blitCommandEncoder = [commandBuffer blitCommandEncoder];

    if(blitCommandEncoder)
    {
        [blitCommandEncoder copyFromTexture:inTexture
                                sourceSlice:0
                                sourceLevel:0
                               sourceOrigin:(MTLOrigin){ 0, 0, 0 }
                                 sourceSize:(MTLSize){ inTexture.width, inTexture.height, inTexture.depth }
                                  toTexture:outTexture
                           destinationSlice:0
                           destinationLevel:0
                          destinationOrigin:(MTLOrigin){ 0, 0, 0}];

        [blitCommandEncoder generateMipmapsForTexture:outTexture];

        [blitCommandEncoder updateFence:fence];

        [blitCommandEncoder endEncoding];
    }

    return outTexture;
}

@end

@implementation ImageFilteringWithHeapsAndFencesGaussianBlurFilter
{
    id <MTLDevice> _device;
    id <MTLComputePipelineState> _horizontalKernel;
    id <MTLComputePipelineState> _verticalKernel;
}

- (instancetype) initWithDevice:(nonnull id <MTLDevice>)device {
    NSError *error;

    self = [super init];

    id <MTLLibrary> defaultLibrary = [device newDefaultLibrary];

    if(!defaultLibrary)
    {
        NSLog(@"Failed creating a new library: %@", error);
    }

    // Create a compute kernel function.
    id <MTLFunction> function = [defaultLibrary newFunctionWithName:@"imageFilteringWithHeapsAndFencesGaussianblurHorizontal"];

    if(!function) {
        NSLog(@"Failed creating a new function");
    }

    // Create a compute kernel.
    _horizontalKernel = [device newComputePipelineStateWithFunction:function
                                                              error:&error];

    if(!_horizontalKernel) {
        NSLog(@"Failed creating a compute kernel: %@", error);
    }

    // Create a compute kernel function.
    function = [defaultLibrary newFunctionWithName:@"imageFilteringWithHeapsAndFencesGaussianblurVertical"];

    if(!function) {
        NSLog(@"Failed creating a new function");
    }

    // Create a compute kernel.
    _verticalKernel = [device newComputePipelineStateWithFunction:function
                                                            error:&error];

    if(!_verticalKernel) {
        NSLog(@"Failed creating a compute kernel: %@", error);
    }

    _device = device;

    return self;
}

- (MTLSizeAndAlign) heapSizeAndAlignWithInputTextureDescriptor:(nonnull MTLTextureDescriptor *)inDescriptor {
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                    width:(inDescriptor.width >> 1)
                                                                                   height:(inDescriptor.height >> 1)
                                                                                mipmapped:NO];

    return [_device heapTextureSizeAndAlignWithDescriptor:textureDescriptor];
}

/// Perform blur in place on each mipmap level, starting with the first mipmap level
- (nullable id <MTLTexture>) executeWithCommandBuffer:(_Nonnull id <MTLCommandBuffer>)commandBuffer
                                         inputTexture:(_Nonnull id <MTLTexture>)inTexture
                                                 heap:(_Nonnull id <MTLHeap>)heap
                                                fence:(_Nonnull id <MTLFence>)fence
{
    MTLTextureDescriptor *textureDescriptor =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                           width:0
                                                          height:0
                                                       mipmapped:NO];

    // Heap resources must share the same storage mode as the heap.
    textureDescriptor.storageMode = heap.storageMode;
    textureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead;

    for(uint32_t mipmapLevel = 1; mipmapLevel < inTexture.mipmapLevelCount; ++mipmapLevel)
    {
        textureDescriptor.width = inTexture.width >> mipmapLevel;
        textureDescriptor.height = inTexture.height >> mipmapLevel;

        if(textureDescriptor.width <= 0) {
            textureDescriptor.width = 1;
        }

        if(textureDescriptor.height <= 0) {
            textureDescriptor.height = 1;
        }

        id <MTLTexture> intermediaryTexture = [heap newTextureWithDescriptor:textureDescriptor];
        assert(intermediaryTexture && "Failed to allocate on heap, did not request enough resources");

        MTLSize threadgroupSize;
        MTLSize threadgroupCount;

        // Set the compute kernel's thread group size of 16x16.
        threadgroupSize = MTLSizeMake(AAPLThreadgroupWidth, AAPLThreadgroupHeight, AAPLThreadgroupDepth);

        // Calculate the compute kernel's width and height.
        threadgroupCount.width = (intermediaryTexture.width  + threadgroupSize.width -  1) / threadgroupSize.width;
        threadgroupCount.height = (intermediaryTexture.height + threadgroupSize.height - 1) / threadgroupSize.height;
        threadgroupCount.depth = 1;

        // Create a view of the input texture from the current mipmap level to output our final result
        id <MTLTexture> outTexture =
            [inTexture newTextureViewWithPixelFormat:inTexture.pixelFormat
                                         textureType:inTexture.textureType
                                              levels:NSMakeRange(mipmapLevel, 1)
                                              slices:NSMakeRange(0, 1)];

        id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];

        if(computeEncoder)
        {
            // Wait for blit operation in AAPLDownsampleFilter AND operations from previous iterations
            // this filter to complete before continuing
            [computeEncoder waitForFence:fence];

            // Perform horizontal blur using the input texture as an input
            // and a view of the mipmap level of input texture as the output

            [computeEncoder setComputePipelineState:_horizontalKernel];

            [computeEncoder setTexture:inTexture
                               atIndex:AAPLBlurTextureIndexInput];

            [computeEncoder setTexture:intermediaryTexture
                               atIndex:AAPLBlurTextureIndexOutput];

            [computeEncoder setBytes:&mipmapLevel
                              length:sizeof(mipmapLevel)
                             atIndex:AAPLBlurBufferIndexLOD];

            [computeEncoder dispatchThreadgroups:threadgroupCount
                           threadsPerThreadgroup:threadgroupSize];

            // Perform vertical blur using the horizontally blurred texture as an input
            // and a view of the mipmap level of the input texture as the output

            [computeEncoder setComputePipelineState:_verticalKernel];

            [computeEncoder setTexture:intermediaryTexture
                               atIndex:AAPLBlurTextureIndexInput];

            [computeEncoder setTexture:outTexture
                               atIndex:AAPLBlurTextureIndexOutput];

            static const uint32_t mipmapLevelZero = 0;
            [computeEncoder setBytes:&mipmapLevelZero
                              length:sizeof(mipmapLevelZero)
                             atIndex:AAPLBlurBufferIndexLOD];

            [computeEncoder dispatchThreadgroups:threadgroupCount
                           threadsPerThreadgroup:threadgroupSize];

            // Indicate that operations on the intermediary texture are complete
            [computeEncoder updateFence:fence];

            [computeEncoder endEncoding];
        }

        // Make the intermediary texture aliasable indicating that the memory can be reused
        [intermediaryTexture makeAliasable];
    }
    return inTexture;
}

@end

#endif
