#  CPU and GPU Synchronization

> Demonstrates how to update buffer data and synchronize access between the CPU and GPU.

演示如何更新缓冲区数据并同步 CPU 和 GPU 之间的访问。

## Overview

> In this sample you’ll learn how to properly update and render animated resources that are shared between the CPU and the graphics processing unit (GPU). In particular, you’ll learn how to modify data each frame, avoid data access hazards, and execute CPU and GPU work in parallel.

在此示例中，你将学习如何正确更新和渲染 CPU 与图形处理单元（ GPU ）之间共享的动画资源。特别是，你将学习如何每帧修改数据，避免数据访问危险，并且并行执行 CPU 和 GPU 工作。

## CPU/GPU Parallelism and Shared Resource Access

> The CPU and GPU are separate, asynchronous processors. In a Metal app or game, the CPU encodes commands and the GPU executes commands. This sequence is repeated in every frame, and a full frame’s work is completed when both the CPU and the GPU have finished their work. The CPU and the GPU can work in parallel and don’t need to wait for each other to finish their work. For example, the GPU can execute commands for frame 1 while the CPU encodes commands for frame 2.
>
> This CPU/GPU parallelism has great advantages for your Metal app or game, effectively enabling you to run on two processors at once. However, these processors still work together and usually access the same shared resources, such as vertex buffers or fragment textures. Shared resource access must be handled with care; otherwise, the CPU and GPU might access a shared resource at the same time, resulting in a race condition and corrupted data.
>
> This sample, like most Metal apps or games, renders animated content by updating vertex data in each frame. Consider the following sequence:
>
> 1. The render loop starts a new frame.
>
> 2. The CPU writes new vertex data into the vertex buffer.
>
> 3. The CPU encodes render commands and commits a command buffer.
>
> 4. The GPU begins executing the command buffer.
>
> 5. The GPU reads vertex data from the vertex buffer.
>
> 6. The GPU renders pixels to a drawable.
>
> 7. The render loop completes the frame.
>
> In this sequence, the CPU and GPU both share a single vertex buffer. If the processors wait for each other to finish their work before beginning their own work, there are no access conflicts for the shared vertex buffer. This model avoids access conflicts, but wastes valuable processing time: when one processor is working, the other is idle.

CPU 和 GPU 是独立的异步处理器。在 Metal 应用程序或游戏中，CPU 对命令进行编码，GPU 执行命令。在每帧中重复这样的工作序列，并且当 CPU 和 GPU 都完成其工作时整个帧的工作完成。CPU 和 GPU 可以并行工作，无需等待彼此完成工作。例如，GPU 可以执行第一帧的命令，同时 CPU 对第二帧的命令进行编码。

这种 CPU / GPU 并行性对于你的 Metal 应用程序或游戏具有很大的优势，有效地使你可以同时在两个处理器上运行。但是，这些处理器仍然可以协同工作，并且通常可以访问相同的共享资源，例如顶点缓冲区或片段纹理。必须小心处理共享资源访问；否则，CPU 和 GPU 可能同时访问共享资源，从而导致竞争条件和数据损坏。

与大多数 Metal 应用或游戏一样，此示例通过每帧更新顶点数据来渲染动画内容。请考虑以下顺序：

1. 渲染循环启动新的一帧。

2. CPU 将新的顶点数据写入顶点缓冲区。

3. CPU 对渲染命令进行编码并提交命令缓冲区。

4. GPU 开始执行命令缓冲区。

5. GPU 从顶点缓冲区读取顶点数据。

6. GPU 将像素渲染到 drawable 。

7. 渲染循环完成当前帧。

在此序列中，CPU 和 GPU 共享一个顶点缓冲区。如果处理器在开始自己的工作之前等待彼此完成工作，则共享顶点缓冲区没有访问冲突。此模型避免了访问冲突，但浪费了宝贵的处理实践：当一个处理器正在工作时，另一个处理器处于空闲状态。

