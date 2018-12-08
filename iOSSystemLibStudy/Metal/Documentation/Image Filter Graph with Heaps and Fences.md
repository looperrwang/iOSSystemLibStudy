#  Image Filter Graph with Heaps and Fences

> Demonstrates how to use heaps and fences to optimize a multistage image filter.

演示如何使用堆和栅栏来优化多级图像滤镜。

## Overview

> This sample demonstrates:
>
> - Creating heaps for static and dynamic textures
>
> - Using aliasing to reduce the amount of memory used for temporary resources
>
> - Using fences to manage dependencies between encoders that produce and consume dynamic textures
>
> This implementation minimizes memory usage in an orderly fashion for a filter graph with a downsample and a Gaussian blur filter.


