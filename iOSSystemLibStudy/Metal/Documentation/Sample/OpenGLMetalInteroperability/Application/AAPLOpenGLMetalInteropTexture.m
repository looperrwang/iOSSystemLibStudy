/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implemenation of class representing a texture shared between OpenGL and Metal
*/
#import "AAPLOpenGLMetalInteropTexture.h"

typedef struct {
    int                 cvPixelFormat;
    MTLPixelFormat      mtlFormat;
    GLuint              glInternalFormat;
    GLuint              glFormat;
    GLuint              glType;
} AAPLTextureFormatInfo;

#if TARGET_IOS
#define GL_UNSIGNED_INT_8_8_8_8_REV 0x8367
#endif

// Table of equivalent formats across CoreVideo, Metal, and OpenGL
static const AAPLTextureFormatInfo AAPLInteropFormatTable[] =
{
    // Core Video Pixel Format,               Metal Pixel Format,            GL internalformat, GL format,   GL type
    { kCVPixelFormatType_32BGRA,              MTLPixelFormatBGRA8Unorm,      GL_RGBA,           GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV },
#if TARGET_IOS
    { kCVPixelFormatType_32BGRA,              MTLPixelFormatBGRA8Unorm_sRGB, GL_RGBA,           GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV },
#else
    { kCVPixelFormatType_ARGB2101010LEPacked, MTLPixelFormatBGR10A2Unorm,    GL_RGB10_A2,       GL_BGRA,     GL_UNSIGNED_INT_2_10_10_10_REV },
    { kCVPixelFormatType_32BGRA,              MTLPixelFormatBGRA8Unorm_sRGB, GL_SRGB8_ALPHA8,   GL_BGRA,     GL_UNSIGNED_INT_8_8_8_8_REV },
    { kCVPixelFormatType_64RGBAHalf,          MTLPixelFormatRGBA16Float,     GL_RGBA,           GL_RGBA,     GL_HALF_FLOAT },
#endif
};

static const NSUInteger AAPLNumInteropFormats = sizeof(AAPLInteropFormatTable) / sizeof(AAPLTextureFormatInfo);

const AAPLTextureFormatInfo *const textureFormatInfoFromMetalPixelFormat(MTLPixelFormat pixelFormat)
{
    for(int i = 0; i < AAPLNumInteropFormats; i++) {
        if(pixelFormat == AAPLInteropFormatTable[i].mtlFormat) {
            return &AAPLInteropFormatTable[i];
        }
    }
    return NULL;
}

@implementation AAPLOpenGLMetalInteropTexture
{
    const AAPLTextureFormatInfo *_formatInfo;
    CVPixelBufferRef _CVPixelBuffer;
    CVMetalTextureRef _CVMTLTexture;

#if TARGET_MACOS
    CVOpenGLTextureCacheRef _CVGLTextureCache;
    CVOpenGLTextureRef _CVGLTexture;
    CGLPixelFormatObj _CGLPixelFormat;
#else // if!(TARGET_IOS || TARGET_TVOS)
    CVOpenGLESTextureRef _CVGLTexture;
    CVOpenGLESTextureCacheRef _CVGLTextureCache;
#endif // !(TARGET_IOS || TARGET_TVOS)

    // Metal
    CVMetalTextureCacheRef _CVMTLTextureCache;

    CGSize _size;
}

