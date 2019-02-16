//
//  texture.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/15.
//  Copyright © 2019 looperwang. All rights reserved.
//

#ifndef texture_h
#define texture_h

#import "imageUtil.h"

class TextureHelper
{
public:
    static GLuint load2DTexture(const char *filePath, GLint internalFormat = GL_RGB, GLenum picFormat = GL_RGB)
    {
        //创建纹理
        GLuint textureId;
        glGenTextures(1, &textureId);
        //绑定纹理
        glActiveTexture(GL_TEXTURE0); //0号纹理默认激活，这行代码不是必须的
        glBindTexture(GL_TEXTURE_2D, textureId);
        //设置WRAP参数
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        //设置filter参数
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        
        demoImage *image = imgLoadImage(filePath, false);
        
        glTexImage2D(GL_TEXTURE_2D, 0, image->format, image->width, image->height, 0, image->format, image->type, image->data);
        
        glGenerateMipmap(GL_TEXTURE_2D); //加载原始纹理对象必须在该行代码之前
        imgDestroyImage(image);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        return textureId;
    }
};

#endif /* texture_h */
