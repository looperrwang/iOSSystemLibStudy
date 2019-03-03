//
//  ViewTransformationRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/16.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "ViewTransformationRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#include "TextureHelper.h"
#import "matrixUtil.h"

//Zfighting问题 - 远裁剪平面附近的两个点，Ze相近的话，由于精度不够，导致计算出来的Ne相同，以致于OpenGL无法判断这两个点哪个在前哪个在后，从而导致渲染出现问题
//解决方案 - 尽量减小[-n, -f]的范围

@interface ViewTransformationRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;

@property (nonatomic, assign) GLuint VAOId;
@property (nonatomic, assign) GLuint VBOId;

@property (nonatomic, assign) Shader *shader;

@property (nonatomic, assign) GLuint textureId;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@property (nonatomic, assign) GLfloat rad; //旋转弧度

@end

@implementation ViewTransformationRenderer

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
    //position数据为什么是这样，因为不考虑model/view/projection的话，这里的position直接就是NDC坐标
    //position+color+textCoord
    GLfloat vertices[] = {
        //前面
        -0.5f, -0.5f, 0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        0.5f, -0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    1.0f, 0.0f,
        0.5f, 0.5f, 0.5f,     0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        0.5f, 0.5f, 0.5f,     0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        -0.5f, 0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    0.0f, 1.0f,
        -0.5f, -0.5f, 0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        //后面
        0.5f, -0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, 0.0f,    1.0f, 0.0f,
        -0.5f, 0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        -0.5f, 0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        0.5f, 0.5f, -0.5f,    0.0f, 0.0f, 0.0f,    0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        //左面
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        -0.5f, -0.5f, 0.5f,   0.0f, 0.0f, 0.0f,    1.0f, 0.0f,
        -0.5f, 0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        -0.5f, 0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        -0.5f, 0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        //右面
        0.5f, -0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    1.0f, 0.0f,
        0.5f, 0.5f, -0.5f,    0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        0.5f, 0.5f, -0.5f,    0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        0.5f, 0.5f, 0.5f,     0.0f, 0.0f, 0.0f,    0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        //上面
        -0.5f, 0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -0.5f,    0.0f, 0.0f, 0.0f,    1.0f, 0.0f,
        0.5f, 0.5f, 0.5f,     0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        0.5f, 0.5f, 0.5f,     0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        -0.5f, 0.5f, 0.5f,    0.0f, 0.0f, 0.0f,    0.0f, 1.0f,
        -0.5f, 0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        //下面
        0.5f, -0.5f, 0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f,
        -0.5f, -0.5f, 0.5f,  0.0f, 0.0f, 0.0f,    1.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,   0.0f, 0.0f, 0.0f,    1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,    0.0f, 0.0f, 0.0f,    0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,   0.0f, 0.0f, 0.0f,    0.0f, 0.0f
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
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid *)(6 * sizeof(GLfloat)));
    glEnableVertexAttribArray(2);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _VAOId = VAOId;
    _VBOId = VBOId;
    
    NSString *vertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/viewTransformation/shaders/cube.vert"];
    NSString *fragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/viewTransformation/shaders/cube.frag"];
    _shader = new Shader(vertexPath.UTF8String, fragPath.UTF8String);
    
    NSString *textureFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/cat.png"];
    _textureId = TextureHelper::load2DTexture(textureFilePath.UTF8String);
    
    //单纯地开启GL_DEPTH_TEST并没有起效果的原因是 - 没有分配深度缓冲区
    glEnable(GL_DEPTH_TEST);
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArray(_VAOId);
    _shader->use();
    
    GLfloat model[16];
    GLfloat view[16];
    GLfloat projection[16];
    
    mtxLoadIdentity(model);
    mtxLoadIdentity(view);
    mtxLoadIdentity(projection);
    
    //设置view矩阵
    /* xoz平面圆周运动
    GLfloat radius = 6.0f;
    GLfloat eyePos[3];
    eyePos[0] = radius * sinf(_rad);
    eyePos[1] = 0.0f;
    eyePos[2] = radius * cosf(_rad);*/
    
    /*球面运动*/
    GLfloat radius = 6.0f;
    GLfloat eyePos[3];
    eyePos[0] = radius * sin(_rad) * cos(_rad / 2);
    eyePos[1] = radius * sin(_rad) * sin(_rad / 2);
    eyePos[2] = radius * cos(_rad);
    
    GLfloat target[3] = {0.0f, 0.0f, 0.0f};
    GLfloat viewUp[3] = {0.0f, 1.0f, 0.0f};
    mtxLoadLookAt(view, eyePos, target, viewUp);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "view"), 1, GL_FALSE, view);
    
    //设置projection矩阵
    //注意理解projection中fov的含义 - aspect + nearZ 一定的情况下，fov 越大，近投影面越大，看到的世界坐标系中的模型就越多，同一个模型绘制到屏幕上就越小
    mtxLoadPerspective(projection, 60.0f, (float)_backingWidth / (float)_backingHeight, 1.0f, 100.0f);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "projection"), 1, GL_FALSE, projection);
    
    //设置纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureId);
    glUniform1i(glGetUniformLocation(_shader->_programId, "tex"), 0);
    
    GLfloat cubePositions[] = {
        0.0f, 0.0f, 1.2f,
        0.0f, 0.0f, 0.0f,
        1.2f, 1.2f, 0.0f,
        -1.2f, 1.2f, 0.0f,
        -1.2f, -1.5f, 0.0f,
        1.2f, -1.5f, 0.0f,
        0.0f, 0.0f, -1.2f
    };
    
    for (int i = 0; i < sizeof(cubePositions) / (sizeof(GLfloat) * 3); i++) {
        //设置model矩阵
        mtxLoadIdentity(model);
        mtxTranslateMatrix(model, cubePositions[i * 3], cubePositions[i * 3 + 1], cubePositions[i * 3 + 2]);
        glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "model"), 1, GL_FALSE, model);
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glUseProgram(0);
    glBindVertexArray(0);
    
    _rad += (1 * M_PI / 180);
    
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
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_textureId) {
        glDeleteTextures(1, &_textureId);
        _textureId = 0;
    }
    
    if (_shader) {
        delete _shader;
        _shader = NULL;
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
