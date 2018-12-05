#  MTLDevice

原文地址 https://developer.apple.com/documentation/metal/mtldevice?language=objc

> A GPU that you use to draw graphics or do parallel computation.

用于绘制图形或进行并行计算的 GPU 。

## Declaration - 声明

```objc
@protocol MTLDevice
```

## Overview - 概述

> The MTLDevice protocol defines the interface to a GPU. You can query a GPU device for the unique capabilities it offers your Metal app, and use the GPU device to issue all of your Metal commands. Don't implement this protocol yourself; instead, request a GPU from the system at runtime using [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc) on iOS or tvOS, and on macOS, get a list of available GPU devices using [MTLCopyAllDevicesWithObserver(handler:)](https://developer.apple.com/documentation/metal/2928189-mtlcopyalldeviceswithobserver?language=objc). See Default GPU for a full discussion on choosing the right GPU(s).
>
> GPU devices are your go-to object to do anything in Metal, so all of the Metal objects your app interacts with come from the MTLDevice instances you acquire at runtime. Device-created objects are expensive but persistent; many of them are designed to be initialized once and reused through the lifetime of your app. However, GPU device-created objects are specific to the GPU that issued them, so if you switch mid run to using different GPU(s), then you create a new suite of command objects from the new GPU device(s), too.

