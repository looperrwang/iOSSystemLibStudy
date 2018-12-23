#  OpenGL ES Programming Guide - OpenGL ES 编程指引

翻译自英文完整版 https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008793-CH1-SW1

## About OpenGL ES - OpenGL ES 概述

> The Open Graphics Library (OpenGL) is used for visualizing 2D and 3D data. It is a multipurpose open-standard graphics library that supports applications for 2D and 3D digital content creation, mechanical and architectural design, virtual prototyping, flight simulation, video games, and more. You use OpenGL to configure a 3D graphics pipeline and submit data to it. Vertices are transformed and lit, assembled into primitives, and rasterized to create a 2D image. OpenGL is designed to translate function calls into graphics commands that can be sent to underlying graphics hardware. Because this underlying hardware is dedicated to processing graphics commands, OpenGL drawing is typically very fast.
>
> OpenGL for Embedded Systems (OpenGL ES) is a simplified version of OpenGL that eliminates redundant functionality to provide a library that is both easier to learn and easier to implement in mobile graphics hardware.

Open Graphics Library (OpenGL) 用来可视化 2D 与 3D 数据。它是一个多用途的开放标准图形库，支持 2D 和 3D 数字内容创建、机械和建筑设计、虚拟原型设计、飞行模拟、视频游戏等应用。你可以使用 OpenGL 配置 3D 图形管线并向其提交数据。顶点数据经过变换组装成图元，经过光栅化创建出 2D 图像。OpenGL 旨在将函数调用转换为可以发送到底层图形硬件的图形命令。因为此底层硬件专用于处理图形命令，因此 OpenGL 绘制通常非常快。

OpenGL for Embedded Systems (OpenGL ES) 是 OpenGL 的简化版本，它消除了冗余功能，提供了一个既易于学习更易于在移动图形硬件上实现的库。

![architecture](../../resource/OpenGLES/Markdown/architecture.png)

### At a Glance - 摘要

> OpenGL ES allows an app to harness the power of the underlying graphics processor. The GPU on iOS devices can perform sophisticated 2D and 3D drawing, as well as complex shading calculations on every pixel in the final image. You should use OpenGL ES if the design requirements of your app call for the most direct and comprehensive access possible to GPU hardware. Typical clients for OpenGL ES include video games and simulations that present 3D graphics.
>
> OpenGL ES is a low-level, hardware-focused API. Though it provides the most powerful and flexible graphics processing tools, it also has a steep learning curve and a significant effect on the overall design of your app. For apps that require high-performance graphics for more specialized uses, iOS provides several higher-level frameworks:
>
> - The Sprite Kit framework provides a hardware-accelerated animation system optimized for creating 2D games. (See [SpriteKit Programming Guide](https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013043).)
> - The Core Image framework provides real-time filtering and analysis for still and video images. (See [Core Image Programming Guide](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185).)
> - Core Animation provides the hardware-accelerated graphics rendering and animation infrastructure for all iOS apps, as well as a simple declarative programming model that makes it simple to implement sophisticated user interface animations. (See [Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514).)
> - You can add animation, physics-based dynamics, and other special effects to Cocoa Touch user interfaces using features in the UIKit framework.

OpenGL 允许应用程序利用底层图形处理器的强大功能。iOS 设备上的 GPU 可以执行复杂的 2D 和 3D 绘图，以及最终图像中每个像素的复杂着色计算。如果你的应用程序的设计要求需要最直接和全面的 GPU 硬件访问，你应该使用 OpenGL ES 。OpenGL ES 的典型客户包括呈现 3D 图形的视频游戏和模拟。

OpenGL ES 是一种底层，以硬件为重点的 API 。虽然它提供了最强大和最灵活的图形处理工具，但它也具有陡峭的学习曲线，并对应用程序的整体设计产生重大影响。对于需要高性能图形以用于更专业用途的应用程序，iOS 提供了几个更高级别的框架：

- Sprite Kit 框架提供了一个硬件加速动画系统，该系统针对创建 2D 游戏进行了优化。（见 [SpriteKit Programming Guide](https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013043) ）
- Core Image 框架为静态和视频图像提供实时滤镜和分析。（见 [Core Image Programming Guide](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185) ）
- Core Animation 为所有 iOS 应用程序提供硬件加速的图形渲染和动画基础架构，以及简单的声明性编程模型，使得实现复杂的用户界面动画变得简单。（见 [Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514) ）
- 你可以使用 UIKit 框架中的功能向 Cocoa Touch 用户界面添加动画，基于物理的动态和其他特殊效果。

