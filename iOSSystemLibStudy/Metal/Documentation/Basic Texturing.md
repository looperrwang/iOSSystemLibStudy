#  Basic Texturing

> Demonstrates how to load image data and texture a quad.

演示如何加载图像数据和纹理四边形。

## Overview

> In the [Basic Buffers](https://developer.apple.com/documentation/metal/basic_buffers?language=objc) sample, you learned how to render basic geometry in Metal.
>
> In this sample, you’ll learn how to render a 2D image by applying a texture to a single quad. In particular, you’ll learn how to configure texture properties, interpret texture coordinates, and access a texture in a fragment function.

在 [Basic Buffers](https://developer.apple.com/documentation/metal/basic_buffers?language=objc) 示例中，学习了如何在 Metal 中渲染基本几何体。

在此示例中，你将学习如何通过将纹理应用于单个四边形来渲染 2D 图像。特别是，你将学习如何配置纹理属性，解释纹理坐标以及在片段函数中访问纹理。

## Images and Textures

> A key feature of any graphics technology is the ability to process and draw images. Metal supports this feature in the form of textures that contain image data. Unlike regular 2D images, textures can be used in more creative ways and applied to more surface types. For example, textures can be used to displace select vertex positions, or they can be completely wrapped around a 3D object. In this sample, image data is loaded into a texture, applied to a single quad, and rendered as a 2D image.

任何图形技术的一个关键特性是处理和绘制图像的能力。Metal 以包含图像数据的纹理形式支持此功能。与常规 2D 图像不同，纹理可以以更具创造性的方式使用，并应用于更多表面类型。例如，纹理可用于替换选定的顶点位置，或者它们可以完全包裹在 3D 对象周围。在此示例中，图像数据被加载到纹理中，应用于单个四边形，并渲染为 2D 图像。

## Load Image Data

> The Metal framework doesn’t provide API that directly loads image data from a file to a texture. Instead, Metal apps or games rely on custom code or other frameworks, such as Image I/O, MetalKit, UIKit, or AppKit, to handle image files. Metal itself only allocates texture resources and then populates them with image data that was previously loaded into memory.
>
> In this sample, for simplicity, the custom BasicTexturingImage class loads image data from a file (Image.tga) into memory (NSData).
>
> Note - The BasicTexturingImage class isn’t the focal point of this sample, so it isn’t discussed in detail. The class demonstrates basic image loading operations but doesn’t use or depend on the Metal framework in any way. Its sole purpose is to facilitate loading image data for this particular sample.
>
> This sample uses the TGA file format for its simplicity. The file consists of a header describing metadata, such as the image dimensions, and the image data itself. The key takeaway from this file format is the memory layout of the image data; in particular, the layout of each pixel.
>
> Metal requires all textures to be formatted with a specific MTLPixelFormat value. The pixel format describes the layout of each of the texture’s pixels (its texels). To populate a Metal texture with image data, its pixel data must already be formatted in a Metal-compatible pixel format, defined by a single MTLPixelFormat enumeration value. This sample uses the MTLPixelFormatBGRA8Unorm pixel format, which indicates that each pixel has the following memory layout:

Metal 框架不提供直接从文件中加载图像数据转换为纹理的 API 。相反，Metal 应用程序或游戏依赖于自定义代码或其他框架（如 Image I / O ，MetalKit ，UIKit 或 AppKit ）来处理图像文件。Metal 本身仅分配纹理资源，然后使用先前加载到内存中的图像数据填充它们。

在此示例中，为简单起见，自定义 BasicTexturingImage 类从文件（ Image.tga ）加载图像数据到内存（ NSData ）中。

注意 - BasicTexturingImage 类不是此示例的焦点，因此不对其进行详细讨论。该类演示了基本的图像加载操作，但不以任何方式使用或依赖于 Metal 框架。其唯一目的是便于加载该特定示例的图像数据。

简便起见，此示例使用 TGA 文件格式。该文件由描述元数据的头（例如图像尺寸）和图像数据本身组成。这种文件格式的关键点是图像数据的内存布局；特别是每个像素的布局。

Metal 要求使用特定的 MTLPixelFormat 值格式化所有纹理。像素格式描述了每个纹理像素（其纹理像素）的布局。要使用图像数据填充 Metal 纹理，其像素数据必须已经格式化为 Metal 兼容的像素格式，该格式由单个 MTLPixelForma t枚举值定义。此示例使用 MTLPixelFormatBGRA8Unorm 像素格式，表示每个像素具有以下内存布局：

![LoadImageData](../../../resource/Metal/Markdown/LoadImageData.png)

> This pixel format uses 32 bits per pixel, arranged into 8 bits per component, in blue, green, red, and alpha order. TGA files that use 32 bits per pixel are already arranged in this format, so no further conversion operations are needed. However, this sample uses a 24-bit-per-pixel BGR image that needs an extra 8-bit alpha component added to each pixel. Because alpha typically defines the opacity of an image and the sample’s image is fully opaque, the additional 8-bit alpha component of a 32-bit BGRA pixel is set to 255.
>
> After the BasicTexturingImage class loads an image file, the image data is accessible through a query to the data property.

此像素格式每个像素使用 32 位，按照蓝，绿，红和 alpha 顺序排列，每个组件 8 位。每个像素使用 32 位的 TGA 文件已经以这种格式排列，因此不需要进一步的转换操作。但是，此示例使用每像素 24 位的 BGR 图像，需要为每个像素添加额外的 8 位 alpha 分量。由于 alpha 通常定义图像的不透明度，并且示例的图像完全不透明，因此 32 位 BGRA 像素的附加 8 位 alpha 分量设置为 255 。

BasicTexturingImage 类加载图像文件之后，可以通过对 data 属性的查询来访问图像数据。

```objc
// Initialize a source pointer with the source image data that's in BGR form
uint8_t *srcImageData = ((uint8_t*)fileData.bytes +
sizeof(TGAHeader) +
tgaInfo->IDSize);

// Initialize a destination pointer to which you'll store the converted BGRA
// image data
uint8_t *dstImageData = mutableData.mutableBytes;

// For every row of the image
for(NSUInteger y = 0; y < _height; y++)
{
    // For every column of the current row
    for(NSUInteger x = 0; x < _width; x++)
    {
        // Calculate the index for the first byte of the pixel you're
        // converting in both the source and destination images
        NSUInteger srcPixelIndex = 3 * (y * _width + x);
        NSUInteger dstPixelIndex = 4 * (y * _width + x);

        // Copy BGR channels from the source to the destination
        // Set the alpha channel of the destination pixel to 255
        dstImageData[dstPixelIndex + 0] = srcImageData[srcPixelIndex + 0];
        dstImageData[dstPixelIndex + 1] = srcImageData[srcPixelIndex + 1];
        dstImageData[dstPixelIndex + 2] = srcImageData[srcPixelIndex + 2];
        dstImageData[dstPixelIndex + 3] = 255;
    }
}
_data = mutableData;
```

## Create a Texture

> A MTLTextureDescriptor object is used to configure properties such as texture dimensions and pixel format for a MTLTexture object. The newTextureWithDescriptor: method is then called to create an empty texture container and allocate enough memory for the texture data.

MTLTextureDescriptor 对象用于配置 MTLTexture 对象的纹理尺寸和像素格式等属性。然后调用 newTextureWithDescriptor: 方法创建一个空纹理容器并为纹理数据分配足够的内存。

```objc
MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];

// Indicate that each pixel has a blue, green, red, and alpha channel, where each channel is
// an 8-bit unsigned normalized value (i.e. 0 maps to 0.0 and 255 maps to 1.0)
textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;

// Set the pixel dimensions of the texture
textureDescriptor.width = image.width;
textureDescriptor.height = image.height;

// Create the texture from the device by using the descriptor
_texture = [_device newTextureWithDescriptor:textureDescriptor];
```

> Unlike MTLBuffer objects, which store many kinds of custom data, MTLTexture objects are used specifically to store formatted image data. Although a MTLTextureDescriptor object specifies enough information to allocate texture memory, additional information is needed to populate the empty texture container. A MTLTexture object is populated with image data by the replaceRegion:mipmapLevel:withBytes:bytesPerRow: method.
>
> Image data is typically organized in rows. This sample calculates the number of bytes per row as the number of bytes per pixel multiplied by the image width. This type of image data is considered to be tightly packed because the data of subsequent pixel rows immediately follows the previous row.

与存储多种自定义数据的 MTLBuffer 对象不同，MTLTexture 对象专门用于存储格式化的图像数据。尽管 MTLTextureDescriptor 对象指定了足够的信息来分配纹理内存，但还需要其他信息来填充空纹理容器。通过 replaceRegion:mipmapLevel:withBytes:bytesPerRow: 方法用图像数据填充 MTLTexture 对象。

图像数据通常按行组织。此示例计算每行的字节数，即每个像素的字节数乘以图像宽度。这种类型的图像数据被认为是紧密打包的，因为后续像素行的数据紧跟在前一行之后。

```objc
NSUInteger bytesPerRow = 4 * image.width;
```

> Textures have known dimensions that can be interpreted as regions of pixels. A MTLRegion structure is used to identify a specific region of a texture. This sample populates the entire texture with image data; therefore, the region of pixels that covers the entire texture is equal to the texture’s dimensions.

纹理具有已知的尺寸，可以解释为像素区域。MTLRegion 结构用于标识纹理的特定区域。此示例使用图像数据填充整个纹理；因此，覆盖整个纹理的像素区域等于纹理的尺寸。

```objc
MTLRegion region = {
    { 0, 0, 0 },                   // MTLOrigin
    {image.width, image.height, 1} // MTLSize
};
```

> Note - To specify a subregion of a texture, a MTLRegion structure must have either a nonzero origin value, or a smaller size value for any of the texture’s dimensions.
>
> The number of bytes per row and specific pixel region are required arguments for populating an empty texture container with image data. Calling the replaceRegion:mipmapLevel:withBytes:bytesPerRow: method performs this operation by copying data from the image.data.bytes pointer into the _texture object.

注意 - 要指定纹理的子区域，MTLRegion 结构必须具有非零原点值或比纹理尺寸较小的任意值。

每行的字节数和特定像素区域是使用图像数据填充空纹理容器的必需参数。调用  replaceRegion:mipmapLevel:withBytes:bytesPerRow: 方法通过将 image.data.bytes 指针中的数据复制到 _texture 对象中来执行此操作。

```objc
[_texture replaceRegion:region
mipmapLevel:0
withBytes:image.data.bytes
bytesPerRow:bytesPerRow];
```

## Texture Coordinates

> The main task of the fragment function is to process incoming fragment data and calculate a color value for the drawable’s pixels. The goal of this sample is to display the color of each texel on the screen by applying a texture to a single quad. Therefore, the sample’s fragment function must be able to read each texel and output its color.
>
> A texture can’t be rendered on its own; it must correspond to some geometric surface that’s output by the vertex function and turned into fragments by the rasterizer. This relationship is defined by texture coordinates: floating-point positions that map locations on a texture image to locations on a geometric surface.
>
> For 2D textures, texture coordinates are values from 0.0 to 1.0 in both x and y directions. A value of (0.0, 0.0) maps to the texel at the first byte of the image data (the bottom-left corner of the image). A value of (1.0, 1.0) maps to the texel at the last byte of the image data (the top-right corner of the image). Following these rules, accessing the texel in the center of the image requires specifying a texture coordinate of (0.5, 0.5).

片段函数的主要任务是处理传入的片段数据并计算可绘制像素的颜色值。此示例的目标是通过将纹理应用于单个四边形来在屏幕上显示每个纹素的颜色。因此，示例的片段函数必须能够读取每个纹素并输出其颜色。

纹理不能单独渲染；它必须对应于顶点函数输出的一些几何表面，并由光栅化器转换成片段。此关系由纹理坐标定义：浮点位置，将纹理图像上的位置映射到几何表面上的位置。

对于 2D 纹理，纹理坐标在 x 和 y 方向上的值均为 0.0 到 1.0 。值（0.0, 0.0）映射到图像数据的第一个字节（图像的左下角）处的纹素。值（1.0, 1.0）映射到图像数据的最后一个字节（图像的右上角）处的纹素。遵循这些规则，访问图像中心的纹素需要指定纹理坐标（0.5, 0.5）。

![TextureCoordinates](../../../resource/Metal/Markdown/TextureCoordinates.png)

## Map the Vertex Texture Coordinates

> To render a complete 2D image, the texture that contains the image data must be mapped onto vertices that define a 2D quad. In this sample, each of the quad’s vertices specifies a texture coordinate that maps the quad’s corners to the texture’s corners.

要渲染完整的 2D 图像，必须将包含图像数据的纹理映射到定义 2D 四边形的顶点上。在此示例中，四边形的每个顶点都指定一个纹理坐标，将四边形的角映射到纹理的角。

```objc
static const AAPLVertex quadVertices[] =
{
    // Pixel positions, Texture coordinates
    { {  250,  -250 },  { 1.f, 0.f } },
    { { -250,  -250 },  { 0.f, 0.f } },
    { { -250,   250 },  { 0.f, 1.f } },

    { {  250,  -250 },  { 1.f, 0.f } },
    { { -250,   250 },  { 0.f, 1.f } },
    { {  250,   250 },  { 1.f, 1.f } },
};
```

> The vertexShader vertex function passes these values along the pipeline by writing them into the textureCoordinate member of the RasterizerData output structure. These values are interpolated across the quad’s triangle fragments, similar to the interpolated color values in the [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) sample.

vertexShader 顶点函数通过将这些值写入 RasterizerData 输出结构的 textureCoordinate 成员中，沿管道传递这些值。 这些值在四边形的三角形片段中进行插值，类似于 [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) 示例中对颜色值进行的插值。

```objc
out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
```

## Sample Texels

> The signature of the samplingShader fragment function includes the colorTexture argument, which has a texture2d type and uses the [[texture(index)]] attribute qualifier. This argument is a reference to a MTLTexture object and is used to read its texels.

samplingShader 片段函数的签名包括 colorTexture 参数，该参数具有 texture2d 类型并使用 [[texture(index)]] 属性限定符。此参数是对 MTLTexture 对象的引用，用于读取其纹素。

```objc
ragment float4
samplingShader(RasterizerData in [[stage_in]],
texture2d<half> colorTexture [[ texture(AAPLTextureIndexBaseColor) ]])
```

> Reading a texel is also known as sampling. The fragment function uses the built-in texture sample() function to sample texel data. The sample() function takes two arguments: a sampler (textureSampler) and a texture coordinate (in.textureCoordinate). The sampler is used to calculate the color of a texel, and the texture coordinate is used to locate a specific texel.
>
> When the area being rendered to isn’t the same size as the texture, the sampler can use different algorithms to calculate exactly what texel color the sample() function should return. The mag_filter mode specifies how the sampler should calculate the returned color when the area is larger than the size of the texture; the min_filter mode specifies how the sampler should calculate the returned color when the area is smaller than the size of the texture. Setting a linear mode for both filters makes the sampler average the color of texels surrounding the given texture coordinate, resulting in a smoother output image.

读取纹素也称为采样。片段函数使用内置的纹理 sample() 函数来对 texel 数据进行采样。sample() 函数有两个参数：一个采样器（ textureSampler ）和一个纹理坐标（ in.textureCoordinate ）。采样器用于计算纹素的颜色，纹理坐标用于定位特定纹理元素。

当渲染的区域与纹理的大小不同时，采样器可以使用不同的算法来精确计算 sample() 函数应返回的 texel 颜色。 mag_filter 模式指定当区域大于纹理大小时，采样器应如何计算返回的颜色；min_filter 模式指定当区域小于纹理大小时，采样器应如何计算返回的颜色。为两个过滤器设置线性模式可使采样器输出给定纹理坐标周围纹素颜色的平均值，从而使输出图像更平滑。

```objc
constexpr sampler textureSampler (mag_filter::linear,
min_filter::linear);

// Sample the texture to obtain a color
const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
```

## Set a Fragment Texture

> This sample uses the AAPLTextureIndexBaseColor index to identify the texture in both Objective-C and Metal Shading Language code. Fragment functions also take arguments similarly to vertex functions: you call the setFragmentTexture:atIndex: method to set a texture at a specific index.

此示例使用 AAPLTextureIndexBaseColor 索引来标识 Objective-C 和 Metal Shading Language 代码中的纹理。片段函数采用与顶点函数类似的参数：调用 setFragmentTexture:atIndex: 方法为特定索引设置纹理。

```objc
[renderEncoder setFragmentTexture:_texture
atIndex:AAPLTextureIndexBaseColor];
```

## Next Steps

> In this sample, you learned how to render a 2D image by applying a texture to a single quad.
>
> In the [Hello Compute](https://developer.apple.com/documentation/metal/hello_compute?language=objc) sample, you’ll learn how to execute compute-processing workloads in Metal for image processing.

在此示例中，学习了如何通过将纹理应用于单个四边形来渲染 2D 图像。

在 [Hello Compute](https://developer.apple.com/documentation/metal/hello_compute?language=objc) 示例中，你将学习如何在 Metal 中执行计算处理工作以进行图像处理。
