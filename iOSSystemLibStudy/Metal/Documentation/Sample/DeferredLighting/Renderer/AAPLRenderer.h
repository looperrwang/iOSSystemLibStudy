/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which performs Metal setup and per frame rendering
*/
#import "AAPLConfig.h"
#import "AAPLBufferExamination.h"

@import MetalKit;

// Number of "fairy" lights in scene
static const NSUInteger AAPLNumLights = 256;

static const float AAPLNearPlane = 1;
static const float AAPLFarPlane = 150;

@interface AAPLRenderer : NSObject

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

// Common rendering methods called by derived classes

- (void)loadMetal;

- (void)loadScene;

- (nonnull id <MTLCommandBuffer>)beginFrame;

- (void)endFrame:(nonnull id <MTLCommandBuffer>) commandBuffer;

- (void)drawMeshes:(nonnull id<MTLRenderCommandEncoder>)renderEncoder;

- (void)drawShadow:(nonnull id <MTLCommandBuffer>)commandBuffer;

- (void)drawGBuffer:(nonnull id <MTLRenderCommandEncoder>)renderEncoder;

- (void)drawDirectionalLightCommon:(nonnull id <MTLRenderCommandEncoder>)renderEncoder;

- (void)drawPointLightMask:(nonnull id<MTLRenderCommandEncoder>)renderEncoder;

- (void)drawPointLightsCommon:(nonnull id<MTLRenderCommandEncoder>)renderEncoder;

- (void)drawFairies:(nonnull id <MTLRenderCommandEncoder>)renderEncoder;

- (void)drawSky:(nonnull id <MTLRenderCommandEncoder>)renderEncoder;

- (void)drawableSizeWillChange:(CGSize)size withGBufferStorageMode:(MTLStorageMode)storageMode;

@property (nonatomic, readonly, nonnull) id <MTLDevice> device;

@property (nonatomic, readonly, nonnull) MTKView *view;

// Current buffer to fill with dynamic uniform data and set for the current frame
@property (nonatomic, readonly) int8_t currentBufferIndex;

// GBuffer properties

@property (nonatomic, readonly) MTLPixelFormat albedo_specular_GBufferFormat;

@property (nonatomic, readonly) MTLPixelFormat normal_shadow_GBufferFormat;

@property (nonatomic, readonly) MTLPixelFormat depth_GBufferFormat;

@property (nonatomic, readonly, nonnull) id <MTLTexture> albedo_specular_GBuffer;

@property (nonatomic, readonly, nonnull) id <MTLTexture> normal_shadow_GBuffer;

@property (nonatomic, readonly, nonnull) id <MTLTexture> depth_GBuffer;

@property (nonatomic, readonly, nullable) id <MTLTexture> currentDrawableTexture;

// Depth texture used to render shadows
@property (nonatomic, readonly, nonnull) id <MTLTexture> shadowMap;

// This is used to build render pipelines that perform common operations for both the iOS and macOS
// renderers.  The only difference between the iOS and macOS versions of these pipelines is that
// the iOS renderer needs the GBuffers attached as render target while the macOS renderer needs
// the GBuffers set as textures to sample/read from.   So this is YES for the iOS renderer and NO
// for the macOS renderer so that some of the code to create these pipelines can be shared and
// implemented in this AAPLRenderer base class which is common to both renderers.
@property (nonatomic) BOOL GBuffersAttachedInFinalPass;

@property (nonatomic, readonly, nonnull) id <MTLDepthStencilState> dontWriteDepthStencilState;

@property (nonatomic, readonly, nonnull) id <MTLDepthStencilState> pointLightDepthStencilState;

// Buffers used to store dynamically changing per frame data
@property (nonatomic, readonly, nonnull) NSArray<id<MTLBuffer>> *uniformBuffers;

// Buffers used to story dynamically changing light positions
@property (nonatomic, readonly, nonnull) NSArray<id<MTLBuffer>> *lightPositions;

// Buffer for constant light data
@property (nonatomic, readonly, nonnull) id <MTLBuffer> lightsData;

// Mesh for an icosahedron used for rendering point lights
@property (nonatomic, readonly, nonnull) MTKMesh *icosahedronMesh;

// Mesh buffer for simple Quad
@property (nonatomic, readonly, nonnull)  id<MTLBuffer> quadVertexBuffer;

#if SUPPORT_BUFFER_EXAMINATION_MODE

- (void)toggleBufferExaminationMode:(AAPLExaminationMode)mode;

@property (nonatomic, readonly) AAPLExaminationMode bufferExaminationMode;

#endif // END SUPPORT_BUFFER_EXAMINATION_MODE

@end
