//
//  LightingInWorldSpaceRenderer.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/17.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "EAGLRenderer.h"
#import <OpenGLES/gltypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface LightingInWorldSpaceRenderer : EAGLRenderer

@property (nonatomic, assign) GLfloat ambientStrength;
@property (nonatomic, assign) GLfloat diffuseStrength;
@property (nonatomic, assign) GLfloat specularStrength;
@property (nonatomic, assign) GLfloat coefficient;

@end

NS_ASSUME_NONNULL_END
