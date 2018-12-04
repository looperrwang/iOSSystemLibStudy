#  About Tile Shading

> Learn about combining rendering and compute operations into a single render pass while sharing local memory.

## Overview

> Many rendering techniques require a mixture of drawing and compute commands. Traditionally, rendering and compute commands were separated into distinct passes. These passes couldn’t communicate directly with each other; results from one pass were copied into device memory, only to be copied back into local memory by the next pass. In a multiphase rendering algorithm, intermediate data might be copied to device memory multiple times, as shown in Figure 1.
>
> Figure 1 Render and compute passes communicating through device memory

许多渲染技术需要混合绘图和计算命令。传统上，渲染和计算命令被分成不同的过程。这些过程无法直接相互通信；一个过程的结果被复制到设备存储器中，只能在下一个过程时复制回本地存储器。在多阶段渲染算法中，中间数据可能会被多次复制到设备存储器，如图 1 所示。

图 1 通过设备内存进行渲染和计算过程通信

![RenderAndComputePassesCommunicatingThroughDeviceMemory](../../resource/Metal/Markdown/RenderAndComputePassesCommunicatingThroughDeviceMemory.png)

> Tile shaders are compute or fragment functions that execute as part of a render pass, allowing for midrender compute with persistent memory between rendering phases. Figure 2 shows that the tile memory that tile shaders work within remains in the on-chip memory of the graphics processing unit (GPU). As a result, you avoid having to store intermediate results out to device memory. Tile memory from one phase is available to any subsequent fragment phases.
>
> Figure 2 Render and compute passes communicating through tile memory

tile 着色器是计算或片段函数，它们作为渲染过程的一部分执行，允许使用渲染阶段之间的持久内存进行 midrender 计算。图 2 显示了 tile 着色器工作的 tile 内存，该内存保留在图形处理单元（ GPU ）的片上内存中。因此，你可以避免将中间结果存储到设备内存中。来自一个阶段的 tile 内存可用于任何后续片段阶段。

图 2 通过 tile 内存进行渲染和计算过程通信

![RenderAndComputePassesCommunicatingThroughTileMemory](../../resource/Metal/Markdown/RenderAndComputePassesCommunicatingThroughTileMemory.png)
