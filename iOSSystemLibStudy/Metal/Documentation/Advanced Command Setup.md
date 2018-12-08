#  Advanced Command Setup

> Organize your commands for maximum concurrency and minimal dependencies.

组织命令以获得最大的并发性和最小的依赖性。

## Overview

> Metal performs basic synchronization for you, but take full control of the work yourself for best performance.

Metal 为你执行基本的同步，但你可以自己完全控制同步工作以获得最佳性能。

## Topics

### First Steps

> Use semaphores or events to coordinate actions across threads. Copy shared data to multiple buffers to avoid multi-threaded resource contention.
>
> [CPU and GPU Synchronization](https://developer.apple.com/documentation/metal/advanced_command_setup/cpu_and_gpu_synchronization?language=objc)
> Demonstrates how to update buffer data and synchronize access between the CPU and GPU.
>
> [About Synchronization Events](https://developer.apple.com/documentation/metal/advanced_command_setup/about_synchronization_events?language=objc)
> Learn how to use synchronization events in your app or game.

使用信号量或事件来协调跨线程的操作。将共享数据复制到多个缓冲区以避免多线程资源争用。

[CPU and GPU Synchronization](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/CPU%20and%20GPU%20Synchronization.md)
演示如何更新缓冲区数据并同步 CPU 和 GPU 之间的访问。

[About Synchronization Events](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/About%20Synchronization%20Events.md)
了解如何在你的应用或游戏中使用同步事件。

### Shareable Events

### Nonshareable Events

> [Image Filter Graph with Heaps and Events](https://developer.apple.com/documentation/metal/advanced_command_setup/image_filter_graph_with_heaps_and_events?language=objc)
> Demonstrates how to use heaps and events to optimize a multistage image filter.

[Image Filter Graph with Heaps and Events](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/Image%20Filter%20Graph%20with%20Heaps%20and%20Events.md)
演示如何使用堆和事件来优化多级图像过滤器。

### Fences

> [Image Filter Graph with Heaps and Fences](https://developer.apple.com/documentation/metal/resource_objects/image_filter_graph_with_heaps_and_fences?language=objc)
> Demonstrates how to use heaps and fences to optimize a multistage image filter.

[Image Filter Graph with Heaps and Fences](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/Image%20Filter%20Graph%20with%20Heaps%20and%20Fences.md)
演示如何使用堆和栅栏来优化多级图像滤镜。

### Indirect Command Buffers

> Recoup encoding time by reusing commands, or create a GPU-driven rendering pipeline by generating and executing commands from the GPU.
>
> [Encoding Indirect Command Buffers on the CPU](https://developer.apple.com/documentation/metal/advanced_command_setup/encoding_indirect_command_buffers_on_the_cpu?language=objc)
> Reduce CPU overhead and simplify your command execution by reusing commands.
>
> [Encoding Indirect Command Buffers on the GPU](https://developer.apple.com/documentation/metal/advanced_command_setup/encoding_indirect_command_buffers_on_the_gpu?language=objc)
> Maximize CPU to GPU parallelization by generating render commands on the GPU.

通过重用命令来减少编码时间，或者通过从 GPU 生成并执行命令来创建 GPU 驱动的渲染管道。

 [Encoding Indirect Command Buffers on the CPU](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/Encoding%20Indirect%20Command%20Buffers%20on%20the%20CPU.md)
通过重用命令减少 CPU 开销并简化命令执行。

[Encoding Indirect Command Buffers on the GPU](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/Encoding%20Indirect%20Command%20Buffers%20on%20the%20GPU.md)
通过在 GPU 上生成渲染命令，最大化 CPU 到 GPU 的并行化。
