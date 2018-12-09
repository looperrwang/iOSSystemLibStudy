#  Basic Buffers

> Demonstrates how to manage hundreds of vertices with a vertex buffer.

演示如何使用顶点缓冲区管理数百个顶点。

## Overview

> In the [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) sample, you learned how to render basic geometry in Metal
>
> In this sample, you’ll learn how to use a vertex buffer to improve your rendering efficiency. In particular, you’ll learn how to use a vertex buffer to store and load vertex data for multiple quads.

在 [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) 示例中，学习了如何在 Metal 中渲染基本几何体

在此示例中，你将学习如何使用顶点缓冲区来提高渲染效率。特别是，你将学习如何使用顶点缓冲区来存储和加载多个四边形的顶点数据。

## Manage Large Amounts of Vertex Data

> In the [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) sample, the sample renders three vertices of 32 bytes each, amounting to 96 bytes of vertex data. This small amount of vertex data is sent to a vertex function through a call to the setVertexBytes:length:atIndex: method. This method allocates a small amount of memory that’s accessible to the graphics processing unit (GPU) and can be allocated in each frame without a noticeable performance cost.
>
> Unlike the [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) sample, this sample renders 2,250 vertices of 32 bytes each, amounting to 72,000 bytes of vertex data. This amount of vertex data needs to be managed more efficiently. In fact, Metal does not allow use of the setVertexBytes:length:atIndex: method for vertex data that exceeds 4 kilobytes (4,096 bytes). More importantly, the vertex data should not be reallocated and copied in each frame.
>
> Typically, Metal apps or games draw models with thousands of vertices, each with multiple vertex attributes, that consume several megabytes of memory. For these apps or games to scale well and be managed efficiently, Metal provides specialized data containers represented by MTLBuffer objects. These buffers are GPU-accessible memory allocations for storing many kinds of custom data, although they’re typically used for vertex data. This sample allocates a large amount of vertex data once, copies it into a MTLBuffer object, and then reuses the vertex data in each frame.

在 [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) 示例中，示例渲染了三个顶点，每个顶点 32 个字节，相当于 96 个字节的顶点数据。通过调用 setVertexBytes:length:atIndex: 方法将少量顶点数据发送到顶点函数。此方法分配了图形处理单元（ GPU ）可访问的少量内存，并且可以在每帧中分配，而不会产生明显的性能成本。

与 [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) 示例不同，此示例渲染 2,250 个顶点，每个顶点 32 个字节，相当于 72,000 个字节的顶点数据。这样量级的顶点数据需要更有效的管理方式。事实上，对于超过 4 千字节（ 4,096字节）的顶点数据，Metal 不允许使用 setVertexBytes:length:atIndex: 方法。更重要的是，不应在每帧中重新分配和复制顶点数据。

通常，Metal 应用程序或游戏会绘制具有数千个顶点的模型，每个顶点都有多个顶点属性，这些顶点属性消耗几兆字节的内存。为了使这些应用程序或游戏能够很好地扩展并进行有效管理，Metal 提供了由 MTLBuffer 对象表示的专用数据容器。这些缓冲区是 GPU 可访问的内存分配，用于存储多种自定义数据，尽管它们通常用于存储顶点数据。此示例一次性分配大量顶点数据，将其复制到 MTLBuffer 对象中，然后在每帧中重用这些顶点数据。

## Allocate, Generate, and Copy Vertex Data

> In Objective-C, byte buffers are wrapped by NSData or NSMutableData objects, which are safe and convenient to use. The AAPLVertex data type is used for each vertex in the sample, and each quad is made up of 6 of these vertex values (with two triangles per quad). The 30 x 20 grid of quads amounts to 3,600 vertices occupying 115,200 bytes of memory, the amount to allocate for the sample’s vertex data.

在 Objective-C 中，字节缓冲区由 NSData 或 NSMutableData 对象包装，使用起来既安全又方便。AAPLVertex 数据类型用于示例中的每个顶点，每个四边形由 6 个这些顶点值组成（每个四边形有两个三角形）。 30 x 20 的四边形网格共计 3,600 个顶点，占用 115,200 字节的内存（示例的顶点数据需要分配的内存总量）。

```
const AAPLVertex quadVertices[] =
{
    // Pixel positions, RGBA colors
    { { -20,   20 },    { 1, 0, 0, 1 } },
    { {  20,   20 },    { 0, 0, 1, 1 } },
    { { -20,  -20 },    { 0, 1, 0, 1 } },

    { {  20,  -20 },    { 1, 0, 0, 1 } },
    { { -20,  -20 },    { 0, 1, 0, 1 } },
    { {  20,   20 },    { 0, 0, 1, 1 } },
};
const NSUInteger NUM_COLUMNS = 25;
const NSUInteger NUM_ROWS = 15;
const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(AAPLVertex);
const float QUAD_SPACING = 50.0;

NSUInteger dataSize = sizeof(quadVertices) * NUM_COLUMNS * NUM_ROWS;
NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
```

> Typically, Metal apps or games load vertex data from model files. The complexity of model-loading code varies by model, but ultimately the vertex data is also stored in a byte buffer that’s handed off to Metal code. To avoid introducing model-loading code, this sample simulates the vertex data handoff with the generateVertexData method, which generates simple vertex data at runtime.
>
> Both NSData and MTLBuffer objects store custom data, which means your app is responsible for defining and interpreting this data correctly during read or write operations. In this sample, the vertex data is read-only and its memory layout is defined by the AAPLVertex data type, which is what the vertexShader vertex function requires.

