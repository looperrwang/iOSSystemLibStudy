//
//  EAGLRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/14.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "EAGLRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES3/gl.h>

@implementation EAGLRenderer

- (instancetype)init
{
    if (self = [super init]) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!_context || ![EAGLContext setCurrentContext:_context]) {
            return nil;
        }
        
        [self initGLResource];
    }
    
    return self;
}

- (void)initGLResource
{
    [EAGLContext setCurrentContext:_context];
}

- (void)render
{
    [EAGLContext setCurrentContext:_context];
}

- (BOOL)resizeFromLayer:(id)layer
{
    [EAGLContext setCurrentContext:_context];
    
    return YES;
}

- (void)onApplicationDidEnterBackground
{
    [EAGLContext setCurrentContext:_context];
    
    glFlush();
    glFinish();
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    _context = nil;
}

@end
