//
//  simpleObjLoader.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/22.
//  Copyright © 2019 looperwang. All rights reserved.
//

#ifndef simpleObjLoader_h
#define simpleObjLoader_h

struct Vertex
{
    float position[3];
    float texCoords[2];
    float normal[3];
};

struct VertexCombineIndex
{
    GLuint posIndex;
    GLuint textCoordIndex;
    GLuint normIndex;
};

class SimpleMesh
{
public:
    void draw(Shader& shader)
    {
        shader.use();
        glBindVertexArray(this->VAOId);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, this->textureId);
        glUniform1i(glGetUniformLocation(shader._programId, "tex"), 0);
        
        glDrawArrays(GL_TRIANGLES, 0, (GLsizei)this->vertData.size());
        
        glBindVertexArray(0);
        glUseProgram(0);
    }
    SimpleMesh(){}
    SimpleMesh(const std::vector<Vertex>& vertData, GLint textureId, bool bShowData = false)
    {
        this->vertData = vertData;
        this->textureId = textureId;
        this->setupMesh();
        if (bShowData)
        {
            const char * fileName = "vert-data.txt";
            std::ofstream file(fileName);
            for (std::vector<Vertex>::const_iterator it = this->vertData.begin(); it != this->vertData.end(); ++it)
            {
                //file << glm::to_string(it->position) << ","
                //<< glm::to_string(it->texCoords) << ","
                //<< glm::to_string(it->normal) << std::endl;
            }
            file.close();
            std::cout << " vert data saved in file:" << fileName << std::endl;
        }
    }
    ~SimpleMesh()
    {
        glDeleteVertexArrays(1, &this->VAOId);
        glDeleteBuffers(1, &this->VBOId);
    }
public:
    std::vector<Vertex> vertData;
    GLuint VAOId, VBOId;
    GLint textureId;
    
    void setupMesh()
    {
        glGenVertexArrays(1, &this->VAOId);
        glGenBuffers(1, &this->VBOId);
        
        glBindVertexArray(this->VAOId);
        glBindBuffer(GL_ARRAY_BUFFER, this->VBOId);
        glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex)* this->vertData.size(),
                     &this->vertData[0], GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE,
                              sizeof(Vertex), (GLvoid*)0);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE,
                              sizeof(Vertex), (GLvoid*)(3 * sizeof(GL_FLOAT)));
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE,
                              sizeof(Vertex), (GLvoid*)(5 * sizeof(GL_FLOAT)));
        glEnableVertexAttribArray(2);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
};

class ObjLoader
{
public:
    static bool loadFromFile(const char* path,
                             std::vector<Vertex>& vertData)
    {
        
        std::vector<VertexCombineIndex> vertComIndices;
        std::vector<float> temp_vertices;
        std::vector<float> temp_textCoords;
        std::vector<float> temp_normals;
        
        std::ifstream file(path);
        if (!file)
        {
            std::cerr << "Error::ObjLoader, could not open obj file:"
            << path << " for reading." << std::endl;
            return false;
        }
        std::string line;
        while (getline(file, line))
        {
            if (line.substr(0, 2) == "vt")
            {
                std::istringstream s(line.substr(2));
                float temp;
                s >> temp;
                temp_textCoords.push_back(temp);
                s >> temp;
                temp_textCoords.push_back(-temp);
            }
            else if (line.substr(0, 2) == "vn")
            {
                std::istringstream s(line.substr(2));
                float temp;
                s >> temp;
                temp_normals.push_back(temp);
                s >> temp;
                temp_normals.push_back(temp);
                s >> temp;
                temp_normals.push_back(temp);
            }
            else if (line.substr(0, 1) == "v")
            {
                std::istringstream s(line.substr(2));
                float temp;
                s >> temp;
                temp_vertices.push_back(temp);
                s >> temp;
                temp_vertices.push_back(temp);
                s >> temp;
                temp_vertices.push_back(temp);
            }
            else if (line.substr(0, 1) == "f")
            {
                std::istringstream vtns(line.substr(2));
                std::string vtn;
                while (vtns >> vtn)
                {
                    VertexCombineIndex vertComIndex;
                    std::replace(vtn.begin(), vtn.end(), '/', ' ');
                    std::istringstream ivtn(vtn);
                    if (vtn.find("  ") != std::string::npos)
                    {
                        std::cerr << "Error:ObjLoader, no texture data found within file:"
                        << path << std::endl;
                        return false;
                    }
                    ivtn >> vertComIndex.posIndex
                    >> vertComIndex.textCoordIndex
                    >> vertComIndex.normIndex;
                    
                    vertComIndex.posIndex--;
                    vertComIndex.textCoordIndex--;
                    vertComIndex.normIndex--;
                    vertComIndices.push_back(vertComIndex);
                }
            }
            else if (line[0] == '#')
            { }
            else
            {
                //
            }
        }
        for (std::vector<GLuint>::size_type i = 0; i < vertComIndices.size(); ++i)
        {
            Vertex vert;
            VertexCombineIndex comIndex = vertComIndices[i];
            
            vert.position[0] = temp_vertices[comIndex.posIndex * 3];
            vert.position[1] = temp_vertices[comIndex.posIndex * 3 + 1];
            vert.position[2] = temp_vertices[comIndex.posIndex * 3 + 2];
            
            vert.texCoords[0] = temp_textCoords[comIndex.textCoordIndex * 2];
            vert.texCoords[1] = temp_textCoords[comIndex.textCoordIndex * 2 + 1];
            
            vert.normal[0] = temp_normals[comIndex.normIndex * 3];
            vert.normal[1] = temp_normals[comIndex.normIndex * 3 + 1];
            vert.normal[2] = temp_normals[comIndex.normIndex * 3 + 2];
            
            vertData.push_back(vert);
        }
        
        return true;
    }
};

#endif /* simpleObjLoader_h */
