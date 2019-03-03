//
//  SkyBoxUsingScaleRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/2.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SkyBoxUsingScaleRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#include "TextureHelper.h"
#import "matrixUtil.h"
#import "LearningFootprints.h"

@interface SkyBoxUsingScaleRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;

@property (nonatomic, assign) GLuint cubeVAOId;
@property (nonatomic, assign) GLuint cubeVBOId;

@property (nonatomic, assign) GLuint skyBoxVAOId;
@property (nonatomic, assign) GLuint skyBoxVBOId;

@property (nonatomic, assign) GLuint cubeTextureId;
@property (nonatomic, assign) GLuint skyBoxTextureId;

@property (nonatomic, assign) Shader *sceneShader;
@property (nonatomic, assign) Shader *skyBoxShader;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@end

@implementation SkyBoxUsingScaleRenderer

- (void)initGLResource
{
    [super initGLResource];
    
    //构造帧缓冲区
    glGenFramebuffers(1, &_defaultFramebuffer);
    //构造渲染缓冲区
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //将_colorRenderbuffer渲染缓冲区关联到_defaultFramebuffer帧缓冲区的GL_COLOR_ATTACHMENT0上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    //深度缓冲区+模板缓冲区
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    [self initCube];
    [self initSkyBox];
    
    NSString *cubeTexturePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/container.jpg"];
    _cubeTextureId = TextureHelper::load2DTexture(cubeTexturePath.UTF8String);
    
    std::vector<const char *> skyBoxFilePath;
    NSString *skyBoxPositiveX = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/sky/sky_rt.jpg"];
    NSString *skyBoxNegativeX = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/sky/sky_lf.jpg"];
    NSString *skyBoxPositiveY = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/sky/sky_up.jpg"];
    NSString *skyBoxNegativeY = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/sky/sky_dn.jpg"];
    NSString *skyBoxPositiveZ = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/sky/sky_bk.jpg"];
    NSString *skyBoxNegativeZ = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/sky/sky_ft.jpg"];
    skyBoxFilePath.push_back(skyBoxPositiveX.UTF8String);
    skyBoxFilePath.push_back(skyBoxNegativeX.UTF8String);
    skyBoxFilePath.push_back(skyBoxPositiveY.UTF8String);
    skyBoxFilePath.push_back(skyBoxNegativeY.UTF8String);
    skyBoxFilePath.push_back(skyBoxPositiveZ.UTF8String);
    skyBoxFilePath.push_back(skyBoxNegativeZ.UTF8String);
    _skyBoxTextureId = TextureHelper::loadCubeMapTexture(skyBoxFilePath);
    
    NSString *sceneVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/skyBox/skyBoxOptimized/shaders/scene.vert"];
    NSString *sceneFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/skyBox/skyBoxOptimized/shaders/scene.frag"];
    _sceneShader = new Shader(sceneVertexPath.UTF8String, sceneFragPath.UTF8String);
    
    NSString *skyBoxVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/skyBox/skyBoxOptimized/shaders/skybox.vert"];
    NSString *skyBoxFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/skyBox/skyBoxOptimized/shaders/skybox.frag"];
    _skyBoxShader = new Shader(skyBoxVertexPath.UTF8String, skyBoxFragPath.UTF8String);
    
    glEnable(GL_DEPTH_TEST);
}

- (void)initCube
{
    //构造顶点数据
    GLfloat cubeVertices[] = {
        -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,    // A
        0.5f, -0.5f, 0.5f, 1.0f, 0.0f,    // B
        0.5f, 0.5f, 0.5f,1.0f, 1.0f,    // C
        0.5f, 0.5f, 0.5f,1.0f, 1.0f,    // C
        -0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // D
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
        
        
        -0.5f, -0.5f, -0.5f,0.0f, 0.0f,    // E
        -0.5f, 0.5f, -0.5f,0.0, 1.0f,   // H
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // F
        -0.5f, -0.5f, -0.5f,0.0f, 0.0f,    // E
        
        -0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // D
        -0.5f, 0.5f, -0.5f,1.0, 1.0f,   // H
        -0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // E
        -0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // E
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
        -0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // D
        
        0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // F
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // C
        0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // C
        0.5f, -0.5f, 0.5f, 0.0f, 0.0f,    // B
        0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // F
        
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        -0.5f, 0.5f, -0.5f,0.0, 1.0f,   // H
        -0.5f, 0.5f, 0.5f,0.0f, 0.0f,    // D
        -0.5f, 0.5f, 0.5f,0.0f, 0.0f,    // D
        0.5f, 0.5f, 0.5f,1.0f, 0.0f,    // C
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
        -0.5f, -0.5f, -0.5f, 0.0f, 1.0f,// E
        0.5f, -0.5f, -0.5f,1.0f, 1.0f,    // F
        0.5f, -0.5f, -0.5f,1.0f, 1.0f,    // F
        0.5f, -0.5f, 0.5f,1.0f, 0.0f,    // B
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
    };
    
    //生成VAO/VBO对象
    GLuint cubeVAOId, cubeVBOId;
    //创建VAO对象
    glGenVertexArrays(1, &cubeVAOId);
    glBindVertexArray(cubeVAOId);
    //创建VBO对象
    glGenBuffers(1, &cubeVBOId);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _cubeVAOId = cubeVAOId;
    _cubeVBOId = cubeVBOId;
}

