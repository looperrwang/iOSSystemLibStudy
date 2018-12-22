#  About Argument Buffers

> Improve your app's performance by grouping your resources into an argument buffer.

通过将资源分组到参数缓冲区来提高应用程序的性能。

## Overview

> An argument buffer is an opaque data representation of a group of resources that can be collectively assigned as graphics or compute function arguments. An argument buffer can contain multiple resources of various sizes and types, such as buffers, textures, samplers, and inlined constant data.

参数缓冲区是一组资源的不透明数据表示，可以作为图形或计算函数的参数进行整体赋值。参数缓冲区可以包含多种不同大小和类型的资源，例如缓冲区，纹理，采样器和内联常量数据。

## Specifying Argument Buffers in Metal Shading Language Functions

> Argument buffers may contain the following:
>
> - Basic scalar data types, such as half and float.
>
> - Basic vector and matrix data types, such as half4 and float4x4.
>
> - Arrays and structures of basic data types.
>
> - Buffer pointers.
>
> - Texture data types and arrays of textures.
>
> - Sampler data types and arrays of samplers.
>
> Note - Regular buffers may contain unions, but argument buffers may not.
>
> The following example shows an argument buffer structure named My_AB that specifies resources for a kernel function named my_kernel:

参数缓冲区可能包含以下内容：

- 基本标量数据类型，例如 half 和 float 。

- 基本矢量和矩阵数据类型，例如 half4 和 float4x4 。

- 基本数据类型的数组和结构。

- 缓冲区指针。

- 纹理数据类型和纹理数组。

- 采样器数据类型和采样器数组。

注意 - 常规缓冲区可能包含联合，但参数缓冲区可能不包含。

以下示例显示名为 My_AB 的参数缓冲区结构，该结构指定名为 my_kernel 的内核函数的资源：

```objc
struct My_AB {
    texture2d<float, access::write> a;
    depth2d<float> b;
    sampler c;
    texture2d<float> d;
    device float4* e;
    texture2d<float> f;
    int g;
};
kernel void my_kernel(constant My_AB & my_AB [[buffer(0)]])
{ ... }
```

## Encoding Resources into Argument Buffers

