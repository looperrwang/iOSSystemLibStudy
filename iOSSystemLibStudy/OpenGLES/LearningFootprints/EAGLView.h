//
//  EAGLView.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/12.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EAGLRenderer;

@interface EAGLView : UIView

- (instancetype)initWithFrame:(CGRect)frame renderer:(EAGLRenderer *)renderer;

- (void)startAnimation;
- (void)stopAnimation;

- (void)onApplicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
