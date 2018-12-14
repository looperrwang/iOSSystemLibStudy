/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which performs Metal setup and per frame rendering
*/

@import MetalKit;

// Our platform independent renderer class
@interface BasicBuffersRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end