> The Metal driver may perform certain optimizations that modify the physical memory layout of an argument buffer. The layout is unknown; you must use a [MTLArgumentEncoder](https://developer.apple.com/documentation/metal/mtlargumentencoder?language=objc) object to encode argument buffer resources into a destination [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) object. You can encode the following resources into argument buffers:
>
> - Buffers ([MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc))
>
> - Textures ([MTLTexture](https://developer.apple.com/documentation/metal/mtltexture?language=objc))
>
> - Samplers ([MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate?language=objc))
>
> - Inlined constant data (void* pointer)
>
> You can then set an encoded argument buffer as a graphics or compute function argument using any of the following [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder?language=objc) or [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder?language=objc) methods:
>
> - [setVertexBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515829-setvertexbuffer?language=objc)
>
> - [setFragmentBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515470-setfragmentbuffer?language=objc)
>
> - [setBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/1443126-setbuffer?language=objc)

Metal 驱动程序可能执行某些优化，以修改参数缓冲区的物理内存布局。布局不明；必须使用 [MTLArgumentEncoder](https://developer.apple.com/documentation/metal/mtlargumentencoder?language=objc) 对象将参数缓冲区资源编码目标 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) 对象。可以将以下资源编码到参数缓冲区：

- 缓冲区（[MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc)）

- 纹理（[MTLTexture](https://developer.apple.com/documentation/metal/mtltexture?language=objc)）

- 采样器（[MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate?language=objc)）

- 内联常量数据（void *指针）

然后，你可以使用以下任何 [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder?language=objc) 或 [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder?language=objc) 方法将编码的参数缓冲区设置为图形或计算函数参数：

- [setVertexBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515829-setvertexbuffer?language=objc)

- [setFragmentBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/1515470-setfragmentbuffer?language=objc)

- [setBuffer:offset:atIndex:](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/1443126-setbuffer?language=objc)

## Benefits of Using Argument Buffers

> Argument buffers can assign a group of resources all at once to a single index in the function argument table. The main benefit of using argument buffers is to reduce the overhead incurred by assigning the same multiple resources to individual indices of the same function argument table. This is particularly beneficial for resources that do not change from frame to frame, because they can be assigned to an argument buffer once and reused many times.
>
> Encoding resources into argument buffers eliminates the need for the Metal driver to capture state and track residency when individual resources are assigned to the indices of a function's argument table. Instead, argument buffers provide greater control over resource residency that you must explicitly declare before issuing draw or dispatch calls.
>
> Using resource heaps is already a great way to reduce resource overhead. When you combine resource heaps with argument buffers, you can further reduce overhead by:
>
> - Encoding argument buffer resources before entering a draw or dispatch loop.
>
> - Allocating argument buffers from a resource heap, reducing the cost of tracking the residency of the argument buffer itself.
>
> - Managing argument buffer resources and resource heap residency outside of a draw or dispatch loop, further reducing the cost of tracking residency.
>
> Finally, argument buffers allow resources to be indexed dynamically at function execution time by greatly increasing the limit on the number of resources that can be placed inside them.

参数缓冲区可以将一组资源一次性分配给函数参数表中的单个索引。使用参数缓冲区的主要好处是减少了将相同的多个资源分配给同一函数参数表的各个索引所产生的开销。这对于不会逐帧更改的资源特别有用，因为它们可以分配给参数缓冲区一次并重复使用多次。

将资源编码到参数缓冲区中，无需 Metal 驱动程序在将各个资源分配给函数参数表的索引时捕获状态和跟踪驻留。相反，参数缓冲区可以更好地控制在发出绘制或调度调用之前必须显式声明的资源驻留。

使用资源堆已经是减少资源开销的好方法。将资源堆与参数缓冲区组合使用时，可以通过以下方式进一步减少开销：

- 在进入绘制或分派循环之前编码参数缓冲区资源。

- 从资源堆分配参数缓冲区，降低了跟踪参数缓冲区本身驻留的成本。

- 在绘制或分派循环之外管理参数缓冲区资源和资源堆驻留，进一步降低了跟踪驻留的成本。

最后，参数缓冲区允许资源在函数执行时动态索引，大大增加了可以放在其中的资源数量限制。

## Argument Buffer Tiers, Limits, and Capabilities

> Argument buffer feature support is divided into two tiers: Tier 1 and Tier 2. You can query these tiers by accessing the [argumentBuffersSupport](https://developer.apple.com/documentation/metal/mtldevice/2915742-argumentbufferssupport?language=objc) property of a [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice?language=objc) object.

参数缓冲区功能支持分为两层：第 1 层和第 2 层。可以通过访问 [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice?language=objc) 对象的 [argumentBuffersSupport](https://developer.apple.com/documentation/metal/mtldevice/2915742-argumentbufferssupport?language=objc) 属性来查询这些层。

### Common Limits

> For both tiers, the maximum number of argument buffer entries in each function argument table is 8.
>
> For both tiers, the maximum number of unique samplers per app are 96 for iOS and tvOS, and at least 1024 for macOS; these limits are only applicable to samplers that have their [supportArgumentBuffers](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor/2915782-supportargumentbuffers?language=objc) property set to [YES](https://developer.apple.com/documentation/objectivec/yes?language=objc). Query the [maxArgumentBufferSamplerCount](https://developer.apple.com/documentation/metal/mtldevice/2977322-maxargumentbuffersamplercount?language=objc) to determine the exact maximum number of unique samplers per app for a given device.
>
> A [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate?language=objc) object is considered unique if the configuration of its originating [MTLSamplerDescriptor](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor?language=objc) properties is unique. For example, two samplers with equal [minFilter](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor/1515792-minfilter?language=objc) values but different [magFilter](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor/1515926-magfilter?language=objc) values are considered unique.

对于这两个层，每个函数参数表中的参数缓冲区条目的最大数量为 8 。

对于这两个层，每个应用程序的唯一采样器的最大数量对于 iOS 和 tvOS 是96，对于 macOS 至少为 1024 ；这些限制仅适用于其 [supportArgumentBuffers](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor/2915782-supportargumentbuffers?language=objc) 属性设置为 [YES](https://developer.apple.com/documentation/objectivec/yes?language=objc) 的采样器。 查询 [maxArgumentBufferSamplerCount](https://developer.apple.com/documentation/metal/mtldevice/2977322-maxargumentbuffersamplercount?language=objc) 以确定给定设备的每个应用程序的唯一采样器的确切最大数量。

如果 [MTLSamplerState](https://developer.apple.com/documentation/metal/mtlsamplerstate?language=objc) 对象的原始 [MTLSamplerDescriptor](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor?language=objc) 属性的配置是唯一的，则该对象被视为唯一。例如，具有相同 [minFilter](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor/1515792-minfilter?language=objc) 值但不同 [magFilter](https://developer.apple.com/documentation/metal/mtlsamplerdescriptor/1515926-magfilter?language=objc) 值的两个采样器被认为是唯一的。

### Tier 1 Limits

> The following resource limits are defined as the maximum combined number of resources set within an argument buffer and set individually, per graphics or compute function. For example, if a kernel function uses 4 individual textures and one argument buffer with 8 textures, the total number of textures for that kernel function is 12.
>
> In iOS and tvOS, the maximum entries in each function argument table are:
>
> - 31 buffers
>
> - 31 textures*
>
> - 16 samplers
>
> *Writable textures are not supported within an argument buffer.
>
> In macOS, the maximum entries in each function argument table are:
>
> - 64 buffers
>
> - 128 textures
>
> - 16 samplers
>
> Note - For all Tier 1 feature sets, the argument buffer entries are counted against the maximum buffer entries in each function argument table.

以下资源限制定义为每个图形或计算函数参数缓冲区中单独设置的最大资源组合数。 例如，如果内核函数使用 4 个单独纹理和一个具有 8 个纹理的参数缓冲区，则该内核函数的纹理总数为 12 。

在 iOS 和 tvOS 中，每个函数参数表中的最大条目是：

- 31 个缓冲区

- 31 个纹理*

- 16 个采样器

*参数缓冲区不支持可写纹理。

在macOS中，每个函数参数表中的最大条目是：

- 64 个缓冲区

- 128 个纹理

- 16 个采样器

注意 - 对于所有第 1 层功能集，参数缓冲区条目将根据每个函数参数表中的最大缓冲区条目进行计数。

### Tier 2 Limits

> Tier 2 argument buffers are supported only by macOS devices with a discrete GPU. In macOS, the maximum per-app resources available at any given time are:
>
> - 500,000 buffers or textures
>
> - 2048 unique samplers

仅具有独立 GPU 的 macOS 设备支持第 2 层参数缓冲区。在 macOS 中，任何给定时间可用的最大应用程序资源是：

- 500,000 个缓冲区或纹理

- 2048 个独特的采样器

### Resource Access

> Tier 1 argument buffers must be immutable; the GPU cannot modify the contents of an argument buffer. Tier 1 argument buffers must also be CPU-accessible (the buffer must specify either a [MTLStorageModeShared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc) or [MTLStorageModeManaged](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodemanaged?language=objc) storage mode).
>
> Tier 2 argument buffers can be mutable; the GPU and CPU can both modify the contents of an argument buffer at any time. However, the Metal driver may perform certain optimizations if you specify that neither the CPU nor the GPU will modify a buffer's contents between the time the buffer is set in a function's argument table and the time its associated command buffer completes execution. These types of argument buffers are considered immutable, and you can define them by setting the [mutability](https://developer.apple.com/documentation/metal/mtlpipelinebufferdescriptor/2879274-mutability?language=objc) property of an associated [MTLPipelineBufferDescriptor](https://developer.apple.com/documentation/metal/mtlpipelinebufferdescriptor?language=objc) object to [MTLMutabilityImmutable](https://developer.apple.com/documentation/metal/mtlmutability/mtlmutabilityimmutable?language=objc).

第 1 层参数缓冲区必须是不可变的；GPU 无法修改参数缓冲区的内容。第 1 层参数缓冲区也必须是 CPU 可访问的（缓冲区必须指定 [MTLStorageModeShared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc) 或 [MTLStorageModeManaged](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodemanaged?language=objc) 存储模式）。

第 2 层参数缓冲区可以是可变的；GPU 和 CPU 都可以随时修改参数缓冲区的内容。然而，如果在函数参数表设置缓冲区的事件与其关联命令缓冲区执行完毕时间之间，指定 CPU 与 GPU 都不修改缓冲区内容的话，则 Metal 驱动程序可能会执行某些优化。这些类型的参数缓冲区被认为是不可变的，你可以设置关联 [MTLPipelineBufferDescriptor](https://developer.apple.com/documentation/metal/mtlpipelinebufferdescriptor?language=objc) 对象的 [mutability](https://developer.apple.com/documentation/metal/mtlpipelinebufferdescriptor/2879274-mutability?language=objc) 属性为 [MTLMutabilityImmutable](https://developer.apple.com/documentation/metal/mtlmutability/mtlmutabilityimmutable?language=objc) 来定义它们。

### Metal Shading Language Capabilities

> Tier 1 argument buffers cannot be accessed through pointer indexing, nor can they include pointers to other argument buffers.
>
> Tier 2 argument buffers can be accessed through pointer indexing, as shown in the following example:

第 1 层参数缓冲区不能通过指针索引访问，也不能包含指向其他参数缓冲区的指针。

第 2 层参数缓冲区可以通过指针索引访问，如以下示例所示：

```objc
kernel void my_kernel(constant My_AB_Resources *resourcesArray [[buffer(0)]]) {
    constant My_AB_Resources & resources = resourcesArray[3];
}
```

> Tier 2 argument buffers can also access other argument buffers by including pointers to them, as shown in the following example:

第 2 层参数缓冲区还可以通过包含指向它们的指针来访问其他参数缓冲区，如以下示例所示：

```objc
struct My_AB_Textures {
    texture2d<float> diffuse;
    texture2d<float> specular;
};
struct My_AB_Material {
    device My_AB_Textures *textures;
};
fragment float4 my_fragment(device My_AB_Material & material)
{...}
```

> Samplers cannot be copied from the thread address space to the device address space; therefore, argument buffer samplers can be copied only between argument buffers:

不能从线程地址空间复制采样器到设备地址空间；因此，参数缓冲区采样器只能在参数缓冲区之间复制：

```objc
struct My_AB_Sampler {
    sampler sam0;
};
kernel void my_kernel(device My_AB_Sampler *source, device My_AB_Sampler *destination, sampler sam1) {
    constexpr sampler sam2;
    // device-to-device copy is allowed
    destination->sam0 = source->sam0;
    // thread-to-device copies are not allowed
    destination->sam0 = sam1;
    destination->sam0 = sam2;
}
```