- (nonnull instancetype)initWithMetalDevice:(nonnull id <MTLDevice>) metalevice
                              openGLContext:(nonnull PlatformGLContext *) glContext
                           metalPixelFormat:(MTLPixelFormat)mtlPixelFormat
                                       size:(CGSize)size
{
    self = [super init];
    if(self)
    {
        _formatInfo =
            textureFormatInfoFromMetalPixelFormat(mtlPixelFormat);

        if(!_formatInfo)
        {
            assert(!"Metal Format supplied not supported in this sample");
            return nil;
        }

        _size = size;
        _metalDevice = metalevice;
        _openGLContext = glContext;
#ifdef TARGET_MACOS
        _CGLPixelFormat = _openGLContext.pixelFormat.CGLPixelFormatObj;
#endif

        NSDictionary* cvBufferProperties = @{
            (__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @YES,
            (__bridge NSString*)kCVPixelBufferMetalCompatibilityKey : @YES,
        };
        CVReturn cvret = CVPixelBufferCreate(kCFAllocatorDefault,
                                size.width, size.height,
                                _formatInfo->cvPixelFormat,
                                (__bridge CFDictionaryRef)cvBufferProperties,
                                &_CVPixelBuffer);

        if(cvret != kCVReturnSuccess)
        {
            assert(!"Failed to create CVPixelBufferf");
            return nil;
        }

        [self createGLTexture];
        [self createMetalTexture];
    }
    return self;
}



#if TARGET_MACOS

/**
 On macOS, create an OpenGL texture and retrieve an OpenGL texture name using the following steps, and as annotated in the code listings below:
 */
- (BOOL)createGLTexture
{
    CVReturn cvret;
    // 1. Create an OpenGL CoreVideo texture cache from the pixel buffer.
    cvret  = CVOpenGLTextureCacheCreate(
                    kCFAllocatorDefault,
                    nil,
                    _openGLContext.CGLContextObj,
                    _CGLPixelFormat,
                    nil,
                    &_CVGLTextureCache);
    if(cvret != kCVReturnSuccess)
    {
        assert(!"Failed to create OpenGL Texture Cache");
        return NO;
    }
    // 2. Create a CVPixelBuffer-backed OpenGL texture image from the texture cache.
    cvret = CVOpenGLTextureCacheCreateTextureFromImage(
                    kCFAllocatorDefault,
                    _CVGLTextureCache,
                    _CVPixelBuffer,
                    nil,
                    &_CVGLTexture);
    if(cvret != kCVReturnSuccess)
    {
        assert(!"Failed to create OpenGL Texture From Image");
        return NO;
    }
    // 3. Get an OpenGL texture name from the CVPixelBuffer-backed OpenGL texture image.
    _openGLTexture = CVOpenGLTextureGetName(_CVGLTexture);

    return YES;
}

#else // if!(TARGET_IOS || TARGET_TVOS)

/**
 On iOS, create an OpenGL ES texture from the CoreVideo pixel buffer using the following steps, and as annotated in the code listings below:
 */
- (BOOL) createGLTexture
{
    CVReturn cvret;
    // 1. Create an OpenGL ES CoreVideo texture cache from the pixel buffer.
    cvret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                    nil,
                    _openGLContext,
                    nil,
                    &_CVGLTextureCache);
    if(cvret != kCVReturnSuccess)
    {
        assert(!"Failed to create OpenGL ES Texture Cache");
        return NO;
    }
    // 2. Create a CVPixelBuffer-backed OpenGL ES texture image from the texture cache.
    cvret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                    _CVGLTextureCache,
                    _CVPixelBuffer,
                    nil,
                    GL_TEXTURE_2D,
                    _formatInfo->glInternalFormat,
                    _size.width, _size.height,
                    _formatInfo->glFormat,
                    _formatInfo->glType,
                    0,
                    &_CVGLTexture);
    if(cvret != kCVReturnSuccess)
    {
        assert(!"Failed to create OpenGL ES Texture From Image");
        return NO;
    }
    // 3. Get an OpenGL ES texture name from the CVPixelBuffer-backed OpenGL ES texture image.
    _openGLTexture = CVOpenGLESTextureGetName(_CVGLTexture);

    return YES;
}

#endif // !(TARGET_IOS || TARGET_TVOS)

/**
 Create a Metal texture from the CoreVideo pixel buffer using the following steps, and as annotated in the code listings below:
 */
- (BOOL)createMetalTexture
{
    CVReturn cvret;
    // 1. Create a Metal Core Video texture cache from the pixel buffer.
    cvret = CVMetalTextureCacheCreate(
                    kCFAllocatorDefault,
                    nil,
                    _metalDevice,
                    nil,
                    &_CVMTLTextureCache);
    if(cvret != kCVReturnSuccess)
    {
        return NO;
    }
    // 2. Create a CoreVideo pixel buffer backed Metal texture image from the texture cache.
    cvret = CVMetalTextureCacheCreateTextureFromImage(
                    kCFAllocatorDefault,
                    _CVMTLTextureCache,
                    _CVPixelBuffer, nil,
                    _formatInfo->mtlFormat,
                    _size.width, _size.height,
                    0,
                    &_CVMTLTexture);
    if(cvret != kCVReturnSuccess)
    {
        assert(!"Failed to create Metal texture cache");
        return NO;
    }
    // 3. Get a Metal texture using the CoreVideo Metal texture reference.
    _metalTexture = CVMetalTextureGetTexture(_CVMTLTexture);
    // Get a Metal texture object from the Core Video pixel buffer backed Metal texture image
    if(!_metalTexture)
    {
        assert(!"Failed to get metal texture from CVMetalTextureRef");
        return NO;
    };
    
    return YES;
}

@end