MTLDevice 协议定义了 GPU 的接口。你可以查询 GPU 设备为你的 Metal 应用程序提供了哪些独特功能，并使用 GPU 设备发出所有的 Metal 命令。不要自己实施此协议；相反，在运行时使用 iOS 或 tvOS 上的  [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc) 从系统请求 GPU ，在 macOS  上，使用 [MTLCopyAllDevicesWithObserver(handler:)](https://developer.apple.com/documentation/metal/2928189-mtlcopyalldeviceswithobserver?language=objc) 获取可用 GPU 设备的列表。有关选择正确的 GPU 的完整讨论，见 Default GPU 。

GPU 设备是你在 Metal 中执行任何操作的首选对象，你的应用程序与之交互的所有 Metal 对象都来自你在运行时获取的 MTLDevice 实例。设备创建的对象既昂贵又持久；其中许多设计为初始化一次，并在应用程序的生命周期中重复使用。但是，GPU 设备创建的对象特定于发布它们的 GPU ，因此如果你在运行时切换为使用不同的 GPU ，那么你也需要从新的 GPU 设备创建一组新的命令对象。

## Topics - 主题

### Acquiring Devices - 获取设备

[iOS and tvOS Devices](https://developer.apple.com/documentation/metal/mtldevice/ios_and_tvos_devices?language=objc)

Learn how to develop Metal apps for specific types of iOS and tvOS devices.

了解如何为特定类型的 iOS 和 tvOS 设备开发 Metal 应用程序。

- [About GPU Family 4](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/iOSSystemLibStudy/Metal/Documentation/About%20GPU%20Family%204.md)

[macOS Devices]()

Learn how to develop Metal apps for specific types of macOS devices.

了解如何为特定类型的 macOS 设备开发 Metal 应用程序。

[MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc)

Returns a reference to the preferred system default Metal device.

返回对首选系统默认 Metal 设备的引用。

[MTLCopyAllDevices](https://developer.apple.com/documentation/metal/1433367-mtlcopyalldevices?language=objc)

Returns an array of references to all Metal devices in the system.

返回对系统中所有 Metal 设备的引用数组。

[MTLCopyAllDevicesWithObserver](https://developer.apple.com/documentation/metal/2869731-mtlcopyalldeviceswithobserver?language=objc)

Returns an array of the available Metal devices and registers a notification observer for them.

返回可用 Metal 设备的数组，并为它们注册通知观察器。

[MTLRemoveDeviceObserver](https://developer.apple.com/documentation/metal/2869724-mtlremovedeviceobserver?language=objc)

Removes a registered observer of device notifications.

移除已注册的设备通知观察者。

[CGDirectDisplayCopyCurrentMetalDevice](https://developer.apple.com/documentation/coregraphics/1493900-cgdirectdisplaycopycurrentmetald?language=objc)

Returns a reference to the Metal device currently driving a given display.

返回当前驱动给定显示的 Metal 设备的引用。

### Querying Properties - 查询属性

[headless](https://developer.apple.com/documentation/metal/mtldevice/1433377-headless?language=objc)

A Boolean value that indicates whether a device is configured as headless.

指示设备是否配置为 headless 的布尔值。

[lowPower](https://developer.apple.com/documentation/metal/mtldevice/1433409-lowpower?language=objc)

A Boolean value that indicates whether a device is low-power.

一个布尔值，指示设备是否为低功耗。

[removable](https://developer.apple.com/documentation/metal/mtldevice/2889851-removable?language=objc)

A Boolean value that determines whether or not a GPU is removable.

一个布尔值，用于确定 GPU 是否可移动。

[registryID](https://developer.apple.com/documentation/metal/mtldevice/2915737-registryid?language=objc)

The registry ID value for the device.

设备的注册表 ID 值。

[name](https://developer.apple.com/documentation/metal/mtldevice/1433359-name?language=objc)

The name of the device.

设备名称。

### Querying Features - 查询功能

[MTLFeatureSet](https://developer.apple.com/documentation/metal/mtlfeatureset?language=objc)

The device feature sets that define specific platform, hardware, and software configurations.

设备功能集定义特定的平台，硬件和软件配置。

[supportsFeatureSet:](https://developer.apple.com/documentation/metal/mtldevice/1433418-supportsfeatureset?language=objc)

Returns a Boolean value that indicates whether a device supports a particular feature set.

返回一个布尔值，指示设备是否支持特定功能集。

### Creating a Command Queue - 创建命令队列

[newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue?language=objc)

Creates and return a command submission queue.

创建并返回命令提交队列。

[newCommandQueueWithMaxCommandBufferCount:](https://developer.apple.com/documentation/metal/mtldevice/1433433-newcommandqueuewithmaxcommandbuf?language=objc)

Creates and returns a command submission queue with a maximum number of uncompleted command buffers.

创建并返回具有最大未完成命令缓冲区数的命令提交队列。

### Synchronizing Commands - 同步命令

[newEvent](https://developer.apple.com/documentation/metal/mtldevice/2966565-newevent?language=objc)

Creates a new, nonshareable event for this specific device.

为此特定设备创建一个新的，不可共享的事件。

[newSharedEvent](https://developer.apple.com/documentation/metal/mtldevice/2966569-newsharedevent?language=objc)

Creates a new, shareable event for multiple devices, processors, and processes.

为多个设备，处理器和进程创建新的可共享事件。

[newSharedEventWithHandle:](https://developer.apple.com/documentation/metal/mtldevice/2981024-newsharedeventwithhandle?language=objc)

Creates a new, shareable event from a shareable event handle.

从可共享事件句柄创建新的可共享事件。

[newFence](https://developer.apple.com/documentation/metal/mtldevice/1649923-newfence?language=objc)

Creates a new fence.

创建一个新的围栏。

### Acquiring Shader Functions - 获取着色器函数

[newDefaultLibrary](https://developer.apple.com/documentation/metal/mtldevice/1433380-newdefaultlibrary?language=objc)

Creates a new library that contains the functions stored in the app’s default Metal library.

创建一个新库，其中包含存储在应用程序默认 Metal 库中的函数。

[newDefaultLibraryWithBundle:error:](https://developer.apple.com/documentation/metal/mtldevice/2177054-newdefaultlibrarywithbundle?language=objc)

Creates a new library that contains the functions stored in the specified bundle.

创建一个包含存储在指定包中函数的新库。

[newLibraryWithFile:error:](https://developer.apple.com/documentation/metal/mtldevice/1433416-newlibrarywithfile?language=objc)

Creates a new library that contains the functions stored in the specified Metal library.

创建一个新库，其中包含存储在指定 Metal 库中的函数。

[newLibraryWithURL:error:](https://developer.apple.com/documentation/metal/mtldevice/2877432-newlibrarywithurl?language=objc)

Creates a new library that contains the functions from a Metal library file at a specified URL.

创建一个新库，其中包含指定 URL 处的 Metal 库文件中的函数。

[newLibraryWithData:error:](https://developer.apple.com/documentation/metal/mtldevice/1433391-newlibrarywithdata?language=objc)

Creates a new library that contains the functions stored in the specified binary data object.

创建一个新库，其中包含存储在指定二进制数据对象中的函数。

[newLibraryWithSource:options:completionHandler:](https://developer.apple.com/documentation/metal/mtldevice/1433351-newlibrarywithsource?language=objc)

Asynchronously creates a new library by compiling the functions stored in the specified source string.

通过编译存储在指定源字符串中的函数来异步创建新库。

[newLibraryWithSource:options:error:](https://developer.apple.com/documentation/metal/mtldevice/1433431-newlibrarywithsource?language=objc)

Synchronously creates a new library that contains the functions stored in the specified source string.

同步创建一个新库，其中包含存储在指定源字符串中的函数。

### Creating a Render Pipeline - 创建渲染管线

### Creating a Compute Pipeline - 创建计算管线

### Querying Memory Availability - 查询内存可用性

### Creating Buffers - 创建缓冲区

### Creating Textures and Samplers - 创建纹理和采样器

### Creating Argument Buffers - 创建参数缓冲区

### Creating Indirect Command Buffers - 创建间接命令缓冲区

### Creating Resource Heaps and Fences - 创建资源堆和围栏

### Creating Depth and Stencil State - 创建深度和模版状态

### Querying Programmable Sample Positions - 查询可编程样本位置

### Querying Raster Order Groups Support - 查询光栅顺序组支持
