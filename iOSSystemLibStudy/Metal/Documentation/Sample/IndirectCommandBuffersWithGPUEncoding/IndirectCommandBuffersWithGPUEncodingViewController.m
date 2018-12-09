/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of our cross-platform view controller
*/

#import "IndirectCommandBuffersWithGPUEncodingViewController.h"
#import "IndirectCommandBuffersWithGPUEncodingRenderer.h"

@implementation IndirectCommandBuffersWithGPUEncodingViewController
{
    MTKView *_view;

    IndirectCommandBuffersWithGPUEncodingRenderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the view to use the default device
    _view = (MTKView *)self.view;
    _view.device = MTLCreateSystemDefaultDevice();

    if(!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
        return;
    }

    BOOL supportICB = NO;
#if !TARGET_IOS
    supportICB = [_view.device supportsFeatureSet:MTLFeatureSet_iOS_GPUFamily3_v4];
#else
    supportICB = [_view.device supportsFeatureSet:MTLFeatureSet_macOS_GPUFamily2_v1];
#endif
    if (!supportICB)
    {
        NSLog(@"Indirect Command Buffer is not supported on this GPU family or OS version");
        return;
    }
    
    _renderer = [[IndirectCommandBuffersWithGPUEncodingRenderer alloc] initWithMetalKitView:_view];

    if(!_renderer)
    {
        NSLog(@"Renderer failed initialization");
        return;
    }

    // Initialize our renderer with the view size
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];

    _view.delegate = _renderer;
}

@end
