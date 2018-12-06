/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/

@import simd;
@import MetalKit;

#import "DevicesAndCommandsRenderer.h"

/// Main class performing the rendering
@implementation DevicesAndCommandsRenderer
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
}

typedef struct {
    float red, green, blue, alpha;
} Color;

/// Initialize with the MetalKit view from which we'll obtain our Metal device
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;

		_commandQueue = [_device newCommandQueue];
    }

    return self;
}

/// Gradually cycles through different colors on each invocation.  Generally you would just pick
///   a single clear color, set it once and forget, but since that would make this sample
///   very boring we'll just return a different clear color each frame :)
- (Color)makeFancyColor
{
    static BOOL       growing = YES;
    static NSUInteger primaryChannel = 0;
    static float      colorChannels[] = {1.0, 0.0, 0.0, 1.0};

    const float DynamicColorRate = 0.015;

    if(growing)
    {
        NSUInteger dynamicChannelIndex = (primaryChannel+1)%3;
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        if(colorChannels[dynamicChannelIndex] >= 1.0)
        {
            growing = NO;
            primaryChannel = dynamicChannelIndex;
        }
    }
    else
    {
        NSUInteger dynamicChannelIndex = (primaryChannel+2)%3;
        colorChannels[dynamicChannelIndex] -= DynamicColorRate;
        if(colorChannels[dynamicChannelIndex] <= 0.0)
        {
            growing = YES;
        }
    }

    Color color;

    color.red   = colorChannels[0];
    color.green = colorChannels[1];
    color.blue  = colorChannels[2];
    color.alpha = colorChannels[3];

    return color;
}

#pragma mark - MTKViewDelegate methods

/// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view
{
    Color color = [self makeFancyColor];
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);

    // Create a new command buffer for each render pass to the current drawable
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    // Obtain a render pass descriptor, generated from the view's drawable
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    // If you've successfully obtained a render pass descriptor, you can render to
    // the drawable; otherwise you skip any rendering this frame because you have no
    // drawable to draw to
    if(renderPassDescriptor != nil)
    {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

        renderEncoder.label = @"MyRenderEncoder";

        // We would normally use the render command encoder to draw our objects, but for
        //   the purposes of this sample, all we need is the GPU clear command that
        //   Metal implicitly performs when we create the encoder.

        // Since we aren't drawing anything, indicate we're finished using this encoder
        [renderEncoder endEncoding];

        // Add a final command to present the cleared drawable to the screen
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    // Finalize rendering here and submit the command buffer to the GPU
    [commandBuffer commit];
}

/// Called whenever the view size changes or a relayout occurs (such as changing from landscape to
///   portrait mode or the size of the window changes)
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

@end