通常，Metal 应用程序或游戏从模型文件中加载顶点数据。模型加载代码的复杂性因模型而异，但最终顶点数据也存储在传递给 Metal 代码的字节缓冲区中。为避免引入模型加载代码，此示例使用 generateVertexData 方法模拟顶点数据切换，该方法在运行时生成简单的顶点数据。

NSData 和 MTLBuffer 对象都存储自定义数据，这意味着你的应用程序负责在读取或写入操作期间正确定义和解释此数据。在此示例中，顶点数据是只读的，其内存布局由 AAPLVertex 数据类型定义，这是 vertexShader 顶点函数所需的。

```objc
vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
device AAPLVertex *vertices [[ buffer(AAPLVertexInputIndexVertices) ]],
constant vector_uint2 *viewportSizePointer  [[ buffer(AAPLVertexInputIndexViewportSize) ]])
```

> Fundamentally, both NSData and MTLBuffer objects are quite similar. However, a MTLBuffer object is a specialized container accessible to the GPU, enabling the graphics render pipeline to read vertex data from it.

从根本上说，NSData 和 MTLBuffer 对象都非常相似。然而，MTLBuffer 对象是 GPU 可访问的专用容器，图形渲染管道能够从中读取顶点数据。

```objc
NSData *vertexData = [AAPLRenderer generateVertexData];

// Create a vertex buffer by allocating storage that can be read by the GPU
_vertexBuffer = [_device newBufferWithLength:vertexData.length
options:MTLResourceStorageModeShared];

// Copy the vertex data into the vertex buffer by accessing a pointer via
// the buffer's `contents` property
memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
```

> First, the newBufferWithLength:options: method creates a new MTLBuffer object of a certain byte size and with certain access options. The vertex data occupies 115,200 bytes of memory (vertexData.length) that’s written by the CPU and read by the GPU (MTLResourceStorageModeShared).
>
> Second, the memcpy() function copies vertex data from a source NSData object to a destination MTLBuffer object. The _vertexBuffer.contents query returns a CPU-accessible pointer to the buffer’s memory. The vertex data is copied into this destination through a pointer to the source data (vertexData.bytes) and a specified amount of data to be copied (vertexData.length).

首先，newBufferWithLength:options: 方法创建一个具有特定字节大小和特定访问选项的新 MTLBuffer 对象。顶点数据占用 115,200 字节的内存（ vertexData.length ），该块内存由 CPU 写入并由 GPU 读取（MTLResourceStorageModeShared）。

其次，memcpy() 函数将顶点数据从源 NSData 对象复制到目标 MTLBuffer 对象。 _vertexBuffer.contents 查询返回指向缓冲区内存的 CPU 可访问的指针。顶点数据通过指向源数据（ vertexData.bytes ）的指针和指定的要复制的数据量（ vertexData.length ）复制到此目标。

## Set and Draw Vertex Data

> Because the sample’s vertex data is now stored in a MTLBuffer object, the setVertexBytes:length:atIndex: method can no longer be called; the setVertexBuffer:offset:atIndex: method is called instead. This method takes as parameters a vertex buffer, a byte offset to the vertex data in that buffer, and an index that maps the buffer to the vertex function.
>
> Note - Using a MTLBuffer as a vertex function argument does not prevent an app or game from using the setVertexBytes:length:atIndex: method to set data for another argument. In fact, this sample still uses the viewportSizePointer argument introduced in the [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) sample.
>
> Finally, all vertices are drawn by issuing a draw call that starts from the first vertex in the array (0) and ends at the last (_numVertices).

由于示例的顶点数据现在存储在 MTLBuffer 对象中，因此无法再调用setVertexBytes:length:atIndex: 方法；取而代之的是 setVertexBuffer:offset:atIndex: 方法。 此方法将顶点缓冲区，该缓冲区中顶点数据的字节偏移量以及将缓冲区映射到顶点函数的索引作为参数。

注意 - 使用 MTLBuffer 作为顶点函数参数不会阻止应用或游戏使用 setVertexBytes:length:atIndex: 方法为其他参数设置数据。实际上，此示例仍使用 [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) 示例中引入的 viewportSizePointer 参数。

最后，通过发出一个从数组中的第一个顶点（0）开始并最后一个（_numVertices）结束的绘制调用来绘制所有顶点。

最后，通过发出一个从数组中的第一个顶点（ 0 ）开始并最后一个（ _numVertices ）结束的绘制调用，所有的顶点都被绘制了出来。

```objc
[renderEncoder setVertexBuffer:_vertexBuffer
offset:0
atIndex:AAPLVertexInputIndexVertices];

[renderEncoder setVertexBytes:&_viewportSize
length:sizeof(_viewportSize)
atIndex:AAPLVertexInputIndexViewportSize];

// Draw the vertices of the quads
[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
vertexStart:0
vertexCount:_numVertices];
```

## Next Steps

> In this sample, you learned how to use a vertex buffer to improve your rendering efficiency.
>
> In the [Basic Texturing](https://developer.apple.com/documentation/metal/basic_texturing?language=objc) sample, you’ll learn how to load image data and texture a quad.

在此示例中，学习了如何使用顶点缓冲区来提高渲染效率。

在 [Basic Texturing](https://developer.apple.com/documentation/metal/basic_texturing?language=objc) 示例中，你将学习如何加载图像数据和纹理四边形。
