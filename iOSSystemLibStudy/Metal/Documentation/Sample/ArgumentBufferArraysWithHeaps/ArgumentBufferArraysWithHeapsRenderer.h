/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which performs Metal setup and per frame rendering
*/

#if TARGET_OS_IPHONE

@import MetalKit;

// Our platform independent renderer class
@interface ArgumentBufferArraysWithHeapsRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

#endif
