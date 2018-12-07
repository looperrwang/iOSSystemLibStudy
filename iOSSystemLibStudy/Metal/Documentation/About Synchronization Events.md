#  About Synchronization Events

> Learn how to use synchronization events in your app or game.

了解如何在你的应用或游戏中使用同步事件。

## Overview

> Events are used to specify synchronization points in your app or game, providing you with more control over workload balance and execution timelines while maximizing concurrency. An example is an event that synchronizes graphics rendering on one command queue with compute processing on another. There are two types of events that you can use in your app:
>
> - Nonshareable. [MTLEvent](https://developer.apple.com/documentation/metal/mtlevent?language=objc) objects synchronize events within a single device.
>
> - Shareable. [MTLSharedEvent](https://developer.apple.com/documentation/metal/mtlsharedevent?language=objc) objects synchronize events across multiple devices, processors, or processes.
>
> Nonshareable and shareable events can signal or wait for specific command completion in the GPU. Events are encoded into command buffers with the [encodeSignalEvent:value:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/2966542-encodesignalevent?language=objc) and [encodeWaitForEvent:value:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/2966543-encodewaitforevent?language=objc) methods. These methods take uint64_t signal values as parameters, which always start at 0 and can only be increased monotonically.
>
> Note - You can only encode events outside command encoder boundaries, not between encoded commands of a command encoder.
>
> Additionally, you can use shareable events to:
>
> - Set or listen for a signal value in the CPU with the [signaledValue](https://developer.apple.com/documentation/metal/mtlsharedevent/2966575-signaledvalue?language=objc) property and the [notifyListener:atValue:block:](https://developer.apple.com/documentation/metal/mtlsharedevent/2966574-notifylistener?language=objc) method.
>
> - Pass a [MTLSharedEventHandle](https://developer.apple.com/documentation/metal/mtlsharedeventhandle?language=objc) between processes via an [XPC](https://developer.apple.com/documentation/foundation/xpc?language=objc) connection.
>
> Note - Shareable events have a higher overhead than nonshareable events. Don't use [MTLSharedEvent](https://developer.apple.com/documentation/metal/mtlsharedevent?language=objc) to synchronize events within a single device; use [MTLEvent](https://developer.apple.com/documentation/metal/mtlevent?language=objc) instead.

事件用于指定应用程序或游戏中的同步点，最大化并发的同时为你提供对负载均衡及执行时间线更多的控制。事件的一个例子是，用来同步分别运行于不同命令队列上的图形渲染任务和计算处理任务。你可以在应用中使用两种类型的事件：

- 非共享。[MTLEvent](https://developer.apple.com/documentation/metal/mtlevent?language=objc) 对象同步单个设备中的事件。

- 共享。[MTLSharedEvent](https://developer.apple.com/documentation/metal/mtlsharedevent?language=objc) 对象跨多个设备，处理器或进程间同步事件。

非共享和可共享的事件可以发出信号或等待 GPU 中的特定命令完成。使用 [encodeSignalEvent:value:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/2966542-encodesignalevent?language=objc) 和 [encodeWaitForEvent:value:](https://developer.apple.com/documentation/metal/mtlcommandbuffer/2966543-encodewaitforevent?language=objc) 方法将事件编码到命令缓冲区中。这些方法将 uint64_t 信号值作为参数，该值始终从 0 开始，并且只能单调增加。

注意 - 你只能编码命令编码器边界外的事件，而不能编码命令编码器已编码命令间的事件。

此外，你可以使用可共享事件：

- 使用 [signaledValue](https://developer.apple.com/documentation/metal/mtlsharedevent/2966575-signaledvalue?language=objc) 属性和 [notifyListener:atValue:block:](https://developer.apple.com/documentation/metal/mtlsharedevent/2966574-notifylistener?language=objc) 方法在 CPU 中设置或侦听信号值。

- 通过 [XPC](https://developer.apple.com/documentation/foundation/xpc?language=objc) 连接在进程之间传递 [MTLSharedEventHandle](https://developer.apple.com/documentation/metal/mtlsharedeventhandle?language=objc) 。

注意 - 可共享事件比不可共享事件具有更高的开销。不要使用 [MTLSharedEvent](https://developer.apple.com/documentation/metal/mtlsharedevent?language=objc) 来同步单个设备中的事件；改用 [MTLEvent](https://developer.apple.com/documentation/metal/mtlevent?language=objc) 。

## Topics

### Nonshareable Events

> [Synchronizing Events Within a Single Device](https://developer.apple.com/documentation/metal/advanced_command_setup/synchronizing_events_within_a_single_device?language=objc)
> Use nonshareable events to synchronize your app's work within a single device.

[Synchronizing Events Within a Single Device](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Synchronizing%20Events%20Within%20a%20Single%20Device.md)
使用不可共享的事件在单个设备中同步应用的工作。

### Shareable Events

> [Synchronizing Events Across Multiple Devices](https://developer.apple.com/documentation/metal/advanced_command_setup/synchronizing_events_across_multiple_devices?language=objc)
> Use shareable events to synchronize your app's work across multiple devices.
>
> [Synchronizing Events Between a GPU and the CPU](https://developer.apple.com/documentation/metal/advanced_command_setup/synchronizing_events_between_a_gpu_and_the_cpu?language=objc)
> Use shareable events to synchronize your app's work between a GPU and the CPU.

[Synchronizing Events Across Multiple Devices](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Synchronizing%20Events%20Across%20Multiple%20Devices.md)
使用可共享事件在多个设备上同步应用的工作。

[Synchronizing Events Between a GPU and the CPU](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Synchronizing%20Events%20Between%20a%20GPU%20and%20the%20CPU.md)
使用可共享事件来同步应用程序在 GPU 和 CPU 之间的工作。
