/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for a very simple container for image data
*/

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>

// Our image
@interface HelloComputeImage : NSObject

/// Initialize this image by loading a *very* simple TGA file.  Will not load compressed, palleted,
//    flipped, or color mapped images.  Only support TGA files with 32-bits per pixels
-(nullable instancetype) initWithTGAFileAtLocation:(nonnull NSURL *)location;

// Width of image in pixels
@property (nonatomic, readonly) NSUInteger      width;

// Height of image in pixels
@property (nonatomic, readonly) NSUInteger      height;

// BGRA 32-bpp data
@property (nonatomic, readonly, nonnull) NSData *data;

@end

#endif
