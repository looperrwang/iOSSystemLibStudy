#  MTLDevice

> A GPU that you use to draw graphics or do parallel computation.

用于绘制图形或进行并行计算的 GPU 。

## Declaration

```objc
@protocol MTLDevice
```

## Overview

> The MTLDevice protocol defines the interface to a GPU. You can query a GPU device for the unique capabilities it offers your Metal app, and use the GPU device to issue all of your Metal commands. Don't implement this protocol yourself; instead, request a GPU from the system at runtime using [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc) on iOS or tvOS, and on macOS, get a list of available GPU devices using [MTLCopyAllDevicesWithObserver(handler:)](https://developer.apple.com/documentation/metal/2928189-mtlcopyalldeviceswithobserver?language=objc). See Default GPU for a full discussion on choosing the right GPU(s).
>
> GPU devices are your go-to object to do anything in Metal, so all of the Metal objects your app interacts with come from the MTLDevice instances you acquire at runtime. Device-created objects are expensive but persistent; many of them are designed to be initialized once and reused through the lifetime of your app. However, GPU device-created objects are specific to the GPU that issued them, so if you switch mid run to using different GPU(s), then you create a new suite of command objects from the new GPU device(s), too.

MTLDevice 协议定义了 GPU 的接口。你可以查询 GPU 设备为你的 Metal 应用程序提供了哪些独特功能，并使用 GPU 设备发出所有的 Metal 命令。不要自己实施此协议；相反，在运行时使用 iOS 或 tvOS 上的  [MTLCreateSystemDefaultDevice](https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice?language=objc) 从系统请求 GPU ，在 macOS  上，使用 [MTLCopyAllDevicesWithObserver(handler:)](https://developer.apple.com/documentation/metal/2928189-mtlcopyalldeviceswithobserver?language=objc) 获取可用 GPU 设备的列表。有关选择正确的 GPU 的完整讨论，见 Default GPU 。

GPU 设备是你在 Metal 中执行任何操作的首选对象，你的应用程序与之交互的所有 Metal 对象都来自你在运行时获取的 MTLDevice 实例。设备创建的对象既昂贵又持久；其中许多设计为初始化一次，并在应用程序的生命周期中重复使用。但是，GPU 设备创建的对象特定于发布它们的 GPU ，因此如果你在运行时切换为使用不同的 GPU ，那么你也需要从新的 GPU 设备创建一组新的命令对象。
