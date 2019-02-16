//
//  Shader.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/14.
//  Copyright © 2019 looperwang. All rights reserved.
//

#ifndef Shader_h
#define Shader_h

#include <fstream>

struct ShaderFile
{
    ShaderFile(GLenum type, const char *path) : shaderType(type), filePath(path) {}
    
    GLenum shaderType;
    const char *filePath;
};

class Shader
{
public:
    Shader(const char *vertexPath, const char *fragPath) : _programId(0)
    {
        std::vector<ShaderFile> fileVec;
        fileVec.push_back(ShaderFile(GL_VERTEX_SHADER, vertexPath));
        fileVec.push_back(ShaderFile(GL_FRAGMENT_SHADER, fragPath));
        
        loadFromFile(fileVec);
    }
    
    Shader(const char *vertexPath, const char *fragPath, const char *geometryPath) : _programId(0)
    {
        std::vector<ShaderFile> fileVec;
        fileVec.push_back(ShaderFile(GL_VERTEX_SHADER, vertexPath));
        fileVec.push_back(ShaderFile(GL_FRAGMENT_SHADER, fragPath));
        //fileVec.push_back(ShaderFile(GL_GEOMETRY_SHADER, geometryPath));
        
        loadFromFile(fileVec);
    }
    
    void use()
    {
        glUseProgram(_programId);
    }
    
    ~Shader()
    {
        if (_programId) {
            glDeleteProgram(_programId);
        }
    }
    
    GLuint _programId;
    
private:
    
    void loadFromFile(std::vector<ShaderFile> &shaderFileVec)
    {
        //加载着色器文件内容
        std::vector<std::string> sourceVec;
        size_t shaderCount = shaderFileVec.size();
        for (size_t i = 0; i < shaderCount; i++) {
            std::string shaderSource;
            if (!loadShaderSource(shaderFileVec[i].filePath, shaderSource)) {
                std::cout << "Error::Shader could not load file:" << shaderFileVec[i].filePath << std::endl;
                return;
            }
            sourceVec.push_back(shaderSource);
        }
        
        //构造着色器对象，并编译着色器
        std::vector<GLuint> shaderObjectIdVec;
        
        bool bSuccess = true;
        for (size_t i = 0; i < shaderCount; i++) {
            GLuint shaderId = glCreateShader(shaderFileVec[i].shaderType);
             const char *c_str = sourceVec[i].c_str();
            glShaderSource(shaderId, 1, &c_str, NULL);
            glCompileShader(shaderId);
            
            GLint compileStatus = 0;
            glGetShaderiv(shaderId, GL_COMPILE_STATUS, &compileStatus);
            if (compileStatus == GL_FALSE) {
                GLint maxLength = 0;
                glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &maxLength);
                
                std::vector<GLchar> errLog(maxLength);
                glGetShaderInfoLog(shaderId, maxLength, &maxLength, &errLog[0]);
                
                std::cout << "Error::Shader file [" << shaderFileVec[i].filePath << "] compiled failed," << &errLog[0] << std::endl;
                bSuccess = false;
            }
            
            shaderObjectIdVec.push_back(shaderId);
        }
        
        if (bSuccess) {
            _programId = glCreateProgram();
            for (size_t i = 0; i < shaderCount; i++) {
                glAttachShader(_programId, shaderObjectIdVec[i]);
            }
            
            glLinkProgram(_programId);
            
            GLint linkStatus = 0;
            glGetProgramiv(_programId, GL_LINK_STATUS, &linkStatus);
            if (linkStatus == GL_FALSE) {
                GLint maxLength = 0;
                glGetProgramiv(_programId, GL_INFO_LOG_LENGTH, &maxLength);
                std::vector<GLchar> errLog(maxLength);
                glGetProgramInfoLog(_programId, maxLength, &maxLength, &errLog[0]);
                std::cout << "Error::shader link failed," << &errLog[0] << std::endl;
            }
        }
        
        for (size_t i = 0; i < shaderCount; i++) {
            if (_programId) {
                glDetachShader(_programId, shaderObjectIdVec[i]);
            }
            
            glDeleteShader(shaderObjectIdVec[i]);
        }
    }
    
    //将filePath路径文件的内容读取至source中
    bool loadShaderSource(const char *filePath, std::string &source)
    {
        source.clear();
        
        std::ifstream in_stream(filePath);
        if (!in_stream)
            return false;
        
        source.assign(std::istreambuf_iterator<char>(in_stream), std::istreambuf_iterator<char>());
            
        return true;
    }
};

#endif /* Shader_h */
