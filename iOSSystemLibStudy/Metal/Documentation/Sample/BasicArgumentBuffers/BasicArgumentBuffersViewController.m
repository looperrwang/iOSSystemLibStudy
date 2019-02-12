/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of our cross-platform view controller
*/

#if TARGET_OS_IPHONE

#import "BasicArgumentBuffersViewController.h"
#import "BasicArgumentBuffersRenderer.h"

@implementation BasicArgumentBuffersViewController
{
    MTKView *_view;

    BasicArgumentBuffersRenderer *_renderer;
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

    _renderer = [[BasicArgumentBuffersRenderer alloc] initWithMetalKitView:_view];

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

#endif
