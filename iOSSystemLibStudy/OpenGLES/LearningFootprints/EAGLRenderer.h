//
//  EAGLRenderer.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/14.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EAGLContext;

NS_ASSUME_NONNULL_BEGIN

@interface EAGLRenderer : NSObject

@property (nonatomic, strong) EAGLContext *context;

- (void)initGLResource;

- (void)render;
- (BOOL)resizeFromLayer:(id)layer;
- (void)onApplicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
