#  Choosing a Resource Storage Mode in iOS and tvOS

> Choose an appropriate storage mode for your iOS and tvOS resources.

为 iOS 和 tvOS 资源选择合适的存储模式。

## Overview

> All iOS and tvOS devices have an integrated GPU. These devices have a unified memory model in which the CPU and the GPU share system memory.
>
> The [MTLStorageModeShared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc) mode defines system memory accessible to both the CPU and the GPU, whereas the [MTLStorageModePrivate](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeprivate?language=objc) mode defines system memory accessible only to the GPU. Additionally, the [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) mode defines tile memory within the GPU accessible only to memoryless render targets.

所有 iOS 和 tvOS 设备都集成了 GPU 。这些设备具有统一的内存模型，通过该模型 CPU 和 GPU 共享系统内存。

[MTLStorageModeShared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc) 模式定义了 CPU 和 GPU 都可访问的系统内存，而 [MTLStorageModePrivate](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeprivate?language=objc) 模式定义了只能由 GPU 访问的系统内存。此外，[MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) 模式定义 GPU 内的 tile 内存，只能访问无记忆渲染目标。

## Choose a Resource Storage Mode for Buffers or Textures

> The [MTLStorageModePrivate](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeprivate?language=objc) is mode is ideal for render targets, intermediary resources, or texture streaming. Choose this mode if your resource is:
>
> - Accessed exclusively by the GPU.
>
> - Populated by the GPU via a render, compute, or blit pass.
>
> The [MTLStorageModeShared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc) mode is ideal for static textures or for resources used to stage updates to other private resources. Choose this mode if your resource is:
>
> - Accessed by both the CPU and the GPU.
>
> - Most often populated by the CPU.

 [MTLStorageModePrivate](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeprivate?language=objc) 模式适用于渲染目标，中间资源或纹理流。如果你的资源是：

- 仅由 GPU 访问。

- 由 GPU 通过渲染，计算或 blit 过程填充。

[MTLStorageModeShared](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc) 模式非常适用于静态纹理或用于阶段更新其他私有资源的资源。如果你的资源是：

- 由 CPU 和 GPU 访问。

- 通常由 CPU 填充。

## Use Memoryless Storage Mode for Memoryless Render Targets

> Use [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) mode if your texture is a memoryless render target that's temporarily populated and accessed by the GPU. An example is a depth or stencil texture that's used only within a render pass and isn't needed before or after GPU execution.
>
> To create a memoryless render target, set the [storageMode](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516262-storagemode?language=objc) property of a [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor?language=objc) to [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) and use this descriptor to create a new MTLTexture. Then set this new texture as the [texture](https://developer.apple.com/documentation/metal/mtlrenderpassattachmentdescriptor/1437958-texture?language=objc) property of a [MTLRenderPassAttachmentDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassattachmentdescriptor?language=objc).
>
> Note - You can create only textures, not buffers, using [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) mode. Buffers can't be used as memoryless render targets.

如果纹理是 GPU 暂时填充和访问的无记忆渲染目标，使用 [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) 模式。一个示例是深度或模板纹理，其仅在渲染过程中使用，在 GPU 执行之前或之后不再需要。

要创建无记忆渲染目标，请将 [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor?language=objc) 的 [storageMode](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516262-storagemode?language=objc) 属性设置为 [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) ，并使用此描述符创建新的 MTLTexture 。然后将此新纹理设置为 [MTLRenderPassAttachmentDescriptor](https://developer.apple.com/documentation/metal/mtlrenderpassattachmentdescriptor?language=objc) 的 [texture](https://developer.apple.com/documentation/metal/mtlrenderpassattachmentdescriptor/1437958-texture?language=objc) 属性。

注意 - 使用 [MTLStorageModeMemoryless](https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodememoryless?language=objc) 模式，只能创建纹理而不能创建缓冲区。缓冲区不能用作无记忆渲染目标。