#### OpenGL ES Is a Platform-Neutral API Implemented in iOS

> Because OpenGL ES is a C-based API, it is extremely portable and widely supported. As a C API, it integrates seamlessly with Objective-C Cocoa Touch apps. The OpenGL ES specification does not define a windowing layer; instead, the hosting operating system must provide functions to create an OpenGL ES rendering context, which accepts commands, and a framebuffer, where the results of any drawing commands are written to. Working with OpenGL ES on iOS requires using iOS classes to set up and present a drawing surface and using platform-neutral API to render its contents.
>
> Relevant Chapters: [Checklist for Building OpenGL ES Apps for iOS](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESontheiPhone/OpenGLESontheiPhone.html#//apple_ref/doc/uid/TP40008793-CH101-SW1), [Configuring OpenGL ES Contexts](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html#//apple_ref/doc/uid/TP40008793-CH2-SW1)

由于 OpenGL ES 是基于 C 的 API ，因此它是可移植且受到广泛支持的。作为 C API ，它与 Objective-C Cocoa Touch 应用程序无缝集成。OpenGL ES 规范没有定义窗口层；相反，托管操作系统必须提供函数来创建一个接收命令的 OpenGL ES 渲染上下文和一个 framebuffer ，其中任何绘图命令的结果写入该缓冲区。在 iOS 上使用 OpenGL ES 需要使用 iOS 类来设置和呈现绘图表面，并使用与平台无关的 API 来渲染其内容。

相关章节：[Checklist for Building OpenGL ES Apps for iOS](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESontheiPhone/OpenGLESontheiPhone.html#//apple_ref/doc/uid/TP40008793-CH101-SW1)，[Configuring OpenGL ES Contexts](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html#//apple_ref/doc/uid/TP40008793-CH2-SW1)

#### GLKit Provides a Drawing Surface and Animation Support

> Views and view controllers, defined by the UIKit framework, control the presentation of visual content on iOS. The GLKit framework provides OpenGL ES–aware versions of these classes. When you develop an OpenGL ES app, you use a [GLKView](https://developer.apple.com/documentation/glkit/glkview) object to render your OpenGL ES content. You can also use a [GLKViewController](https://developer.apple.com/documentation/glkit/glkviewcontroller) object to manage your view and support animating its contents.
>
> Relevant Chapters: [Drawing with OpenGL ES and GLKit](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1)

由 UIKit 框架定义的视图和视图控制器控制 iOS 上可视内容的呈现。GLKit 框架提供这些类的 OpenGL ES 感知版本。在开发 OpenGL ES 应用程序时，可以使用 [GLKView](https://developer.apple.com/documentation/glkit/glkview) 对象来呈现 OpenGL ES 内容。还可以使用 [GLKViewController](https://developer.apple.com/documentation/glkit/glkviewcontroller) 对象来管理视图并支持在其内容上做动画。

相关章节：[Drawing with OpenGL ES and GLKit](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1)

#### iOS Supports Alternative Rendering Targets

> Besides drawing content to fill an entire screen or part of a view hierarchy, you can also use OpenGL ES framebuffer objects for other rendering strategies. iOS implements standard OpenGL ES framebuffer objects, which you can use for rendering to an offscreen buffer or to a texture for use elsewhere in an OpenGL ES scene. In addition, OpenGL ES on iOS supports rendering to a Core Animation layer (the [CAEAGLLayer](https://developer.apple.com/documentation/quartzcore/caeagllayer) class), which you can then combine with other layers to build your app’s user interface or other visual displays.
>
> Relevant Chapters: [Drawing to Other Rendering Destinations](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html#//apple_ref/doc/uid/TP40008793-CH103-SW1)

除了绘制内容以填充整个屏幕或视图层次结构的一部分之外，还可以将 OpenGL ES 帧缓冲区对象用于其他渲染策略。iOS 实现了标准的 OpenGL ES 帧缓冲对象，你可以将其用于渲染到离屏缓冲区或纹理以供 OpenGL ES 场景中的其他地方使用。 此外，iOS 上的 OpenGL ES 支持渲染到 Core Animation layer（ [CAEAGLLayer](https://developer.apple.com/documentation/quartzcore/caeagllayer) 类），然后你可以将其与其他图层组合以构建应用程序的用户界面或其他可视化显示。

相关章节：[Drawing to Other Rendering Destinations](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html#//apple_ref/doc/uid/TP40008793-CH103-SW1)

#### Apps Require Additional Performance Tuning

> Graphics processors are parallelized devices optimized for graphics operations. To get great performance in your app, you must carefully design your app to feed data and commands to OpenGL ES so that the graphics hardware runs in parallel with your app. A poorly tuned app forces either the CPU or the GPU to wait for the other to finish processing commands.
>
> You should design your app to efficiently use the OpenGL ES API. Once you have finished building your app, use Instruments to fine tune your app’s performance. If your app is bottlenecked inside OpenGL ES, use the information provided in this guide to optimize your app’s performance.
>
> Xcode provides tools to help you improve the performance of your OpenGL ES apps.
>
> Relevant Chapters: [OpenGL ES Design Guidelines](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESApplicationDesign/OpenGLESApplicationDesign.html#//apple_ref/doc/uid/TP40008793-CH6-SW1), [Best Practices for Working with Vertex Data](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/TechniquesforWorkingwithVertexData/TechniquesforWorkingwithVertexData.html#//apple_ref/doc/uid/TP40008793-CH107-SW1), [Best Practices for Working with Texture Data](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/TechniquesForWorkingWithTextureData/TechniquesForWorkingWithTextureData.html#//apple_ref/doc/uid/TP40008793-CH104-SW1), [Best Practices for Shaders](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/BestPracticesforShaders/BestPracticesforShaders.html#//apple_ref/doc/uid/TP40008793-CH7-SW3), [Tuning Your OpenGL ES App](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Performance/Performance.html#//apple_ref/doc/uid/TP40008793-CH105-SW1)

图形处理器是针对图形操作优化的并行设备。要在你的应用中获得出色的性能，你必须仔细设计你的应用以向 OpenGL ES 提供数据和命令，以便图形硬件与你的应用并行运行。调整不佳的应用程序会强制 CPU 或 GPU 等待另一个完成处理命令。

你应该设计你的应用程序以有效地使用 OpenGL ES API 。完成应用程序构建后，使用 Instruments 调整应用程序的性能。如果你的应用程序在 OpenGL ES 中存在瓶颈，请使用本指南中提供的信息来优化应用程序的性能。

Xcode 提供的工具可以帮助你提高 OpenGL ES 应用程序的性能。

相关章节：[OpenGL ES Design Guidelines](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESApplicationDesign/OpenGLESApplicationDesign.html#//apple_ref/doc/uid/TP40008793-CH6-SW1)，[Best Practices for Working with Vertex Data](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/TechniquesforWorkingwithVertexData/TechniquesforWorkingwithVertexData.html#//apple_ref/doc/uid/TP40008793-CH107-SW1)，[Best Practices for Working with Texture Data](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/TechniquesForWorkingWithTextureData/TechniquesForWorkingWithTextureData.html#//apple_ref/doc/uid/TP40008793-CH104-SW1)，[Best Practices for Shaders](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/BestPracticesforShaders/BestPracticesforShaders.html#//apple_ref/doc/uid/TP40008793-CH7-SW3)，[Tuning Your OpenGL ES App](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Performance/Performance.html#//apple_ref/doc/uid/TP40008793-CH105-SW1)

#### OpenGL ES May Not Be Used in Background Apps

> Apps that are running in the background may not call OpenGL ES functions. If your app accesses the graphics processor while it is in the background, it is automatically terminated by iOS. To avoid this, your app should flush any pending commands previously submitted to OpenGL ES prior to being moved into the background and avoid calling OpenGL ES until it is moved back to the foreground.
>
> Relevant Chapters: [Multitasking, High Resolution, and Other iOS Features](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ImplementingaMultitasking-awareOpenGLESApplication/ImplementingaMultitasking-awareOpenGLESApplication.html#//apple_ref/doc/uid/TP40008793-CH5-SW1)

在后台运行的应用程序可能无法调用 OpenGL ES 函数。如果你的应用程序在后台运行时访问图形处理器，它将自动由 iOS 终止。为了避免这种情况，你的应用程序应该在移动到后台之前 flush 先前提交给 OpenGL ES 的任何待处理命令，并避免在将其移回前台之前调用 OpenGL ES 。

相关章节：[Multitasking, High Resolution, and Other iOS Features](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ImplementingaMultitasking-awareOpenGLESApplication/ImplementingaMultitasking-awareOpenGLESApplication.html#//apple_ref/doc/uid/TP40008793-CH5-SW1)

#### OpenGL ES Places Additional Restrictions on Multithreaded Apps

> Designing apps to take advantage of concurrency can be useful to help improve your app’s performance. If you intend to add concurrency to an OpenGL ES app, you must ensure that it does not access the same context from two different threads at the same time.
>
> Relevant Chapters: [Concurrency and OpenGL ES](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ConcurrencyandOpenGLES/ConcurrencyandOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH409-SW2)

利用并发性设计应用程序可以帮助提高应用程序的性能。如果你打算为 OpenGL ES 应用程序添加并发性，则必须确保它不会同时从两个不同的线程访问相同的上下文。

相关章节：[Concurrency and OpenGL ES](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ConcurrencyandOpenGLES/ConcurrencyandOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH409-SW2)

### How to Use This Document

> Begin by reading the first three chapters: [Checklist for Building OpenGL ES Apps for iOS](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESontheiPhone/OpenGLESontheiPhone.html#//apple_ref/doc/uid/TP40008793-CH101-SW1), [Configuring OpenGL ES Contexts](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html#//apple_ref/doc/uid/TP40008793-CH2-SW1), [Drawing with OpenGL ES and GLKit](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1). These chapters provide an overview of how OpenGL ES integrates into iOS and all the details necessary to get your first OpenGL ES apps up and running on an iOS device.
>
> If you’re familiar with the basics of using OpenGL ES in iOS, read [Drawing to Other Rendering Destinations](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html#//apple_ref/doc/uid/TP40008793-CH103-SW1) and [Multitasking, High Resolution, and Other iOS Features](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ImplementingaMultitasking-awareOpenGLESApplication/ImplementingaMultitasking-awareOpenGLESApplication.html#//apple_ref/doc/uid/TP40008793-CH5-SW1) for important platform-specific guidelines. Developers familiar with using OpenGL ES in iOS versions before 5.0 should study [Drawing with OpenGL ES and GLKit](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1) for details on new features for streamlining OpenGL ES development.
>
> Finally, read [OpenGL ES Design Guidelines](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESApplicationDesign/OpenGLESApplicationDesign.html#//apple_ref/doc/uid/TP40008793-CH6-SW1), [Tuning Your OpenGL ES App](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Performance/Performance.html#//apple_ref/doc/uid/TP40008793-CH105-SW1), and the following chapters to dig deeper into how to design efficient OpenGL ES apps.
>
> Unless otherwise noted, OpenGL ES code examples in this book target OpenGL ES 3.0. You may need to make changes to use these code examples with other OpenGL ES versions.

首先阅读前三章：[Checklist for Building OpenGL ES Apps for iOS](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESontheiPhone/OpenGLESontheiPhone.html#//apple_ref/doc/uid/TP40008793-CH101-SW1)，[Configuring OpenGL ES Contexts](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html#//apple_ref/doc/uid/TP40008793-CH2-SW1)， [Drawing with OpenGL ES and GLKit](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1) 。这些章节概述了 OpenGL ES 如何集成到 iOS 中，以及在 iOS 设备上启动和运行首个 OpenGL ES 应用程序所需的所有详细信息。

如果你熟悉在 iOS 中使用 OpenGL ES 的基础知识，请阅读 [Drawing to Other Rendering Destinations](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html#//apple_ref/doc/uid/TP40008793-CH103-SW1) 和[Multitasking, High Resolution, and Other iOS Features](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ImplementingaMultitasking-awareOpenGLESApplication/ImplementingaMultitasking-awareOpenGLESApplication.html#//apple_ref/doc/uid/TP40008793-CH5-SW1) ，以获取重要的平台特定指南。熟悉在 5.0 之前的 iOS 版本中使用 OpenGL ES 的开发人员应该学习 [Drawing with OpenGL ES and GLKit](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1) ，以获得有关简化 OpenGL ES 开发的新功能的详细信息。

最后，阅读 [OpenGL ES Design Guidelines](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESApplicationDesign/OpenGLESApplicationDesign.html#//apple_ref/doc/uid/TP40008793-CH6-SW1)，[Tuning Your OpenGL ES App](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Performance/Performance.html#//apple_ref/doc/uid/TP40008793-CH105-SW1) 以及以下章节，深入探讨如何设计高效的 OpenGL ES 应用程序。

除非另有说明，否则本书中的 OpenGL ES 代码示例将以 OpenGL ES 3.0 为目标。如果结合其他 OpenGL ES 版本来使用这些代码示例的话，你可能需要对代码进行一定的更改。

### Prerequisites

> Before attempting use OpenGL ES, you should already be familiar with general iOS app architecture. See [Start Developing iOS Apps Today (Retired)](https://developer.apple.com/library/archive/referencelibrary/GettingStarted/RoadMapiOS-Legacy/index.html#//apple_ref/doc/uid/TP40011343).
>
> This document is not a complete tutorial or a reference for the cross-platform OpenGL ES API. To learn more about OpenGL ES, consult the references below.

在尝试使用 OpenGL ES 之前，你应该已经熟悉一般的 iOS 应用程序架构。见 [Start Developing iOS Apps Today (Retired)](https://developer.apple.com/library/archive/referencelibrary/GettingStarted/RoadMapiOS-Legacy/index.html#//apple_ref/doc/uid/TP40011343)。

本文档不是跨平台 OpenGL ES API 的完整教程或参考。要了解有关 OpenGL ES 的更多信息，请参阅以下参考资料。

### See Also

> OpenGL ES is an open standard defined by the Khronos Group. For more information about the OpenGL ES standard, please consult their web page at [http://www.khronos.org/opengles/](http://www.khronos.org/opengles/).
>
> - *OpenGL® ES 3.0 Programming Guide*, published by Addison-Wesley, provides a comprehensive introduction to OpenGL ES concepts.
> - *OpenGL® Shading Language, Third Edition*, also published by Addison-Wesley, provides many shading algorithms useable in your OpenGL ES app. You may need to modify some of these algorithms to run efficiently on mobile graphics processors.
> - [OpenGL ES API Registry](http://www.khronos.org/registry/gles/) is the official repository for the OpenGL ES specifications, the OpenGL ES shading language specifications, and documentation for OpenGL ES extensions.
> - [OpenGL ES Framework Reference](https://developer.apple.com/documentation/opengles) describes the platform-specific functions and classes provided by Apple to integrate OpenGL ES into iOS.
> - [iOS Device Compatibility Reference](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013599) provides more detailed information on the hardware and software features available to your app.
> - [GLKit Framework Reference](https://developer.apple.com/documentation/glkit) describes a framework provided by Apple to make it easier to develop OpenGL ES 2.0 and 3.0 apps.

OpenGL ES 是 Khronos Group 定义的开放标准。有关 OpenGL ES 标准的更多信息，请访问他们的网页 [http://www.khronos.org/opengles/](http://www.khronos.org/opengles/) 。

- 由 Addison-Wesley 出版的 *OpenGL® ES 3.0 Programming Guide* 提供了对 OpenGL ES 概念的全面介绍。
- 由 Addison-Wesley 出版的 *OpenGL® Shading Language, Third Edition* ，提供了许多可用于 OpenGL ES 应用程序的着色算法。你可能需要修改其中一些算法才能在移动图形处理器上高效运行。
- [OpenGL ES API Registry](http://www.khronos.org/registry/gles/) 是 OpenGL ES 规范、OpenGL ES 着色语言规范以及 OpenGL ES 扩展文档的官方知识库。
- [OpenGL ES Framework Reference](https://developer.apple.com/documentation/opengles) 描述了 Apple 提供的用于将 OpenGL ES 集成到 iOS 中的特定于平台的功能和类。
- [iOS Device Compatibility Reference](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013599) 提供有关应用程序可用的硬件和软件功能的更多详细信息。
- [GLKit Framework Reference](https://developer.apple.com/documentation/glkit) 描述了 Apple 提供的框架，使用该框架可以更容易地开发 OpenGL ES 2.0 和 3.0 应用程序。

## Checklist for Building OpenGL ES Apps for iOS

> The OpenGL ES specification defines a platform-neutral API for using GPU hardware to render graphics. Platforms implementing OpenGL ES provide a rendering context for executing OpenGL ES commands, framebuffers to hold rendering results, and one or more rendering destinations that present the contents of a framebuffer for display. In iOS, the [EAGLContext](https://developer.apple.com/documentation/opengles/eaglcontext) class implements a rendering context. iOS provides only one type of framebuffer, the OpenGL ES framebuffer object, and the [GLKView](https://developer.apple.com/documentation/glkit/glkview) and [CAEAGLLayer](https://developer.apple.com/documentation/quartzcore/caeagllayer) classes implement rendering destinations.
>
> Building an OpenGL ES app in iOS requires several considerations, some of which are generic to OpenGL ES programming and some of which are specific to iOS. Follow this checklist and the detailed sections below to get started:
>
> 1. Determine which version(s) of OpenGL ES have the right feature set for your app, and create an OpenGL ES context.
> 2. Verify at runtime that the device supports the OpenGL ES capabilities you want to use.
> 3. Choose where to render your OpenGL ES content.
> 4. Make sure your app runs correctly in iOS.
> 5. Implement your rendering engine.
> 6. Use Xcode and Instruments to debug your OpenGL ES app and tune it for optimal performance .

OpenGL ES 规范定义了一个平台无关的 API ，用于使用 GPU 硬件渲染图形。实现 OpenGL ES 的平台提供用于执行 OpenGL ES 命令的渲染上下文，用于保存渲染结果的帧缓冲区，以及用于显示帧缓冲区内容的一个或多个渲染目的地。在 iOS 中，[EAGLContext](https://developer.apple.com/documentation/opengles/eaglcontext) 类实现了渲染上下文。iOS 仅提供一种类型的帧缓冲，OpenGL ES 帧缓冲对象，[GLKView](https://developer.apple.com/documentation/glkit/glkview) 和 [CAEAGLLayer](https://developer.apple.com/documentation/quartzcore/caeagllayer) 类实现渲染目标。

在 iOS 中构建 OpenGL ES 应用程序需要考虑几个因素，其中一些是 OpenGL ES 编程的通用代码，其中一些特定于 iOS 。按照此清单和下面的详细部分开始：

1. 确定哪个版本的 OpenGL ES 具有适合应用的功能集，并创建 OpenGL ES 上下文。
2. 在运行时验证设备是否支持你要使用的 OpenGL ES 功能。
3. 选择 OpenGL ES 内容渲染的位置。
4. 确保你的应用在 iOS 中正常运行。
5. 实现渲染引擎。
6. 使用 Xcode 和 Instruments 调试 OpenGL ES 应用程序并对其进行调整以获得最佳性能。

### Choosing Which OpenGL ES Versions to Support

> Decide whether your app should support OpenGL ES 3.0, OpenGL ES 2.0, OpenGL ES 1.1, or multiple versions.
>
> - OpenGL ES 3.0 is new in iOS 7. It adds a number of new features that enable higher performance, general-purpose GPU computing techniques, and more complex visual effects previously only possible on desktop-class hardware and game consoles.
> - OpenGL ES 2.0 is the baseline profile for iOS devices, featuring a configurable graphics pipeline based on programmable shaders.
> - OpenGL ES 1.1 provides only a basic fixed-function graphics pipeline and is available in iOS primarily for backward compatibility.
> You should target the version or versions of OpenGL ES that support the features and devices most relevant to your app. To learn more about the OpenGL ES capabilities of iOS devices, read [iOS Device Compatibility Reference](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013599).

> To create contexts for the versions of OpenGL ES you plan to support, read [Configuring OpenGL ES Contexts](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html#//apple_ref/doc/uid/TP40008793-CH2-SW1). To learn how your choice of OpenGL ES version relates to the rendering algorithms you might use in your app, read [OpenGL ES Versions and Renderer Architecture](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESApplicationDesign/OpenGLESApplicationDesign.html#//apple_ref/doc/uid/TP40008793-CH6-SW2).

确定你的应用程序是否应支持 OpenGL ES 3.0 ，OpenGL ES 2.0 ，OpenGL ES 1.1 或多个版本。

- OpenGL ES 3.0 是 iOS 7 中的新功能。它增加了许多新功能，支持更高性能，通用 GPU 计算技术，以及以前只能在桌面级硬件和游戏机上实现的更复杂的视觉效果。
- OpenGL ES 2.0 是 iOS 设备的基线配置，具有基于可编程着色器的可配置图形管道。
- OpenGL ES 1.1 仅提供基本的固定功能图形管道，主要用于向后兼容。
您应该选择支持与你的应用最相关的功能和设备的 OpenGL ES 版本。要了解有关 iOS 设备的 OpenGL ES 功能的更多信息，阅读 [iOS Device Compatibility Reference](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013599) 。

要为计划支持的 OpenGL ES 版本创建上下文，阅读 [Configuring OpenGL ES Contexts](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html#//apple_ref/doc/uid/TP40008793-CH2-SW1) 。要了解你选择的 OpenGL ES 版本如何与你可能在应用程序中使用的渲染算法相关，阅读 [OpenGL ES Versions and Renderer Architecture](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/OpenGLESApplicationDesign/OpenGLESApplicationDesign.html#//apple_ref/doc/uid/TP40008793-CH6-SW2) 。




































