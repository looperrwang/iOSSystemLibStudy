/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of event wrapper class, embedding monotonic event increments functionality
*/

#import "ImageFilteringWithHeapsAndEventsEventWrapper.h"


@implementation AAPLSingleDeviceEventWrapper
{
    // Event, controlling sequential operations on GPU
    id<MTLEvent> _event;
    // filters calls counter
    uint64_t _signalCounter;
}

/// device-based constructor
- (instancetype) initWithDevice:(nonnull id <MTLDevice>)device
{
    self = [super init];
 
    // create event
    _event = [device newEvent];
    // zero out signal counter
    _signalCounter = 0u;
    
    return self;
}

/// wait for an event
- (void) wait:(_Nonnull id <MTLCommandBuffer>)commandBuffer
{
    assert([_event.class conformsToProtocol:@protocol(MTLSharedEvent)] || (commandBuffer.device == _event.device));
    
    // Wait for the event to be signaled
    [commandBuffer encodeWaitForEvent:_event value:_signalCounter];
}

/// signal an event
- (void) signal:(_Nonnull id<MTLCommandBuffer>)commandBuffer
{
    assert([_event.class conformsToProtocol:@protocol(MTLSharedEvent)] || (commandBuffer.device == _event.device));

    // Increase the signal counter
    ++_signalCounter;
    // Signal the event
    [commandBuffer encodeSignalEvent:_event value:_signalCounter];
}

@end
