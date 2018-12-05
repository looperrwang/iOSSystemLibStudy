#  Framework - Metal

原文地址 https://developer.apple.com/documentation/metal?language=objc

> Render advanced 3D graphics and perform data-parallel computations using graphics processors.

使用图形处理器渲染高级 3D 图形并执行数据并行计算。

## Overview - 概述

> Graphics processors (GPUs) are designed to quickly render graphics and perform data-parallel calculations. Use the Metal framework when you need to communicate directly with the GPUs available on a device. Apps that render complex scenes or that perform advanced scientific calculations can use this power to achieve maximum performance. Such apps include:
>
> - Games that render sophisticated 3D environments
>
> - Video processing apps, like Final Cut Pro
>
> - Data-crunching apps, such as those used to perform scientific research
>
> Metal works hand-in-hand with other frameworks that supplement its capability. Use [MetalKit](https://developer.apple.com/documentation/metalkit?language=objc) to simplify the task of getting your Metal content onscreen. Use [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders?language=objc) to implement custom rendering functions or to take advantage of a large library of existing functions.
>
> Many high level Apple frameworks are built on top of Metal to take advantage of its performance, including [Core Image](https://developer.apple.com/documentation/coreimage?language=objc), [SpriteKit](https://developer.apple.com/documentation/spritekit?language=objc), and [SceneKit](https://developer.apple.com/documentation/scenekit?language=objc). Using one of these high-level frameworks shields you from the details of GPU programming, but writing custom Metal code enables you to achieve the highest level of performance.

图形处理器旨在快速渲染图形并执行数据并行计算。当你需要直接与设备上可用的 GPU 通信时，使用 Metal 框架。渲染复杂场景或执行高级科学计算应用程序可以使用该能力实现最佳性能。此类应用包括：

- 渲染复杂 3D 环境的游戏

- 视频处理应用，如 Final Cut Pro

- 数据处理应用程序，例如用于科学研究的应用程序

Metal 与其他补充其能力的框架协同工作。使用 [MetalKit](https://developer.apple.com/documentation/metalkit?language=objc) 简化 Metal 内容的绘制。使用 [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders?language=objc) 实现自定义渲染函数或利用大型现有功能库。

许多高级 Apple 框架基于 Metal 构建以利用其性能，包括 [Core Image](https://developer.apple.com/documentation/coreimage?language=objc) ，[SpriteKit](https://developer.apple.com/documentation/spritekit?language=objc) 和 [SceneKit](https://developer.apple.com/documentation/scenekit?language=objc) 。使用这些高级框架可以使你免受 GPU 编程的细节影响，但编写自定义 Metal 代码可以使你获得最高级别的性能。

## Topics - 主题

### GPU Devices - GPU 设备

> Access GPU device(s) at runtime, which form the basis of Metal development.
>
> [Getting the Default GPU](https://developer.apple.com/documentation/metal/getting_the_default_gpu)
> Select the system's default GPU device on which to run your Metal code.
>
> protocol [MTLDevice](https://developer.apple.com/documentation/metal/mtldevice)
> A GPU that you use to draw graphics or do parallel computation.
>
> [Choosing GPUs on Mac](https://developer.apple.com/documentation/metal/choosing_gpus_on_mac?language=objc)
> Select one or more GPUs on which to run your Metal code by considering GPU capabilities, power, or performance characteristics.

在运行时访问 GPU 设备，这是 Metal 开发的基础。

[Getting the Default GPU](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/Getting%20the%20Default%20GPU.md)
    选择运行 Metal 代码的系统默认 GPU 设备。

[MTLDevice](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/MTLDevice.md)
    用于绘制图形或执行并行计算的 GPU。

[Choosing GPUs on Mac](https://developer.apple.com/documentation/metal/choosing_gpus_on_mac?language=objc)
    通过考虑 GPU 能力，功率或性能特征，选择一个或多个 GPU 来运行 Metal 代码。

### Command Setup - 命令设置

> Set up infrastructure to execute your custom code on the GPU.
>
> [Setting Up a Command Structure](https://developer.apple.com/documentation/metal/setting_up_a_command_structure)
> Discover how Metal executes commands on a GPU.
>
> [Devices and Commands](https://developer.apple.com/documentation/metal/devices_and_commands)
> Demonstrates how to access and interact with the GPU.
>
> [Labeling Metal Objects and Commands](https://developer.apple.com/documentation/metal/labeling_metal_objects_and_commands)
> Assign meaningful labels to your Metal objects and commands so you can easily identify them in the call list of a captured frame.
>
> protocol [MTLCommandQueue](https://developer.apple.com/documentation/metal/mtlcommandqueue)
> A queue that organizes the order in which command buffers are executed by the GPU.
>
> protocol [MTLCommandBuffer](https://developer.apple.com/documentation/metal/mtlcommandbuffer)
> A container that stores encoded commands that are committed to and executed by the GPU.
>
> protocol [MTLCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandencoder)
> An encoder that writes GPU commands into a command buffer.
>
> [Advanced Command Setup](https://developer.apple.com/documentation/metal/advanced_command_setup)
> Organize your commands for maximum concurrency and minimal dependencies.

设置基础架构以在 GPU 上执行自定义代码。

### Graphics - 图形

### Parallel Computation - 并行计算

### Custom Functions - 自定义函数

### Resource Management - 资源管理

### Tools - 工具

### Cookbook

### Interoperability - 互通性

