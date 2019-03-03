//
//  TextureHelper.h
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/23.
//  Copyright © 2019 looperwang. All rights reserved.
//

#ifndef TextureHelper_h
#define TextureHelper_h

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
        //glActiveTexture(GL_TEXTURE0); //0号纹理默认激活，这行代码不是必须的
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
    
    static GLuint loadCubeMapTexture(std::vector<const char *> picFilePathVec)
    {
        GLuint textureId;
        glGenTextures(1, &textureId);
        glBindTexture(GL_TEXTURE_CUBE_MAP, textureId);
        
        for (std::vector<const char *>::size_type i = 0; i < picFilePathVec.size(); i++) {
            demoImage *image = imgLoadImage(picFilePathVec[i], false);
            glTexImage2D((GLenum)(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i), 0, image->format, image->width, image->height, 0, image->format, image->type, image->data);
            imgDestroyImage(image);
        }
        
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
        
        glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
        
        return textureId;
    }
    
#define FOURCC_DXT1 0x31545844 // Equivalent to "DXT1" in ASCII
#define FOURCC_DXT3 0x33545844 // Equivalent to "DXT3" in ASCII
#define FOURCC_DXT5 0x35545844 // Equivalent to "DXT5" in ASCII
    
    // PVRTC (GL_IMG_texture_compression_pvrtc) : Imagination based gpus
#ifndef GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG
#define GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG 0x8C01
#endif
#ifndef GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG
#define GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG 0x8C03
#endif
#ifndef GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG
#define GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG 0x8C00
#endif
#ifndef GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG
#define GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG 0x8C02
#endif
    
    // S3TC/DXT (GL_EXT_texture_compression_s3tc) : Most desktop/console gpus
#ifndef GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
#define GL_COMPRESSED_RGBA_S3TC_DXT1_EXT 0x83F1
#endif
#ifndef GL_COMPRESSED_RGBA_S3TC_DXT3_EXT
#define GL_COMPRESSED_RGBA_S3TC_DXT3_EXT 0x83F2
#endif
#ifndef GL_COMPRESSED_RGBA_S3TC_DXT5_EXT
#define GL_COMPRESSED_RGBA_S3TC_DXT5_EXT 0x83F3
#endif
    
    // ATC (GL_AMD_compressed_ATC_texture) : Qualcomm/Adreno based gpus
#ifndef ATC_RGB_AMD
#define ATC_RGB_AMD 0x8C92
#endif
#ifndef ATC_RGBA_EXPLICIT_ALPHA_AMD
#define ATC_RGBA_EXPLICIT_ALPHA_AMD 0x8C93
#endif
#ifndef ATC_RGBA_INTERPOLATED_ALPHA_AMD
#define ATC_RGBA_INTERPOLATED_ALPHA_AMD 0x87EE
#endif
    
    // ETC1 (OES_compressed_ETC1_RGB8_texture) : All OpenGL ES chipsets
