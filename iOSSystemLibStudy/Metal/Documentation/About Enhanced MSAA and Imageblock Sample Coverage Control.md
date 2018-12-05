#  About Enhanced MSAA and Imageblock Sample Coverage Control - 关于增强的 MSAA 和 Imageblock 样本覆盖控制

> Learn about accessing multisample tracking data within a tile shader, enabling development of custom MSAA resolve algorithms, and more.

了解如何在 tile 着色器中访问多重采样跟踪数据，启用自定义 MSAA 解析算法的开发等。

## Overview

> Multisample antialiasing (MSAA) is a technique used to improve the appearance of primitive edges by using multiple depth and color samples for each pixel. Figure 1 shows a triangle rendered without MSAA. Because each pixel has a single sample position, it’s either covered or not covered by the triangle, leading to jagged edges.
>
> Figure 1 Antialiasing using a single sample per pixel

多重采样抗锯齿（ MSAA ）是一种通过对每个像素使用多个深度和颜色样本来改善图元边缘外观的技术。图 1 显示了没有使用 MSAA 渲染的三角形。因为每个像素只有一个样本位置，所以它要么被三角形覆盖要么不被三角形覆盖，导致锯齿状边缘。

图 1 每个像素单个样本的抗锯齿

![AntialiasingUsingaSingleSamplePerPixel](../../resource/Metal/Markdown/AntialiasingUsingaSingleSamplePerPixel.png)

> Figure 2 shows the same triangle rendered using 4x MSAA; that is, each pixel has four sampling positions. The graphics processing unit (GPU) averages the colors of each sample within the pixel to determine a final color. This process results in a smoother appearance and reduces the jagged edges.
>
> Figure 2 Antialiasing using four samples per pixel

图 2 显示了使用 4x MSAA 渲染的相同三角形；也就是说，每个像素具有四个采样位置。图形处理单元（ GPU ）平均像素内的每个样本的颜色以确定最终颜色。该过程产生更光滑的外观并减少锯齿状边缘。

图 2 每个像素使用四个样本进行抗锯齿处理

![AntialiasingUsingFourSamplesPerixel](../../resource/Metal/Markdown/AntialiasingUsingFourSamplesPerixel.png)

> Apple’s A-Series GPUs have an efficient MSAA implementation. The hardware tracks whether each pixel contains a primitive edge so that your blending executes per sample only when necessary. If all samples in a pixel are covered by a single primitive, the GPU blends only once for the entire pixel.

Apple 的 A 系列 GPU 具有高效的 MSAA 实现。硬件跟踪每个像素是否包含图元边缘，以便仅在必要时对每个样本执行混合。如果像素中的所有样本都被单个图元覆盖，则 GPU 仅对整个像素进行一次混合。

## Imageblock Sample Coverage Control

> Metal 2 on A11 tracks the number of unique samples (or colors) for each pixel, updating this information as new primitives are rendered. For example, the pixel in Figure 3 contains the edges of two overlapping triangles, and the sample positions are covered by three unique colors. In current A-Series GPUs, this pixel blends each of the three covered samples. On the A11 GPU, this pixel blends only twice because two of the covered samples share the same color. In this case, the color at index 1 is a blend of green and pink, and the color at index 2 is pink.
>
> Figure 3 One pixel that contains three unique samples

A11 上的 Metal 2 跟踪每个像素的唯一样本（或颜色）的数量，在渲染新图元时更新此信息。例如，图 3 中的像素包含两个重叠三角形的边缘，样本位置由三种独特的颜色覆盖。在当前的 A 系列 GPU 中，该像素混合了三个覆盖样本中的每一个。在 A11 GPU 上，此像素仅混合两次，因为两个覆盖的样本共享相同的颜色。在这种情况下，索引 1 处的颜色是绿色和粉红色的混合，索引 2 处的颜色是粉红色。

图 3 一个包含三个唯一样本的像素

![OnePixelThatContainsThreeUniqueSamples](../../resource/Metal/Markdown/OnePixelThatContainsThreeUniqueSamples.png)

> Metal 2 on A11 can reduce the number of unique colors in a pixel. In Figure 4, an additional opaque triangle is rendered on top of the earlier primitives. Because all of the samples are covered by the new triangle and can be represented by a single color, the A11 GPU merges the three colors into one.

Figure 4 One pixel that contains one unique sample

A11 上的 Metal 2 可以减少像素中唯一颜色的数量。在图 4 中，在较早的图元之上渲染了另一个不透明的三角形。由于所有样本都被新三角形覆盖并且可以用单个颜色表示，因此 A11 GPU 将三种颜色合并为一种颜色。

图 4 包含一个唯一样本的像素

![OnePixelThatContainsOneUniqueSample](../../resource/Metal/Markdown/OnePixelThatContainsOneUniqueSample.png)

> Additionally, you can access and modify sample coverage data in tile shaders to implement custom resolve algorithms. For example, given a complex scene containing separate render phases for opaque and translucent geometry, you can add a tile shader to resolve the sample data for the opaque geometry before blending the translucent geometry. With Metal 2 on A11, this tile shader works on data in local memory and can be part of the opaque geometry phase, as shown in Figure 5.

Figure 5 Using a tile shader to implement a custom resolve algorithm

此外，你可以在 tile 着色器中访问和修改样本覆盖数据，以实现自定义解析算法。例如，给定包含不透明和半透明几何体的单独渲染阶段的复杂场景，你可以添加 tile 着色器以在混合半透明几何体之前解析不透明几何体的样本数据。使用 A11 上的 Metal 2 ，此 tile 着色器可以处理本地内存中的数据，并且可以是不透明几何阶段的一部分，如图 5 所示。

图 5 使用 tile 着色器实现自定义解析算法

![UsingATileShaderToImplementACustomResolveAlgorithm](../../resource/Metal/Markdown/UsingATileShaderToImplementACustomResolveAlgorithm.png)
