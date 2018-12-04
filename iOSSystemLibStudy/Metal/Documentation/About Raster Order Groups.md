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





