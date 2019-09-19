//
//  EAGLView.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/12.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "EAGLView.h"
#import "EAGLRenderer.h"

@interface EAGLView ()

@property (nonatomic, strong) EAGLRenderer *renderer;

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) NSInteger animationFrameInterval;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation EAGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame renderer:(nonnull EAGLRenderer *)renderer
{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.contentsScale = [UIScreen mainScreen].scale;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        _renderer = renderer;
        if (!_renderer) {
            return nil;
        }
        
        _isAnimating = NO;
        _animationFrameInterval = 1;
        _displayLink = nil;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [_renderer resizeFromLayer:(CAEAGLLayer *)self.layer];
    [self drawView:nil];
}

- (void)drawView:(id)sender
{
    [_renderer render];
}

- (void)setAnimationFrameInterval:(NSInteger)animationFrameInterval
{
    if (animationFrameInterval != _animationFrameInterval && animationFrameInterval >= 1) {
        _animationFrameInterval = animationFrameInterval;
        
        if (_isAnimating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!_isAnimating) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [_displayLink setFrameInterval:_animationFrameInterval];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        _isAnimating = YES;
    }
}

- (void)stopAnimation
{
    if (_isAnimating) {
        [_displayLink invalidate];
        _displayLink = nil;
        
        _isAnimating = NO;
    }
}

- (void)onApplicationDidEnterBackground
{
    [_renderer onApplicationDidEnterBackground];
}

@end
