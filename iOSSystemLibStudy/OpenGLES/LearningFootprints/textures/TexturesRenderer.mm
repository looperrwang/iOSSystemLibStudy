//
//  TexturesRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "TexturesRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#import "TextureHelper.h"

@interface TexturesRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;

@property (nonatomic, assign) GLuint VAOId;
@property (nonatomic, assign) GLuint VBOId;
@property (nonatomic, assign) GLuint EBOId;

@property (nonatomic, assign) Shader *shader;

@property (nonatomic, assign) GLuint textureId1;
@property (nonatomic, assign) GLuint textureId2;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@end

@implementation TexturesRenderer

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
    
    //构造顶点数据
    //position+color+textCoord
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f,     1.0f, 0.0f, 0.0f,      0.0f, 0.0f, //0
        0.5f, -0.5f, 0.0f,      0.0f, 1.0f, 0.0f,      1.0f, 0.0f,  //1
        0.5f, 0.5f, 0.0f,       0.0f, 0.0f, 1.0f,      1.0f, 1.0f,  //2
        -0.5f, 0.5f, 0.0f,      1.0f, 1.0f, 0.0f,      0.0f, 1.0f  //3
    };
    GLushort indices[] = {
        0, 1, 2, //上三角
        0, 2, 3  //下三角
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
    
    _VAOId = VAOId;
    _VBOId = VBOId;
    _EBOId = EBOId;
    
    NSString *vertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/textures/shaders/textures.vert"];
    NSString *fragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/textures/shaders/textures.frag"];
    _shader = new Shader(vertexPath.UTF8String, fragPath.UTF8String);
    
    NSString *texture1FilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/wood.png"];
    NSString *texture2FilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/cat.png"];
    _textureId1 = TextureHelper::load2DTexture(texture1FilePath.UTF8String);
    _textureId2 = TextureHelper::load2DTexture(texture2FilePath.UTF8String);
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindVertexArray(_VAOId);
    //注意这里要重新绑定下
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBOId);
    _shader->use();
    
    //为uniform设置值
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureId1);
    glUniform1i(glGetUniformLocation(_shader->_programId, "tex1"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _textureId2);
    glUniform1i(glGetUniformLocation(_shader->_programId, "tex2"), 1);
    
    glUniform1f(glGetUniformLocation(_shader->_programId, "mixValue"), 0.5f);
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glUseProgram(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
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
    if (_textureId2) {
        glDeleteTextures(1, &_textureId2);
        _textureId2 = 0;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_textureId1) {
        glDeleteTextures(1, &_textureId1);
        _textureId1 = 0;
    }
    
    if (_shader) {
        delete _shader;
        _shader = NULL;
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    if (_EBOId) {
        glDeleteBuffers(1, &_EBOId);
        _EBOId = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_VBOId) {
        glDeleteBuffers(1, &_VBOId);
        _VBOId = 0;
    }
    
    glBindVertexArray(0);
    if (_VAOId) {
        glDeleteVertexArrays(1, &_VAOId);
        _VAOId = 0;
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
