#  Setting Up a Command Structure - 设置命令结构

> Discover how Metal executes commands on a GPU.

了解 Metal 如何在 GPU 上执行命令。

## Overview

> To get the GPU to perform work on your behalf, you send commands to it. A command performs the drawing, parallel computation, or resource management work your app requires. The relationship between Metal apps and a GPU is that of a client-server pattern:
>
> - Your Metal app is the client.
>
> - The GPU is the server.
>
> - You make requests by sending commands to the GPU.
>
> - After processing the commands, the GPU can notify your app when it's ready for more work.
>
> Figure 1 Client-server usage pattern when using Metal.

要让 GPU 代表你执行工作，你可以向其发送命令。命令执行应用程序所需的绘图，并行计算或资源管理工作。Metal 应用程序和 GPU 之间的关系是客户端 - 服务器模式的关系：

- 你的 Metal 应用程序是客户端。

- GPU是服务器。

- 你可以通过向 GPU 发送命令来发出请求。

- 处理完命令后，GPU 可以在其准备好进行更多工作时通知你的应用程序。

图 1 使用 Metal 时的客户端 - 服务器使用模式。

![Client-serverUsagePatternWhenUsingMetal](../../resource/Metal/Markdown/Client-serverUsagePatternWhenUsingMetal.png)

> To send commands to a GPU, you add them to a command buffer using a command encoder object. You add the command buffer to a command queue and then commit the command buffer when you're ready for Metal to execute the command buffer's commands. The order that you place commands in command buffers, enqueue and commit command buffers, is important because it effects the perceived order in which Metal promises to execute your commands.
>
> The following sections cover the steps to set up a working command structure, ordered in the way you create objects to interact with Metal.

要将命令发送到 GPU ，可以使用命令编码器对象将它们添加到命令缓冲区。将命令缓冲区添加到命令队列，然后在准备好 Metal 执行命令缓冲区命令时提交命令缓冲区。将命令放入命令缓冲区，入队和提交命令缓冲区的顺序非常重要，因为它会影响命令被 Metal 执行的顺序。

以下部分介绍了设置一个可以工作的命令结构的步骤，按照创建对象与 Metal 交互的方式排序。

## Make Initialization-Time Objects

> You create some Metal objects at initialization and normally keep them around indefinitely. Those are the command queue, and pipeline objects. You create them once because they're expensive to set up, but once initialized, they're fast to reuse.

在初始化时创建一些 Metal 对象，并且通常会无限期地保留它们。这样的对象包括命令队列和管道对象。创建它们一次因为它们设置起来很昂贵，但是一旦初始化，就可以快速地重复使用它们。

### Make a Command Queue

> To make a command queue, call the device's [newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue?language=objc) function:

要创建命令队列，请调用设备的 [newCommandQueue](https://developer.apple.com/documentation/metal/mtldevice/1433388-newcommandqueue?language=objc) 函数：

```objc
commandQueue = device.makeCommandQueue()
```

> Because you typically reuse the command queue, make a strong reference to it. You use the command queue to hold command buffers, as seen here:
>
> Figure 2 Your app's command queue.

因为你通常会重用命令队列，所以请对其进行强引用。你可以使用命令队列来保存命令缓冲区，如下所示：

图 2 应用程序的命令队列。

![YourApp'sCommandQueue](../../resource/Metal/Markdown/YourApp'sCommandQueue.png)

### Make One or More Pipeline Objects

> A pipeline object tells Metal how to process your commands. The pipeline object encapsulates functions that you write in the Metal shading language. Here's how pipelines fit into your Metal workflow:
>
> - You write Metal shader functions that process your data.
>
> - Create a pipeline object that contains your shaders.
>
> - When you're ready to use it, enable the pipeline.
>
> - Make draw, compute, or blit calls.
>
> Metal doesn't perform your draw, compute, or blit calls immediately; instead, you use an encoder object to insert commands that encapsulate those calls into your command buffer. After you commit the command buffer, Metal sends it to the GPU and uses the active pipeline object to process its commands.
>
> Figure 3 The active pipeline on the GPU containing your custom shader code that processes commands.

管道对象告诉 Metal 如何处理命令。管道对象封装了使用 Metal 着色语言编写的函数。以下是管道适合你的 Metal 工作流程的方式：

- 你编写处理数据的 Metal Shader 函数。

- 创建包含着色器的管道对象。

- 当准备好使用它时，启用管道。

- 进行绘制，计算或 blit 调用。

Metal 不会立即执行绘制，计算或 blit 调用；相反，你使用编码器对象将封装了这些调用的命令插入到命令缓冲区中。提交命令缓冲区后，Metal 将其发送到 GPU 并使用处于激活状态的管道对象处理其命令。
>
>图 3 GPU 上的已激活管道，包含处理命令的自定义着色器代码。

![TheActivePipelineOnTheGPUContainingYourCustomShaderCodeThatProcessesCommands](../../resource/Metal/Markdown/TheActivePipelineOnTheGPUContainingYourCustomShaderCodeThatProcessesCommands.png)

## Issue Commands to the GPU
















