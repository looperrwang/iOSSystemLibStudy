//
//  SpotLightRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/19.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "SpotLightRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#include "TextureHelper.h"
#import "matrixUtil.h"

@interface SpotLightRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;

@property (nonatomic, assign) GLuint modelVAOId;
@property (nonatomic, assign) GLuint modelVBOId;

@property (nonatomic, assign) GLuint lampVAOId;

@property (nonatomic, assign) Shader *modelShader;
@property (nonatomic, assign) Shader *lampShader;

@property (nonatomic, assign) GLuint diffuseMap;
@property (nonatomic, assign) GLuint specularMap;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@end

@implementation SpotLightRenderer

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
    
    //深度缓冲区
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    //构造顶点数据
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 0.0f,1.0f,    // A
        0.5f, -0.5f, 0.5f, 1.0f, 0.0f,  0.0f, 0.0f, 1.0f,    // B
        0.5f, 0.5f, 0.5f,  1.0f, 1.0f,   0.0f, 0.0f, 1.0f,    // C
        0.5f, 0.5f, 0.5f,  1.0f, 1.0f,   0.0f, 0.0f, 1.0f,    // C
        -0.5f, 0.5f, 0.5f,  0.0f, 1.0f,  0.0f, 0.0f, 1.0f,    // D
        -0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f,    // A
        
        
        -0.5f, -0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 0.0f, -1.0f,    // E
        -0.5f, 0.5f, -0.5f,  0.0, 1.0f,  0.0f, 0.0f, -1.0f, // H
        0.5f, 0.5f, -0.5f,   1.0f, 1.0f, 0.0f, 0.0f, -1.0f,    // G
        0.5f, 0.5f, -0.5f,   1.0f, 1.0f, 0.0f, 0.0f, -1.0f,    // G
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f, 0.0f, 0.0f, -1.0f,    // F
        -0.5f, -0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 0.0f, -1.0f,    // E
        
        -0.5f, 0.5f, 0.5f, 0.0f, 1.0f,   -1.0f, 0.0f, 0.0f,    // D
        -0.5f, 0.5f, -0.5f, 1.0, 1.0f,   -1.0f, 0.0f, 0.0f, // H
        -0.5f, -0.5f, -0.5f, 1.0f, 0.0f, -1.0f, 0.0f, 0.0f,    // E
        -0.5f, -0.5f, -0.5f,1.0f, 0.0f, -1.0f, 0.0f, 0.0f,    // E
        -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,  -1.0f, 0.0f, 0.0f,    // A
        -0.5f, 0.5f, 0.5f, 0.0f, 1.0f,   -1.0f, 0.0f, 0.0f,    // D
        
        0.5f, -0.5f, -0.5f,1.0f, 0.0f, 1.0f, 0.0f, 0.0f,  // F
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,  1.0f, 0.0f, 0.0f, // G
        0.5f, 0.5f, 0.5f,0.0f, 1.0f,   1.0f, 0.0f, 0.0f, // C
        0.5f, 0.5f, 0.5f,0.0f, 1.0f,   1.0f, 0.0f, 0.0f, // C
        0.5f, -0.5f, 0.5f,0.0f, 0.0f,  1.0f, 0.0f, 0.0f, // B
        0.5f, -0.5f, -0.5f,1.0f, 0.0f, 1.0f, 0.0f, 0.0f, // F
        
        0.5f, 0.5f, -0.5f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f,    // G
        -0.5f, 0.5f, -0.5f, 0.0, 1.0f, 0.0f, 1.0f, 0.0f,    // H
        -0.5f, 0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f,    // D
        -0.5f, 0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f,    // D
        0.5f, 0.5f, 0.5f,  1.0f, 0.0f,  0.0f, 1.0f, 0.0f,    // C
        0.5f, 0.5f, -0.5f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f,    // G
        
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,  0.0f, -1.0f, 0.0f,  // A
        -0.5f, -0.5f, -0.5f,0.0f, 1.0f, 0.0f, -1.0f, 0.0f,  // E
        0.5f, -0.5f, -0.5f, 1.0f, 1.0f,  0.0f, -1.0f, 0.0f, // F
        0.5f, -0.5f, -0.5f, 1.0f, 1.0f,  0.0f, -1.0f, 0.0f, // F
        0.5f, -0.5f, 0.5f, 1.0f, 0.0f,   0.0f, -1.0f, 0.0f, // B
        -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,  0.0f, -1.0f, 0.0f, // A
    };
    
    //生成VAO/VBO对象
    GLuint VAOId, VBOId;
    //创建VAO对象
    glGenVertexArrays(1, &VAOId);
    glBindVertexArray(VAOId);
    //创建VBO对象
    glGenBuffers(1, &VBOId);
    glBindBuffer(GL_ARRAY_BUFFER, VBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)(5 * sizeof(GLfloat)));
    glEnableVertexAttribArray(2);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _modelVAOId = VAOId;
    _modelVBOId = VBOId;
    
    //代表灯的模型
    GLuint lampVAOId;
    glGenVertexArrays(1, &lampVAOId);
    glBindVertexArray(lampVAOId);
    glBindBuffer(GL_ARRAY_BUFFER, _modelVBOId);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _lampVAOId = lampVAOId;
    
    NSString *modelVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/lighting/spotLight/shaders/cube.vert"];
    NSString *modelFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/lighting/spotLight/shaders/cube.frag"];
    _modelShader = new Shader(modelVertexPath.UTF8String, modelFragPath.UTF8String);
    
    NSString *lampVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/lighting/spotLight/shaders/lamp.vert"];
    NSString *lampFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/lighting/spotLight/shaders/lamp.frag"];
    _lampShader = new Shader(lampVertexPath.UTF8String, lampFragPath.UTF8String);
    
    NSString *diffuseMapFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/container_diffuse.png"];
    NSString *specularMapFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/container_specular.png"];
    glActiveTexture(GL_TEXTURE0);
    _diffuseMap = TextureHelper::load2DTexture(diffuseMapFilePath.UTF8String);
    glActiveTexture(GL_TEXTURE1);
    _specularMap = TextureHelper::load2DTexture(specularMapFilePath.UTF8String);
    
    //单纯地开启GL_DEPTH_TEST并没有起效果的原因是 - 没有分配深度缓冲区
    glEnable(GL_DEPTH_TEST);
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    //glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArray(_modelVAOId);
    _modelShader->use();
    
    GLfloat model[16];
    GLfloat view[16];
    GLfloat projection[16];
    
    mtxLoadIdentity(model);
    mtxLoadIdentity(view);
    mtxLoadIdentity(projection);
    
    //设置view
    GLfloat eyePos[3] = {0.0f, 0.0f, 4.0f};
    GLfloat target[3] = {0.0f, 0.0f, 0.0f};
    GLfloat viewUp[3] = {0.0f, 1.0f, 0.0f};
    mtxLoadLookAt(view, eyePos, target, viewUp);
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "view"), 1, GL_FALSE, view);
    //设置projection
    //注意理解projection中fov的含义 - aspect + nearZ 一定的情况下，fov 越大，近投影面越大，看到的世界坐标系中的模型就越多，同一个模型绘制到屏幕上就越小
    mtxLoadPerspective(projection, 60.0f, (float)_backingWidth / (float)_backingHeight, 1.0f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    //设置material.diffuseMap
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _diffuseMap);
    glUniform1i(glGetUniformLocation(_modelShader->_programId, "material.diffuseMap"), 0);
    //设置material.specularMap
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _specularMap);
    glUniform1i(glGetUniformLocation(_modelShader->_programId, "material.specularMap"), 1);
    //设置material.shininess
    glUniform1f(glGetUniformLocation(_modelShader->_programId, "material.shininess"), 32.0f);
    
    //设置viewPos
    glUniform3f(glGetUniformLocation(_modelShader->_programId, "viewPos"), eyePos[0], eyePos[1], eyePos[2]);
    
    //设置light.ambient
    glUniform3f(glGetUniformLocation(_modelShader->_programId, "light.ambient"), 0.2f, 0.2f, 0.2f);
    //设置light.diffuse
    glUniform3f(glGetUniformLocation(_modelShader->_programId, "light.diffuse"), 0.5f, 0.5f, 0.5f);
    //glUniform3f(glGetUniformLocation(_modelShader->_programId, "light.diffuse"), 1.0f, 1.0f, 1.0f);
    //设置light.specular
    glUniform3f(glGetUniformLocation(_modelShader->_programId, "light.specular"), 1.0f, 1.0f, 1.0f);
    //设置light.position
    glUniform3f(glGetUniformLocation(_modelShader->_programId, "light.position"), eyePos[0], eyePos[1], eyePos[2]);
    //设置light.direction
    glUniform3f(glGetUniformLocation(_modelShader->_programId, "light.direction"), target[0] - eyePos[0], target[1] - eyePos[1], target[2] - eyePos[2]);
    //设置light.cutoff
    glUniform1f(glGetUniformLocation(_modelShader->_programId, "light.cutoff"), cosf(12.5f * M_PI / 180.0f));
    //衰减
    glUniform1f(glGetUniformLocation(_modelShader->_programId, "light.constant"), 1.0f);
    glUniform1f(glGetUniformLocation(_modelShader->_programId, "light.linear"), 0.09f);
    glUniform1f(glGetUniformLocation(_modelShader->_programId, "light.quadratic"), 0.032f);
    
    GLfloat cubePositions[] = {
        0.0f, 0.0f, 0.0f,
        2.0f, 5.0f, -15.0f,
        -1.5f, -2.2f, -2.5f,
        -3.8f, -2.0f, -12.3f,
        2.4f, -0.4f, -3.5f,
        -1.7f, 3.0f, -7.5f,
        1.3f, -2.0f, -2.5f,
        1.5f, 2.0f, -2.5f,
        1.5f, 0.2f, -1.5f,
        -1.3f, 1.0f, -1.5f
    };
    
    for (int i = 0; i < sizeof(cubePositions) / (sizeof(GLfloat) * 3); i++) {
        //设置model
        mtxLoadIdentity(model);
        mtxTranslateMatrix(model, cubePositions[i * 3], cubePositions[i * 3 + 1], cubePositions[i * 3 + 2]);
        GLfloat angle = 20.0f * i;
        mtxRotateMatrix(model, angle, 1.0f, 0.3f, 0.5f);
        glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "model"), 1, GL_FALSE, model);
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
//    glBindVertexArray(_lampVAOId);
//    _lampShader->use();
//    //设置model
//    mtxLoadIdentity(model);
//    mtxScaleMatrix(model, 0.2f, 0.2f, 0.2f);
//    mtxTranslateMatrix(model, lampPos[0], lampPos[1], lampPos[2]);
//    glUniformMatrix4fv(glGetUniformLocation(_lampShader->_programId, "model"), 1, GL_FALSE, model);
//    //设置view
//    glUniformMatrix4fv(glGetUniformLocation(_lampShader->_programId, "view"), 1, GL_FALSE, view);
//    //设置projection
//    glUniformMatrix4fv(glGetUniformLocation(_lampShader->_programId, "projection"), 1, GL_FALSE, projection);
//
//    //绘制lamp
//    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glUseProgram(0);
    glBindVertexArray(0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //将渲染结果呈现出来
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(id)layer
{
    [super resizeFromLayer:layer];
    
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
    
    return YES;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];
    
    glFlush();
    glFinish();
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_specularMap) {
        glDeleteTextures(1, &_specularMap);
        _specularMap = 0;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_diffuseMap) {
        glDeleteTextures(1, &_diffuseMap);
        _diffuseMap = 0;
    }
    
    if (_lampShader) {
        delete _lampShader;
        _lampShader = NULL;
    }
    
    if (_modelShader) {
        delete _modelShader;
        _modelShader = NULL;
    }
    
    glBindVertexArray(0);
    if (_lampVAOId) {
        glDeleteBuffers(1, &_lampVAOId);
        _lampVAOId = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_modelVBOId) {
        glDeleteVertexArrays(1, &_modelVBOId);
        _modelVBOId = 0;
    }
    
    if (_modelVAOId) {
        glDeleteBuffers(1, &_modelVAOId);
        _modelVAOId = 0;
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
