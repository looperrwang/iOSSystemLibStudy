//
//  PostProcessRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/27.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "PostProcessRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#include "TextureHelper.h"
#import "matrixUtil.h"
#import "LearningFootprints.h"

@interface PostProcessRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;

@property (nonatomic, assign) GLuint cubeVAOId;
@property (nonatomic, assign) GLuint cubeVBOId;

@property (nonatomic, assign) GLuint planeVAOId;
@property (nonatomic, assign) GLuint planeVBOId;

@property (nonatomic, assign) GLuint quadVAOId;
@property (nonatomic, assign) GLuint quadVBOId;

@property (nonatomic, assign) GLuint cubeTextureId;
@property (nonatomic, assign) GLuint planeTextureId;

@property (nonatomic, assign) Shader *sceneShader;

@property (nonatomic, assign) Shader *quad_blurKernelShader;
@property (nonatomic, assign) Shader *quad_edgeDetectionKernelShader;
@property (nonatomic, assign) Shader *quad_embossKernelShader;
@property (nonatomic, assign) Shader *quad_grayscaleShader;
@property (nonatomic, assign) Shader *quad_inversionShader;
@property (nonatomic, assign) Shader *quad_sharpenKernelShader;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

//离屏渲染用
@property (nonatomic, assign) GLuint fboId;
@property (nonatomic, assign) GLuint colorTextureId;
@property (nonatomic, assign) GLuint depthStencilId;

@end

@implementation PostProcessRenderer

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
    [self initPlane];
    [self initQuad];
    
    NSString *cubeTexturePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/container.jpg"];
    _cubeTextureId = TextureHelper::load2DTexture(cubeTexturePath.UTF8String);
    NSString *planeTexturePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/metal.png"];
    _planeTextureId = TextureHelper::load2DTexture(planeTexturePath.UTF8String);
    
    NSString *sceneVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/scene.vert"];
    NSString *sceneFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/scene.frag"];
    _sceneShader = new Shader(sceneVertexPath.UTF8String, sceneFragPath.UTF8String);
    
    
    NSString *quadVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad.vert"];
    NSString *quad_blurKernelFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad_blurKernel.frag"];
    NSString *quad_edgeDetectionKernelFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad_edgeDetectionKernel.frag"];
    NSString *quad_embossKernelFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad_embossKernel.frag"];
    NSString *quad_grayscaleFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad_grayscale.frag"];
    NSString *quad_inversionFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad_inversion.frag"];
    NSString *quad_sharpenKernelFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/frameBufferObject/postProcess/shaders/quad_sharpenKernel.frag"];
    
    _quad_blurKernelShader = new Shader(quadVertexPath.UTF8String, quad_blurKernelFragPath.UTF8String);
    _quad_edgeDetectionKernelShader = new Shader(quadVertexPath.UTF8String, quad_edgeDetectionKernelFragPath.UTF8String);
    _quad_embossKernelShader = new Shader(quadVertexPath.UTF8String, quad_embossKernelFragPath.UTF8String);
    _quad_grayscaleShader = new Shader(quadVertexPath.UTF8String, quad_grayscaleFragPath.UTF8String);
    _quad_inversionShader = new Shader(quadVertexPath.UTF8String, quad_inversionFragPath.UTF8String);
    _quad_sharpenKernelShader = new Shader(quadVertexPath.UTF8String, quad_sharpenKernelFragPath.UTF8String);
    
    [self prepareFBO];
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

