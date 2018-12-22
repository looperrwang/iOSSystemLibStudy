#  Tracking the Resource Residency of Argument Buffers

> Optimize resource performance within an argument buffer.

优化参数缓冲区内的资源性能。

## Overview

> The Metal driver cannot automatically track the residency of argument buffer resources. You must track it manually.

Metal 驱动程序无法自动跟踪参数缓冲区资源的驻留时间。必须手动跟踪它。

## Track Argument Buffer Resource Residency Manually

> Call a [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder?language=objc) or [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder?language=objc) method:
>
> - For individual resources. Call [useResource:usage:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/2866168-useresource?language=objc) or [useResource:usage:](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/2866548-useresource?language=objc).
>
> - For all resources in a heap. Call [useHeap:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/2866163-useheap?language=objc) or [useHeap:](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/2866530-useheap?language=objc).
>
> These methods perform two important functions:
>
> - Add argument buffer resources to the set of resources that must be resident for the duration of the render or compute pass.
>
> - Ensure that argument buffer resources are in a format compatible with the required function operation, as specified by a [MTLResourceUsage](https://developer.apple.com/documentation/metal/mtlresourceusage?language=objc) value.
>
> Call these methods before issuing any draw or dispatch calls that may access the specified resources.
>
> Note - To track resource access and dependency hazards, you must use [MTLFence](https://developer.apple.com/documentation/metal/mtlfence?language=objc) objects.
>
> If all the required resources are not resident when executing a render or compute pass, the associated [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer?language=objc) object fails.

调用 [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder?language=objc) 或 [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder?language=objc) 方法：

- 对于单独资源。调用 [useResource:usage:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/2866168-useresource?language=objc) 或 [useResource:usage:](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/2866548-useresource?language=objc) 。

- 对于堆中的所有资源。调用 [useHeap:](https://developer.apple.com/documentation/metal/mtlrendercommandencoder/2866163-useheap?language=objc) 或 [useHeap:](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/2866530-useheap?language=objc) 。

这些方法执行两个重要功能：

- 将参数缓冲区资源添加到在渲染或计算过程期间必须驻留的资源集中。

- 确保参数缓冲区资源的格式与所需的函数操作兼容，如 [MTLResourceUsage](https://developer.apple.com/documentation/metal/mtlresourceusage?language=objc) 值所指定。

在发出可能访问指定资源的任何绘制或调度调用之前调用这些方法。

注意 - 要跟踪资源访问和依赖性危险，必须使用 [MTLFence](https://developer.apple.com/documentation/metal/mtlfence?language=objc) 对象。

如果在执行渲染或计算过程时所有必需的资源都不常驻内存的话，则关联的 [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer?language=objc) 对象将失败。
