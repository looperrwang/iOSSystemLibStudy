/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for our our cross-platform view controller
*/

#if TARGET_OS_IPHONE

#if defined(TARGET_IOS) || defined(TARGET_TVOS)
@import UIKit;
#define PlatformViewController UIViewController
#else
@import AppKit;
#define PlatformViewController NSViewController
#endif

@import MetalKit;

#import "ArgumentBufferArraysWithHeapsRenderer.h"

// Our view controller
@interface ArgumentBufferArraysWithHeapsViewController : PlatformViewController

@end

#endif
