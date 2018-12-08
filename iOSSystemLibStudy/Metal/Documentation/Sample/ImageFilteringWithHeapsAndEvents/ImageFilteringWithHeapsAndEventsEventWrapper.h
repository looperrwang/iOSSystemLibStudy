/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Event wrapper protocol and class providing basic synchronization routines to facilitate encoders ordering. On signaling it advances the internal counter for integrity.
*/

#ifndef ImageFilteringWithHeapsAndEventsEventWrapper_h
#define ImageFilteringWithHeapsAndEventsEventWrapper_h

@import Metal;

@protocol ImageFilteringWithHeapsAndEventsEventWrapper

- (nonnull instancetype) initWithDevice:(nonnull id <MTLDevice>)device;

- (void) wait:(_Nonnull id <MTLCommandBuffer>)commandBuffer;
- (void) signal:(_Nonnull id <MTLCommandBuffer>)commandBuffer;

@end

// Single device event wrapper
@interface AAPLSingleDeviceEventWrapper : NSObject <ImageFilteringWithHeapsAndEventsEventWrapper>
@end

#endif /* APPLEventWrapper_h */

