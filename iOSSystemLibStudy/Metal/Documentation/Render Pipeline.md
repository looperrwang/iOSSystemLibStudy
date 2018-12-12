#  Render Pipeline

> A specification for how graphics primitives should be rendered.

应该如何呈现图形基元的规范。

## Overview

> A rendering pipeline consists of custom functions you provide to process graphics commands on the GPU. The order that functions are exectuted in a render pipeline is defined by Metal, but you supply the function implementations. Set up pipeline objects ahead of time (typically, at initialization) because pipelines are expesive to create, but quick to reuse.

渲染管道由你提供的自定义函数组成，用于处理 GPU 上的图形命令。函数在渲染管道中被执行的顺序由 Metal 定义，但是你提供函数实现。提前设置管道对象（通常在初始化时），因为管道很难创建，但可以快速重用。

## Topics

### Statistics Viewing

> [Viewing Pipeline Statistics of a Draw](https://developer.apple.com/documentation/metal/render_pipeline/viewing_pipeline_statistics_of_a_draw?language=objc)
> See relative percentages of where a given draw call spent its time across the GPU architecture.
>
> [Viewing Performance Metrics with GPU Counters](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Render%20Pipeline.md)
> Ensure that properties related to an encoder's rendering are within the desired range.

[Viewing Pipeline Statistics of a Draw](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Viewing%20Pipeline%20Statistics%20of%20a%20Draw.md)
查看给定绘制调用在 GPU 架构中花费时间的相对百分比。

[Viewing Performance Metrics with GPU Counters](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Viewing%20Performance%20Metrics%20with%20GPU%20Counters.md)
确保与编码器渲染相关的属性在期望范围内。
