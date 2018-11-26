#  Metal Best Practices Guide - Metal 最佳实践指南

英文原文 https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/index.html#//apple_ref/doc/uid/TP40016642?language=objc

## Metal Best Practices - Metal 最佳实践

### Fundamental Concepts - 基础概念

> Metal provides the lowest-overhead access to the GPU, enabling you to maximize the graphics and compute potential of your app on iOS, macOS, and tvOS. Every millisecond and every bit is integral to a Metal app and the user experience–it’s your responsibility to make sure your Metal app performs as efficiently as possible by following the best practices described in this guide. Unless otherwise stated, these best practices apply to all platforms that support Metal.
>
> An efficient Metal app requires:
>
> - Low CPU overhead. Metal is designed to reduce or eliminate many CPU-side performance bottlenecks. Your app can benefit from this design only if you use the Metal API as recommended.
> - Optimal GPU performance. Metal allows you to create and submit commands to the GPU. To optimize GPU performance, your app should optimize the configuration and organization of these commands.
> - Continuous processor parallelism. Metal is designed to maximize CPU and GPU parallelism. Your app should keep these processors busy and working simultaneously.
> - Effective resource management. Metal provides simple yet powerful interfaces to your resource objects. Your app should manage these resources effectively to reduce memory consumption and increase access speed.

Metal 提供对 GPU 的最低开销访问，使你能够在 iOS ，macOS 和 tvOS 上最大化应用程序的图形和计算潜力。每毫秒和每个 bit 位都是 Metal 应用程序及用户体验的组成部分 - 你有责任通过遵循本指南中描述的最佳实践来确保 Metal 应用程序尽可能高效地运行。除非另有说明，这些最佳实践使用于支持 Metal 的所有平台。

高效的 Metal 应用程序需要：

- ![LowCPUOverhead](../../resource/Metal/Markdown/LowCPUOverhead.png) 低 CPU 开销。Metal 旨在减少或消除许多 CPU 端的性能瓶颈。只要按照推荐使用 Metal API ，你的应用程序才能从此设计中受益。
- ![OptimalGPUPerformance](../../resource/Metal/Markdown/OptimalGPUPerformance.png) 最佳 GPU 性能。Metal 允许创建并提交命令到 GPU 。要优化 GPU 性能，你的应用程序需要优化这些命令的配置和组织。
- ![ContinuousProcessorParallelism](../../resource/Metal/Markdown/ContinuousProcessorParallelism.png) 连续的处理器并行。Metal 旨在最大化 CPU 和 GPU 并行性。你的应用程序应该让这些处理器保持忙碌并让它们同时工作。
- ![EffectiveResourceManagement](../../resource/Metal/Markdown/EffectiveResourceManagement.png) 有效的资源管理。Metal 为资源对象提供了简单且强大的接口。你的应用程序应该有效地管理这些资源，以减少内存消耗并提高访问速度。

## Resource Management - 资源管理

### Persistent Objects - 持久对象

> Best Practice: Create persistent objects early and reuse them often.
>
> The Metal framework provides protocols to manage persistent objects throughout the lifetime of your app. These objects are expensive to create but are usually initialized once and reused often. You do not need to create these objects at the beginning of every render or compute loop.

最佳实践：尽早创建持久对象并经常重用它们

Metal 框架提供了协议管理应用程序整个生命周期内持久对象的。这些对象的创建成本很高，但通常会初始化一次并经常重复使用。你不需要在每个渲染或者计算循环的开头创建这些对象。

#### Initialize Your Device and Command Queue First - 首先初始化设备和命令队列

