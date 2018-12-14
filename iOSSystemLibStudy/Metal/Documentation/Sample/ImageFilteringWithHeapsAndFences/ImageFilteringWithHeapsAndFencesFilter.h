/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Filter protocol and classes which provide utilities for allocating and manipulating
 textures allocated as a heap resource.
*/

#ifndef ImageFilteringWithHeapsAndFencesFilter_h
#define ImageFilteringWithHeapsAndFencesFilter_h

@import Metal;

@protocol ImageFilteringWithHeapsAndFencesFilter

- (nonnull instancetype) initWithDevice:(nonnull id <MTLDevice>)device;

- (MTLSizeAndAlign) heapSizeAndAlignWithInputTextureDescriptor:(nonnull MTLTextureDescriptor *)inDescriptor;

- (nullable id <MTLTexture>) executeWithCommandBuffer:(_Nonnull id <MTLCommandBuffer>)commandBuffer
                                         inputTexture:(_Nonnull id <MTLTexture>)inTexture
                                                 heap:(_Nonnull id <MTLHeap>)heap
                                                fence:(_Nonnull id <MTLFence>)fence;

@end

// Uses the blit encoder to take an input texture and blit it into a texture
// that has been allocated as a heap resource and then generate full a mipmap
// for the texture.
@interface ImageFilteringWithHeapsAndFencesDownsampleFilter : NSObject <ImageFilteringWithHeapsAndFencesFilter>
@end

// Uses a compute encoder to perform a gaussian blur filter on mipmap levels
// [1...n] on the provided input texture.
@interface ImageFilteringWithHeapsAndFencesGaussianBlurFilter : NSObject <ImageFilteringWithHeapsAndFencesFilter>
@end

#endif /* ImageFilteringWithHeapsAndFencesFilter_h */