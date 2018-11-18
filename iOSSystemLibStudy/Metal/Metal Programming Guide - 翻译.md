#  Metal Programming Guide - Metal 编程指引

翻译自英文完整版 https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221?language=objc

## About Metal and This Guide - Metal 与本指引概述

> The Metal framework supports GPU-accelerated advanced 3D graphics rendering and data-parallel computation workloads. Metal provides a modern and streamlined API for fine-grained, low-level control of the organization, processing, and submission of graphics and computation commands, as well as the management of the associated data and resources for these commands. A primary goal of Metal is to minimize the CPU overhead incurred by executing GPU workloads.

Metal 框架支持 GPU 加速的高级 3D 图形渲染与数据并行计算工作。Metal 提供了一个现代化的精简 API ，这些 API 用于组织、处理、提交图形及计算命令细粒度、底层的控制，以及这些命令的相关数据及资源的管理。Metal 的主要目标是最小化由于执行 GPU 工作所带来的 CPU 开销。

### At a Glance - 摘要

> This document describes the fundamental concepts of Metal: the command submission model, the memory management model, and the use of independently compiled code for graphics shader and data-parallel computation functions. The document then details how to use the Metal API to write an app.
>
> You can find more details in the following chapters:
>
> - [Fundamental Metal Concepts](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Device/Device.html#//apple_ref/doc/uid/TP40014221-CH2-SW1) briefly describes the main features of Metal.
> - [Command Organization and Execution Model](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW1) explains how to create and submit commands to the GPU for execution.
> - [Resource Objects: Buffers and Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW1) discusses the management of device memory, including buffer and texture objects that represent GPU memory allocations.
> - [Functions and Libraries](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Prog-Func/Prog-Func.html#//apple_ref/doc/uid/TP40014221-CH5-SW1) describes how Metal shading language code can be represented in a Metal app, and how Metal shading language code is loaded onto and executed by the GPU.
> - [Graphics Rendering: Render Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW1) describes how to render 3D graphics, including how to distribute graphics operations across multiple threads.
> - [Data-Parallel Compute Processing: Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW1) explains how to perform data-parallel processing.
> - [Buffer and Texture Operations: Blit Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Blit-Ctx/Blit-Ctx.html#//apple_ref/doc/uid/TP40014221-CH9-SW3) describes how to copy data between textures and buffers.
> - [Metal Tools](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Dev-Technique/Dev-Technique.html#//apple_ref/doc/uid/TP40014221-CH8-SW1) lists the tools available to help you customize and improve your development workflow.
> - [Metal Feature Set Tables](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/MetalFeatureSetTables/MetalFeatureSetTables.html#//apple_ref/doc/uid/TP40014221-CH13-SW1) lists the feature availability, implementation limits, and pixel format capabilities of each Metal feature set.
> - [What's New in iOS 9 and OS X 10.1](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/WhatsNewiniOS9andOSX1011/WhatsNewiniOS9andOSX1011.html#//apple_ref/doc/uid/TP40014221-CH12-SW11)1 summarizes the new features introduced in iOS 9 and OS X 10.11.
> - [What’s New in iOS 10, tvOS 10, and OS X 10.12](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/WhatsNewiniOS10tvOS10andOSX1012/WhatsNewiniOS10tvOS10andOSX1012.html#//apple_ref/doc/uid/TP40014221-CH14-SW1) summarizes the new features introduced in iOS 10, tvOS 10, and OS X 10.12.
> - [Tessellation](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Tessellation/Tessellation.html#//apple_ref/doc/uid/TP40014221-CH15-SW1) describes the Metal tessellation pipeline used to tessellate a patch, including the use of a compute kernel, tessellator, and post-tessellation vertex function.
> - [Resource Heaps](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/ResourceHeaps/ResourceHeaps.html#//apple_ref/doc/uid/TP40014221-CH16-SW1) describes how to sub-allocate resources from a heap, alias between them, and track them with a fence.

本文描述了 Metal 的基本概念：命令提交模型、内存管理模型、以及用于图形着色器和数据并行计算功能的独立编译代码的使用。然后，该文档详细说明了如何使用 Metal API 编写 app 。

你可以在以下章节中找到更多详细信息：

- [Fundamental Metal Concepts](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Device/Device.html#//apple_ref/doc/uid/TP40014221-CH2-SW1) 简要介绍了 Metal 的主要特征
- [Command Organization and Execution Model](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW1) 解释了如何创建命令并将其提交给 GPU 执行
- [Resource Objects: Buffers and Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW1) 讨论了设备内存的管理，包括表示 GPU 内存分配的缓冲区和纹理对象
- [Functions and Libraries](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Prog-Func/Prog-Func.html#//apple_ref/doc/uid/TP40014221-CH5-SW1) 描述了如何在 Metal 应用程序中表示 Metal 着色语言代码，以及如何将 Metal 着色语言代码加载到 GPU 上并执行它们
- [Graphics Rendering: Render Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW1) 描述了如何渲染 3D 图形，包括如何跨多个线程分布图形操作
- [Data-Parallel Compute Processing: Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW1) 解释了如何执行数据并行处理
- [Buffer and Texture Operations: Blit Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Blit-Ctx/Blit-Ctx.html#//apple_ref/doc/uid/TP40014221-CH9-SW3) 描述了如何在纹理与缓冲区之间拷贝数据
- [Metal Tools](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Dev-Technique/Dev-Technique.html#//apple_ref/doc/uid/TP40014221-CH8-SW1) 列出可用于帮助你自定义以及改进开发工作流程的工具
- [Metal Feature Set Tables](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/MetalFeatureSetTables/MetalFeatureSetTables.html#//apple_ref/doc/uid/TP40014221-CH13-SW1) 列出了每个 Metal 功能集的功能可用性、实现限制及像素格式能力
- [What's New in iOS 9 and OS X 10.1](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/WhatsNewiniOS9andOSX1011/WhatsNewiniOS9andOSX1011.html#//apple_ref/doc/uid/TP40014221-CH12-SW11) 总结了 iOS 9 和 OS X 10.11 中引入的新功能
- [What’s New in iOS 10, tvOS 10, and OS X 10.12](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/WhatsNewiniOS10tvOS10andOSX1012/WhatsNewiniOS10tvOS10andOSX1012.html#//apple_ref/doc/uid/TP40014221-CH14-SW1) 总结了 iOS 10 和 OS X 10.12 中引入的新功能
- [Tessellation](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Tessellation/Tessellation.html#//apple_ref/doc/uid/TP40014221-CH15-SW1) 描述了用于细分补丁的 Metal 细分管线，包括计算内核、曲面戏份及后细分顶点函数的使用
- [Resource Heaps](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/ResourceHeaps/ResourceHeaps.html#//apple_ref/doc/uid/TP40014221-CH16-SW1) 介绍了如何从堆中分配资源，在它们之间使用别名，并使用 fence 跟踪它们

### Prerequisites - 预备知识

> You should be familiar with the Objective-C language and experienced in programming with OpenGL, OpenCL, or similar APIs.

你应该熟悉 Objective-C 语言，并且熟悉使用 OpenGL、OpenAL 或类似 API 编程。

### See Also - 参考

> The [Metal Framework Reference](https://developer.apple.com/documentation/metal) is a collection of documents that describes the interfaces in the Metal framework.
>
> The [Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf) is a document that specifies the Metal shading language, which is used to write a graphics shader or a compute function that is used by a Metal app.
>
> In addition, several sample code projects using Metal are available in the Apple Developer Library.

[Metal Framework Reference](https://developer.apple.com/documentation/metal) 是描述 Metal 接口的文档集合。

[Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf) 是一个 Metal 着色语言的规范文档，使用 Metal 着色语言编写 Metal 应用程序中使用的图形着色器或者计算函数。

此外，Apple Developer Library 中提供了几个使用 Metal 的示例代码程序。

## Fundamental Metal Concepts - Metal 基本概念

> Metal provides a single, unified programming interface and language for both graphics and data-parallel computation workloads. Metal enables you to integrate graphics and computation tasks much more efficiently without needing to use separate APIs and shader languages.
>
> The Metal framework provides the following:
>
> Low-overhead interface. Metal is designed to eliminate “hidden” performance bottlenecks such as implicit state validation. You get control over the asynchronous behavior of the GPU for efficient multithreading used to create and commit command buffers in parallel.
>For details on Metal command submission, see [Command Organization and Execution Model](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW1).
>
> Memory and resource management. The Metal framework describes buffer and texture objects that represent allocations of GPU memory. Texture objects have specific pixel formats and may be used for texture images or attachments.
> For details on Metal memory objects, see [Resource Objects: Buffers and Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW1).
>
> Integrated support for both graphics and compute operations. Metal uses the same data structures and resources (such as buffers, textures, and command queues) for both graphics and compute operations. In addition, the Metal shading language supports both graphics and compute functions. The Metal framework enables resources to be shared between the runtime interface, graphics shaders, and compute functions.
> For details on writing apps that use Metal for graphics rendering or data-parallel compute operations, see [Graphics Rendering: Render Command Encoder or Data-Parallel Compute Processing: Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW1).
>
> Precompiled shaders. Metal shaders can be compiled at build time along with your app code and then loaded at runtime. This workflow provides better code generation as well as easier debugging of shader code. (Metal also supports runtime compilation of shader code.)
> For details on working with Metal shaders from your Metal framework code, see [Functions and Libraries](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Prog-Func/Prog-Func.html#//apple_ref/doc/uid/TP40014221-CH5-SW1). For details on the Metal shading language itself, see Metal Shading Language Guide.
>
> A Metal app cannot execute Metal commands in the background, and a Metal app that attempts this is terminated.

Metal 为图形及数据并行计算提供了单一、统一的编程接口和语言。Metal 使你能够更有效地集成图形与计算任务，而无需使用单独的 API 和着色语言。

Metal 提供以下内容：

- 低开销接口。Metal 旨在消除“隐藏”的性能瓶颈，例如隐式状态验证。你可以控制 GPU 的异步行为，以使用高效的多线程模式并行地创建和提交命令缓冲区。
有关 Metal 命令提交的详细信息，参阅 [Command Organization and Execution Model](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW1)。

- 内存和资源管理。Metal 框架描述了表示 GPU 内存分配的缓冲区和纹理对象。纹理对象具有特定的像素格式，可用于纹理图像或附件。
有关 Metal 内存对象的详细信息，参阅 [Resource Objects: Buffers and Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW1)。

- 对图形和计算操作的集成支持。Metal 为图形及计算操作使用相同的数据操作和资源（如缓冲区、纹理和命令队列）。此外，Metal 着色语言既支持图形又支持计算函数。Metal 允许在运行时接口、图形着色器和计算函数之间共享资源。
有关编写使用 Metal 进行图形渲染或数据并行计算操作的应用程序的详细信息，参阅 [Graphics Rendering: Render Command Encoder or Data-Parallel Compute Processing: Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW1)。

- 预编译的着色器。Metal 着色器可以与应用程序代码一起在构建阶段进行编译，然后在运行时加载。此工作流程提供了着色代码更好的代码生成及更简单的调试（ Metal 还支持着色器代码的运行时编译。）。
有关使用 Metal 框架代码中的 Metal 着色器的详细信息，参阅 [Functions and Libraries](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Prog-Func/Prog-Func.html#//apple_ref/doc/uid/TP40014221-CH5-SW1)。有关 Metal 着色语言本身的详细信息，参阅 Metal Shading Language Guide。

Metal 应用程序无法在后台执行 Metal 命令。并且尝试此操作的 Metal 应用程序将被终止。

## Command Organization and Execution Model - 命令组织及执行模型

> In the Metal architecture, the [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) protocol defines the interface that represents a single GPU. The MTLDevice protocol supports methods for interrogating device properties, for creating other device-specific objects such as buffers and textures, and for encoding and queueing render and compute commands to be submitted to the GPU for execution.
>
> A command queue consists of a queue of command buffers, and a command queue organizes the order of execution of those command buffers. A command buffer contains encoded commands that are intended for execution on a particular device. A command encoder appends rendering, computing, and blitting commands onto a command buffer, and those command buffers are eventually committed for execution on the device.

在 Metal 架构中， [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 协议定义了代表单个 GPU 的接口。MTLDevice 协议支持查询设备属性的方法，支持创建其他特定于设备对象（缓冲区或纹理）的方法，以及对渲染和计算命令进行编码以队列形式提交给 GPU 执行的方法。

命令队列由命令缓冲区队列组成，命令队列组织这些命令缓冲区的执行顺序。命令缓冲区包含用于在特定设备上执行的编码过的命令。命令编码器将渲染、计算和 blitting 命令附加到命令缓冲区，并且这些命令缓冲区最终被提交到设备上执行。

> The [MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue) protocol defines an interface for command queues, primarily supporting methods for creating command buffer objects. The [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) protocol defines an interface for command buffers and provides methods for creating command encoders, enqueueing command buffers for execution, checking status, and other operations. The MTLCommandBuffer protocol supports the following command encoder types, which are interfaces for encoding different kinds of GPU workloads into a command buffer:
>
> - The [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) protocol encodes graphics (3D) rendering commands for a single rendering pass.
> - The [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) protocol encodes data-parallel computation workloads.
> - The [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder) protocol encodes simple copy operations between buffers and textures, as well as utility operations like mipmap generation.

[MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue) 协议定义了命令队列的接口，主要支持创建命令缓冲区对象的方法。[MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) 协议定义了命令缓冲区的接口，并提供了创建命令编码器、enqueue 命令缓冲区以执行、状态检查和其他操作的方法。MTLCommandBuffer 协议支持以下命令编码器类型，这些接口用于将不同类型的 GPU 工作负载编码到命令缓冲区中：

- [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) 协议对单个渲染阶段的图形（3D）渲染命令进行编码。
- [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) 协议对数据并行计算工作负载进行编码。
- [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder) 协议对缓冲区和纹理之间的简单复制操作以及类似 mipmap 生成等的实用程序操作进行编码。

> At any point in time, only a single command encoder can be active and append commands into a command buffer. Each command encoder must be ended before another command encoder can be created for use with the same command buffer. The one exception to the “one active command encoder for each command buffer” rule is the [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder) protocol, discussed in [Encoding a Single Rendering Pass Using Multiple Threads](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW16).
>
> Once all encoding is completed, you commit the MTLCommandBuffer object itself, which marks the command buffer as ready for execution by the GPU. The MTLCommandQueue protocol controls when the commands in the committed MTLCommandBuffer object are executed, relative to other MTLCommandBuffer objects that are already in the command queue.
>
> Figure 2-1 shows how the command queue, command buffer, and command encoder objects are closely related. Each column of components at the top of the diagram (buffer, texture, sampler, depth and stencil state, pipeline state) represent resources and state that are specific to a particular command encoder.

在任何时间点，只有一个命令编码器可以处于激活状态，将命令附加到命令缓冲区中。对于同一个命令缓冲区，必须先结束每一个已经存在的命令编码器，然后才能创建另一个命令编码器。“每个命令缓冲区对应一个激活的命令编码器”规则的一个例外是  [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder)  协议，在 [Encoding a Single Rendering Pass Using Multiple Threads](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW16) 中讨论。

完成所有编码后，你将提交 MTLCommandBuffer 对象，此时该对象将命令缓冲区标记为可供 GPU 执行。相对于已在命令队列中的其他 MTLCommandBuffer 对象，MTLCommandQueue 协议控制何时执行提交的 MTLCommandBuffer 对象中的命令。

图 2 - 1显示了命令队列、命令缓冲区和命令编码器对象的关联。图顶部的每列组件（缓冲区、纹理、采样器、深度和模版状态、管线状态）表示特定于命令编码器的资源和状态。

![Metal Object Relationships](../../resource/Metal/Markdown/MetalObjectRelationships.png)

### The Device Object Represents a GPU - 代表 GPU 的设置对象

> A [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) object represents a GPU that can execute commands. The MTLDevice protocol has methods to create new command queues, to allocate buffers from memory, to create textures, and to make queries about the device’s capabilities. To obtain the preferred system device on the system, call the [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice) function.

[MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 对象表示一个可以执行命令的 GPU 。MTLDevice 协议具有创建新的命令队列、从内存分配缓冲区、创建纹理以及查询设备能力的方法。要获取系统的首选设备，调用 [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice) 函数。

### Transient and Non-transient Objects in Metal - Metal 中的持久与非持久对象

> Some objects in Metal are designed to be transient and extremely lightweight, while others are more expensive and can last for a long time, perhaps for the lifetime of the app.
>
> Command buffer and command encoder objects are transient and designed for a single use. They are very inexpensive to allocate and deallocate, so their creation methods return autoreleased objects.
>
> The following objects are not transient. Reuse these objects in performance sensitive code, and avoid creating them repeatedly.
>
> - Command queues
> - Data buffers
> - Textures
> - Sampler states
> - Libraries
> - Compute states
> - Render pipeline states
> - Depth/stencil states

Metal 中的一些对象被设计为非持久并且及其轻量的，而其他对象则更加昂贵并且持续很长时间，可能是应用程序的生命周期。

命令缓冲区和命令编码器被设计为非持久使用，仅供单次使用的对象。分配并且释放它们开销极小，所以它们的创建方法返回自动释放的对象。

以下对象不是瞬态的。在性能敏感的代码中重用这些对象，避免重复创建它们。

- 命令队列
- 数据缓冲区
- 纹理
- 采样器状态
- Libraries
- 计算状态
- 渲染管线状态
- 深度/模版状态

### Command Queue - 命令队列

> A command queue accepts an ordered list of command buffers that the GPU will execute. All command buffers sent to a single queue are guaranteed to execute in the order in which the command buffers were enqueued. In general, command queues are thread-safe and allow multiple active command buffers to be encoded simultaneously.
>
> To create a command queue, call either the [newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue) method or the [newCommandQueueWithMaxCommandBufferCount:](https://developer.apple.com/documentation/metal/mtldevice/1433433-makecommandqueue) method of a [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) object. In general, command queues are expected to be long-lived, so they should not be repeatedly created and destroyed.

命令队列容纳一个即将被 GPU 执行的命令缓冲区的有序队列。发送到单个队列的所有命令缓冲区可以保证按照其入队的顺序执行。通常，命令队列是线程安全的，允许同时编码多个激活的命令缓冲区。

调用 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 对象的 [newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue) 方法或者 [newCommandQueueWithMaxCommandBufferCount:](https://developer.apple.com/documentation/metal/mtldevice/1433433-makecommandqueue) 方法，以创建一个命令队列。通常，命令队列应该是长期存活的，因此不应该重复地创建和销毁它们。

### Command Buffer - 命令缓冲区

> A command buffer stores encoded commands until the buffer is committed for execution by the GPU. A single command buffer can contain many different kinds of encoded commands, depending on the number and type of encoders that are used to build it. In a typical app, an entire frame of rendering is encoded into a single command buffer, even if rendering that frame involves multiple rendering passes, compute processing functions, or blit operations.
>
> Command buffers are transient single-use objects and do not support reuse. Once a command buffer has been committed for execution, the only valid operations are to wait for the command buffer to be scheduled or completed—through synchronous calls or handler blocks discussed in [Registering Handler Blocks for Command Buffer Execution](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW20)—and to check the status of the command buffer execution.
>
> Command buffers also represent the only independently trackable unit of work by the app, and they define the coherency boundaries established by the Metal memory model, as detailed in [Resource Objects: Buffers and Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW1).

命令缓冲区存储编码过的命令，直到缓冲区被提交以供 GPU 执行。单个命令缓冲区可以包含许多不同类型的编码命令，具体取决于用于构建它的编码器的数量和类型。在典型的应用程序中，整个渲染帧被编码到单个命令缓冲区中，即使渲染该帧涉及多个渲染过程，多个计算处理函数或者多个 blit 操作。

命令缓冲区是瞬态一次性对象，不支持重用。一旦命令缓冲区被提交执行，唯一有效的操作是，通过在 [Registering Handler Blocks for Command Buffer Execution](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW20) 中讨论的同步调用或者处理程序块等待命令缓冲区被调度或执行完成，以及检查命令缓冲区的执行状态。

命令缓冲区也是应用程序唯一可独立跟踪的工作单元，它们定义了由 Metal memory 模型建立的一致性边界，详见 [Resource Objects: Buffers and Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW1)。

#### Creating a Command Buffer - 创建一个命令缓冲区

> To create a [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) object, call the commandBuffer method of [MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue). A MTLCommandBuffer object can only be committed into the MTLCommandQueue object that created it.
>
>Command buffers created by the commandBuffer method retain data that is needed for execution. For certain scenarios, where you hold a retain to these objects elsewhere for the duration of the execution of a MTLCommandBuffer object, you can instead create a command buffer by calling the commandBufferWithUnretainedReferences method of MTLCommandQueue. Use the commandBufferWithUnretainedReferences method only for extremely performance-critical apps that can guarantee that crucial objects have references elsewhere in the app until command buffer execution is completed. Otherwise, an object that no longer has other references may be prematurely released, and the results of the command buffer execution are undefined.

要创建 [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) 对象，调用 [MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue) 的 commandBuffer 方法。MTLCommandBuffer 对象只能提交到创建它的 MTLCommandQueue 对象中。

commandBuffer 方法创建的命令缓冲区会 ratain 执行所需要的数据。对于某些情况，如果在执行 MTLCommandBuffer 对象期间在其他地方 retain 这些对象，则可以通过调用 MTLCommandQueue 的 commandBufferWithUnretainedReferences 方法来创建命令缓冲区。仅对那些对性能极其敏感的应用程序使用 commandBufferWithUnretainedReferences 方法，这些应用程序必须保证在命令缓冲区执行完毕之前，关键对象不会被释放。否则，可能过早释放不再具有其他引用的对象，这样的话，命令缓冲区的执行结果是未定义的。

#### Executing Commands - 执行命令

> The MTLCommandBuffer protocol uses the following methods to establish the execution order of command buffers in the command queue. A command buffer does not begin execution until it is committed. Once committed, command buffers are executed in the order in which they were enqueued.
>
> - The [enqueue](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue) method reserves a place for the command buffer on the command queue, but does not commit the command buffer for execution. When this command buffer is eventually committed, it is executed after any previously enqueued command buffers within the associated command queue.
> - The [commit](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit) method causes the command buffer to be executed as soon as possible, but after any previously enqueued command buffers in the same command queue are committed. If the command buffer has not previously been enqueued, commit makes an implied enqueue call.
>
> For an example of using enqueue with multiple threads, see [Multiple Threads, Command Buffers, and Command Encoders](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW6).

MTLCommandBuffer 协议使用以下方法建立加入命令队列中的命令缓冲区的执行顺序。命令缓冲区在提交之前不会开始执行，一旦提交，命令缓冲区按照它们入队的顺序执行。

- [enqueue](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue) 方法为命令队列上的命令缓冲区保留一个位置，但并不提交命令缓冲区以供执行。当该缓冲区最终提交时，将在相关命令队列中任何先前入队的命令缓冲区执行之后被执行。
- [commit](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit) 方法会导致命令缓冲区尽快执行，但也是在同一个命令队列中的之前入队的命令缓冲区提交之后。如果先前没有将命令缓冲区入队，则 commit 会进行隐式的入队调用。

有关使用多线程入队的示例，参阅 [Multiple Threads, Command Buffers, and Command Encoders](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html#//apple_ref/doc/uid/TP40014221-CH3-SW6)。

#### Registering Handler Blocks for Command Buffer Execution - 为命令缓冲区的执行注册处理程序块

> The [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) methods listed below monitor command execution. Scheduled and completed handlers are invoked in execution order on an undefined thread. Any code you execute in these handlers should complete quickly; if expensive or blocking work needs to be done, defer that work to another thread.
>
> - The [addScheduledHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442991-addscheduledhandler) method registers a block of code to be called when the command buffer is scheduled. A command buffer is considered scheduled when any dependencies between work submitted by other MTLCommandBuffer objects or other APIs in the system is satisfied. You can register multiple scheduled handlers for a command buffer.
> - The [waitUntilScheduled](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443036-waituntilscheduled) method synchronously waits and returns after the command buffer is scheduled and all handlers registered by the addScheduledHandler: method are completed.
> - The [addCompletedHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler) method registers a block of code to be called immediately after the device completes the execution of the command buffer. You can register multiple completed handlers for a command buffer.
> - The [waitUntilCompleted](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443039-waituntilcompleted) method synchronously waits and returns after the device has completed the execution of the command buffer and all handlers registered by the [addCompletedHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler) method have returned.
> The [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) method is a special case of completed handler. This convenience method presents the contents of a displayable resource (a CAMetalDrawable object) when the command buffer is scheduled. For details about the presentDrawable: method, see [Integration with Core Animation: CAMetalLayer](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW36).

下面列出的 [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) 方法监控命令的执行。调度和完成的处理程序在未定义的线程上按执行顺序调用。你在这些处理程序中执行的任何代码都应该快速完成；如果需要进行开销较大或者阻塞的工作，将该工作推迟到另外的线程去处理。

- [addScheduledHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442991-addscheduledhandler) 方法注册一个代码块，当命令缓冲区被调度时，该代码块被执行。当满足其他 MTLCommandBuffer 对象或系统中的其他 API 提交的工作之间的任何依赖关系时，将考虑调度该命令缓冲区。你可以为一个命令缓冲区注册多个调度处理程序。
- [waitUntilScheduled](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443036-waituntilscheduled) 方法在命令缓冲区被调度之后及通过 addScheduledHandler: 注册的所有处理程序都执行完毕之后同步返回。
- [addCompletedHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler) 方法注册一个代码块，在设备完成命令缓冲区的执行之后，该代码块被立即执行。你可以为一个命令缓冲区注册多个完成处理程序。
- [waitUntilCompleted](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443039-waituntilcompleted) 方法在设置执行完命令缓冲区及通过  [addCompletedHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler) 注册的所有处理程序都返回之后同步返回。

[presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) 方法是完成处理程序的特例。这种便捷方法在调度命令缓冲区时呈现可显示资源（一个 CAMetalDrawable 对象）的内容。关于presentDrawable: 方法的详细信息，参阅 [Integration with Core Animation: CAMetalLayer](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW36)。

#### Monitoring Command Buffer Execution Status - 监控命令缓冲区执行状态

> The read-only [status](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status) property contains a MTLCommandBufferStatus enum value listed in [Command Buffer Status Codes](https://developer.apple.com/documentation/metal/mtlcommandbufferstatus) that reflects the current scheduling stage in the lifetime of this command buffer.
>
> If execution finishes successfully, the value of the read-only [error](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443040-error) property is nil. If execution fails, then status is set to MTLCommandBufferStatusError, and the error property may contain a value listed in [Command Buffer Error Codes](https://developer.apple.com/documentation/metal/mtlcommandbuffererror/code) that indicates the cause of the failure.

只读的 [status](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status) 属性包含一个 [Command Buffer Status Codes](https://developer.apple.com/documentation/metal/mtlcommandbufferstatus) 中列出的 MTLCommandBufferStatus 枚举值，该值反映了此命令缓冲区生命周期中的当前调度阶段。

如果执行成功完成，只读的 [error](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443040-error) 属性值为 nil 。如果执行失败，status 属性设置为 MTLCommandBufferStatusError ，error 属性可能包含一个[Command Buffer Error Codes](https://developer.apple.com/documentation/metal/mtlcommandbuffererror/code) 中列出的值，该值指示失败的原因。

### Command Encoder - 命令编码器

> A command encoder is a transient object that you use once to write commands and state into a single command buffer in a format that the GPU can execute. Many command encoder object methods append commands onto the command buffer. While a command encoder is active, it has the exclusive right to append commands for its command buffer. Once you finish encoding commands, call the [endEncoding](https://developer.apple.com/documentation/metal/mtlcommandencoder/1458038-endencoding) method. To write further commands, create a new command encoder.

命令编码器是一个瞬态对象，你可以使用该对象以 GPU 可以执行的格式将命令和状态写入单个命令缓冲区。许多命令编码器对象方法附加命令到命令缓冲区。当命令编码器处于激活状态时，它具有为其命令缓冲区附加命令的专有权。一旦完成命令的编码，调用 [endEncoding](https://developer.apple.com/documentation/metal/mtlcommandencoder/1458038-endencoding) 方法。今后再要写入命令的话，就再创建一个新的命令编码器。

#### Creating a Command Encoder Object - 创建一个命令编码器对象

> Because a command encoder appends commands into a specific command buffer, you create a command encoder by requesting one from the [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) object you want to use it with. Use the following MTLCommandBuffer methods to create command encoders of each type:
>
> - The [renderCommandEncoderWithDescriptor:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442999-rendercommandencoderwithdescript) method creates a [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) object for graphics rendering to an attachment in a [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor).
> - The [computeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443044-computecommandencoder) method creates a [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) object for data-parallel computations.
> - The [blitCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443001-blitcommandencoder) method creates a [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder) object for memory operations.
> - The [parallelRenderCommandEncoderWithDescriptor:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443009-parallelrendercommandencoderwith) method creates a [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder) object that enables several MTLRenderCommandEncoder objects to run on different threads while still rendering to an attachment that is specified in a shared [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor).

由于命令编码器将命令附加到特定命令缓冲区，因此通过从指定的命令缓冲区对象申请的方式来创建一个命令编码器。使用以下 MTLCommandBuffer 的方法创建每种类型的命令编码器：

- [renderCommandEncoderWithDescriptor:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442999-rendercommandencoderwithdescript) 方法创建一个用于渲染图像到 [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor) 中附件的 [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) 对象。
- [computeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443044-computecommandencoder) 方法创建一个用于数据并行计算的 [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) 对象。
- [blitCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443001-blitcommandencoder) 方法创建一个用于内存操作的 [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder) 对象。
- [parallelRenderCommandEncoderWithDescriptor:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443009-parallelrendercommandencoderwith) 方法创建一个 [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder) 对象，该对象使多个 MTLRenderCommandEncoder 对象能够在不同的线程上运行，同时渲染图像到指定的共享 [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor) 中的附件。

#### Render Command Encoder - 渲染命令编码器

> Graphics rendering can be described in terms of a rendering pass. A [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) object represents the rendering state and drawing commands associated with a single rendering pass. A MTLRenderCommandEncoder requires an associated [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor) (described in Creating a [Render Pass Descriptor](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW5)) that includes the color, depth, and stencil attachments that serve as destinations for rendering commands. The MTLRenderCommandEncoder has methods to:
>
> - Specify graphics resources, such as buffer and texture objects, that contain vertex, fragment, or texture image data
> - Specify a [MTLRenderPipelineState](https://developer.apple.com/documentation/metal/mtlrenderpipelinestate) object that contains compiled rendering state, including vertex and fragment shaders
> - Specify fixed-function state, including viewport, triangle fill mode, scissor rectangle, depth and stencil tests, and other values
Draw 3D primitives
> For detailed information about the MTLRenderCommandEncoder protocol, see [Graphics Rendering: Render Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW1).

可以根据渲染过程来描述图形渲染。[MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) 对象表示与单个渲染过程关联的渲染状态和绘制命令。一个 MTLRenderCommandEncoder 需要关联一个 [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor) ，其包含颜色、深度和模版附件，渲染命令的渲染结果即保存在该 MTLRenderPassDescriptor 对应的附件中。MTLRenderCommandEncoder 具有以下方法：

- 指定图形资源，比如包含顶点、片元或者纹理图像数据的缓冲区和纹理对象
- 指定 [MTLRenderPipelineState](https://developer.apple.com/documentation/metal/mtlrenderpipelinestate) 对象，其中包含已编译的渲染状态，包括顶点和片段着色器
- 指定固定功能状态，包括 viewport、三角形填充模式、裁剪区域、深度和模版测试和其他绘制 3D 图元的值

有关 MTLRenderCommandEncoder 协议的详细信息，参阅 [Graphics Rendering: Render Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW1)。

#### Compute Command Encoder - 计算命令编码器

> For data-parallel computing, the [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) protocol provides methods to encode commands in the command buffer that can specify the compute function and its arguments (for example, texture, buffer, and sampler state) and dispatch the compute function for execution. To create a compute command encoder object, use the [computeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443044-computecommandencoder) method of [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer). For detailed information about the MTLComputeCommandEncoder methods and properties, see [Data-Parallel Compute Processing: Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW1).

对于数据并行计算，[MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder)  协议提供了对命令缓冲区中的命令进行编码的方法，该命令缓冲区可以指定计算函数及其参数（例如，纹理、缓冲区和采样器状态）并调度计算函数以供执行。使用 [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) 的 [computeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443044-computecommandencoder) 方法创建一个计算命令编码器对象。关于 MTLComputeCommandEncoder 方法和属性的详细信息，参阅 [Data-Parallel Compute Processing: Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW1)。

#### Blit Command Encoder - Blit 命令编码器

> The [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder) protocol has methods that append commands for memory copy operations between buffers ([MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer)) and textures ([MTLTexture](https://developer.apple.com/documentation/metal/mtltexture)). The MTLBlitCommandEncoder protocol also provides methods to fill textures with a solid color and to generate mipmaps. To create a blit command encoder object, use the [blitCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443001-blitcommandencoder) method of MTLCommandBuffer. For detailed information about the MTLBlitCommandEncoder methods and properties, see [Buffer and Texture Operations: Blit Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Blit-Ctx/Blit-Ctx.html#//apple_ref/doc/uid/TP40014221-CH9-SW3).

[MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder) 协议具有为缓冲区（ [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) ）和纹理（ [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) ）之间的内存复制操作附加命令的方法。MTLBlitCommandEncoder 协议还提供了使用纯色填充纹理及生成 mipmaps 的方法。使用 MTLCommandBuffer 的 [blitCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443001-blitcommandencoder) 方法去创建一个 blit 命令编码器对象。关于 MTLBlitCommandEncoder 方法和属性的详细信息，参阅 [Buffer and Texture Operations: Blit Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Blit-Ctx/Blit-Ctx.html#//apple_ref/doc/uid/TP40014221-CH9-SW3) 。

#### Multiple Threads, Command Buffers, and Command Encoders - 多线程，命令缓冲区和命令编码器

> Most apps use a single thread to encode the rendering commands for a single frame in a single command buffer. At the end of each frame, you commit the command buffer, which both schedules and begins command execution.
>
> If you want to parallelize command buffer encoding, then you can create multiple command buffers at the same time, and encode to each one with a separate thread. If you know ahead of time in what order a command buffer should execute, then the [enqueue]((https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue)) method of [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) can declare the execution order within the command queue without needing to wait for the commands to be encoded and committed. Otherwise, when a command buffer is committed, it is assigned a place in the command queue after any previously enqueued command buffers.
>
> Only one CPU thread can access a command buffer at time. Multithreaded apps can use one thread per command buffer to create multiple command buffers in parallel.
>
> Figure 2-2 shows an example with three threads. Each thread has its own command buffer. For each thread, one command encoder at a time has access to its associated command buffer. Figure 2-2 also shows each command buffer receiving commands from different command encoders. When you finish encoding, call the [endEncoding](https://developer.apple.com/documentation/metal/mtlcommandencoder/1458038-endencoding) method of the command encoder, and a new command encoder object can then begin encoding commands to the command buffer.
>
> A [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder) object allows a single rendering pass to be broken up across multiple command encoders and assigned to separate threads. For more information about [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder), see [Encoding a Single Rendering Pass Using Multiple Threads](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW16).

大多数应用程序使用单个线程在单个命令缓冲区中为单个帧编码渲染命令。在每一帧的末尾，你提交命令缓冲区，引发命令的调度以及执行的开始。

如果要并行化命令缓冲区编码，则可以同时创建多个命令缓冲区，并使用单独的线程对每个命令缓冲区进行编码。如果事先知道命令缓冲区应该以什么顺序执行，那么 [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) 的 [enqueue]((https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443019-enqueue)) 方法可以在命令队列中声明执行顺序，而无需等待命令的编码和提交。否则，当提交命令缓冲区时，该命令缓冲区将被放置于先前入队的任何命令缓冲区之后的位置。

同一时刻只允许一个 CPU 线程访问一个命令缓冲区。多线程应用程序可以使用每个命令缓冲区一个线程的方式来并行创建多个命令缓冲区。

图 2-2 显示了一个包含三个线程的例子。每个线程都有自己的命令缓冲区。对于每个线程，同一时刻一个命令编码器访问其关联的命令缓冲区。图 2-2 还显示了每个命令缓冲区接收来自不同命令编码器的命令。完成编码后，调用命令编码器的 [endEncoding](https://developer.apple.com/documentation/metal/mtlcommandencoder/1458038-endencoding) 方法，然后新的命令编码器对象可以开始编码命令到命令缓冲区中。

![MetalCommandBuffersWithMultipleThreads](../../resource/Metal/Markdown/MetalCommandBuffersWithMultipleThreads.png)

[MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder) 对象允许单个渲染过程分解到多个命令编码器之间，其中每个命令编码器分配单独的线程。关于 [MTLParallelRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlparallelrendercommandencoder) 的更多信息，参阅 [Encoding a Single Rendering Pass Using Multiple Threads](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW16) 。

## Resource Objects: Buffers and Textures - 资源对象：缓冲区与纹理

> This chapter describes Metal resource objects ([MTLResource](https://developer.apple.com/documentation/metal/mtlresource)) for storing unformatted memory and formatted image data. There are two types of [MTLResource](https://developer.apple.com/documentation/metal/mtlresource) objects:
>
> - [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) represents an allocation of unformatted memory that can contain any type of data. Buffers are often used for vertex, shader, and compute state data.
> - [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) represents an allocation of formatted image data with a specified texture type and pixel format. Texture objects are used as source textures for vertex, fragment, or compute functions, as well as to store graphics rendering output (that is, as an attachment).
>
> [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) objects are also discussed in this chapter. Although samplers are not resources themselves, they are used when performing lookup calculations with a texture object.

本章介绍用于存储未格式化内存和格式化图像数据的 Metal 资源对象（ [MTLResource](https://developer.apple.com/documentation/metal/mtlresource) ）。有两种类型的 [MTLResource](https://developer.apple.com/documentation/metal/mtlresource) 对象：

- [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 表示可以包含任何类型数据的未格式化内存的分配。缓冲区通常用于顶点、着色器和计算状态数据。
- [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) 表示具有指定纹理类型和像素格式的格式化图像数据的分配。纹理对象用作顶点、片段或者计算函数的源纹理，以及用作存储图形渲染输出（即作为一个 attachment ）。

本章还讨论了 [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) 对象。虽然采样器本身不是资源，但在使用纹理对象执行查找计算时会使用它们。

### Buffers Are Typeless Allocations of Memory - 缓冲区是内存的弱类型分配

> A [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) object represents an allocation of memory that can contain any type of data.

[MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 对象表示可以包含任何类型数据的内存分配。

#### Creating a Buffer Object - 创建缓冲区对象

> The following [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) methods create and return a [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) object:
>
> - The [newBufferWithLength:options:](https://developer.apple.com/documentation/metal/mtldevice/1433375-newbufferwithlength) method creates a MTLBuffer object with a new storage allocation.
> - The [newBufferWithBytes:length:options:](https://developer.apple.com/documentation/metal/mtldevice/1433429-newbufferwithbytes) method creates a MTLBuffer object by copying data from existing storage (located at the CPU address pointer) into a new storage allocation.
> - The [newBufferWithBytesNoCopy:length:options:deallocator:](https://developer.apple.com/documentation/metal/mtldevice/1433382-makebuffer) method creates a MTLBuffer object with an existing storage allocation and does not allocate any new storage for this object.
> All buffer creation methods have the input value length to indicate the size of the storage allocation, in bytes. All the methods also accept a MTLResourceOptions object for options that can modify the behavior of the created buffer. If the value for options is 0, the default values are used for resource options.

以下 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 方法创建并返回 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 对象：

- [newBufferWithLength:options:](https://developer.apple.com/documentation/metal/mtldevice/1433375-newbufferwithlength) 创建具有新存储分配的 MTLBuffer 对象
- [newBufferWithBytes:length:options:](https://developer.apple.com/documentation/metal/mtldevice/1433429-newbufferwithbytes) 方法通过将数据从现有存储（ CPU 地址指针 ）复制到新的存储分配中来创建 MTLBuffer 对象
- [newBufferWithBytesNoCopy:length:options:deallocator:](https://developer.apple.com/documentation/metal/mtldevice/1433382-makebuffer) 方法以现有存储分配创建 MTLBuffer 对象，并且不为该对象分配任何新存储

所有缓冲区创建方法都有 length 的输入参数，以指示存储分配的大小（以字节为单位）。所有的方法同时也接受一个作为选项的 MTLResourceOptions 对象，该选项可以改变创建的缓冲区的行为。如果 option 值为 0 ，则使用默认值作为资源选项。

#### Buffer Methods - 缓冲区方法

> The [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) protocol has the following methods:
>
> - The [contents](https://developer.apple.com/documentation/metal/mtlbuffer/1515716-contents) method returns the CPU address of the buffer’s storage allocation.
> - The [newTextureWithDescriptor:offset:bytesPerRow:](https://developer.apple.com/documentation/metal/mtlbuffer/1613852-newtexturewithdescriptor) method creates a special kind of texture object that references the buffer's data. This method is detailed in [Creating a Texture Object](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW10).

[MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 协议具有如下方法：

- [contents](https://developer.apple.com/documentation/metal/mtlbuffer/1515716-contents) 方法返回缓冲区存储分配的 CPU 地址
- [newTextureWithDescriptor:offset:bytesPerRow:](https://developer.apple.com/documentation/metal/mtlbuffer/1613852-newtexturewithdescriptor) 方法创建一个引用该缓冲区数据的特定类型的纹理对象。关于该方法的详细介绍，见 [Creating a Texture Object](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW10) 。

### Textures Are Formatted Image Data - 纹理是格式化的图像数据

> A [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) object represents an allocation of formatted image data that can be used as a resource for a vertex shader, fragment shader, or compute function, or as an attachment to be used as a rendering destination. A MTLTexture object can have one of the following structures:
>
> - A 1D, 2D, or 3D image
> - An array of 1D or 2D images
> - A cube of six 2D images
> MTLPixelFormat specifies the organization of individual pixels in a MTLTexture object. Pixel formats are discussed further in [Pixel Formats for Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW12).

[MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象表示格式化图像数据的分配，可以将其用作顶点着色器、片段着色器或者计算函数的资源，或者作为 attachment 用作渲染的目标缓冲区。MTLTexture 对象可以具有如下结构之一：

- 1D、2D 或者 3D 图像
- 1D 或者 2D 图像的数组
- 六个 2D 图像的立方体

MTLPixelFormat 指定了 MTLTexture 对象中每个像素的组织形式。像素格式在 [Pixel Formats for Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW12) 中进一步讨论。

#### Creating a Texture Object - 创建纹理对象

> The following methods create and return a [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) object:
>
> - The [newTextureWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433425-maketexture) method of MTLDevice creates a MTLTexture object with a new storage allocation for the texture image data, using a [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor) object to describe the texture’s properties.
> - The [newTextureViewWithPixelFormat:](https://developer.apple.com/documentation/metal/mtltexture/1515598-newtextureviewwithpixelformat) method of MTLTexture creates a MTLTexture object that shares the same storage allocation as the calling MTLTexture object. Since they share the same storage, any changes to the pixels of the new texture object are reflected in the calling texture object, and vice versa. For the newly created texture, the [newTextureViewWithPixelFormat:](https://developer.apple.com/documentation/metal/mtltexture/1515598-newtextureviewwithpixelformat) method reinterprets the existing texture image data of the storage allocation of the calling MTLTexture object as if the data was stored in the specified pixel format. The MTLPixelFormat of the new texture object must be compatible with the MTLPixelFormat of the original texture object. (See [Pixel Formats for Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW12) for details about the ordinary, packed, and compressed pixel formats.)
> - The [newTextureWithDescriptor:offset:bytesPerRow:](https://developer.apple.com/documentation/metal/mtlbuffer/1613852-newtexturewithdescriptor) method of MTLBuffer creates a MTLTexture object that shares the storage allocation of the calling MTLBuffer object as its texture image data. As they share the same storage, any changes to the pixels of the new texture object are reflected in the calling texture object, and vice versa. Sharing storage between a texture and a buffer can prevent the use of certain texturing optimizations, such as pixel swizzling or tiling.

以下方法创建并返回 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象：

- MTLDevice 的 [newTextureWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433425-maketexture) 方法使用描述纹理属性的 [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor) 对象创建一个具有纹理图像数据的新存储分配的 MTLTexture 对象
- MTLTexture 的 [newTextureViewWithPixelFormat:](https://developer.apple.com/documentation/metal/mtltexture/1515598-newtextureviewwithpixelformat) 方法创建一个 MTLTexture 对象，该对象与调用 MTLTexture 对象共享存储分配。由于它们共享相同的存储空间，因此对新纹理对象像素的任何更改都会反映在调用方纹理对象上，反之亦然。对于新创建的纹理，[newTextureViewWithPixelFormat:](https://developer.apple.com/documentation/metal/mtltexture/1515598-newtextureviewwithpixelformat) 方法会重新解释调用方 MTLTexture 对象已经存在的纹理图像数据，就像数据是以指定的像素格式存储一样。新纹理对象的 MTLPixelFormat 必须与原纹理对象的 MTLPixelFormat 兼容（有关原始、压缩和压缩像素格式的详细信息，参阅 [Pixel Formats for Textures](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW12) ）。
- MTLBuffer 的[newTextureWithDescriptor:offset:bytesPerRow:](https://developer.apple.com/documentation/metal/mtlbuffer/1613852-newtexturewithdescriptor) 方法创建一个 MTLTexture 对象，该对象将 MTLBuffer 对象的数据作为纹理图像数据与 MTLBuffer 共享。由于它们共享相同的存储，新纹理对象像素的任何更改都会反应在调用方纹理对象中，反之亦然。在纹理和缓冲区之间共享存储可以防止特定纹理优化的使用，比如像素调整或平铺。

#### Creating a Texture Object with a Texture Descriptor - 使用纹理描述符创建纹理对象

> [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor) defines the properties that are used to create a [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) object, including its image size (width, height, and depth), pixel format, arrangement (array or cube type) and number of mipmaps. The MTLTextureDescriptor properties are only used during the creation of a MTLTexture object. After you create a MTLTexture object, property changes in its MTLTextureDescriptor object no longer have any effect on that texture.
>
> To create one or more textures from a descriptor:
>
> 1. Create a custom [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor) object that contains texture properties that describe the texture data:
> - The [textureType](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516228-texturetype) property specifies a texture’s dimensionality and arrangement (for example, array or cube).
> - The [width](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515649-width), [height](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516000-height), and [depth](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516298-depth) properties specify the pixel size in each dimension of the base level texture mipmap.
> - The [pixelFormat](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515450-pixelformat) property specifies how a pixel is stored in a texture.
> - The [arrayLength](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515331-arraylength) property specifies the number of array elements for a [MTLTextureType1DArray](https://developer.apple.com/documentation/metal/mtltexturetype/type1darray) or [MTLTextureType2DArray](https://developer.apple.com/documentation/metal/mtltexturetype/type2darray) type texture object.
> - The [mipmapLevelCount](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516300-mipmaplevelcount) property specifies the number of mipmap levels.
> - The [sampleCount](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516260-samplecount) property specifies the number of samples in each pixel.
> - The [resourceOptions](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515776-resourceoptions) property specifies the behavior of its memory allocation.
> 2. Create a texture from the MTLTextureDescriptor object by calling the [newTextureWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433425-maketexture) method of a MTLDevice object. After texture creation, call the [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion) method to load the texture image data, as detailed in [Copying Image Data to and from a Texture](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW17).
> 3. To create more MTLTexture objects, you can reuse the same MTLTextureDescriptor object, modifying the descriptor’s property values as needed.
>
> Listing 3-1 shows code for creating a texture descriptor txDesc and setting its properties for a 3D, 64x64x64 texture.
>
> Listing 3-1  Creating a Texture Object with a Custom Texture Descriptor

[MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor) 定义了用于创建 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象的属性，包括图像大小（宽度、高度和深度）、像素格式、排列（数组或多维数据集）和 mipmap 数。MTLTextureDescriptor 属性仅在创建 MTLTexture 对象期间使用。创建 MTLTexture 对象之后，其 MTLTextureDescriptor 对象上的属性更改不再对该纹理产生任何影响。

使用描述符创建一个或者多个：

- 1. 创建一个自定义 MTLTextureDescriptor 对象，其中包含描述纹理数据的纹理属性：
- [textureType](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516228-texturetype) 属性指定纹理维度和排列（数组或多维数据集）
- [width](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515649-width), [height](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516000-height) 和  [depth](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516298-depth) 属性指定基级纹理 mipmap 各个维度上的像素大小
- [pixelFormat](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515450-pixelformat) 属性指定像素在纹理中的存储方式
- [arrayLength](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515331-arraylength) 属性指定[MTLTextureType1DArray](https://developer.apple.com/documentation/metal/mtltexturetype/type1darray) 或者 [MTLTextureType2DArray](https://developer.apple.com/documentation/metal/mtltexturetype/type2darray) 类型纹理对象数组元素个数
- [mipmapLevelCount](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516300-mipmaplevelcount) 属性指定 mipmap 级别的数量
- [sampleCount](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516260-samplecount) 属性指定每个像素中的样本数
- [resourceOptions](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515776-resourceoptions) 属性指定其内存分配行为

- 2. 调用 MTLDevice 对象的 [newTextureWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433425-maketexture)  方法由 MTLTextureDescriptor 对象创建纹理。纹理创建完成之后，调用 [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion) 方法加载纹理图像数据，详见  [Copying Image Data to and from a Texture](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW17) 。
- 3. 要创建更多 MTLTexture 对象，可以重用相同的 MTLTextureDescriptor 对象，根据需要修改其属性值。

清单 3-1 创建纹理描述符 txDesc 并为 3D 尺寸为 64x64x64 的纹理设置属性的代码。

Listing 3-1  使用自定义的纹理描述符创建纹理对象

```objc
MTLTextureDescriptor* txDesc = [[MTLTextureDescriptor alloc] init];
txDesc.textureType = MTLTextureType3D;
txDesc.height = 64;
txDesc.width = 64;
txDesc.depth = 64;
txDesc.pixelFormat = MTLPixelFormatBGRA8Unorm;
txDesc.arrayLength = 1;
txDesc.mipmapLevelCount = 1;
id <MTLTexture> aTexture = [device newTextureWithDescriptor:txDesc];
```

#### Working with Texture Slices - 使用纹理切片

> A slice is a single 1D, 2D, or 3D texture image and all its associated mipmaps. For each slice:
>
> - The size of the base level mipmap is specified by the [width](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515649-width), [height](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516000-height), and [depth](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516298-depth) properties of the MTLTextureDescriptor object.
> - The scaled size of mipmap level i is specified by max(1, floor(width / 2i)) x max(1, floor(height / 2i)) x max(1, floor(depth / 2i)). The maximum mipmap level is the first mipmap level where the size 1 x 1 x 1 is achieved.
> - The number of mipmap levels in one slice can be determined by floor(log2(max(width, height, depth)))+1.
>
> All texture objects have at least one slice; cube and array texture types may have several slices. In the methods that write and read texture image data that are discussed in [Copying Image Data to and from a Texture](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW17), slice is a zero-based input value. For a 1D, 2D, or 3D texture, there is only one slice, so the value of slice must be 0. A cube texture has six total 2D slices, addressed from 0 to 5. For the 1DArray and 2DArray texture types, each array element represents one slice. For example, for a 2DArray texture type with arrayLength = 10, there are 10 total slices, addressed from 0 to 9. To choose a single 1D, 2D, or 3D image out of an overall texture structure, first select a slice, and then select a mipmap level within that slice.

切片是单个 1D、2D 或者 3D 纹理图像及其所有关联的 mipmaps 。对于每个切片：

- 基准级别 mipmap 大小由 MTLTextureDescriptor 对象的 [width](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515649-width), [height](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516000-height), 和 [depth](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516298-depth) 属性指定
- i 级 mipmap 的缩放尺寸由 max(1, floor(width / 2i)) x max(1, floor(height / 2i)) x max(1, floor(depth / 2i)) 指定。一级 mipmap 是最大的 mipmap 级别，缩放比例为 1 x 1 x 1 。
- 所有纹理对象至少由一个切片；立方体和数组纹理类型可能有多个切片。 [Copying Image Data to and from a Texture](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html#//apple_ref/doc/uid/TP40014221-CH4-SW17) 中讨论的读写纹理图像数据的方法中，切片是从零开始的输入值。对于 1D、2D 或者 3D 纹理，只有一个切片，因此切片的值必须为 0 。立方体纹理一共有六个 2D 切片，从 0 到 5 。对于 1DArray 和 2DArray 纹理类型，每个数组元素代表一个切片。例如，对于一个 arrayLength = 10 的 2DArray 纹理类型，总共有 10 个切片，从 0 到 9 。要从整体纹理结构中选取单个 1D、2D 或者 3D 图像，首先选取一个切片，然后在该切片中选取一个 mipmap 级别。

#### Creating a Texture Descriptor with Convenience Methods - 使用便捷方法创建纹理描述符

> For common 2D and cube textures, use the following convenience methods to create a MTLTextureDescriptor object with several of its property values automatically set:
>
> - The [texture2DDescriptorWithPixelFormat:width:height:mipmapped:](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515511-texture2ddescriptor) method creates a MTLTextureDescriptor object for a 2D texture. The width and height values define the dimensions of the 2D texture. The type property is automatically set to MTLTextureType2D, and depth and arrayLength are set to 1.
> - The [textureCubeDescriptorWithPixelFormat:size:mipmapped:](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516090-texturecubedescriptor) method creates a MTLTextureDescriptor object for a cube texture, where the type property is set to MTLTextureTypeCube, width and height are set to size, and depth and arrayLength are set to 1.
> Both MTLTextureDescriptor convenience methods accept an input value, pixelFormat, which defines the pixel format of the texture. Both methods also accept the input value mipmapped, which determines whether or not the texture image is mipmapped. (If mipmapped is YES, the texture is mipmapped.)
>
> Listing 3-2 uses the texture2DDescriptorWithPixelFormat:width:height:mipmapped: method to create a descriptor object for a 64x64 2D texture that is not mipmapped.

对于常见的 2D 和立方体纹理，使用以下便捷方法创建 MTLTextureDescriptor 对象，这些方法会自动设置其若干属性值：

- [texture2DDescriptorWithPixelFormat:width:height:mipmapped:](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1515511-texture2ddescriptor) 方法创建一个用于 2D 纹理的 MTLTextureDescriptor 对象。width 和 height 值定义了该 2D 纹理的尺寸。type 属性自动设置为 MTLTextureType2D ，depth 和 arrayLength 属性自动设置为 1 
-  [textureCubeDescriptorWithPixelFormat:size:mipmapped:](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516090-texturecubedescriptor) 方法创建用于立方体纹理的 MTLTextureDescriptor 对象，type 属性自动设置为 MTLTextureTypeCube ，width 和 height 属性自动设置为 size，depth 和 arrayLength 自动设置为 1 
- 两种 MTLTextureDescriptor 便捷方法都接收输入值 pixelFormat ，它定义纹理的像素格式。也都接收 mipmapped 输入值，它决定纹理图像是否为 mipmapped（若 mipmapped 为 YES ，纹理就是 mipmapped 的）。

清单 3-2 使用 texture2DDescriptorWithPixelFormat:width:height:mipmapped: 方法为非 mipmapped 的 64x64 2D 纹理创建描述符对象。

Listing 3-2  使用便捷纹理描述符创建纹理对象

```objc
MTLTextureDescriptor *texDesc = [MTLTextureDescriptor 
texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm 
width:64 height:64 mipmapped:NO];
id <MTLTexture> myTexture = [device newTextureWithDescriptor:texDesc];
```
#### Copying Image Data to and from a Texture - 复制图像数据到纹理/从纹理复制图像数据

> To synchronously copy image data into or copy data from the storage allocation of a MTLTexture object, use the following methods:
>
> - [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion) copies a region of pixel data from the caller's pointer into a portion of the storage allocation of a specified texture slice. [replaceRegion:mipmapLevel:withBytes:bytesPerRow:](https://developer.apple.com/documentation/metal/mtltexture/1515464-replaceregion) is a similar convenience method that copies a region of pixel data into the default slice, assuming default values for slice-related arguments (i.e., slice = 0 and bytesPerImage = 0).
> - [getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:](https://developer.apple.com/documentation/metal/mtltexture/1516318-getbytes) retrieves a region of pixel data from a specified texture slice. [getBytes:bytesPerRow:fromRegion:mipmapLevel:](https://developer.apple.com/documentation/metal/mtltexture/1515751-getbytes) is a similar convenience method that retrieves a region of pixel data from the default slice, assuming default values for slice-related arguments (slice = 0 and bytesPerImage = 0).
>
> Listing 3-3 shows how to call [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion) to specify a texture image from source data in system memory, textureData, at slice 0 and mipmap level 0.

同步地复制图像数据到 MTLTexture 对象的存储分配区或者同步地从 MTLTexture 对象的存储分配区读取图像数据，使用以下方法：

- [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion) 将来自调用者指针指向的像素数据的一个区域拷贝到指定的纹理切片的存储区。[replaceRegion:mipmapLevel:withBytes:bytesPerRow:](https://developer.apple.com/documentation/metal/mtltexture/1515464-replaceregion) 是类似的便捷方法，将像素数据拷贝到默认切片中，假设切片相关参数的默认值（如，slice = 0 且 bytesPerImage = 0）
- [getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:](https://developer.apple.com/documentation/metal/mtltexture/1516318-getbytes) 从指定的纹理切片中检索某片像素数据。[getBytes:bytesPerRow:fromRegion:mipmapLevel:](https://developer.apple.com/documentation/metal/mtltexture/1515751-getbytes) 是类似的便捷方法，从默认切片中检索像素数据，假设切片相关参数的默认值（如，slice = 0 and bytesPerImage = 0）

清单 3-3 显示了如何调用 [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion) 从系统内存中源数据 textureData 指定纹理图像。

Listing 3-3  拷贝图像数据到纹理

```objc
//  pixelSize is the size of one pixel, in bytes
//  width, height - number of pixels in each dimension
NSUInteger myRowBytes = width * pixelSize;
NSUInteger myImageBytes = rowBytes * height;
[tex replaceRegion:MTLRegionMake2D(0,0,width,height)
    mipmapLevel:0 slice:0 withBytes:textureData
    bytesPerRow:myRowBytes bytesPerImage:myImageBytes];
```

#### Pixel Formats for Textures - 纹理像素格式

> MTLPixelFormat specifies the organization of color, depth, and stencil data storage in individual pixels of a MTLTexture object. There are three varieties of pixel formats: ordinary, packed, and compressed.
>
> - Ordinary formats have only regular 8-, 16-, or 32-bit color components. Each component is arranged in increasing memory addresses with the first listed component at the lowest address. For example, [MTLPixelFormatRGBA8Unorm](https://developer.apple.com/documentation/metal/mtlpixelformat/mtlpixelformatrgba8unorm) is a 32-bit format with eight bits for each color component; the lowest addresses contains red, the next addresses contain green, and so on. In contrast, for [MTLPixelFormatBGRA8Unorm](https://developer.apple.com/documentation/metal/mtlpixelformat/bgra8unorm), the lowest addresses contains blue, the next addresses contain green, and so on.
> - Packed formats combine multiple components into one 16-bit or 32-bit value, where the components are stored from the least to most significant bit (LSB to MSB). For example, [MTLPixelFormatRGB10A2Uint](https://developer.apple.com/documentation/metal/mtlpixelformat/rgb10a2uint) is a 32-bit packed format that consists of three 10-bit channels (for R, G, and B) and two bits for alpha.
> - Compressed formats are arranged in blocks of pixels, and the layout of each block is specific to that pixel format. Compressed pixel formats can only be used for 2D, 2D Array, or cube texture types. Compressed formats cannot be used to create 1D, 2DMultisample or 3D textures.
>
>The [MTLPixelFormatGBGR422](https://developer.apple.com/documentation/metal/mtlpixelformat/gbgr422) and [MTLPixelFormatBGRG422](https://developer.apple.com/documentation/metal/mtlpixelformat/mtlpixelformatbgrg422) are special pixel formats that are intended to store pixels in the YUV color space. These formats are only supported for 2D textures (but neither 2D Array, nor cube type), without mipmaps, and an even width.
>
> Several pixel formats store color components with sRGB color space values (for example, [MTLPixelFormatRGBA8Unorm_sRGB](https://developer.apple.com/documentation/metal/mtlpixelformat/rgba8unorm_srgb) or [MTLPixelFormatETC2_RGB8_sRGB](https://developer.apple.com/documentation/metal/mtlpixelformat/mtlpixelformatetc2_rgb8_srgb)). When a sampling operation references a texture with an sRGB pixel format, the Metal implementation converts the sRGB color space components to a linear color space before the sampling operation takes place. The conversion from an sRGB component, S, to a linear component, L, is as follows:
>
> - If S <= 0.04045, L = S/12.92
> - If S > 0.04045, L = ((S+0.055)/1.055)2.4
>
> Conversely, when rendering to a color-renderable attachment that uses a texture with an sRGB pixel format, the implementation converts the linear color values to sRGB, as follows:
>
> - If L <= 0.0031308, S = L * 12.92
> - If L > 0.0031308, S = (1.055 * L0.41667) - 0.055
>
> For more information about pixel format for rendering, see [Creating a Render Pass Descriptor](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW5).

MTLPixelFormat 指定 MTLTexture 对象单个像素的颜色、深度、模版数组存储的组织方式。有三种像素格式：普通、打包和压缩。

- 普通格式只有常规的 8 位、16 位或 32 位颜色分量。各个通道以地址递增的顺序存储，首先列出的通道存储于最低地址处。例如，[MTLPixelFormatRGBA8Unorm](https://developer.apple.com/documentation/metal/mtlpixelformat/mtlpixelformatrgba8unorm) 是 32 位格式，每个颜色分量占 8 个位，最低地址存储红色分量，下一地址存储绿色分量，以此类推。相反，对于 [MTLPixelFormatBGRA8Unorm](https://developer.apple.com/documentation/metal/mtlpixelformat/bgra8unorm) ，最低地址存储蓝色分量，下一地址存储绿色分量，以此类推。
- 打包格式将多个分量组合成一个 16 位或者 32 位的值，各个分量存储于最低到最高有效位（LSB to MSB）。例如，[MTLPixelFormatRGB10A2Uint](https://developer.apple.com/documentation/metal/mtlpixelformat/rgb10a2uint) 是一个 32 位打包格式，由三个 10 位通道和 2 位 alpha 通道组成。
- 压缩格式以像素块排列，每个块的布局特定于该像素格式。压缩像素格式只能用于 2D、2D 数组或者立方体纹理类型。压缩格式不能用于创建 1D、2DMultisample 或者 3D 纹理。

[MTLPixelFormatGBGR422](https://developer.apple.com/documentation/metal/mtlpixelformat/gbgr422) 和 [MTLPixelFormatBGRG422](https://developer.apple.com/documentation/metal/mtlpixelformat/mtlpixelformatbgrg422) 是特殊的像素格式，用于存储 YUV 颜色空间中的像素。这些格式仅支持非 mipmap并且均匀宽度的 2D 纹理（不包括 2D 数组和立方体纹理）。

一些像素格式存储具有 sRGB 颜色空间值的颜色分量（例如 [MTLPixelFormatRGBA8Unorm_sRGB](https://developer.apple.com/documentation/metal/mtlpixelformat/rgba8unorm_srgb) 或者 [MTLPixelFormatETC2_RGB8_sRGB](https://developer.apple.com/documentation/metal/mtlpixelformat/mtlpixelformatetc2_rgb8_srgb)）。当采样操作引用具有 sRGB 像素格式的纹理时，Metal 实现会在采样操作发生之前将 sRGB 颜色空间分量转换为线型颜色空间。从 sRGB 分量 S 到线型分量 L 的转换如下：
- 如果 S <= 0.04045, L = S/12.92
- 如果 S > 0.04045, L = ((S+0.055)/1.055)2.4

相反，当渲染到使用 sRGB 像素格式纹理的颜色 attachment 时，Metal 实现将线型颜色值转换为 sRGB ，如下所示：
- 如果 L <= 0.0031308, S = L * 12.92
- 如果 L > 0.0031308, S = (1.055 * L0.41667) - 0.055

有关渲染相关像素格式的更多信息，参阅 [Creating a Render Pass Descriptor](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW5)。

### Creating a Sampler States Object for Texture Lookup - 创建用于纹理查找的采样器状态对象

> A [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) object defines the addressing, filtering, and other properties that are used when a graphics or compute function performs texture sampling operations on a MTLTexture object. A sampler descriptor defines the properties of a sampler state object. To create a sampler state object:
>
> - Call the [newSamplerStateWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433408-makesamplerstate) method of a [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) object to create a [MTLSamplerDescriptor](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor) object.
> - Set the desired values in the MTLSamplerDescriptor object, including filtering options, addressing modes, maximum anisotropy, and level-of-detail parameters.
> - Create a [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) object from the sampler descriptor by calling the [newSamplerStateWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433408-makesamplerstate) method of the MTLDevice object that created the descriptor.
>
> You can reuse the sampler descriptor object to create more MTLSamplerState objects, modifying the descriptor’s property values as needed. The descriptor's properties are only used during object creation. After a sampler state has been created, changing the properties in its descriptor no longer has an effect on that sampler state.
> 
> Listing 3-4 is a code example that creates a MTLSamplerDescriptor and configures it in order to create a [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate). Non-default values are set for filter and address mode properties of the descriptor object. Then the [newSamplerStateWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433408-makesamplerstate) method uses the sampler descriptor to create a sampler state object.

[MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) 对象定义了图像或计算函数对 MTLTexture 对象执行纹理采样操作时使用的寻址、过滤和其他属性。采样器描述符定义采样器状态对象的属性，要创建采样器状态对象：

- 调用 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 对象的 [newSamplerStateWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433408-makesamplerstate) 创建 MTLSamplerDescriptor 对象
- 为 MTLSamplerDescriptor 对象设置所需要的值，包括过滤选项、寻址模式、最大各向异性和详细级别参数
- 通过调用创建描述符的 MTLDevice 对象的 [newSamplerStateWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433408-makesamplerstate) 方法由采样器描述符创建 [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) 对象

你可以重用采样器描述符去创建更多 MTLSamplerState 对象，根据需要修改描述符的属性值。描述符的属性仅在对象创建期间使用。采样器状态对象创建之后，更改其描述符的属性不再对该采样器状态产生影响。

清单 3-4 的代码示例展示了创建 MTLSamplerDescriptor 并对其进行配置，然后创建 [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) 。为描述符对象的过滤器和地址模式设置非默认值。然后 [newSamplerStateWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433408-makesamplerstate) 方法使用采样器描述符创建采样器状态对象。

Listing 3-4  创建采样器状态对象

```objc
// create MTLSamplerDescriptor
MTLSamplerDescriptor *desc = [[MTLSamplerDescriptor alloc] init];
desc.minFilter = MTLSamplerMinMagFilterLinear;
desc.magFilter = MTLSamplerMinMagFilterLinear;
desc.sAddressMode = MTLSamplerAddressModeRepeat;
desc.tAddressMode = MTLSamplerAddressModeRepeat;
//  all properties below have default values
desc.mipFilter        = MTLSamplerMipFilterNotMipmapped;
desc.maxAnisotropy    = 1U;
desc.normalizedCoords = YES;
desc.lodMinClamp      = 0.0f;
desc.lodMaxClamp      = FLT_MAX;
// create MTLSamplerState
id <MTLSamplerState> sampler = [device newSamplerStateWithDescriptor:desc];
```

### Maintaining Coherency Between CPU and GPU Memory - 保持 CPU 内存和 GPU 内存之间的一致性

> Both the CPU and GPU can access the underlying storage for a [MTLResource](https://developer.apple.com/documentation/metal/mtlresource) object. However, the GPU operates asynchronously from the host CPU, so keep the following in mind when using the host CPU to access the storage for these resources.
>
> When executing a [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) object, the [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) object is only guaranteed to observe any changes made by the host CPU to the storage allocation of any MTLResource object referenced by that MTLCommandBuffer object if (and only if) those changes were made by the host CPU before the MTLCommandBuffer object was committed. That is, the MTLDevice object might not observe changes to the resource that the host CPU makes after the corresponding MTLCommandBuffer object was committed (i.e., the [status](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status) property of the MTLCommandBuffer object is [MTLCommandBufferStatusCommitted](https://developer.apple.com/documentation/metal/mtlcommandbufferstatus/mtlcommandbufferstatuscommitted)).
>
> Similarly, after the MTLDevice object executes a MTLCommandBuffer object, the host CPU is only guaranteed to observe any changes the MTLDevice object makes to the storage allocation of any resource referenced by that command buffer if the command buffer has completed execution (that is, the status property of the MTLCommandBuffer object is [MTLCommandBufferStatusCompleted](https://developer.apple.com/documentation/metal/mtlcommandbufferstatus/completed)).

CPU 和 GPU 都可以访问 [MTLResource](https://developer.apple.com/documentation/metal/mtlresource) 对象的底层存储。然而，GPU 与主机 CPU 操作是异步进行的，因此在使用主机 CPU 访问这些资源的存储时注意一下几点：

执行 [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer) 对象时，[MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 仅保证在该 MTLCommandBuffer 对象提交之前主机 CPU 对该 MTLCommandBuffer 对象引用的任何 MTLResource 对象存储所做的任何修改可以被观察到。也就是说，MTLDevice 对象可能观察不到 MTLCommandBuffer 提交之后主机 CPU 所做的资源修改（即，MTLCommandBuffer 对象的 [status](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status) 属性为 [MTLCommandBufferStatusCommitted](https://developer.apple.com/documentation/metal/mtlcommandbufferstatus/mtlcommandbufferstatuscommitted) ）。

类似的，在 MTLDevice 对象执行 MTLCommandBuffer 对象之后，如果命令缓冲区已经执行完成（即，MTLCommandBuffer 对象的 status 属性为 [MTLCommandBufferStatusCompleted](https://developer.apple.com/documentation/metal/mtlcommandbufferstatus/completed) ），则主机 CPU 仅保证观察到 MTLDevice 对象对该命令缓冲区引用的任何资源存储分配的更改。

## Functions and Libraries - 函数和库

> This chapter describes how to create a [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) object as a reference to a Metal shader or compute function and how to organize and access functions with a [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) object.

本章介绍如何创建作为 Metal 着色器或者计算函数引用的 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象以及如何使用 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) 对象组织和访问函数。

### MTLFunction Represents a Shader or Compute Function - MTLFunction 代表一个着色器或者计算函数

> A [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) object represents a single function that is written in the Metal shading language and executed on the GPU as part of a graphics or compute pipeline. For details on the Metal shading language, see the Metal Shading Language Guide.
>
> To pass data or state between the Metal runtime and a graphics or compute function written in the Metal shading language, you assign an argument index for textures, buffers, and samplers. The argument index identifies which texture, buffer, or sampler is being referenced by both the Metal runtime and Metal shading code.
>
> For a rendering pass, you specify a MTLFunction object for use as a vertex or fragment shader in a [MTLRenderPipelineDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpipelinedescriptor) object, as detailed in [Creating a Render Pipeline State](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW37). For a compute pass, you specify a MTLFunction object when creating a [MTLComputePipelineState](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate) object for a target device, as described in [Specify a Compute State and Resources for a Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW30).

[MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象表示使用 Metal shading language 编写并且作为图形或者计算管线一部分运行于 GPU 上的单个函数。关于 Metal shading language 的更多细节，参阅 Metal Shading Language Guide 。

要在 Metal 运行时和使用 Metal 着色语言编写的图形或计算函数之间传递数据或状态，可以为纹理、缓冲区和采样器分配参数索引。参数索引标识 Metal 运行时和 Metal 着色代码正在引用哪个纹理、缓冲区或采样器。

对于渲染过程，你可以指定 MTLFunction 对象作为 [MTLRenderPipelineDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpipelinedescriptor) 对象中的顶点或片段着色器，如 [Creating a Render Pipeline State](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW37) 中所述。对于计算过程，在为目标设备创建 [MTLComputePipelineState](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate) 对象时指定 MTLFunction 对象，如 [Specify a Compute State and Resources for a Compute Command Encoder](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Compute-Ctx/Compute-Ctx.html#//apple_ref/doc/uid/TP40014221-CH6-SW30) 中所述。

### A Library Is a Repository of Functions - Library 是函数的仓库

> A [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) object represents a repository of one or more [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) objects. A single MTLFunction object represents one Metal function that has been written with the shading language. In the Metal shading language source code, any function that uses a Metal function qualifier (vertex, fragment, or kernel) can be represented by a MTLFunction object in a library. A Metal function without one of these function qualifiers cannot be directly represented by a MTLFunction object, although it can called by another function within the shader.
>
> The MTLFunction objects in a library can be created from either of these sources:
>
> - Metal shading language code that was compiled into a binary library format during the app build process.
> - A text string containing Metal shading language source code that is compiled by the app at runtime.

[MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) 对象表示一个或多个 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象的存储库。单个 MTLFunction 对象表示使用着色语言编写的 Metal 函数。在 Metal 着色语言源代码中，任何使用 Metal 函数限定符（vertex、fragment 或 kernel ）的函数都可以由库中的 MTLFunction 对象表示。没有使用这些函数限定符的 Metal 函数不能由 MTLFunction 对象直接表示，尽管它可以被着色器中的其他函数调用。

可以从以下任一来源创建库中的 MTLFunction 对象：

- 应用程序构建过程中编译为二进制库格式的 Metal 着色语言代码
- 由应用程序在运行时进行编译的包含 Metal 着色语言源代码的文本字符串

#### Creating a Library from Compiled Code - 由已编译的代码创建库

> For the best performance, compile your Metal shading language source code into a library file during your app's build process in Xcode, which avoids the costs of compiling function source during the runtime of your app. To create a [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) object from a library binary, call one of the following methods of [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice):
>
> - [newDefaultLibrary](https://developer.apple.com/documentation/metal/mtldevice/1433380-newdefaultlibrary) retrieves a library built for the main bundle that contains all shader and compute functions in an app’s Xcode project.
> - [newLibraryWithFile:error:](https://developer.apple.com/documentation/metal/mtldevice/1433416-newlibrarywithfile) takes the path to a library file and returns a MTLLibrary object that contains all the functions stored in that library file.
> - [newLibraryWithData:error:](https://developer.apple.com/documentation/metal/mtldevice/1433391-makelibrary) takes a binary blob containing code for the functions in a library and returns a MTLLibrary object.

> For more information about compiling Metal shading language source code during the build process, see [Creating Libraries During the App Build Process](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Dev-Technique/Dev-Technique.html#//apple_ref/doc/uid/TP40014221-CH8-SW8).

为了获得最佳性能，在 Xcode 的应用程序构建过程中将 Metal 着色语言源代码编译到库文件中，这样可以避免在应用程序运行期间编译函数源的代价。要从库二进制文件创建 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) 对象，调用以下 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 方法之一：

- [newDefaultLibrary](https://developer.apple.com/documentation/metal/mtldevice/1433380-newdefaultlibrary) 检索为 main bundle 构建的库，该库包含应用程序 Xcode 项目中的所有着色器和计算函数。
- [newLibraryWithFile:error:](https://developer.apple.com/documentation/metal/mtldevice/1433416-newlibrarywithfile) 获取库文件的路径，返回包含存储在该库文件中所有函数的 MTLLibrary 对象。
- [newLibraryWithData:error:](https://developer.apple.com/documentation/metal/mtldevice/1433391-makelibrary) 获取包含库中函数代码的二进制 blob ，返回 MTLLibrary 对象。

关于构建过程中中编译 Metal 着色语言源代码的更多信息，参阅 [Creating Libraries During the App Build Process](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Dev-Technique/Dev-Technique.html#//apple_ref/doc/uid/TP40014221-CH8-SW8) 。

#### Creating a Library from Source Code - 由源代码创建库

> To create a [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) from a string of Metal shading language source code that may contain several functions, call one of the following methods of [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice). These methods compile the source code when the library is created. To specify the compiler options to use, set the properties in a [MTLCompileOptions](https://developer.apple.com/documentation/metal/mtlcompileoptions) object.
>
> - [newLibraryWithSource:options:error:](https://developer.apple.com/documentation/metal/mtldevice/1433431-newlibrarywithsource) synchronously compiles source code from the input string to create MTLFunction objects and then returns a MTLLibrary object that contains them.
> - [newLibraryWithSource:options:completionHandler:](https://developer.apple.com/documentation/metal/mtldevice/1433351-newlibrarywithsource) asynchronously compiles source code from the input string to create MTLFunction objects and then returns a MTLLibrary object that contains them. completionHandler is a block of code that is invoked when object creation is completed.

要从可能包含多个函数的 Metal 着色语言源代码的字符串创建 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) ，调用 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 的以下方法之一。这些方法在库被创建时编译源代码。设置 [MTLCompileOptions](https://developer.apple.com/documentation/metal/mtlcompileoptions) 对象中的属性，可以指定要使用的编译选项。

- [newLibraryWithSource:options:error:](https://developer.apple.com/documentation/metal/mtldevice/1433431-newlibrarywithsource) 从输入字符串同步地编译源代码以创建 MTLFunction 对象，然后返回包含它们的 MTLLibrary 对象。
- [newLibraryWithSource:options:completionHandler:](https://developer.apple.com/documentation/metal/mtldevice/1433351-newlibrarywithsource) 从输入字符串异步地编译源代码以创建 MTLFunction 对象，然后返回包含它们的 MTLLibrary 对象。completionHandler 是在完成对象创建时调用的代码块。

#### Getting a Function from a Library - 从库中获取函数

> The [newFunctionWithName:](https://developer.apple.com/documentation/metal/mtllibrary/1515524-newfunctionwithname) method of MTLLibrary returns a MTLFunction object with the requested name. If the name of a function that uses a Metal shading language function qualifier is not found in the library, then newFunctionWithName: returns nil.
>
> Listing 4-1 uses the [newLibraryWithFile:error:](https://developer.apple.com/documentation/metal/mtldevice/1433416-newlibrarywithfile) method of MTLDevice to locate a library file by its full path name and uses its contents to create a MTLLibrary object with one or more MTLFunction objects. Any errors from loading the file are returned in error. Then the newFunctionWithName: method of MTLLibrary creates a MTLFunction object that represents the function called my_func in the source code. The returned function object myFunc can now be used in an app.

MTLLibrary 的 [newFunctionWithName:](https://developer.apple.com/documentation/metal/mtllibrary/1515524-newfunctionwithname) 方法返回具有所请求名称的 MTLFunction 对象。如果在库中找不到使用 Metal 着色语言函数限定符的函数的名称，该函数返回 nil 。

清单 4-1 使用 MTLDevice 的方法 [newLibraryWithFile:error:](https://developer.apple.com/documentation/metal/mtldevice/1433416-newlibrarywithfile) 通过完整路径名定位库文件，并使用其内容创建包含一个或者多个 MTLFunction 对象的 MTLLibrary 对象。加载文件产生的任何错误返回到 error 参数中。然后 MTLLibrary 的 newFunctionWithName: 方法创建一个 MTLFunction 对象，该对象表示源代码中名为 my_func 的函数。返回的函数对象 myFunc 现在可以在应用程序中使用了。

Listing 4-1  访问来自库的函数

```objc
NSError *errors;
id <MTLLibrary> library = [device newLibraryWithFile:@"myarchive.metallib"
error:&errors];
id <MTLFunction> myFunc = [library newFunctionWithName:@"my_func"];
```

### Determining Function Details at Runtime - 运行时确定函数详细信息















































