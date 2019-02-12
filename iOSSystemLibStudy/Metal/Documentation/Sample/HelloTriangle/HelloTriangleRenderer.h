/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for our platform independent renderer class, which performs Metal setup and per frame rendering
*/

#if TARGET_OS_IPHONE

@import MetalKit;

// Our platform independent renderer class
@interface HelloTriangleRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

#endif
