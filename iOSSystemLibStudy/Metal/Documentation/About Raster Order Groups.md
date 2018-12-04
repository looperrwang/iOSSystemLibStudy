#  About Raster Order Groups

> Learn about precisely controlling the order of parallel fragment shader threads accessing the same pixel coordinates.

了解精确控制访问相同像素坐标的并行片段着色器线程的顺序。

## Overview

> Metal 2 introduces raster order groups that give ordered memory access from fragment shaders and simplify rendering techniques, such as order-independent transparency, dual-layer G-buffers, and voxelization.
>
> Given a scene containing two overlapping triangles, Metal guarantees that blending happens in draw call order, giving the illusion that the triangles are rendered serially. Figure 1 shows a blue triangle partially occluded by a green triangle.
>
> However, behind the scenes, the process is highly parallel; multiple threads are running concurrently, and there’s no guarantee that the fragment shader for the rear triangle has executed before the fragment shader for the front triangle. Figure 1 shows that although the two threads execute concurrently, the blending happens in draw call order.
>
> Figure 1 Blending of two triangles in draw call order

Metal 2 引入了栅格顺序组，可以从片段着色器中进行有序内存访问，并简化渲染技术，例如与顺序无关的透明度，双层 G 缓冲区和体素化。

给定一个包含两个重叠三角形的场景，Metal 保证以绘制调用顺序进行混合，从而产生三角形连续渲染的错觉。图 1 显示了一个被绿色三角形部分遮挡的蓝色三角形。

然而，在幕后，这个过程是高度并行的；多个线程同时运行，并且无法保证后三角形的片段着色器在前三角形的片段着色器之前执行完毕。 图 1 显示尽管两个线程同时执行，但是混合以绘制调用的顺序进行。

图 1 以绘制调用顺序混合两个三角形

![BlendingOfTwoTrianglesInDrawCallOrder](../resource/Metal/Markdown/BlendingOfTwoTrianglesInDrawCallOrder.png)

> A custom blend function in your fragment shader may need to read the results of the rear triangle’s fragment shader before applying that function based on the front triangle’s fragment. Because of concurrency, this read–modify–write sequence can create a race condition. Figure 2 shows thread 2 attempting to simultaneously read the same memory that thread 1 is writing.
>
> Figure 2 Attempting to simultaneously read and write the same memory

片段着色器中的自定义混合函数可能需要在前三角形片段应用该函数之前读取后三角形片段着色器的结果。由于并发性，此读取 - 修改 - 写入序列会产生竞争条件。图 2 显示了线程 2 试图读取线程 1 正在写入的相同内存。

图 2 试图同时读写相同的内存

![AttemptingToSimultaneouslyReadAndWriteTheSameMemory](../resource/Metal/Markdown/AttemptingToSimultaneouslyReadAndWriteTheSameMemory.png)

## Raster Order Groups for Overcoming Access Conflict - 用于克服访问冲突的光栅顺序组

Raster order groups overcome this access conflict by synchronizing threads that target the same pixel coordinates and sample (if per-sample shading is activated). You implement raster order groups by annotating pointers to memory with an attribute qualifier. Access through those pointers is then done in a per-pixel submission order. The hardware waits for any older fragment shader threads that overlap the current thread to finish before the current thread proceeds.

Figure 3 shows how raster order groups synchronize both threads so that thread 2 waits until the write is complete before attempting to read that piece of memory.

Figure 3 Synchronized threads serially reading and writing the same memory

光栅顺序组通过同步以相同像素坐标和样本为目标的线程（ 如果每个样本着色被激活 ）来克服此访问冲突。你可以通过使用属性限定符注释指向内存的指针来实现栅格顺序组。然后通过每个像素的提交顺序完成对这些指针的访问。硬件在当前线程继续之前等待与当前线程重叠的任何旧片段着色器线程完成。

图 3 显示了栅格顺序组如何同步两个线程，以便线程 2 在尝试读取该内存之前一直等待，直到写入操作完成。

图 3 同步线程串行读取和写入相同的内存

![SynchronizedThreadsSeriallyReadingAndWritingTheSameMemory](../resource/Metal/Markdown/SynchronizedThreadsSeriallyReadingAndWritingTheSameMemory.png)

## Extended Raster Order Groups with Metal 2 on A11