- (void)initPlane
{
    //构造顶点数据
    GLfloat planeVertices[] = {
        5.0f, -0.5f, 5.0f, 2.0f, 0.0f,   // A
        5.0f, -0.5f, -5.0f, 2.0f, 2.0f,  // D
        -5.0f, -0.5f, -5.0f, 0.0f, 2.0f, // C
        
        -5.0f, -0.5f, -5.0f, 0.0f, 2.0f, // C
        -5.0f, -0.5f, 5.0f, 0.0f, 0.0f,  // B
        5.0f, -0.5f, 5.0f, 2.0f, 0.0f,   // A
    };
    
    //生成VAO/VBO对象
    GLuint planeVAOId, planeVBOId;
    //创建VAO对象
    glGenVertexArrays(1, &planeVAOId);
    glBindVertexArray(planeVAOId);
    //创建VBO对象
    glGenBuffers(1, &planeVBOId);
    glBindBuffer(GL_ARRAY_BUFFER, planeVBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(planeVertices), planeVertices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _planeVAOId = planeVAOId;
    _planeVBOId = planeVBOId;
}

- (void)initQuad
{
    //构造顶点数据
    GLfloat quadVertices[] = {
        -1.0f, 1.0f, 0.0f, 1.0f,
        -1.0f, -1.0f, 0.0f, 0.0f,
        1.0f, -1.0f, 1.0f, 0.0f,
        
        -1.0f, 1.0f, 0.0f, 1.0f,
        1.0f, -1.0f, 1.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 1.0f
    };
    
    //生成VAO/VBO对象
    GLuint quadVAOId, quadVBOId;
    //创建VAO对象
    glGenVertexArrays(1, &quadVAOId);
    glBindVertexArray(quadVAOId);
    //创建VBO对象
    glGenBuffers(1, &quadVBOId);
    glBindBuffer(GL_ARRAY_BUFFER, quadVBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)(2 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _quadVAOId = quadVAOId;
    _quadVBOId = quadVBOId;
}

- (BOOL)prepareFBO
{
    glGenFramebuffers(1, &_fboId);
    glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
    
    glGenRenderbuffers(1, &_depthStencilId);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthStencilId);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthStencilId);
    
    return YES;
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    GLfloat model[16];
    GLfloat view[16];
    GLfloat projection[16];
    
    mtxLoadIdentity(model);
    mtxLoadIdentity(view);
    mtxLoadIdentity(projection);
    
    GLfloat eyePos[3] = {0.0f, 0.0f, 6.0f};
    GLfloat target[3] = {0.0f, 0.0f, 0.0f};
    GLfloat viewUp[3] = {0.0f, 1.0f, 0.0f};
    mtxLoadLookAt(view, eyePos, target, viewUp);
    mtxLoadPerspective(projection, 60.0f, (float)_backingWidth / (float)_backingHeight, 1.0f, 100.0f);
    
    //先绘制到离屏的纹理中
    _sceneShader->use();
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "view"), 1, GL_FALSE, view);
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _cubeTextureId);
    glBindVertexArray(_cubeVAOId);
    
    mtxTranslateMatrix(model, -1.0f, 0.0f, -1.0f);
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "model"), 1, GL_FALSE, model);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, 2.0f, 0.0f, 0.0f);
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "model"), 1, GL_FALSE, model);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    mtxLoadIdentity(model);
    glUniformMatrix4fv(glGetUniformLocation(_sceneShader->_programId, "model"), 1, GL_FALSE, model);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _planeTextureId);
    glBindVertexArray(_planeVAOId);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    //使用上面生成的纹理绘制到屏幕上
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    
    glDisable(GL_DEPTH_TEST);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    //通过这种方式可以查看上面生成纹理的内容
    glBindTexture(GL_TEXTURE_2D, _colorTextureId);
    glBindVertexArray(_quadVAOId);
    
    
    
    
    _quad_blurKernelShader->use();
    glViewport(0, 2 * _backingHeight / 3, _backingWidth / 2, _backingHeight / 3);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    _quad_edgeDetectionKernelShader->use();
    glViewport(_backingWidth / 2, 2 * _backingHeight / 3, _backingWidth / 2, _backingHeight / 3);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    _quad_embossKernelShader->use();
    glViewport(0, _backingHeight / 3, _backingWidth / 2, _backingHeight / 3);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    _quad_grayscaleShader->use();
    glViewport(_backingWidth / 2, _backingHeight / 3, _backingWidth / 2, _backingHeight / 3);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    _quad_inversionShader->use();
    glViewport(0, 0, _backingWidth / 2, _backingHeight / 3);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    _quad_sharpenKernelShader->use();
    glViewport(_backingWidth / 2, 0, _backingWidth / 2, _backingHeight / 3);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    
    
    
    
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
    
    glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
    
    if (_colorTextureId) {
        glDeleteTextures(1, &_colorTextureId);
        _colorTextureId = 0;
    }
    
    _colorTextureId = TextureHelper::makeAttachmentTexture(_backingWidth, _backingHeight);
    glBindTexture(GL_TEXTURE_2D, _colorTextureId);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorTextureId, 0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _depthStencilId);
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
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    if (_depthStencilId) {
        glDeleteRenderbuffers(1, &_depthStencilId);
        _depthStencilId = 0;
    }
    
    if (_colorTextureId) {
        glDeleteTextures(1, &_colorTextureId);
        _colorTextureId = 0;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    if (_fboId) {
        glDeleteFramebuffers(1, &_fboId);
        _fboId = 0;
    }
    
    if (_quad_sharpenKernelShader) {
        delete _quad_sharpenKernelShader;
        _quad_sharpenKernelShader = NULL;
    }
    
    if (_quad_inversionShader) {
        delete _quad_inversionShader;
        _quad_inversionShader = NULL;
    }
    
    if (_quad_grayscaleShader) {
        delete _quad_grayscaleShader;
        _quad_grayscaleShader = NULL;
    }
    
    if (_quad_embossKernelShader) {
        delete _quad_embossKernelShader;
        _quad_embossKernelShader = NULL;
    }
    
    if (_quad_edgeDetectionKernelShader) {
        delete _quad_edgeDetectionKernelShader;
        _quad_edgeDetectionKernelShader = NULL;
    }
    
    if (_quad_blurKernelShader) {
        delete _quad_blurKernelShader;
        _quad_blurKernelShader = NULL;
    }
    
    if (_sceneShader) {
        delete _sceneShader;
        _sceneShader = NULL;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_planeTextureId) {
        glDeleteTextures(1, &_planeTextureId);
        _planeTextureId = 0;
    }
    if (_cubeTextureId) {
        glDeleteTextures(1, &_cubeTextureId);
        _cubeTextureId = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_quadVBOId) {
        glDeleteBuffers(1, &_quadVBOId);
        _quadVBOId = 0;
    }
    
    glBindVertexArray(0);
    if (_quadVAOId) {
        glDeleteVertexArrays(1, &_quadVAOId);
        _quadVAOId = 0;
    }
    
    if (_planeVAOId) {
        glDeleteBuffers(1, &_planeVAOId);
        _planeVAOId = 0;
    }
    if (_planeVBOId) {
        glDeleteVertexArrays(1, &_planeVBOId);
        _planeVBOId = 0;
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
