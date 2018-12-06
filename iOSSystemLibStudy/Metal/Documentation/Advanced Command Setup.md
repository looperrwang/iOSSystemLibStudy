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

使用信号量或事件来协调跨线程的操作。将共享数据复制到多个缓冲区以避免多线程资源争用。

[CPU and GPU Synchronization](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/CPU%20and%20GPU%20Synchronization.md)
演示如何更新缓冲区数据并同步 CPU 和 GPU 之间的访问。
