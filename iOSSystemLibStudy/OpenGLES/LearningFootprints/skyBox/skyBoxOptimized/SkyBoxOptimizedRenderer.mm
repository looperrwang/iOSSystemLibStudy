//
//  SkyBoxOptimizedRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/2.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SkyBoxOptimizedRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#include "TextureHelper.h"
#import "matrixUtil.h"
#import "LearningFootprints.h"
#import "skybox.h"

@interface SkyBoxOptimizedRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;

@property (nonatomic, assign) GLuint cubeVAOId;
@property (nonatomic, assign) GLuint cubeVBOId;

@property (nonatomic, assign) GLuint cubeTextureId;

@property (nonatomic, assign) SkyBox *skybox;

@property (nonatomic, assign) Shader *sceneShader;
@property (nonatomic, assign) Shader *skyBoxShader;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@end

@implementation SkyBoxOptimizedRenderer

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
    
    NSString *cubeTexturePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/container.jpg"];
    _cubeTextureId = TextureHelper::load2DTexture(cubeTexturePath.UTF8String);
    
    std::vector<const char *> skyBoxFilePath;
    NSString *skyBoxPositiveX = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/urbansp/urbansp_rt.png"];
    NSString *skyBoxNegativeX = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/urbansp/urbansp_lf.png"];
    NSString *skyBoxPositiveY = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/urbansp/urbansp_up.png"];
    NSString *skyBoxNegativeY = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/urbansp/urbansp_dn.png"];
    NSString *skyBoxPositiveZ = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/urbansp/urbansp_bk.png"];
    NSString *skyBoxNegativeZ = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/skybox/urbansp/urbansp_ft.png"];
    skyBoxFilePath.push_back(skyBoxPositiveX.UTF8String);
    skyBoxFilePath.push_back(skyBoxNegativeX.UTF8String);
    skyBoxFilePath.push_back(skyBoxPositiveY.UTF8String);
    skyBoxFilePath.push_back(skyBoxNegativeY.UTF8String);
    skyBoxFilePath.push_back(skyBoxPositiveZ.UTF8String);
    skyBoxFilePath.push_back(skyBoxNegativeZ.UTF8String);
    
    _skybox = new SkyBox();
    _skybox->init(skyBoxFilePath);
    
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
    glUniformMatrix4fv(glGetUniformLocation(_skyBoxShader->_programId, "model"), 1, GL_FALSE, model);
    static GLfloat r = 3.0f;
    static float viewRad = 0.0f;
    eyePos[0] = r * sinf(viewRad);
    eyePos[1] = 0.0f;
    eyePos[2] = r * cosf(viewRad);
    r += 0.01f;
    if (r > 10.0f) {
        r = 3.0f;
    }
    viewRad += 0.01f;
    target[0] = 0.0f;
    target[1] = 0.0f;
    target[2] = 0.0f;
    viewUp[0] = 0.0f;
    viewUp[1] = 1.0f;
    viewUp[2] = 0.0f;
    mtxLoadLookAt(view, eyePos, target, viewUp);
    
    GLfloat viewWithoutTranslation[16];
    viewWithoutTranslation[0] = view[0];
    viewWithoutTranslation[1] = view[1];
    viewWithoutTranslation[2] = view[2];
    viewWithoutTranslation[3] = 0;
    viewWithoutTranslation[4] = view[4];
    viewWithoutTranslation[5] = view[5];
    viewWithoutTranslation[6] = view[6];
    viewWithoutTranslation[7] = 0;
    viewWithoutTranslation[8] = view[8];
    viewWithoutTranslation[9] = view[9];
    viewWithoutTranslation[10] = view[10];
    viewWithoutTranslation[11] = 0;
    viewWithoutTranslation[12] = 0;
    viewWithoutTranslation[13] = 0;
    viewWithoutTranslation[14] = 0;
    viewWithoutTranslation[15] = 1;
    glUniformMatrix4fv(glGetUniformLocation(_skyBoxShader->_programId, "view"), 1, GL_FALSE, viewWithoutTranslation);
    glUniformMatrix4fv(glGetUniformLocation(_skyBoxShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _skybox->getTextId());
    glUniform1i(glGetUniformLocation(_skyBoxShader->_programId, "text"), 0);
    
    _skybox->draw(*_skyBoxShader);
    
    
    
    
    
    
    
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
    
    if (_skybox) {
        delete _skybox;
        _skybox = NULL;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_cubeTextureId) {
        glDeleteTextures(1, &_cubeTextureId);
        _cubeTextureId = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_cubeVBOId) {
        glDeleteBuffers(1, &_cubeVBOId);
        _cubeVBOId = 0;
    }
    
    glBindVertexArray(0);
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
