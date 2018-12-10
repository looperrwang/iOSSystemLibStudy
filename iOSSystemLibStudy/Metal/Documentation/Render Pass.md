#  Render Pass

> A collection of commands that updates a set of render targets.

用于更新一组渲染目标的命令集合。

## Overview

> The draw commands you encode with a single render command encoder correspond to a single render pass. Therefore, there's a 1:1 relationship between a render command encoder and a render pass.
>
> On macOS, one of the ways that render passes surface in a Metal rendering workflow is when a group of draws must finish before another group of draws starts. For example, the [Deferred Lighting](https://developer.apple.com/documentation/metal/deferred_lighting?language=objc) sample code renders in two passes:
>
> - Graphical elements are rendered to an offscreen texture
>
> - The offscreen texture is analyzed and translated to a final rendering to the screen
>
> Deferred Lighting employs a two-pass rendering strategy on macOS because the render targets differ across the two passes: offscreen texture, versus the screen. Also, the first set of render targets is input to the second render pass, and thererfore the second render pass is dependent on the completion of the work done by the first render pass.

使用单个渲染命令编码器编码的绘制命令对应于单个渲染过程。因此，渲染命令编码器和渲染过程之间存在 1:1 的关系。

在 macOS 上，在 Metal 渲染工作流中渲染传递曲面的方法之一是在一组绘制开始之前，另一组绘制必须完成。例如，[Deferred Lighting](https://developer.apple.com/documentation/metal/deferred_lighting?language=objc) 示例代码分两个阶段渲染：

- 图形元素渲染至离屏纹理中

- 分析离屏纹理并将其转换为对屏幕的最终渲染

延迟光照在 macOS 上采用了两阶段渲染策略，因为两个阶段的渲染目标是不同的：离屏纹理，与屏幕相关的纹理。此外，第一阶段渲染目标是第二阶段渲染过程的输入，因此第二渲染阶段取决于第一阶段渲染过程的完成。

## Topics

### Programmable Sample Positions

> [Using Programmable Sample Positions](https://developer.apple.com/documentation/metal/render_pass/using_programmable_sample_positions?language=objc)
> Configure the position of samples when rendering to a multisampled render target.
>
> [Handling MSAA Depth with Programmable Sample Positions](https://developer.apple.com/documentation/metal/render_pass/handling_msaa_depth_with_programmable_sample_positions?language=objc)
> Use depth render targets and programmable sample positions effectively.

###  Dependency Viewing

> [Seeing a Frame's Render Passes with the Dependency Viewer](https://developer.apple.com/documentation/metal/render_pass/seeing_a_frame_s_render_passes_with_the_dependency_viewer?language=objc)
> View your render passes as a flow chart and inspect individual resource dependencies to understand which commands wait on others to complete.

[Using Programmable Sample Positions](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Using%20Programmable%20Sample%20Positions.md)
渲染到多重采样渲染目标时配置样本的位置。

[Handling MSAA Depth with Programmable Sample Positions](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Handling%20MSAA%20Depth%20with%20Programmable%20Sample%20Positions.md)
有效地使用深度渲染目标和可编程样本位置。

[Seeing a Frame's Render Passes with the Dependency Viewer](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Seeing%20a%20Frame's%20Render%20Passes%20with%20the%20Dependency%20Viewer.md)
以流程图的形式查看渲染过程并检查各个资源依赖关系，以了解哪些命令等待其他命令完成。

### Sample Code

> See how render passes are used in an example app.
>
> [Deferred Lighting](https://developer.apple.com/documentation/metal/deferred_lighting?language=objc)
> Demonstrates how to implement a deferred lighting renderer that takes advantage of unique Metal features.

示例应用程序中如何使用渲染过程。

[Deferred Lighting](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Deferred%20Lighting.md)
演示如何利用 Metal 独特功能实现延迟照明渲染器。
