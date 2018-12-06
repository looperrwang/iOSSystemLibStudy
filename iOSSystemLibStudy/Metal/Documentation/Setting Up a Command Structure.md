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

> With your command queue and pipeline(s) set up, it's time for you to issue commands to the GPU. Here's the process you follow:
>
> 1. Create a command buffer.
>
> 2. Fill the buffer with commands.
>
> 3. Commit the command buffer to the GPU.
>
> If you're performing animation as part of a rendering loop, you do this for every frame of the animation. You also follow this process to execute one-off image processing, or machine learning tasks.
>
> The following subsections walk you through these steps in detail.

设置命令队列和管道后，就可以向 GPU 发出命令了。这是应该遵循的流程：

1. 创建命令缓冲区。

2. 使用命令填充缓冲区。

3. 将命令缓冲区提交给 GPU 。

如果你将动画作为渲染循环的一部分来执行，则可以对动画的每一帧执行此操作。你还可以按照此过程执行一次性图像处理或机器学习任务。

以下小节将详细介绍这些步骤。

### Create a Command Buffer

> Create a command buffer by calling commandBuffer on the command queue:
>
> Listing 2 Creating a command buffer.

通过在命令队列上调用 commandBuffer 来创建命令缓冲区：

清单 2 创建命令缓冲区。

```objc
guard let commandBuffer = commandQueue.makeCommandBuffer() else { 
    return 
}
objc
```

> For single-threaded apps, you create a single command buffer. shows the relationship between commands and their command buffer:
>
> Figure 4 A command buffer's relationship to the commands it contains.

对于单线程应用程序，创建单个命令缓冲区。下图显示了命令与其命令缓冲区之间的关系：

图 4 命令缓冲区与其包含的命令的关系。

![ACommandBuffer'sRelationshipToTheCommandsItContains](../../resource/Metal/Markdown/ACommandBuffer'sRelationshipToTheCommandsItContains.png)

### Add Commands to the Command Buffer

> When you call task-specific functions on an encoder object–like draws, compute or blit operations–the encoder places commands corresponding to those calls in the command buffer. The encoder encodes the commands to include everything the GPU needs to process the task at runtime. shows the workflow:
>
> Figure 5 Command encoder inserting commands into a command buffer as the result of a draw.

当你在编码器对象（如绘制，计算或 blit 操作）上调用特定于任务的函数时，编码器会将与这些调用相对应的命令放到命令缓冲区中。编码器对命令进行编码以包括 GPU 在运行时处理任务所需的所有内容。显示工作流程：

图 5 命令编码器将命令插入命令缓冲区作为绘制结果。

![CommandEncoderInsertingCommandsIntoAcommandBufferAsTheResultOfaDraw](../../resource/Metal/Markdown/CommandEncoderInsertingCommandsIntoAcommandBufferAsTheResultOfaDraw.png)

> You encode actual commands with concrete subclasses of [MTLCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandencoder?language=objc), depending on your task:
>
> - Use [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder?language=objc) to issue render commands.
>
> - Use [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder?language=objc) to issue parallel computation commands.
>
> - Use [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder?language=objc) to issue resource management commands.
>
> See [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) for a complete rendering example. See Hello Compute for a complete parallel processing example.

使用 [MTLCommandEncoder](https://developer.apple.com/documentation/metal/mtlcommandencoder?language=objc) 的具体子类编码实际命令，具体取决于你的任务：

使用 [MTLRenderCommandEncoder](https://developer.apple.com/documentation/metal/mtlrendercommandencoder?language=objc) 发出渲染命令。

使用 [MTLComputeCommandEncoder](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder?language=objc) 发出并行计算命令。

使用 [MTLBlitCommandEncoder](https://developer.apple.com/documentation/metal/mtlblitcommandencoder?language=objc) 发出资源管理命令。

有关完整的渲染示例，请参阅 [Hello Triangle](https://developer.apple.com/documentation/metal/hello_triangle?language=objc) 。 有关完整的并行处理示例，请参阅 Hello Compute 。

### Commit a Command Buffer

> To enable your commands to run, you commit the command buffer to the GPU:

提交命令缓冲区到 GPU 以使命令能够运行：

```objc
commandBuffer.commit()
```

> Committing a command buffer doesn't run its commands immediately. Instead, Metal schedules the buffer's commands to run only after you commit prior command buffers that are waiting in the queue. If you haven't explicitly enqueued a command buffer, Metal does that for you once you commit the buffer.
> 
> You don't reuse a buffer after it's committed, but you can opt into notification of its scheduling, completion, or query its [status](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status?language=objc).
>
> The promise upheld by Metal is that the perceived order in which commands are executed is the same as the way you ordered them. While Metal might reorder some of your commands before processing them, this normally only occurs when there's a performance gain and no other perceivable impact.

提交命令缓冲区不会立即运行其命令。相反，只有在队列中等待的先前命令缓冲区提交之后，Metal 才会调度新的缓冲区命令去运行。如果你没有明确地将命令缓冲区排入队列，则在你提交缓冲区后，Metal 会为你执行入队操作。

缓冲区被提交之后，不要重用该缓冲区，但可以监听其调度、完成的通知来进行必要的操作，也可以查询其 [status](https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status?language=objc) 属性。

Metal 坚持的承诺是，命令执行的感知顺序与你对命令排序的方式相同。虽然 Metal 可能会在处理之前重新排序某些命令，但这通常只会在可以获取性能提升且没有其他可感知的影响时发生。
