#  About GPU Family 4

原文地址 https://developer.apple.com/documentation/metal/mtldevice/ios_and_tvos_devices/about_gpu_family_4?language=objc

> Learn about A11 features, including raster order groups, tile shaders, and imageblocks.

## Overview

> GPU family 4 delineates the new features and performance enhancements enabled by the A11 chip and its Apple-designed graphics processing unit (GPU) architecture.
>
> The GPUs in iOS and tvOS devices implement a rendering technique called tile-based deferred rendering (TBDR) to optimize performance and power efficiency. In a traditional immediate-mode (IM) renderer, when a triangle is submitted to the GPU for processing, it's immediately rendered to device memory. The triangles are processed by the rasterization and fragment function stages even if they're occluded by other primitives submitted to the GPU later.

## Tile-Based Deferred Rendering

> TBDR makes some significant changes to the IM architecture, processing the scene after all of the primitives have been submitted. The screen is split into tiles that are processed separately. All geometry that intersects a tile is processed simultaneously, and occluded fragments are discarded before the rasterization and fragment shading stages. A tile is rendered into fast local memory on the GPU and is written out to device memory only after rendering completes.
>
> TBDR allows the vertex and fragment stages to run asynchronously—providing significant performance improvements over IM. While running the fragment stage of a render pass, the hardware executes the vertex stage of a future render pass in parallel. The vertex stage usually makes heavy use of fixed function hardware, whereas the fragment stage uses math and bandwidth. Completely overlapping them allows the device to use all the hardware blocks on the GPU simultaneously.
>
> There are three important characteristics of the tile memory used by TBDR. First, the bandwidth between the shader core and tile memory is many times higher than the bandwidth between the GPU and device memory, and scales proportionally with the number of shader cores. Second, the memory access latency to tile memory is many times lower than the latency for accesses to device memory. Finally, tile memory consumes significantly less power than device memory.
>
> On A7- through A10-based devices, Metal doesn't explicitly describe this tile-based architecture; instead, you use it to provide hints to the underlying implementation. For example, load and store actions control which data is loaded into local memory and which data is written out to device memory. Similarly, memoryless buffers specify per-pixel intermediate data used only during the render pass; in practice, this data is stored in a tile in the GPU’s fast local memory.

## Metal 2 on the A11 GPU

> The Apple-designed GPU in the A11 delivers several features that significantly enhance TBDR. These features are provided via additional Metal 2 APIs and allow your apps and games to realize new levels of performance and capability.
>
> The features include imageblocks, tile shading, raster order groups, and imageblock sample coverage control. Metal 2 on the A11 GPU also improves fragment discard performance.
>
> Broadly speaking, these features offer greater control over memory layout and access for data stored in the tile, and provide finer-grained synchronization to keep more work on the GPU. The end result is that you can perform a wider variety of calculations in a single rendering pass than you could previously, keeping the calculations in fast local memory.
>
> Metal 2 on A11 also simplifies the implementation of techniques such as subsurface scattering, order-independent transparency, and tile-based lighting algorithms.

## Topics

### GPU Family 4 Features

[About Imageblocks](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/About%20Imageblocks.md)

Learn how imageblocks allow you to define and manipulate custom per-pixel data structures in high-bandwidth tile memory.

了解 imageblocks 如何允许你在高带宽磁贴内存中定义和操作自定义每像素数据结构。

[About Tile Shading](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/About%20Tile%20Shading.md)

Learn about combining rendering and compute operations into a single render pass while sharing local memory.

了解在共享本地内存时将渲染和计算操作组合到单个渲染过程中。

[About Raster Order Groups](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/About%20Raster%20Order%20Groups.md)

Learn about precisely controlling the order of parallel fragment shader threads accessing the same pixel coordinates.

了解精确控制访问相同像素坐标的并行片段着色器线程的顺序。

[About Enhanced MSAA and Imageblock Sample Coverage Control](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/About%20Enhanced%20MSAA%20and%20Imageblock%20Sample%20Coverage%20Control.md)

Learn about accessing multisample tracking data within a tile shader, enabling development of custom MSAA resolve algorithms, and more.

了解如何在切片着色器中访问多重采样跟踪数据，启用自定义MSAA解析算法的开发等。