#ifndef ETC1_RGB8
#define ETC1_RGB8 0x8D64
#endif
    
    static int getMaskByteIndex(unsigned int mask)
    {
        switch (mask)
        {
            case 0xff000000:
                return 3;
            case 0x00ff0000:
                return 2;
            case 0x0000ff00:
                return 1;
            case 0x000000ff:
                return 0;
            default:
                return -1; // no or invalid mask
        }
    }
    
    static GLuint loadDDS(const char * filename) {
        // DDS file structures.
        struct dds_pixel_format
        {
            unsigned int dwSize;
            unsigned int dwFlags;
            unsigned int dwFourCC;
            unsigned int dwRGBBitCount;
            unsigned int dwRBitMask;
            unsigned int dwGBitMask;
            unsigned int dwBBitMask;
            unsigned int dwABitMask;
        };
        
        struct dds_header
        {
            unsigned int     dwSize;
            unsigned int     dwFlags;
            unsigned int     dwHeight;
            unsigned int     dwWidth;
            unsigned int     dwPitchOrLinearSize;
            unsigned int     dwDepth;
            unsigned int     dwMipMapCount;
            unsigned int     dwReserved1[11];
            dds_pixel_format ddspf;
            unsigned int     dwCaps;
            unsigned int     dwCaps2;
            unsigned int     dwCaps3;
            unsigned int     dwCaps4;
            unsigned int     dwReserved2;
        };
        
        struct dds_mip_level
        {
            GLubyte* data;
            GLsizei width;
            GLsizei height;
            GLsizei size;
        };
        
        // Read DDS file.
        std::ifstream file(filename, std::ios::in | std::ios::binary);
        
        // Validate DDS magic number.
        char code[4];
        file.read(code, 4);
        if (strncmp(code, "DDS ", 4) != 0)
        {
            return -1;
        }
        
        // Read DDS header.
        dds_header header;
        file.read((char *)&header, sizeof(header));
        
        if ((header.dwFlags & 0x20000/*DDSD_MIPMAPCOUNT*/) == 0)
        {
            // Mipmap count not specified (non-mipmapped texture).
            header.dwMipMapCount = 1;
        }
        
        // Check type of images. Default is a regular texture
        unsigned int facecount = 1;
        GLenum faces[6] = { GL_TEXTURE_2D };
        GLenum target = GL_TEXTURE_2D;
        if ((header.dwCaps2 & 0x200/*DDSCAPS2_CUBEMAP*/) != 0)
        {
            facecount = 0;
            for (unsigned int off = 0, flag = 0x400/*DDSCAPS2_CUBEMAP_POSITIVEX*/; off < 6; ++off, flag <<= 1)
            {
                if ((header.dwCaps2 & flag) != 0)
                {
                    faces[facecount++] = GL_TEXTURE_CUBE_MAP_POSITIVE_X + off;
                }
            }
            target = GL_TEXTURE_CUBE_MAP;
        }
        else if ((header.dwCaps2 & 0x200000/*DDSCAPS2_VOLUME*/) != 0)
        {
            // Volume textures unsupported.
            return -1;
        }
        
        // Allocate mip level structures.
        dds_mip_level* mipLevels = new dds_mip_level[header.dwMipMapCount * facecount];
        memset(mipLevels, 0, sizeof(dds_mip_level) * header.dwMipMapCount * facecount);
        
        GLenum format = 0;
        GLenum internalFormat = 0;
        bool compressed = false;
        GLsizei width = header.dwWidth;
        GLsizei height = header.dwHeight;
        
        if (header.ddspf.dwFlags & 0x4/*DDPF_FOURCC*/)
        {
            compressed = true;
            int bytesPerBlock;
            
            // Compressed.
            switch (header.ddspf.dwFourCC)
            {
                case ('D'|('X'<<8)|('T'<<16)|('1'<<24)):
                    format = internalFormat = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
                    bytesPerBlock = 8;
                    break;
                case ('D'|('X'<<8)|('T'<<16)|('3'<<24)):
                    format = internalFormat = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
                    bytesPerBlock = 16;
                    break;
                case ('D'|('X'<<8)|('T'<<16)|('5'<<24)):
                    format = internalFormat = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
                    bytesPerBlock = 16;
                    break;
                case ('A'|('T'<<8)|('C'<<16)|(' '<<24)):
                    format = internalFormat = ATC_RGB_AMD;
                    bytesPerBlock = 8;
                    break;
                case ('A'|('T'<<8)|('C'<<16)|('A'<<24)):
                    format = internalFormat = ATC_RGBA_EXPLICIT_ALPHA_AMD;
                    bytesPerBlock = 16;
                    break;
                case ('A'|('T'<<8)|('C'<<16)|('I'<<24)):
                    format = internalFormat = ATC_RGBA_INTERPOLATED_ALPHA_AMD;
                    bytesPerBlock = 16;
                    break;
                case ('E'|('T'<<8)|('C'<<16)|('1'<<24)):
                    format = internalFormat = ETC1_RGB8;
                    bytesPerBlock = 8;
                    break;
                default:
                    delete [] mipLevels;
                    return NULL;
            }
            
            for (unsigned int face = 0; face < facecount; ++face)
            {
                for (unsigned int i = 0; i < header.dwMipMapCount; ++i)
                {
                    dds_mip_level& level = mipLevels[i + face * header.dwMipMapCount];
                    
                    level.width = width;
                    level.height = height;
                    level.size = std::max(1, (width + 3) >> 2) * std::max(1, (height + 3) >> 2) * bytesPerBlock;
                    level.data = new GLubyte[level.size];
                    
                    file.read((char *)level.data, level.size);
                    
                    width = std::max(1, width >> 1);
                    height = std::max(1, height >> 1);
                }
                width = header.dwWidth;
                height = header.dwHeight;
            }
        }
        else if (header.ddspf.dwFlags & 0x40/*DDPF_RGB*/)
        {
            // RGB/RGBA (uncompressed)
            bool colorConvert = false;
            unsigned int rmask = header.ddspf.dwRBitMask;
            unsigned int gmask = header.ddspf.dwGBitMask;
            unsigned int bmask = header.ddspf.dwBBitMask;
            unsigned int amask = header.ddspf.dwABitMask;
            int ridx = getMaskByteIndex(rmask);
            int gidx = getMaskByteIndex(gmask);
            int bidx = getMaskByteIndex(bmask);
            int aidx = getMaskByteIndex(amask);
            
            if (header.ddspf.dwRGBBitCount == 24)
            {
                format = internalFormat = GL_RGB;
                colorConvert = (ridx != 0) || (gidx != 1) || (bidx != 2);
            }
            else if (header.ddspf.dwRGBBitCount == 32)
            {
                format = internalFormat = GL_RGBA;
                if (ridx == 0 && gidx == 1 && bidx == 2)
                {
                    aidx = 3; // XBGR or ABGR
                    colorConvert = false;
                }
                else if (ridx == 2 && gidx == 1 && bidx == 0)
                {
                    aidx = 3; // XRGB or ARGB
                    colorConvert = true;
                }
                else
                {
                    format = 0; // invalid format
                }
            }
            
            if (format == 0)
            {
                delete [] mipLevels;
                return NULL;
            }
            
            // Read data.
            for (unsigned int face = 0; face < facecount; ++face)
            {
                for (unsigned int i = 0; i < header.dwMipMapCount; ++i)
                {
                    dds_mip_level& level = mipLevels[i + face * header.dwMipMapCount];
                    
                    level.width = width;
                    level.height = height;
                    level.size = width * height * (header.ddspf.dwRGBBitCount >> 3);
                    level.data = new GLubyte[level.size];
                    
                    file.read((char *)level.data, level.size);
                    
                    width = std::max(1, width >> 1);
                    height = std::max(1, height >> 1);
                }
                width = header.dwWidth;
                height = header.dwHeight;
            }
            
            // Perform color conversion.
            if (colorConvert)
            {
                // Note: While it's possible to use BGRA_EXT texture formats here and avoid CPU color conversion below,
                // there seems to be different flavors of the BGRA extension, with some vendors requiring an internal
                // format of RGBA and others requiring an internal format of BGRA.
                // We could be smarter here later and skip color conversion in favor of GL_BGRA_EXT (for format
                // and/or internal format) based on which GL extensions are available.
                // Tip: Using A8B8G8R8 and X8B8G8R8 DDS format maps directly to GL RGBA and requires on no color conversion.
                GLubyte *pixel, r, g, b, a;
                if (format == GL_RGB)
                {
                    for (unsigned int face = 0; face < facecount; ++face)
                    {
                        for (unsigned int i = 0; i < header.dwMipMapCount; ++i)
                        {
                            dds_mip_level& level = mipLevels[i + face * header.dwMipMapCount];
                            for (int j = 0; j < level.size; j += 3)
                            {
                                pixel = &level.data[j];
                                r = pixel[ridx]; g = pixel[gidx]; b = pixel[bidx];
                                pixel[0] = r; pixel[1] = g; pixel[2] = b;
                            }
                        }
                    }
                }
                else if (format == GL_RGBA)
                {
                    for (unsigned int face = 0; face < facecount; ++face)
                    {
                        for (unsigned int i = 0; i < header.dwMipMapCount; ++i)
                        {
                            dds_mip_level& level = mipLevels[i + face * header.dwMipMapCount];
                            for (int j = 0; j < level.size; j += 4)
                            {
                                pixel = &level.data[j];
                                r = pixel[ridx]; g = pixel[gidx]; b = pixel[bidx]; a = pixel[aidx];
                                pixel[0] = r; pixel[1] = g; pixel[2] = b; pixel[3] = a;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            // Unsupported.
            delete [] mipLevels;
            return NULL;
        }
        
        // Close file.
        file.close();
        
        // Generate GL texture.
        GLuint textureId;
        glGenTextures(1, &textureId);
        glBindTexture(target, textureId);
        
        glTexParameteri(target, GL_TEXTURE_MIN_FILTER, header.dwMipMapCount > 1 ? GL_NEAREST_MIPMAP_LINEAR : GL_LINEAR );
        
        // Load texture data.
        for (unsigned int face = 0; face < facecount; ++face)
        {
            GLenum texImageTarget = faces[face];
            for (unsigned int i = 0; i < header.dwMipMapCount; ++i)
            {
                dds_mip_level& level = mipLevels[i + face * header.dwMipMapCount];
                if (compressed)
                {
                    glCompressedTexImage2D(texImageTarget, i, format, level.width, level.height, 0, level.size, level.data);
                }
                else
                {
                    glTexImage2D(texImageTarget, i, internalFormat, level.width, level.height, 0, format, GL_UNSIGNED_BYTE, level.data);
                }
                
                // Clean up the texture data.
                delete [] level.data;
            }
        }
        
        // Clean up mip levels structure.
        delete [] mipLevels;
        
        return textureId;
    }
    
    //(0, GL_DEPTH24_STENCIL8, WINDOW_WIDTH, WINDOW_HEIGHT, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8);
//    static GLuint makeAttachmentTexture(GLint level = 0, GLint internalFormat = GL_DEPTH24_STENCIL8,
//                                        GLsizei width = 800, GLsizei height = 600,GLenum picFormat = GL_DEPTH_STENCIL,
//                                        GLenum picDataType = GL_UNSIGNED_INT_24_8)
//    {
//        GLuint textId;
//        glGenTextures(1, &textId);
//        glBindTexture(GL_TEXTURE_2D, textId);
//        glTexImage2D(GL_TEXTURE_2D, level, internalFormat,
//                     width, height, 0, picFormat, picDataType, NULL); // ‘§∑÷≈‰ø’º‰
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//
//        return textId;
//    }
    
    static GLuint makeAttachmentTexture(GLsizei width, GLsizei height, GLint level = 0, GLint internalFormat = GL_RGB, GLenum picFormat = GL_RGB, GLenum picDataType = GL_UNSIGNED_BYTE)
    {
        GLuint textureId;
        glGenTextures(1, &textureId);
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexImage2D(GL_TEXTURE_2D, level, internalFormat, width, height, 0, picFormat, picDataType, NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        return textureId;
    }
};

#endif /* TextureHelper_h */
