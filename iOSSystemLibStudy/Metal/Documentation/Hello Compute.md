#  Hello Compute

> Demonstrates how to perform data-parallel computations using the GPU.

演示如何使用 GPU 执行数据并行计算。

## Overview

> In the [Basic Texturing](https://developer.apple.com/documentation/metal/basic_texturing?language=objc) sample, you learned how to render a 2D image by applying a texture to a single quad.
>
> In this sample, you’ll learn how to execute compute-processing workloads in Metal for image processing. In particular, you’ll learn how to work with the compute processing pipeline and write kernel functions.

[Basic Texturing](https://developer.apple.com/documentation/metal/basic_texturing?language=objc) 示例中，学习了如何通过将纹理应用于单个四边形来渲染 2D 图像。

在此示例中，你将学习如何在 Metal 中执行计算处理工作负载以进行图像处理。特别是，将学习如何使用计算处理管道和编写内核函数。

## General-Purpose GPU Programming

> Graphics processing units (GPUs) were originally designed to process large amounts of graphics data, such as vertices or fragments, in a very fast and efficient manner. This design is evident in the GPU hardware architecture itself, which has many processing cores that execute workloads in parallel.
>
> Throughout the history of GPU design, the parallel-processing architecture has remained fairly consistent, but the processing cores have become increasingly programmable. This change enabled GPUs to move away from a fixed-function pipeline toward a programmable pipeline, a change that also enabled general-purpose GPU (GPGPU) programming.
>
> In the GPGPU model, the GPU can be used for any kind of processing task and isn’t limited to graphics data. For example, GPUs can be used for cryptography, machine learning, physics, or finance. In Metal, GPGPU workloads are known as compute-processing workloads, or compute.
>
> Graphics and compute workloads are not mutually exclusive; Metal provides a unified framework and language that enables seamless integration of graphics and compute workloads. In fact, this sample demonstrates this integration by:
>
> 1. Using a compute pipeline that converts a color image to a grayscale image
>
> 2. Using a graphics pipeline that renders the grayscale image to a quad surface

图形处理单元（ GPU ）最初设计用于以非常快速和有效的方式处理大量图形数据，例如顶点或片段。这种设计在 GPU 硬件架构本身中体现地很明显，其具有许多可以并行执行工作负载的处理核心。

纵观 GPU 设计的历史，并行处理架构保持相当一致，但处理核心变得越来越可编程。这一变化使 GPU 能够从固定功能管道转向可编程管道，这一变化也使得通用 GPU（ GPGPU ）编程变得可能。

在 GPGPU 模型中，GPU 可用于任何类型的处理任务，并不局限于图形数据。例如，GPU 可用于加密，机器学习，物理或财务。在 Metal 中，GPGPU 工作负载称为计算处理工作负载或计算。

图形和计算工作负载不是互斥的；Metal 提供统一的框架和语言，可实现图形和计算工作负载的无缝集成。实际上，此示例通过以下方式演示了此集成：

1. 使用计算管道将彩色图像转换为灰度图像

2. 使用图形管道将灰度图像渲染为四边形表面

## Create a Compute Processing Pipeline

> The compute processing pipeline is made up of only one stage, a programmable kernel function, that executes a compute pass. The kernel function reads from and writes to resources directly, without passing resource data through various pipeline stages.
>
> A MTLComputePipelineState object represents a compute processing pipeline. Unlike a graphics rendering pipeline, you can create a MTLComputePipelineState object with a single kernel function, without using a pipeline descriptor.

计算处理流水线仅由一个阶段组成，即可编程内核函数，它执行计算过程。内核函数直接读写资源，而不会在管道的各个阶段传递资源数据。

MTLComputePipelineState 对象表示计算处理管道。与图形渲染管道不同，可以使用单个内核函数创建 MTLComputePipelineState 对象，而无需使用管道描述符。

```objc
// Load the kernel function from the library
id<MTLFunction> kernelFunction = [defaultLibrary newFunctionWithName:@"grayscaleKernel"];

// Create a compute pipeline state
_computePipelineState = [_device newComputePipelineStateWithFunction:kernelFunction
error:&error];
```

## Write a Kernel Function

> This sample loads image data into a texture and then uses a kernel function to convert the texture’s pixels from color to grayscale. The kernel function processes the pixels independently and concurrently.
>
> Note - An equivalent algorithm can be written for and executed by the CPU. However, a GPU solution is faster because the texture’s pixels don’t need to be processed sequentially.
>
> The kernel function in this sample is called grayscaleKernel and its signature is shown below:

此示例将图像数据加载到纹理中，然后使用内核函数将纹理的像素从彩色转换为灰度。内核函数独立并并发地处理像素。

注意 - 等效的算法也可以执行在 CPU 上。但是，GPU 解决方案更快，因为纹理的像素不需要按顺序处理。

此示例中的内核函数称为 grayscaleKernel ，其签名如下所示：

```objc
kernel void
grayscaleKernel(texture2d<half, access::read>  inTexture  [[texture(AAPLTextureIndexInput)]],
texture2d<half, access::write> outTexture [[texture(AAPLTextureIndexOutput)]],
uint2                          gid         [[thread_position_in_grid]])
```

> The function takes the following resource parameters:
>
> - inTexture: A read-only, 2D texture that contains the input color pixels.
>
> - outTexture: A write-only, 2D texture that stores the output grayscale pixels.
>
> Textures that specify a read access qualifier can be read from using the read() function. Textures that specify a write access qualifier can be written to using the write() function.
>
> A kernel function executes once per thread, which is analogous to how a vertex function executes once per vertex. Threads are organized into a 3D grid; an encoded compute pass specifies how many threads to process by declaring the size of the grid. Because this sample processes a 2D texture, the threads are arranged in a 2D grid where each thread corresponds to a unique texel.
>
> The kernel function’s gid parameter uses the [[thread_position_in_grid]] attribute qualifier, which locates a thread within the compute grid. Each execution of the kernel function has a unique gid value that enables each thread to work distinctly.
>
> A grayscale pixel has the same value for each of its RGB components. This value can be calculated by simply averaging the RGB components of a color pixel, or by applying certain weights to each component. This sample uses the Rec. 709 luma coefficients for the color-to-grayscale conversion.

该函数采用以下资源参数：

- inTexture：包含输入颜色像素的只读 2D 纹理。

- outTexture：存储输出的灰度像素的只写 2D 纹理。

可以使用 read() 函数读取指定读取访问限定符的纹理。可以使用 write() 函数写入指定写访问限定符的纹理。

每个线程只执行一次内核函数，这类似于顶点函数对于每个顶点只执行一次。线程被组织成 3D 网格；编码的计算过程通过声明网格的大小来指定要处理的线程数。因为此示例处理 2D 纹理，所以线程排列在 2D 网格中，其中每个线程对应于唯一的纹理元素。

内核函数的 gid 参数使用 [[thread_position_in_grid]] 属性限定符，该限定符定位计算网格中的线程。内核函数的每次执行都有一个唯一的 gid 值，使每个线程能够清晰地工作。

灰度像素对于其每个 RGB 分量具有相同的值。可以通过简单地平均彩色像素的 RGB 分量，或者通过将某些权重应用于每个分量来计算该值。此示例使用 Rec. 709 luma 系数完成彩色到灰度的转换。

```objc
half4 inColor  = inTexture.read(gid);
half  gray     = dot(inColor.rgb, kRec709Luma);
outTexture.write(half4(gray, gray, gray, 1.0), gid);
```

## Execute a Compute Pass

> A MTLComputeCommandEncoder object contains the commands for executing a compute pass, including references to the kernel function and its resources. Unlike a render command encoder, you can create a MTLComputeCommandEncoder without using a pass descriptor.

MTLComputeCommandEncoder 对象包含用于执行计算过程的命令，包括对内核函数及其资源的引用。与渲染命令编码器不同，可以在不使用传递描述符的情况下创建 MTLComputeCommandEncoder 。

```objc
id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];

[computeEncoder setComputePipelineState:_computePipelineState];

[computeEncoder setTexture:_inputTexture
atIndex:AAPLTextureIndexInput];

[computeEncoder setTexture:_outputTexture
atIndex:AAPLTextureIndexOutput];
```

> A compute pass must specify the number of times to execute a kernel function. This number corresponds to the grid size, which is defined in terms of threads and threadgroups. A threadgroup is a 3D group of threads that are executed concurrently by a kernel function. In this sample, each thread corresponds to a unique texel, and the grid size must be at least the size of the 2D image. For simplicity, this sample uses a 16 x 16 threadgroup size which is small enough to be used by any GPU. In practice, however, selecting an efficient threadgroup size depends on both the size of the data and the capabilities of a specific device.

计算过程必须指定执行内核函数的次数。此数字对应于网格大小，该大小根据线程和线程组定义。线程组是由内核函数并发执行的 3D 线程组。在此示例中，每个线程对应一个唯一的纹理元素，网格大小必须至少为 2D 图像的大小。为简单起见，此示例使用 16 x 16 线程组大小，该大小足以供任何 GPU 使用。但实际上，选择有效的线程组大小取决于数据的大小和特定设备的能力。

```objc
// Set the compute kernel's threadgroup size of 16x16
_threadgroupSize = MTLSizeMake(16, 16, 1);

// Calculate the number of rows and columns of threadgroups given the width of the input image
// Ensure that you cover the entire image (or more) so you process every pixel
_threadgroupCount.width  = (_inputTexture.width  + _threadgroupSize.width -  1) / _threadgroupSize.width;
_threadgroupCount.height = (_inputTexture.height + _threadgroupSize.height - 1) / _threadgroupSize.height;
```

> The sample finalizes the compute pass by issuing a dispatch call and ending the encoding of compute commands.

该示例通过发出调度调用并结束计算命令的编码来最终结束计算过程。

```objc
[computeEncoder dispatchThreadgroups:_threadgroupCount
threadsPerThreadgroup:_threadgroupSize];

[computeEncoder endEncoding];
```

> The sample then continues to encode the rendering commands first introduced in the [Basic Texturing](https://developer.apple.com/documentation/metal/basic_texturing?language=objc) sample. The commands for the compute pass and the render pass use the same grayscale texture, are appended into the same command buffer, and are submitted to the GPU at the same time. However, the grayscale conversion in the compute pass is always executed before the quad rendering in the render pass.

然后，该示例继续编码在 [Basic Texturing](https://developer.apple.com/documentation/metal/basic_texturing?language=objc) 示例中引入的渲染命令。计算过程和渲染过程的命令使用相同的灰度纹理，并被附加到同一个命令缓冲区，并同时提交给 GPU 。但是，计算过程中的灰度转换始终在渲染过程的四边形渲染之前执行。