> Call the [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice) function at the start of your app to obtain the default system device. Next, call the [newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue) or [newCommandQueueWithMaxCommandBufferCount:](https://developer.apple.com/documentation/metal/mtldevice/1433433-makecommandqueue) method to create a command queue for executing GPU instructions on that device.
>
> All apps should create only one [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) object per GPU and reuse it for all your Metal work on that GPU. Most apps should create only one [MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue) object per GPU, though you may want more if each command queue represents different Metal work (for example, non-real-time compute processing and real-time graphics rendering).
>
> NOTE - Some macOS devices feature multiple GPUs. If you need to work with multiple GPUs, call the [MTLCopyAllDevices](https://developer.apple.com/documentation/metal/1433367-mtlcopyalldevices) function to obtain an array of available devices. Create and retain at least one command queue for each GPU you use.

在应用程序启动时调用 [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice) 函数获取默认系统设备。接下来，调用 [newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue) 或 [newCommandQueueWithMaxCommandBufferCount:](https://developer.apple.com/documentation/metal/mtldevice/1433433-makecommandqueue) 方法创建用于在该设备上执行 GPU 指令的命令队列。

所有应用程序应该为每个 GPU 只创建一个 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice) 对象。大多数应用程序应该为每个 GPU 只创建一个 [MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue) 对象，但如果每个命令队列代表不同的 Metal 工作（例如，非实时计算处理和实时图形渲染），你可能需要多个该对象。

注意 - 一些 macOS 设置具有多个 GPU 。如果你需要使用多个 GPU ，调用 [MTLCopyAllDevices](https://developer.apple.com/documentation/metal/1433367-mtlcopyalldevices) 函数获取可用设备的数组。为使用的每个 GPU 至少创建并保留一个命令队列。

#### Compile Your Functions and Build Your Library at Build Time - 在构建时编译函数并构建库

> For an overview of compiling your functions and building your library at build time, see the [Functions and Libraries](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/FunctionsandLibraries.html#//apple_ref/doc/uid/TP40016642-CH24-SW1) best practices.
>
> At runtime, use the [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) and [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) objects to access your library of graphics and compute functions. Avoid building your library at runtime or fetching functions during a render or compute loop.
>
> If you need to configure multiple render or compute pipelines, reuse [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) objects whenever possible. You can release [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) and [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) objects after building all render and compute pipelines that depend on them.

有关在构建时编译函数并构建库的概述，参见 [Functions and Libraries](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/FunctionsandLibraries.html#//apple_ref/doc/uid/TP40016642-CH24-SW1) 最佳实践。

运行时，使用 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) 和 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象访问图形和计算函数库。避免在运行时构建库，避免在渲染或计算循环期间获取函数。

如果你需要配置多个渲染或计算管线，尽可能重用 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象。在所有依赖它们的渲染和计算管线都构建好之后，你就可以释放 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary) 和 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction) 对象了。

#### Build Your Pipelines Once and Reuse Them Often - 一次构建管线并经常重用它们

> Building a programmable pipeline involves an expensive evaluation of GPU state. You should build [MTLRenderPipelineState](https://developer.apple.com/documentation/metal/mtlrenderpipelinestate) and [MTLComputePipelineState](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate) objects only once, then reuse them for every new render or compute command encoder you create. Do not build new pipelines for new command encoders. For an overview of building multiple pipelines asynchronously, see the [Pipelines](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Pipelines.html#//apple_ref/doc/uid/TP40016642-CH25-SW2) best practices.
>
> NOTE - In addition to render and compute pipelines, you may optionally create [MTLDepthStencilState](https://developer.apple.com/documentation/metal/mtldepthstencilstate) and [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) objects that encapsulate depth, stencil, and sampler state. These objects are less expensive but should also be created only once and reused often.

构建可编程管线涉及对 GPU 状态的昂贵评估。你应该只构建一次 [MTLRenderPipelineState](https://developer.apple.com/documentation/metal/mtlrenderpipelinestate) 和 [MTLComputePipelineState](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate) 对象，然后为每一个新创建的渲染或计算命令编码器重用它们。不要为新的命令编码器构建新的管线。有关异步构建多个管线的概述，见 [Pipelines](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Pipelines.html#//apple_ref/doc/uid/TP40016642-CH25-SW2) 最佳实践。

注意 - 除了渲染和计算管线之外，你还可以选择性地创建 [MTLDepthStencilState](https://developer.apple.com/documentation/metal/mtldepthstencilstate) 和 [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate) 对象，这些对象封装了深度，模板和采样器状态。这些对象的创建成本相对来说小很多，但也应仅创建一次并经常重复使用它们。

#### Allocate Resource Storage Up Front - 预先分配资源存储

> Resource data may be static or dynamic and accessed at various stages throughout the lifetime of your app. However, the [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) and [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) objects that allocate memory for this data should be created as early as possible. After these objects are created, the resource properties and storage allocation are immutable, but the data itself is not; you can update the data whenever necessary.
>
> Reuse [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) and [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) objects as much as possible, particularly for static data. Avoid creating new resources during a render or compute loop, even for dynamic data. For further information about buffers and textures, see the [Resource Management](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html#//apple_ref/doc/uid/TP40016642-CH3-SW1) and [Triple Buffering](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/TripleBuffering.html#//apple_ref/doc/uid/TP40016642-CH5-SW1) best practices.

资源数据可能是静态的或动态的，同时也可能在应用整个程序生命周期的各个阶段被访问。然而，应尽早创建为资源数据分配内存的 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 和 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象。创建这些对象后，资源属性和存储分配是不可变的，但数据本身可以改变；你可以在必要时更新数据。

尽可能重用 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 和 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象，尤其是静态数据。避免在渲染或计算循环期间创建新的资源，即使是动态数据。关于缓冲区和纹理的更多信息，见 [Resource Management](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html#//apple_ref/doc/uid/TP40016642-CH3-SW1) 和 [Triple Buffering](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/TripleBuffering.html#//apple_ref/doc/uid/TP40016642-CH5-SW1) 最佳实践。

### Resource Options - 资源选项

> Best Practice: Set appropriate resource storage modes and texture usage options.
>
> Your Metal resources must be configured appropriately to take advantage of fast memory access and driver performance optimizations. Resource storage modes allow you to define the storage location and access permissions for your [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) and [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) objects. Texture usage options allow you to explicitly declare how you intend to use your [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) objects.

最佳实践：设置适当的资源存储模式和纹理使用选项

必须适当地配置你的 Metal 资源，以利用快速内存访问和驱动程序性能优化。资源存储模式允许你定义 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 和 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象的存储位置和访问权限。纹理使用选项允许你显示声明打算如何使用 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象。

#### Familiarize Yourself with Device Memory Models - 熟悉设备内存模型

> Device memory models vary by operating system. iOS and tvOS devices support a unified memory model in which the CPU and the GPU share system memory. macOS devices support a discrete memory model with CPU-accessible system memory and GPU-accessible video memory.
>
> IMPORTANT
>
> - Some macOS devices feature integrated GPUs. In these devices, the driver optimizes the underlying architecture to support a discrete memory model. macOS Metal apps should always target a discrete memory model.
>
> - All iOS and tvOS devices feature integrated GPUs.

设备内存模型因操作系统而异。iOS 和 tvOS 设备支持统一的内存模型，CPU 和 GPU 共享系统内存。macOS 设备支持 CPU 可访问系统内存和 GPU 可访问视频内存的独立内存模型。

重要：
- 一些 macOS 设备为集成 GPU 。在这些设备中，驱动程序优化底层架构以支持分离内存模型。macOS Metal 应用程序应该总是以分离内存模型为目标。
- 所有 iOS 和 tvOS 设备都为集成 GPU 。

#### Choose an Appropriate Resource Storage Mode (iOS and tvOS) - 选择适当的资源存储模式（ iOS 和 tvOS ）

> In iOS and tvOS, the [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode defines system memory accessible to both the CPU and the GPU, whereas the [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode defines system memory accessible only to the GPU.
>
> The [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode is usually the correct choice for iOS and tvOS resources. Choose the [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode only if the CPU never accesses your resource.
>
> NOTE
>
> - In iOS and tvOS, the [memoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless) storage mode is provided for memoryless textures. This storage mode can only be used for temporary render targets stored in on-chip tile memory. For further information, see Memoryless Textures in the [Metal Programming Guide](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221).
>
> Figure 3-1Resource storage modes in iOS and tvOS

iOS 和 tvOS 中，[Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) 模式定义了 CPU 和 GPU 都可以访问的系统内存，而 [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) 模式定义了只有 GPU 可以访问的系统内存。

[Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) 模式通常是 iOS 和 tvOS 资源的正确选择。仅当 CPU 从不访问你的资源时才选择 [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) 模式。

注意：

- iOS 和 tvOS 中，[memoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless) 存储模式用于无记忆纹理。这种存储模式只能用于存储于片上磁贴存储器中的用于临时渲染目标的纹理。关于更多信息，参阅  [Metal Programming Guide](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221) 中 Memoryless Textures 章节。

图 3-1 iOS 和 tvOS 资源存储模式

![ResourceStorageModesIniOSAndTvOS](../../resource/Metal/Markdown/ResourceStorageModesIniOSAndTvOS.png)

#### Choose an Appropriate Resource Storage Mode (macOS)

> In macOS, the [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode defines system memory accessible to both the CPU and the GPU, whereas the [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode defines video memory accessible only to the GPU.
>
> Additionally, macOS implements the [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed) mode that defines a synchronized memory pair for a resource, with one copy in system memory and another in video memory. Managed resources benefit from fast CPU and GPU access to each copy of the resource, with minimal API calls needed to synchronize these copies.
>
> Figure 3-2Resource storage modes in macOS
>
> ![ResourceStorageModesInMacOS](../../resource/Metal/Markdown/ResourceStorageModesInMacOS.png)
>
> IMPORTANT
>
> - In macOS, the [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode is available only for buffers, not textures. Buffer data is usually linear, resulting in simple GPU access patterns. Textures are more complex and their data is usually tiled or swizzled, resulting in more complicated GPU access patterns.

##### Buffer Storage Mode (macOS)

> Use the following guidelines to determine the appropriate storage mode for a particular buffer.
>
> - If the buffer is accessed by the GPU exclusively, choose the [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode. This is a common case for GPU-generated data, such as per-patch tessellation factors.
>
> - If the buffer is accessed by the CPU exclusively, choose the [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode. This is a rare case and is usually an intermediary step in a blit operation.
>
> - If the buffer is accessed by both the CPU and the GPU, as is the case with most vertex data, consider the following points and refer to [Table 3-1](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/ResourceOptions.html#//apple_ref/doc/uid/TP40016642-CH17-SW4):
>
   > - For small-sized data that changes frequently, choose the [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode. The overhead of copying data to video memory may be more expensive than the overhead of the GPU accessing system memory directly.
   >
   > - For medium-sized data that changes infrequently, choose the [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed) mode. Always call an appropriate synchronization method after modifying the contents of a managed buffer.
   >
   > After performing a CPU write, call the [didModifyRange:](https://developer.apple.com/documentation/metal/mtlbuffer/1516121-didmodifyrange) method to notify Metal about the specific range of data that was modified; this allows Metal to update only that specific range in the video memory copy.
   >
   > After encoding a GPU write, encode a blit operation that includes a call to the [synchronizeResource:](https://developer.apple.com/documentation/metal/mtlblitcommandencoder/1400775-synchronize) method; this allows Metal to update the system memory copy after the associated command buffer has completed execution.
   >
   > - For large-sized data that never changes, choose the [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode. Initialize and populate a source buffer with a [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared) mode and then blit its data into a destination buffer with a [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode. This is an optimal operation with a one-time cost.
>
> Table 3-1Choosing a storage mode for buffer data accessed by both the CPU and the GPU

Data size | Resource dirtiness | Update frequency | Storage mode
:------------: | :-------------: | :------------: | :------------:
Small | Full  | Every frame | [Shared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared)
Medium | Partial  | Every n frames | [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed)
Large | N/A | Once | [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private)((After a blit from a shared source buffer))

##### Texture Storage Mode (macOS)

> In macOS, the default storage mode for textures is [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed). Use the following guidelines to determine the appropriate storage mode for a particular texture.
>
> - If the texture is accessed by the GPU exclusively, choose the [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode. This is a common case for GPU-generated data, such as displayable render targets.
>
> - If the texture is accessed by the CPU exclusively, choose the [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed) mode. This is a rare case and is usually an intermediary step in a blit operation.
>
> - If the texture is initialized once by the CPU and accessed frequently by the GPU, initialize a source texture with a [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed) mode and then blit its data into a destination texture with a [Private](https://developer.apple.com/documentation/metal/mtlstoragemode/private) mode. This is a common case for static textures, such as diffuse maps.
>
> - If the texture is accessed frequently by both the CPU and GPU, choose the [Managed](https://developer.apple.com/documentation/metal/mtlstoragemode/managed) mode. This is a common case for dynamic textures, such as image filters. Always call an appropriate synchronization method after modifying the contents of a managed texture.
>
   > To perform a CPU write to a specific region of data and simultaneously notify Metal about the change, call either of the following methods. This allows Metal to update only that specific region in the video memory copy.
   >
   > - [replaceRegion:mipmapLevel:withBytes:bytesPerRow:](https://developer.apple.com/documentation/metal/mtltexture/1515464-replaceregion)
   >
   > - [replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:](https://developer.apple.com/documentation/metal/mtltexture/1515679-replaceregion)
   >
   > After encoding a GPU write, encode a blit operation that includes a call to either of the following methods. This allows Metal to update the system memory copy after the associated command buffer has completed execution.
   >
   > - [synchronizeResource:](https://developer.apple.com/documentation/metal/mtlblitcommandencoder/1400775-synchronize)
   >
   > - [synchronizeTexture:slice:level:](https://developer.apple.com/documentation/metal/mtlblitcommandencoder/1400757-synchronizetexture)

#### Set Appropriate Texture Usage Flags - 设置适当的纹理使用标记
   
> Metal can optimize GPU operations for a given texture, based on its intended use. Always declare explicit texture usage options if you know them in advance. Do not rely on the [Unknown](https://developer.apple.com/documentation/metal/mtltextureusage/mtltextureusageunknown) option; although this option provides the most flexibility for your textures, it incurs a significant performance cost. The driver cannot perform any optimizations if it does not know how you intend to use your texture. For a description of available texture usage options, see the [MTLTextureUsage](https://developer.apple.com/documentation/metal/mtltextureusage) reference.

Metal 可以根据其预期用途优化对于给定纹理的 GPU 操作。如果你事先知道它们的用途，则始终声明显式纹理使用选项。不要依赖 [Unknown](https://developer.apple.com/documentation/metal/mtltextureusage/mtltextureusageunknown) 选项；虽然此选项为纹理提供了最大的灵活性，但却会产生显著的性能损失。如果驱动程序不知道你打算如何使用你的纹理，则无法执行任何优化。关于可用的纹理使用选项的描述，见 [MTLTextureUsage](https://developer.apple.com/documentation/metal/mtltextureusage) 参考。

### Triple Buffering - 三重缓冲

> Best Practice: Implement a triple buffering model to update dynamic buffer data.
>
> Dynamic buffer data refers to frequently updated data stored in a buffer. To avoid creating new buffers per frame and to minimize processor idle time between frames, implement a triple buffering model.

最佳实践：实现三重缓冲模型以更新动态缓冲区数据

动态缓冲区数据是指存储在缓冲区中的频繁更新的数据。为了避免每帧创建新缓冲区并且最小化帧之间的处理器空闲时间，请实现一个三重缓冲模型。

#### Prevent Access Conflicts and Reduce Processor Idle Time - 防止访问冲突并减少处理器空闲时间

> Dynamic buffer data is typically written by the CPU and read by the GPU. An access conflict occurs if these operations happen at the same time; the CPU must finish writing the data before the GPU can read it, and the GPU must finish reading that data before the CPU can overwrite it. If dynamic buffer data is stored in a single buffer, this causes extended periods of processor idle time when either the CPU is stalled or the GPU is starved. For the processors to work in parallel, the CPU should be working at least one frame ahead of the GPU. This solution requires multiple instances of dynamic buffer data, so the CPU can write the data for frame n+1 while the GPU reads the data for frame n.

动态缓冲数据通常由 CPU 写入并由 GPU 读取。如果这些操作同时发生，则会发生访问冲突；在 GPU 可以读取数据之前，CPU 必须完成数据写入，同时 GPU 必须在 CPU 覆写数据之前完成数据读取。如果动态缓冲数据存储在单个缓冲区中，则当 CPU 停滞或者 GPU 等待 CPU 写入新数据时，会导致处理器空闲时间延长。为使处理器并行工作，CPU 应该至少在 GPU 前一帧工作。此解决方案需要多个动态缓冲区数据实例，所以当 GPU 读取第 n 帧数据的同时 CPU 可以写第 n+1 帧的数据。

#### Reduce Memory Overhead and Frame Latency - 减小内存开销和帧延迟

> You can manage multiple instances of dynamic buffer data with a FIFO queue of reusable buffers. However, allocating too many buffers increases memory overhead and may limit memory allocation for other resources. Additionally, allocating too many buffers increases frame latency if the CPU work is too far ahead of the GPU work.
>
> IMPORTANT
>
> - Avoid creating new buffers per frame. For an overview of allocating resource storage up front, see the [Persistent Objects](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html#//apple_ref/doc/uid/TP40016642-CH4-SW1) best practices.

你可以使用可重用缓冲区的 FIFO 队列来管理多个动态缓冲数据实例。但是，分配太多缓冲区会增加内存开销并可能限制其他资源的内存分配。此外，如果 CPU 工作领先 GPU 太多的话，分配太多缓冲区会增加帧延迟。

重要：

- 避免每帧创建新的缓冲区。有关预先分配资源存储的概述，参见 [Persistent Objects](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html#//apple_ref/doc/uid/TP40016642-CH4-SW1) 最佳实践。

#### Allow Time for Command Buffer Transactions - 

> Dynamic buffer data is encoded and bound to a transient command buffer. It takes a certain amount of time to transfer this command buffer from the CPU to the GPU after it has been committed for execution. Similarly, it takes a certain amount of time for the GPU to notify the CPU that it has completed the execution of this command buffer. This sequence is detailed below, for a single frame:
>
> 1. The CPU writes to the dynamic data buffer and encodes commands into a command buffer.
>
> 2. The CPU schedules a completion handler ([addCompletedHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler)), commits the command buffer ([commit](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit)), and transfers the command buffer to the GPU.
>
> 3. The GPU executes the command buffer and reads from the dynamic data buffer.
>
> 4. The GPU completes its execution and calls the command buffer completion handler ([MTLCommandBufferHandler](https://developer.apple.com/documentation/metal/mtlcommandbufferhandler)).
>
> This sequence can be parallelized with two dynamic data buffers, but the command buffer transactions may cause the CPU to stall or the GPU to starve if either processor is waiting on a busy dynamic data buffer.

动态缓冲区数据被编码并绑定到瞬态命令缓冲区。在提交执行后，将此命令缓冲区从 CPU 传输到 GPU 需要一定的时间。类似的，GPU 需要一定的时间来通知 CPU 它已完成该命令缓冲区的执行。对于单个帧，此序列详述如下：

1. CPU 写数据到动态数据缓冲区并将命令编码至命令缓冲区。

2. CPU 调度完成处理程序（ [addCompletedHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler) ），提交命令缓冲区（ [commit](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit) ），并将命令缓冲区传输到 GPU 。

3. GPU 执行命令缓冲区并从动态数据缓冲区读取数据。

4. GPU 完成命令缓冲区的执行并调用命令缓冲区完成处理程序（ [MTLCommandBufferHandler](https://developer.apple.com/documentation/metal/mtlcommandbufferhandler) ）。

使用两个动态数据缓冲区，以上执行序列可以并行化，但是如果任一处理器正在等待繁忙的动态数据缓冲区，则命令缓冲区事务可能导致 CPU 空闲或 GPU 饥饿。

#### Implement a Triple Buffering Model - 实现三重缓冲模型

> Adding a third dynamic data buffer is the ideal solution when considering processor idle time, memory overhead, and frame latency. Figure 4-1 shows a triple buffering timeline, and Listing 4-1 shows a triple buffering implementation.
>
> Figure 4-1Triple buffering timeline

在考虑处理器空闲时间，内存开销和帧延迟时，添加第三个动态数据缓冲区是理想的解决方案。图 4-1 显示了一个三重缓冲时间线，清单 4-1 显示了一个三重缓冲实现。

图 4-1 三重缓冲时间线

![TripleBufferingTimeline](../../resource/Metal/Markdown/TripleBufferingTimeline.png)

清单 4-1 三重缓冲实现

```objc
static const NSUInteger kMaxInflightBuffers = 3;
/* Additional constants */

@implementation Renderer
{
    dispatch_semaphore_t _frameBoundarySemaphore;
    NSUInteger _currentFrameIndex;
    NSArray <id <MTLBuffer>> _dynamicDataBuffers;
    /* Additional variables */
}

- (void)configureMetal
{
    // Create a semaphore that gets signaled at each frame boundary.
    // The GPU signals the semaphore once it completes a frame's work, allowing the CPU to work on a new frame
    _frameBoundarySemaphore = dispatch_semaphore_create(kMaxInflightBuffers);
    _currentFrameIndex = 0;
    /* Additional configuration */
}

- (void)makeResources
{
    // Create a FIFO queue of three dynamic data buffers
    // This ensures that the CPU and GPU are never accessing the same buffer simultaneously
    MTLResourceOptions bufferOptions = /* ... */;
    NSMutableArray *mutableDynamicDataBuffers = [NSMutableArray arrayWithCapacity:kMaxInflightBuffers];
    for(int i = 0; i < kMaxInflightBuffers; i++)
    {
        // Create a new buffer with enough capacity to store one instance of the dynamic buffer data
        id <MTLBuffer> dynamicDataBuffer = [_device newBufferWithLength:sizeof(DynamicBufferData) options:bufferOptions];
        [mutableDynamicDataBuffers addObject:dynamicDataBuffer];
    }
    _dynamicDataBuffers = [mutableDynamicDataBuffers copy];
}

- (void)update
{
    // Advance the current frame index, which determines the correct dynamic data buffer for the frame
    _currentFrameIndex = (_currentFrameIndex + 1) % kMaxInflightBuffers;
    
    // Update the contents of the dynamic data buffer
    DynamicBufferData *dynamicBufferData = [_dynamicDataBuffers[_currentFrameIndex] contents];
    /* Perform updates */
}

- (void)render
{
    // Wait until the inflight command buffer has completed its work
    dispatch_semaphore_wait(_frameBoundarySemaphore, DISPATCH_TIME_FOREVER);
    
    // Update the per-frame dynamic buffer data
    [self update];
    
    // Create a command buffer and render command encoder
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id <MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_renderPassDescriptor];
    
    // Set the dynamic data buffer for the frame
    [renderCommandEncoder setVertexBuffer:_dynamicDataBuffers[_currentFrameIndex] offset:0 atIndex:0];
    /* Additional encoding */
    [renderCommandEncoder endEncoding];
    
    // Schedule a drawable presentation to occur after the GPU completes its work
    [commandBuffer presentDrawable:view.currentDrawable];
    
    __weak dispatch_semaphore_t semaphore = _frameBoundarySemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        // GPU work is complete
        // Signal the semaphore to start the CPU work
        dispatch_semaphore_signal(semaphore);
    }];
    
    // CPU work is complete
    // Commit the command buffer and start the GPU work
    [commandBuffer commit];
}

@end
```

### Buffer Bindings - 缓冲区绑定

> Best Practice: Use an appropriate method to bind your buffer data to a graphics or compute function.
>
> Metal provides several API options for binding buffer data to a graphics or compute function so it can be processed by the GPU.
>
> NOTE
>
> - This chapter uses vertex function bindings as examples. Metal provides equivalent APIs for fragment and kernel functions in the [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) and [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) classes.
>
> The [setVertexBytes:length:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515846-setvertexbytes) method is the best option for binding a very small amount (less than 4 KB) of dynamic buffer data to a vertex function, as shown in Listing 5-1. This method avoids the overhead of creating an intermediary [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) object. Instead, Metal manages a transient buffer for you.
>
> Listing 5-1Binding a very small amount (less than 4 KB) of dynamic buffer data

最佳实践：使用适当的方法将缓冲区数据绑定到图形或计算函数

Metal 提供了一些 API 选项用于将缓冲区数据绑定到图形或计算函数，绑定之后 GPU 就可以处理对应的缓冲区数据。

注意

- 本章节使用顶点函数绑定作为示例。Metal 为 [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder) 和 [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder) 类中的片段和内核函数提供了等效的 API 。

[setVertexBytes:length:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515846-setvertexbytes) 方法是将极小量（少于 4 KB ）的动态缓冲区数据绑定到顶点函数的最佳选项，如清单 5-1 所示。该方法避免了创建中间 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 对象的开销。相反，Metal 为你管理一个瞬态缓冲区。

清单 5-1 绑定极小量（少于 4 KB ）动态缓冲区数据

```objc
float _verySmallData = 1.0;
[renderEncoder setVertexBytes:&_verySmallData length:sizeof(float) atIndex:0];
```

> If your data size is larger than 4 KB, create a [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) object once and update its contents as needed. Call the [setVertexBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515829-setvertexbuffer) method to bind the buffer to a vertex function; if your buffer contains data used in multiple draw calls, call the [setVertexBufferOffset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515433-setvertexbufferoffset) method afterward to update the buffer offset so it points to the location of the corresponding draw call data, as shown in Listing 5-2. You do not need to rebind the currently bound buffer if you are only updating its offset.
>
> Listing 5-2Updating the offset of a bound buffer

如果你的数据大小大于 4 KB ，创建一个 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer) 对象一次并根据需要更新其内容。调用 [setVertexBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515829-setvertexbuffer) 方法将缓冲区绑定到顶点函数；如果缓冲区包含用于多个绘制调用中使用的数据，调用 [setVertexBufferOffset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515433-setvertexbufferoffset) 方法来更新缓冲区偏移，使其指向绘制调用数据的相应的位置，如清单 5-2 所示。你不需要重新绑定当前绑定的缓冲区，如果仅更新其偏移量的话。

清单 5-2 更新绑定缓冲区的偏移量

```objc
// Bind the vertex buffer once
[renderEncoder setVertexBuffer:_vertexBuffer[_frameIndex] offset:0 atIndex:0];
for(int i=0; i<_drawCalls; i++)
{
    //  Update the vertex buffer offset for each draw call
    [renderEncoder setVertexBufferOffset:i*_sizeOfVertices atIndex:0];
    
    // Draw the vertices
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexCount];
}
```

## Display Management - 显示管理

### Drawables - 可绘

> Best Practice: Hold a drawable as briefly as possible.
>
> Most Metal apps implement a layer-backed view defined by a [CAMetalLayer](https://developer.apple.com/documentation/quartzcore/cametallayer) object. This layer vends an efficient displayable resource conforming to the [CAMetalDrawable](https://developer.apple.com/documentation/quartzcore/cametaldrawable) protocol, commonly referred to as a drawable. A drawable provides a [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) object that is typically used as a displayable render target attached to a [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor) object, with the goal of being presented on the screen.
>
> A drawable’s presentation is registered by calling a command buffer’s [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) method before calling its [commit](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit) method. However, the drawable itself is actually presented only after the command buffer has completed execution and the drawable has been rendered or written to.
>
> A drawable tracks whether it has outstanding render or write requests on it and will not present until those requests have been completed. A command buffer registers its drawable requests only when it is scheduled for execution. Registering a drawable presentation after the command buffer is scheduled guarantees that all command buffer work will be completed before the drawable is actually presented. Do not wait for the command buffer to complete its GPU work before registering a drawable presentation; this will cause a considerable CPU stall.
>
> IMPORTANT
>
> - To avoid presenting a drawable before any work is scheduled, or to avoid holding on to a drawable longer than necessary, call a command buffer’s [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) method instead of a drawable’s [present](https://developer.apple.com/documentation/metal/mtldrawable/1470284-present) method. [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) is a convenience method that calls the given drawable's [present](https://developer.apple.com/documentation/metal/mtldrawable/1470284-present) method via the command buffer's [addScheduledHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442991-addscheduledhandler) callback.

最佳实践：尽可能简要地持有 drawable

大多数 Metal 应用程序实现由 [CAMetalLayer](https://developer.apple.com/documentation/quartzcore/cametallayer) 对象定义的 layer-backed 视图。该 layer 提供了一个遵循 [CAMetalDrawable](https://developer.apple.com/documentation/quartzcore/cametaldrawable) 协议的有效可显示资源，通常称为 drawable 。drawable 提供了一个 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture) 对象，该对象通常用作附加到 [MTLRenderPassDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor) 对象上用于在屏幕上显示的渲染目标。

通过在调用命令缓冲区的 [commit](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit) 方法之前调用其 [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) 方法来注册 drawable 的显示。但是，只有在命令缓冲区执行完毕并且完成对 drawable 的渲染或写入之后，drawable 的内容才会显示出来。

drawable 跟踪是否存在关于它的渲染或写入请求，在这些请求没有完成之前是不会呈现出内容的。只在其被调度执行的时候，命令缓冲区才注册其 drawable 请求。在调度命令缓冲区之后注册 drawable 的呈现可确保在实际呈现 drawable 之前完成所有命令缓冲区的工作。在注册 drawable 展示之前，不要等待命令缓冲区完成其 GPU 工作；这将导致相当大的 CPU 停滞。

重要：

- 为了避免在任何工作被调度之前呈现一个 drawable ，或者为了超过必要的持有 drawable ，调用命令缓冲区的 [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) 而不是 [present](https://developer.apple.com/documentation/metal/mtldrawable/1470284-present) 方法。[presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) 是一个便利的方法，其通过命令缓冲区的 [addScheduledHandler:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442991-addscheduledhandler) 回调调用给定 drawable 的 [present](https://developer.apple.com/documentation/metal/mtldrawable/1470284-present) 方法。

#### Hold a Drawable as Briefly as Possible - 尽可能简要地持有 drawable

> Drawables are expensive system resources created and maintained by the Core Animation framework. They exist within a limited and reusable resource pool and may or may not be available when requested by your app. If there is no drawable available at the time of your request, the calling thread is blocked until a new drawable becomes available (which is usually at the next display refresh interval).
>
> To hold a drawable as briefly as possible, follow these two steps:
>
> 1. Always acquire a drawable as late as possible; preferably, immediately before encoding an on-screen render pass. A frame’s CPU work may include dynamic data updates and off-screen render passes that you can perform before acquiring a drawable.
>
> 2. Always release a drawable as soon as possible; preferably, immediately after finalizing a frame’s CPU work. It is highly advisable to contain your rendering loop within an autorelease pool block to avoid possible deadlock situations with multiple drawables.
>
> NOTE
>
> - As of iOS 10 and tvOS 10, drawables can be safely held for post-presentation property queries, such as [drawableID](https://developer.apple.com/documentation/metal/mtldrawable/2806860-drawableid) and [presentedTime](https://developer.apple.com/documentation/metal/mtldrawable/2806855-presentedtime). Otherwise, drawables should be released when they are no longer needed, which is usually after a call to a command buffer’s [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) method.
>
> Figure 6-1 shows the lifetime of a drawable in relation to other CPU work.
>
> Figure 6-1The lifetime of a drawable

Drawables 是由 Core Animation 框架创建并维护的昂贵系统资源。它们存在于有限且可重复使用的资源池中，应用程序请求时，其可能可用，也可能不可用。若当你请求时没有可用的 drawable ，则调用线程将被阻塞，直到新的 drawable 变为可用状态（通常在下一个显示刷新间隔）。

尽可能简要地持有 drawable ，遵循以下两个步骤：

1. 总是尽可能晚的获取 drawable ；宁可在编码用于屏幕显示的渲染过程瞬间之前。帧绘制过程中，CPU 的工作包括更新动态数据及离屏渲染，你可以在获取 drawable 之前执行这些工作。

2. 务必尽快释放 drawable 对象，宁可在完成帧的 CPU 工作之后立马释放。在自动释放池块内包含你的渲染循环是非常明智的选择，以避免可能出现多个 drawables 的死锁情况。

注意：

- 从 iOS 10 和 tvOS 10 开始，drawables 可以安全地被持有用于 post-presentation 属性查询，例如 [drawableID](https://developer.apple.com/documentation/metal/mtldrawable/2806860-drawableid) 和 [presentedTime](https://developer.apple.com/documentation/metal/mtldrawable/2806855-presentedtime) 。否则，drawable 应该在不再需要时立即释放，这通常是在调用命令缓冲区的 [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) 方法之后。

图 6-1 显示了 drawable 相对于其他 CPU 工作的生命周期

图 6-1 drawable 生命周期

![TheLifetimeOfDrawable](../../resource/Metal/Markdown/TheLifetimeOfDrawable.png)

#### Use a MetalKit View to Interact with Drawables - 使用 MetalKit 和 Drawables 交互

> Using an [MTKView](https://developer.apple.com/documentation/metalkit/mtkview) object is the preferred way to interact with drawables. An [MTKView](https://developer.apple.com/documentation/metalkit/mtkview) object is backed by a [CAMetalLayer](https://developer.apple.com/documentation/quartzcore/cametallayer) object and provides the [currentDrawable](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) property to acquire the drawable for the current frame. The current frame renders into this drawable and the [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) method schedules the actual presentation to occur at the next display refresh interval. The [currentDrawable](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) property is automatically updated at the end of every frame.
>
> An [MTKView](https://developer.apple.com/documentation/metalkit/mtkview) object also provides the [currentRenderPassDescriptor](https://developer.apple.com/documentation/metalkit/mtkview/1536024-currentrenderpassdescriptor) convenience property that references the current drawable’s texture; use this property to create a render command encoder that renders into the current drawable. A call to the [currentRenderPassDescriptor](https://developer.apple.com/documentation/metalkit/mtkview/1536024-currentrenderpassdescriptor) property implicitly acquires the drawable for the current frame, which is then stored in the [currentDrawable](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) property.
>
> NOTE
>
> - If you create your own [UIView](https://developer.apple.com/documentation/uikit/uiview) or [NSView](https://developer.apple.com/documentation/appkit/nsview) subclass that is backed by a [CAMetalLayer](https://developer.apple.com/documentation/quartzcore/cametallayer) object, you must explicitly acquire a drawable and use its texture to configure a render pass descriptor. You can also do this for your own [MTKView](https://developer.apple.com/documentation/metalkit/mtkview) object, but it is much easier to simply use the [currentRenderPassDescriptor](https://developer.apple.com/documentation/metalkit/mtkview/1536024-currentrenderpassdescriptor) convenience property. For an example of how to acquire a drawable from a [UIView](https://developer.apple.com/documentation/uikit/uiview) or [NSView](https://developer.apple.com/documentation/appkit/nsview) subclass, see the MetalBasic3D sample.
>
> Listing 6-1 shows how to use a drawable with a MetalKit view.
>
> Listing 6-1Using drawables with a MetalKit view

使用 [MTKView](https://developer.apple.com/documentation/metalkit/mtkview) 对象是与 drawables 交互的首先方式。[MTKView](https://developer.apple.com/documentation/metalkit/mtkview) 对象由 [CAMetalLayer](https://developer.apple.com/documentation/quartzcore/cametallayer) 对象支持，并提供 [currentDrawable](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) 以获取当前帧的 drawable 。当前帧渲染到这个 drawable 中并且 [presentDrawable:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443029-present) 方法在下一个显示刷新间隔调度真实的内容以供显示。[currentDrawable](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) 属性在每帧结束时自动更新。

[MTKView](https://developer.apple.com/documentation/metalkit/mtkview) 对象还提供 [currentRenderPassDescriptor](https://developer.apple.com/documentation/metalkit/mtkview/1536024-currentrenderpassdescriptor) 便利属性，该属性引用当前 drawable 的纹理；使用此属性创建渲染命令编码器将内容渲染到当前 drawable 中。调用 [currentRenderPassDescriptor](https://developer.apple.com/documentation/metalkit/mtkview/1536024-currentrenderpassdescriptor) 属性隐式获取当前帧的 drawable ，然后其被存储于 [currentDrawable](https://developer.apple.com/documentation/metalkit/mtkview/1535971-currentdrawable) 属性中。

注意：

- 如果创建自己的由 [CAMetalLayer](https://developer.apple.com/documentation/quartzcore/cametallayer) 对象支持的 UIView 或 NSView 子类，你必须显试地获取 drawable 并且使用其纹理去配置渲染过程描述符。你也可以为你的 [MTKView](https://developer.apple.com/documentation/metalkit/mtkview) 对象执行该操作，但使用 [currentRenderPassDescriptor](https://developer.apple.com/documentation/metalkit/mtkview/1536024-currentrenderpassdescriptor) 便捷属性要容易的多。有关如何从 [UIView](https://developer.apple.com/documentation/uikit/uiview) 或 [NSView](https://developer.apple.com/documentation/appkit/nsview) 子类获取一个 drawable 的示例，见 MetalBasic3D 示例。

清单 6-1 显示了如何使用带有 MetalKit 视图的 drawable

清单 6-1 使用带有 MetalKit 视图的 drawables

```objc
- (void)render:(MTKView *)view {
    // Update your dynamic data
    [self update];

    // Create a new command buffer
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];

    // BEGIN encoding any off-screen render passes
    /* ... */
    // END encoding any off-screen render passes

    // BEGIN encoding your on-screen render pass
    // Acquire a render pass descriptor generated from the drawable's texture
    // 'currentRenderPassDescriptor' implicitly acquires the drawable
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;

    // If there's a valid render pass descriptor, use it to render into the current drawable
    if(renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        /* Set render state and resources */
        /* Issue draw calls */
        [renderCommandEncoder endEncoding];
        // END encoding your on-screen render pass

        // Register the drawable presentation
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    /* Register optional callbacks */
    // Finalize the CPU work and commit the command buffer to the GPU
    [commandBuffer commit];
}

- (void)drawInMTKView:(MTKView *)view {
    @autoreleasepool {
        [self render:view];
    }
}
```

### Native Screen Scale (iOS and tvOS) - 原生屏幕比例（ iOS 与 tvOS ）

> Best Practice: Render drawables at the exact pixel size of your target display.
>
> The pixel size of your drawables should always match the exact pixel size of their target display. This is critical to avoid rendering to off-screen pixels or incurring an additional sampling stage.
>
> The [UIScreen](https://developer.apple.com/documentation/uikit/uiscreen) class provides two properties that define the native size and scale factor of a physical screen: [nativeBounds](https://developer.apple.com/documentation/uikit/uiscreen/1617810-nativebounds) and [nativeScale](https://developer.apple.com/documentation/uikit/uiscreen/1617825-nativescale). Query the [nativeBounds](https://developer.apple.com/documentation/uikit/uiscreen/1617810-nativebounds) property to determine the native bounding rectangle of the screen, in pixels. Query the [nativeScale](https://developer.apple.com/documentation/uikit/uiscreen/1617825-nativescale) property to determine the native scale factor used to convert points to pixels.
>
> IMPORTANT
>
> In iOS and tvOS, most drawing technologies measure size in points instead of pixels. Your Metal app should always measure size in pixels and avoid points altogether. To learn more about the difference between these two units, see [Points Versus Pixels](https://developer.apple.com/library/archive/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/GraphicsDrawingOverview/GraphicsDrawingOverview.html#//apple_ref/doc/uid/TP40010156-CH14-SW7).

最佳实践：以目标显示的精确像素大小渲染 drawables












### Frame Rate (iOS and tvOS) - 帧率（ iOS 与 tvOS ）







## Command Generation - 命令的生成






### Load and Store Actions - 加载和存储操作





### Render Command Encoders (iOS and tvOS) - 渲染命令编码器（ iOS 与 tvOS ）









### Command Buffers - 命令缓冲区






### Indirect Buffers - 间接缓冲





## Compilation - 汇编





### Functions and Libraries - 函数和库








### Pipelines - 管线



































