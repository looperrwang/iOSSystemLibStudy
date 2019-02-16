//
//  TranslateRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "TranslateRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#import "texture.h"
#import "matrixUtil.h"

@interface TranslateRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;

@property (nonatomic, assign) GLuint modelVAOId;
@property (nonatomic, assign) GLuint modelVBOId;
@property (nonatomic, assign) GLuint modelEBOId;

@property (nonatomic, assign) GLuint axisTriangleVAOId;
@property (nonatomic, assign) GLuint axisLineVAOId;
@property (nonatomic, assign) GLuint axisTriangleVBOId;
@property (nonatomic, assign) GLuint axisLineVBOId;

@property (nonatomic, assign) Shader *modelShader;
@property (nonatomic, assign) Shader *axisShader;

@property (nonatomic, assign) GLuint textureId;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@end

@implementation TranslateRenderer

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
    
    //构造顶点数据 - 模型
    GLfloat vertices[] = {
        0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, //0
        0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,  //1
        0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,  //2
        0.0f, 0.5f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f  //3
    };
    GLushort indices[] = {
        0, 1, 2, //上三角
        0, 2, 3  //下三角
    };
    
    //构造顶点数据 - 坐标轴
    GLfloat axisTriangleData[] = {
        0.945f,    0.03125f,  0.0f,   1.0f, 0.0f, 0.0f, //x轴三角
        1.0f,      0.0f,      0.0f,   1.0f, 0.0f, 0.0f,
        0.945f,    -0.03125f, 0.0f,   1.0f, 0.0f, 0.0f,
        
        -0.03125f, 0.945f,    0.0f,   0.0f, 1.0f, 0.0f, //y轴三角
        0.0f,      1.0f,      0.0f,   0.0f, 1.0f, 0.0f,
        0.03125f,  0.945f,    0.0f,   0.0f, 1.0f, 0.0f,
        
        -0.03125f, 0.0f,      0.945f, 0.0f, 0.0f, 1.0f, //z轴三角
        0.0f,      0.0f,      1.0f,   0.0f, 0.0f, 1.0f,
        0.03125f,  0.0f,      0.945f, 0.0f, 0.0f, 1.0f
    };
    
    //构造顶点数据 - 坐标线
    GLfloat axisLineData[] = {
        -1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, //x轴
        1.0f, 0.0f, 0.0f,  1.0f, 0.0f, 0.0f,
        
        0.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f, //y轴
        0.0f, 1.0f, 0.0f,  0.0f, 1.0f, 0.0f,
        
        0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, //z轴
        0.0f, 0.0f, 1.0f,  0.0f, 0.0f, 1.0f
    };
    
    //生成VAO/VBO/EBO对象
    GLuint VAOId, VBOId, EBOId;
    //创建VAO对象
    glGenVertexArrays(1, &VAOId);
    glBindVertexArray(VAOId);
    //创建VBO对象
    glGenBuffers(1, &VBOId);
    glBindBuffer(GL_ARRAY_BUFFER, VBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //创建EBO对象
    glGenBuffers(1, &EBOId);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBOId);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GL_FLOAT), (GLvoid *)(6 * sizeof(GLfloat)));
    glEnableVertexAttribArray(2); //一开始少了这行代码导致渲染结果非预期
    //解绑VAO/VBO
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _modelVAOId = VAOId;
    _modelVBOId = VBOId;
    _modelEBOId = EBOId;
    
    //坐标轴
    GLuint axisVAOIds[2], axisVBOIds[2];
    glGenVertexArrays(2, axisVAOIds);
    glGenBuffers(2, axisVBOIds);
    //坐标轴三角
    glBindVertexArray(axisVAOIds[0]);
    glBindBuffer(GL_ARRAY_BUFFER, axisVBOIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(axisTriangleData), axisTriangleData, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (GLvoid *)(3 * sizeof(GL_FLOAT)));
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    //坐标轴线
    glBindVertexArray(axisVAOIds[1]);
    glBindBuffer(GL_ARRAY_BUFFER, axisVBOIds[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(axisLineData), axisLineData, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GL_FLOAT), (GLvoid *)(3 * sizeof(GL_FLOAT)));
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _axisTriangleVAOId = axisVAOIds[0];
    _axisTriangleVBOId = axisVBOIds[0];
    _axisLineVAOId = axisVAOIds[1];
    _axisLineVBOId = axisVBOIds[1];
    
    NSString *modelVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/modelTransformation/shaders/rectangle.vert"];
    NSString *modelFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/modelTransformation/shaders/rectangle.frag"];
    _modelShader = new Shader(modelVertexPath.UTF8String, modelFragPath.UTF8String);
    
    NSString *axisVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/modelTransformation/shaders/axis.vert"];
    NSString *axisFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/modelTransformation/shaders/axis.frag"];
    _axisShader = new Shader(axisVertexPath.UTF8String, axisFragPath.UTF8String);
    
    NSString *textureFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/cat.png"];
    _textureId = TextureHelper::load2DTexture(textureFilePath.UTF8String);
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindVertexArray(_modelVAOId);
    //注意这里要重新绑定下
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _modelEBOId);
    _modelShader->use();
    
    GLfloat model[16];
    GLfloat view[16];
    GLfloat projection[16];
    
    mtxLoadIdentity(model);
    mtxLoadIdentity(view);
    mtxLoadIdentity(projection);
    
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "view"), 1, GL_FALSE, view);
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureId);
    glUniform1i(glGetUniformLocation(_modelShader->_programId, "tex"), 0);
    
    //绘制第一个矩形
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "model"), 1, GL_FALSE, model);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
    
    //绘制第二个矩形
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, -0.5f, 0.0f, 0.0f);
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "model"), 1, GL_FALSE, model);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
    
    //绘制第三个矩形
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, -0.8f, -0.8f, 0.0f);
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "model"), 1, GL_FALSE, model);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
    
    //绘制第四个矩形
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, 0.0f, -0.5f, 0.0f);
    glUniformMatrix4fv(glGetUniformLocation(_modelShader->_programId, "model"), 1, GL_FALSE, model);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
    
    //绘制坐标轴三角
    glBindVertexArray(_axisTriangleVAOId);
    _axisShader->use();
    glDrawArrays(GL_TRIANGLES, 0, 9);
    
    //绘制坐标轴线
    glBindVertexArray(_axisLineVAOId);
    glDrawArrays(GL_LINES, 0, 6);
    
    //重置绑定
    glBindVertexArray(0);
    glUseProgram(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
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
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_textureId) {
        glDeleteTextures(1, &_textureId);
        _textureId = 0;
    }
    
    if (_axisShader) {
        delete _axisShader;
        _axisShader = NULL;
    }
    
    if (_modelShader) {
        delete _modelShader;
        _modelShader = NULL;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_axisLineVBOId) {
        glDeleteBuffers(1, &_axisLineVBOId);
        _axisLineVBOId = 0;
    }
    
    if (_axisTriangleVBOId) {
        glDeleteBuffers(1, &_axisTriangleVBOId);
        _axisTriangleVBOId = 0;
    }
    
    glBindVertexArray(0);
    if (_axisLineVAOId) {
        glDeleteVertexArrays(1, &_axisLineVAOId);
        _axisLineVAOId = 0;
    }
    
    if (_axisTriangleVAOId) {
        glDeleteVertexArrays(1, &_axisTriangleVAOId);
        _axisTriangleVAOId = 0;
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    if (_modelEBOId) {
        glDeleteBuffers(1, &_modelEBOId);
        _modelEBOId = 0;
    }
    
    if (_modelVBOId) {
        glDeleteBuffers(1, &_modelVBOId);
        _modelVBOId = 0;
    }
    
    if (_modelVAOId) {
        glDeleteVertexArrays(1, &_modelVAOId);
        _modelVAOId = 0;
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
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
