#  About Imageblocks

> Learn how imageblocks allow you to define and manipulate custom per-pixel data structures in high-bandwidth tile memory.

了解 imageblocks 如何允许你在高带宽 tile 内存中定义和操作自定义每像素数据结构。

## Overview

> Imageblocks are tiles of structured image data stored in local memory that allow you to describe image data in tile memory that the A11 graphics processing unit (GPU) can manipulate efficiently. They’re deeply integrated with fragment processing and the A11’s tile shading stage, and are also available to compute kernels. Metal has always rendered to imageblocks on iOS devices, but Metal 2 on A11 expands on this functionality by exposing imageblocks as data structures that you have complete control over.

Imageblocks 是存储在本地存储器中的结构化图像数据的 titles ，允许你描述 A11 图形处理单元（ GPU ）可以高效操作的 tile 存储中的图像数据。它们与片段处理和 A11 的 tile 着色阶段深度集成，也可用于计算内核。iOS 设备上，Metal 总是渲染到 imageblocks 中，但 A11 上的 Metal 2 通过将 Imageblocks 暴露为你可以完全控制的数据结构来扩展此功能。

## Imageblocks for Passing Data Between Fragment and Tile Stages

> Figure 1 shows the A11 GPU architecture and how an imageblock can pass data between the fragment and tile stages of a render pass. Although threadgroup memory is suitable for unstructured data, an imageblock is recommended for image data.
>
> Figure 1 The A11 GPU architecture

图 1 显示了 A11 GPU 架构以及 imageblock 如何在渲染通道的片段和 tile 阶段之间传递数据。虽然线程组内存适用于非结构化数据，但对于图像数据建议使用 imageblock 。
>
>图1 A11 GPU架构

![TheA11GPUArchitecture](../../resource/Metal/Markdown/TheA11GPUArchitecture.png)

## Imageblock Structure

> An imageblock is a 2D data structure with width, height, and pixel depth. Each pixel in an imageblock can consist of multiple components, and each component can be addressed as its own image slice. Figure 2 shows an imageblock composed of three image slices representing albedo, specular, and normal components.
>
> Figure 2 An imageblock composed of three image slices

imageblock 是具有宽度，高度和像素深度的 2D 数据结构。imageblock 中的每个像素可以由多个组件组成，并且每个组件可以作为其自己的图像切片来寻址。图 2 显示了由三个图像切片组成的 imageblock ，这三个图像切片代表反照率，镜面反射和法线分量。

图 2 由三个图像切片组成的图像块

![AnImageblockComposedOfThreeImageSlices](../../resource/Metal/Markdown/AnImageblockComposedOfThreeImageSlices.png)

> Imageblocks are available to both kernel and fragment functions and persist for the lifetime of a tile, across draws and dispatches. Imageblock persistence means that you can mix render and compute operations in a single rendering pass, with both accessing the same local memory. By keeping multiple operations within a tile, you can create sophisticated algorithms that remain in local GPU memory.
>
> Your existing code automatically creates imageblocks that match your render attachment formats. However, you can also define your own imageblocks completely within your shader. Imageblocks that you define can be far more sophisticated than those created by render attachments; for example, they can include additional channels, arrays, and nested structures. Furthermore, imageblocks you define can be reused for different purposes across different phases of your computation.
>
> Within a fragment shader, the current fragment only has access to the imageblock data associated with that fragment’s position in the tile. In a compute function, a thread can access all of the imageblock data. When using rendering with attachments, load and store actions continue as the means by which slices of data are read into and written from tile memory. However, if you’re using explicit imageblocks, you use compute functions to explicitly read from and write to device memory. Writes can often be performed as block transfers, taking advantage of memory hardware.

