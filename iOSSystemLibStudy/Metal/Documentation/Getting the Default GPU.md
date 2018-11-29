#  Getting the Default GPU - 获取默认 GPU

原文地址 https://developer.apple.com/documentation/metal/getting_the_default_gpu?language=objc

> Select the system's default GPU device on which to run your Metal code.

选择系统默认 GPU 设备来运行你的 Metal 代码。

## Overview - 概述

> To use the Metal framework, you start by getting a GPU device. All of the objects your app needs to interact with Metal come from a MTLDevice that you acquire at runtime. iOS and tvOS devices have only one GPU that you access by calling [MTLCreateSystemDefaultDevice:](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc)

要使用 Metal 框架，首先要获得 GPU 设备。你的应用程序与 Metal 交互所需的所有对象都来自你在运行时获取的 MTLDevice 。iOS 和 tvOS 设备只有一个通过调用 [MTLCreateSystemDefaultDevice:](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc) 访问的 GPU 。

```objc
guard let device = MTLCreateSystemDefaultDevice() else { 
    fatalError( "Failed to get the system's default Metal device." ) 
}
```

> On macOS devices that are built with multiple GPUs like Macbook, the system default is the discrete GPU. However, you may want to choose other GPU device(s) for fine-grained control. See [Choosing GPUs on Mac](https://developer.apple.com/documentation/metal/choosing_gpus_on_mac?language=objc) for more information.

在使用多个 GPU 构建的 macOS 设备上（如 Macbook ），系统默认的 GPU 为独立 GPU 。然而，你可能想选择其他 GPU 设备进行细粒度控制。有关详细信息，见 [Choosing GPUs on Mac](https://developer.apple.com/documentation/metal/choosing_gpus_on_mac?language=objc) 。
