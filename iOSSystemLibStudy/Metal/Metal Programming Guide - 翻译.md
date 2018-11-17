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



























