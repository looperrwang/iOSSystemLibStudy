//
//  skybox.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/3/2.
//  Copyright © 2019 looperwang. All rights reserved.
//

#ifndef skybox_h
#define skybox_h

#include <vector>
#include "TextureHelper.h"

class SkyBox
{
public:
    SkyBox() : skyBoxTextId(0){}
    bool init(std::vector<const char*> picFilePathVec)
    {
        this->setupData();
        this->skyBoxTextId = TextureHelper::loadCubeMapTexture(picFilePathVec);
        return this->skyBoxTextId != 0;
    }
    void draw(Shader& skyBoxShader) const
    {
        GLint OldDepthFuncMode;
        glGetIntegerv(GL_DEPTH_FUNC, &OldDepthFuncMode);
        
        glDepthFunc(GL_LEQUAL);
        skyBoxShader.use();
        glBindVertexArray(this->skyBoxVAOId);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        glBindVertexArray(0);
        glDepthFunc(OldDepthFuncMode);
    }
    ~SkyBox()
    {
        glDeleteVertexArrays(1, &this->skyBoxVAOId);
        glDeleteBuffers(1, &this->skyBoxVBOId);
        glDeleteTextures(1, &skyBoxTextId);
    }
    GLuint getTextId() const
    {
        return this->skyBoxTextId;
    }
private:
    GLuint skyBoxTextId;
    GLuint skyBoxVAOId, skyBoxVBOId;
private:
    void setupData()
    {
        GLfloat skyboxVertices[] = {
            -1.0f, 1.0f, -1.0f,        // A
            -1.0f, -1.0f, -1.0f,    // B
            1.0f, -1.0f, -1.0f,        // C
            1.0f, -1.0f, -1.0f,        // C
            1.0f, 1.0f, -1.0f,        // D
            -1.0f, 1.0f, -1.0f,        // A
            
            -1.0f, -1.0f, 1.0f,        // E
            -1.0f, -1.0f, -1.0f,    // B
            -1.0f, 1.0f, -1.0f,        // A
            -1.0f, 1.0f, -1.0f,        // A
            -1.0f, 1.0f, 1.0f,        // F
            -1.0f, -1.0f, 1.0f,        // E
            
            1.0f, -1.0f, -1.0f,        // C
            1.0f, -1.0f, 1.0f,        // G
            1.0f, 1.0f, 1.0f,        // H
            1.0f, 1.0f, 1.0f,        // H
            1.0f, 1.0f, -1.0f,        // D
            1.0f, -1.0f, -1.0f,        // C
            
            -1.0f, -1.0f, 1.0f,  // E
            -1.0f, 1.0f, 1.0f,  // F
            1.0f, 1.0f, 1.0f,  // H
            1.0f, 1.0f, 1.0f,  // H
            1.0f, -1.0f, 1.0f,  // G
            -1.0f, -1.0f, 1.0f,  // E
            
            -1.0f, 1.0f, -1.0f,  // A
            1.0f, 1.0f, -1.0f,  // D
            1.0f, 1.0f, 1.0f,  // H
            1.0f, 1.0f, 1.0f,  // H
            -1.0f, 1.0f, 1.0f,  // F
            -1.0f, 1.0f, -1.0f,  // A
            
            -1.0f, -1.0f, -1.0f,  // B
            -1.0f, -1.0f, 1.0f,   // E
            1.0f, -1.0f, 1.0f,    // G
            1.0f, -1.0f, 1.0f,    // G
            1.0f, -1.0f, -1.0f,   // C
            -1.0f, -1.0f, -1.0f,  // B
        };
        glGenVertexArrays(1, &this->skyBoxVAOId);
        glGenBuffers(1, &this->skyBoxVBOId);
        glBindVertexArray(this->skyBoxVAOId);
        glBindBuffer(GL_ARRAY_BUFFER, this->skyBoxVBOId);
        glBufferData(GL_ARRAY_BUFFER, sizeof(skyboxVertices), skyboxVertices, GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE,
                              3 * sizeof(GL_FLOAT), (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glBindVertexArray(0);
    }
};

#endif /* skybox_h */
