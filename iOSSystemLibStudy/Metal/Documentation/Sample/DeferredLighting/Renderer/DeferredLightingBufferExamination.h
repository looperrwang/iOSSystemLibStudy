/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which performs Metal setup and per frame rendering
*/

#if TARGET_OS_IPHONE

#import "DeferredLightingConfig.h"

#if SUPPORT_BUFFER_EXAMINATION_MODE

@import MetalKit;

@class DeferredLightingRenderer;

typedef enum AAPLExaminationMode
{
    AAPLExaminationModeDisabled,
    AAPLExaminationModeAlbedo,
    AAPLExaminationModeNormals,
    AAPLExaminationModeSpecular,
    AAPLExaminationModeDepth,
    AAPLExaminationModeShadowGBuffer,
    AAPLExaminationModeShadowMap,
    AAPLExaminationModeMaskedLightVolumes,
    AAPLExaminationModeFullLightVolumes,
    AAPLExaminationModeAll
} AAPLExaminationMode;

@interface DeferredLightingBufferExamination : NSObject

- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)mtkView
                               renderer:(nonnull DeferredLightingRenderer *)renderer;

- (void)toggleMode:(AAPLExaminationMode)mode;

- (void)drawableSizeWillChange:(CGSize)size;

- (void)drawBuffersForExamination:(nonnull id<MTLCommandBuffer>)commandBuffer;

@property (nonatomic, readonly) AAPLExaminationMode mode;

// Texture for rendering the final scene when showing all buffers.  Rendered to in place of the
// drawable since all buffers will be rendered to the drawable
@property (nonatomic, nonnull, readonly) id<MTLTexture> offscreenDrawable;

@end

#endif // End SUPPORT_BUFFER_EXAMINATION_MODE

#endif

