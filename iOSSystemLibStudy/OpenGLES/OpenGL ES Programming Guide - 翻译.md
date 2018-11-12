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

OpenGL 允许应用程序利用底层图形处理器的强大功能。iOS 设备上的 GPU 可以执行复杂的 2D 和 3D 绘图，以及最终图像中每个像素的复杂着色计算。





























