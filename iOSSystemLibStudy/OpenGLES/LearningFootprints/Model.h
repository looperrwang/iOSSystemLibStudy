#ifndef _MODEL_H_
#define _MODEL_H_

#include <map>
#include "Importer.hpp"
#include "scene.h"
#include "postprocess.h"
#include "Mesh.h"
#include "TextureHelper.h"

class Model
{
public:
	void draw(Shader& shader) const
	{
		for (std::vector<Mesh *>::const_iterator it = this->meshes.begin(); this->meshes.end() != it; ++it)
		{
			//it->draw(shader);
            (*it)->draw(shader);
		}
	}
	bool loadModel(const std::string& filePath)
	{
		Assimp::Importer importer;
		if (filePath.empty())
		{
			std::cerr << "Error:Model::loadModel, empty model file path." << std::endl;
			return false;
		}
		const aiScene* sceneObjPtr = importer.ReadFile(filePath, 
			aiProcess_Triangulate | aiProcess_FlipUVs);
		if (!sceneObjPtr
			|| sceneObjPtr->mFlags == AI_SCENE_FLAGS_INCOMPLETE
			|| !sceneObjPtr->mRootNode)
		{
			std::cerr << "Error:Model::loadModel, description: " 
				<< importer.GetErrorString() << std::endl;
			return false;
		}
		this->modelFileDir = filePath.substr(0, filePath.find_last_of('/'));
		if (!this->processNode(sceneObjPtr->mRootNode, sceneObjPtr))
		{
			std::cerr << "Error:Model::loadModel, process node failed."<< std::endl;
			return false;
		}
		return true;
	}
	~Model()
	{
        for (std::vector<Mesh *>::const_iterator it = this->meshes.begin(); this->meshes.end() != it; ++it)
        {
            (*it)->final();
            delete *it;
        }
        this->meshes.clear();
	}
private:
	
	bool processNode(const aiNode* node, const aiScene* sceneObjPtr)
	{
		if (!node || !sceneObjPtr)
		{
			return false;
		}
		
		for (size_t i = 0; i < node->mNumMeshes; ++i)
		{
			
			const aiMesh* meshPtr = sceneObjPtr->mMeshes[node->mMeshes[i]]; 
			if (meshPtr)
			{
				Mesh *meshObj = new Mesh();
				if (this->processMesh(meshPtr, sceneObjPtr, *meshObj))
				{
					this->meshes.push_back(meshObj);
				}
			}
		}
		
		for (size_t i = 0; i < node->mNumChildren; ++i)
		{
			this->processNode(node->mChildren[i], sceneObjPtr);
		}
		return true;
	}
	bool processMesh(const aiMesh* meshPtr, const aiScene* sceneObjPtr, Mesh& meshObj)
	{
		if (!meshPtr || !sceneObjPtr)
		{
			return false;
		}
		std::vector<Vertex> vertData;
		std::vector<Texture> textures;
		std::vector<GLuint> indices;
		
		for (size_t i = 0; i < meshPtr->mNumVertices; ++i)
		{
			Vertex vertex;
            vertex.position[0] = 0.0f;
            vertex.position[1] = 0.0f;
            vertex.position[2] = 0.0f;
            vertex.texCoords[0] = 0.0f;
            vertex.texCoords[1] = 0.0f;
            vertex.normal[0] = 0.0f;
            vertex.normal[1] = 0.0f;
            vertex.normal[2] = 0.0f;
			
			if (meshPtr->HasPositions())
			{
				vertex.position[0] = meshPtr->mVertices[i].x;
				vertex.position[1] = meshPtr->mVertices[i].y;
				vertex.position[2] = meshPtr->mVertices[i].z;
			}
			
			if (meshPtr->HasTextureCoords(0))
			{
                vertex.texCoords[0] = meshPtr->mTextureCoords[0][i].x;
                vertex.texCoords[1] = meshPtr->mTextureCoords[0][i].y;
			}
			else
			{
                vertex.texCoords[0] = 0.0f;
                vertex.texCoords[1] = 0.0f;
			}
			
			if (meshPtr->HasNormals())
			{
				vertex.normal[0] = meshPtr->mNormals[i].x;
				vertex.normal[1] = meshPtr->mNormals[i].y;
				vertex.normal[2] = meshPtr->mNormals[i].z;
			}
			vertData.push_back(vertex);
		}
		
		for (size_t i = 0; i < meshPtr->mNumFaces; ++i)
		{
			aiFace face = meshPtr->mFaces[i];
			if (face.mNumIndices != 3)
			{
				std::cerr << "Error:Model::processMesh, mesh not transformed to triangle mesh." << std::endl;
				return false;
			}
			for (size_t j = 0; j < face.mNumIndices; ++j)
			{
				indices.push_back(face.mIndices[j]);
			}
		}
		
		if (meshPtr->mMaterialIndex >= 0)
		{
			const aiMaterial* materialPtr = sceneObjPtr->mMaterials[meshPtr->mMaterialIndex];
			
			std::vector<Texture> diffuseTexture;
			this->processMaterial(materialPtr, sceneObjPtr, aiTextureType_DIFFUSE, diffuseTexture);
			textures.insert(textures.end(), diffuseTexture.begin(), diffuseTexture.end());
			
			std::vector<Texture> specularTexture;
			this->processMaterial(materialPtr, sceneObjPtr, aiTextureType_SPECULAR, specularTexture);
			textures.insert(textures.end(), specularTexture.begin(), specularTexture.end());
		}
		meshObj.setData(vertData, textures, indices);
		return true;
	}
	
	bool processMaterial(const aiMaterial* matPtr, const aiScene* sceneObjPtr, 
		const aiTextureType textureType, std::vector<Texture>& textures)
	{
		textures.clear();

		if (!matPtr 
			|| !sceneObjPtr )
		{
			return false;
		}
		if (matPtr->GetTextureCount(textureType) <= 0)
		{
			return true;
		}
		for (size_t i = 0; i < matPtr->GetTextureCount(textureType); ++i)
		{
			Texture text;
			aiString textPath;
			aiReturn retStatus = matPtr->GetTexture(textureType, (unsigned int)i, &textPath);
			if (retStatus != aiReturn_SUCCESS 
				|| textPath.length == 0)
			{
				std::cerr << "Warning, load texture type=" << textureType
					<< "index= " << i << " failed with return value= "
					<< retStatus << std::endl;
				continue;
			}
			std::string absolutePath = this->modelFileDir + "/" + textPath.C_Str();
			LoadedTextMapType::const_iterator it = this->loadedTextureMap.find(absolutePath);
			if (it == this->loadedTextureMap.end())
			{
				GLuint textId = TextureHelper::load2DTexture(absolutePath.c_str());
				text.id = textId;
				text.path = absolutePath;
				text.type = textureType;
				textures.push_back(text);
				loadedTextureMap[absolutePath] = text;
			}
			else
			{
				textures.push_back(it->second);
			}
		}
		return true;
	}
private:
	std::vector<Mesh *> meshes;
	std::string modelFileDir;
	typedef std::map<std::string, Texture> LoadedTextMapType;
	LoadedTextMapType loadedTextureMap;
};

#endif