- (void)initSkyBox
{
    //构造顶点数据
    GLfloat skyBoxVertices[] = {
        -1.0f,  1.0f, -1.0f,
        -1.0f, -1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        
        -1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,
        
        1.0f, -1.0f, -1.0f,
        1.0f, -1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        
        -1.0f, -1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,
        
        -1.0f,  1.0f, -1.0f,
        1.0f,  1.0f, -1.0f,
        1.0f,  1.0f,  1.0f,
        1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f, -1.0f,
        
        -1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
        1.0f, -1.0f, -1.0f,
        1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
        1.0f, -1.0f,  1.0f
    };
    
    //生成VAO/VBO对象
    GLuint skyBoxVAOId, skyBoxVBOId;
    //创建VAO对象
    glGenVertexArrays(1, &skyBoxVAOId);
    glBindVertexArray(skyBoxVAOId);
    //创建VBO对象
    glGenBuffers(1, &skyBoxVBOId);
    glBindBuffer(GL_ARRAY_BUFFER, skyBoxVBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(skyBoxVertices), skyBoxVertices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _skyBoxVAOId = skyBoxVAOId;
    _skyBoxVBOId = skyBoxVBOId;
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    //1、绑定shader
    _sceneShader->use();
    
    //2、设置上下文状态
    glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //3、设置shader参数
    GLfloat model[16];
    GLfloat view[16];
    GLfloat projection[16];
    
    mtxLoadIdentity(model);
    mtxLoadIdentity(view);
    mtxLoadIdentity(projection);
    GLfloat eyePos[3] = {0.0f, 0.0f, 3.0f};
    GLfloat target[3] = {0.0f, 0.0f, 0.0f};
    GLfloat viewUp[3] = {0.0f, 1.0f, 0.0f};
    mtxLoadLookAt(view, eyePos, target, viewUp);
    mtxLoadPerspective(projection, 60.0f, (float)_backingWidth / (float)_backingHeight, 0.1f, 100.0f);
    
    static float rad = 0.0f;
    mtxRotateYMatrix(model, rad);
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "model"), 1, GL_FALSE, model);
    rad += 0.01f;
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "view"), 1, GL_FALSE, view);
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _cubeTextureId);
    glUniform1i(glGetUniformLocation(_sceneShader->_programId, "text"), 0);
    
    //4、绘制
    glBindVertexArray(_cubeVAOId);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    
    
    
    
    _skyBoxShader->use();
    
    mtxLoadIdentity(model);
    mtxScaleMatrix(model, 100.0f, 100.0f, 100.0f);
    mtxTranslateMatrix(model, eyePos[0], eyePos[1], eyePos[2]);
    glUniformMatrix4fv(glGetUniformLocation(_skyBoxShader->_programId, "model"), 1, GL_FALSE, model);
    glUniformMatrix4fv(glGetUniformLocation(_skyBoxShader->_programId, "view"), 1, GL_FALSE, view);
    glUniformMatrix4fv(glGetUniformLocation(_skyBoxShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _skyBoxTextureId);
    glUniform1i(glGetUniformLocation(_skyBoxShader->_programId, "skybox"), 0);
    
    glDepthFunc(GL_LEQUAL);
    glBindVertexArray(_skyBoxVAOId);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    
    
    
    glDepthFunc(GL_LESS);
    
    
    
    
    
    
    
    
    glUseProgram(0);
    glBindVertexArray(0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //将渲染结果呈现出来
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(id)layer
{
    [super resizeFromLayer:layer];
    
    glBindFramebuffer(1, _defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //设置layer为_colorRenderbuffer对应的缓冲区，渲染命令将会改变layer的图层存储
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    //深度缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, _backingWidth, _backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    return YES;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];
    
    glFlush();
    glFinish();
    
    if (_skyBoxShader) {
        delete _skyBoxShader;
        _skyBoxShader = NULL;
    }
    
    if (_sceneShader) {
        delete _sceneShader;
        _sceneShader = NULL;
    }
    
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    if (_skyBoxTextureId) {
        glDeleteTextures(1, &_skyBoxTextureId);
        _skyBoxTextureId = 0;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_cubeTextureId) {
        glDeleteTextures(1, &_cubeTextureId);
        _cubeTextureId = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_skyBoxVBOId) {
        glDeleteBuffers(1, &_skyBoxVBOId);
        _skyBoxVBOId = 0;
    }
    
    glBindVertexArray(0);
    if (_skyBoxVAOId) {
        glDeleteVertexArrays(1, &_skyBoxVAOId);
        _skyBoxVAOId = 0;
    }
    
    if (_cubeVBOId) {
        glDeleteBuffers(1, &_cubeVBOId);
        _cubeVBOId = 0;
    }
    if (_cubeVAOId) {
        glDeleteVertexArrays(1, &_cubeVAOId);
        _cubeVAOId = 0;
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_depthBuffer);
        _depthBuffer = 0;
    }
    
    if (_colorRenderbuffer) {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    if (_defaultFramebuffer) {
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        _defaultFramebuffer = 0;
    }
}

@end
