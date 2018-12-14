#  GPU Functions & Libraries

> Load GPU functions with a library object and introspect shaders at runtime.

在运行时使用库对象加载 GPU 函数并 introspect 着色器。

## Overview

> Specify how your app renders its graphics, and how it processes its data on the GPU by creating an [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction?language=objc). Write a fragment function to determine how your app does any graphics processing. Provide a vertex, or tesselation function to describe the spacial characteristics of your app's graphics. Share functions across multiple processes by compiling them into an [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary?language=objc). To do that, see [Building a Library with Metal's Command-Line Tools](https://developer.apple.com/documentation/metal/gpu_functions_libraries/building_a_library_with_metal_s_command-line_tools?language=objc). Run your GPU functions by instantiating your library, and accessing the function by name using MTLLibrary's [newFunctionWithName:](https://developer.apple.com/documentation/metal/mtllibrary/1515524-newfunctionwithname?language=objc).

通过创建 [MTLFunction](https://developer.apple.com/documentation/metal/mtlfunction?language=objc) 指定应用程序如何渲染其图形，以及如何在 GPU 上处理数据。编写片段函数以确定你的应用程序如何处理任何图形。提供顶点或 tesselation 函数来描述应用程序图形的空间特征。通过将多个函数编译到一个 [MTLLibrary](https://developer.apple.com/documentation/metal/mtllibrary?language=objc) 来在多个进程之间共享函数。为此，见 [Building a Library with Metal's Command-Line Tools](https://developer.apple.com/documentation/metal/gpu_functions_libraries/building_a_library_with_metal_s_command-line_tools?language=objc) 。通过实例化库来运行 GPU 函数，并使用 MTLLibrary 的 [newFunctionWithName:](https://developer.apple.com/documentation/metal/mtllibrary/1515524-newfunctionwithname?language=objc) 按名称访问函数。

## Topics

### Functions

> Create your app's shaders that run on the GPU.
>
> [About the Metal Shading Language Filename Extension](https://developer.apple.com/documentation/metal/gpu_functions_libraries/about_the_metal_shading_language_filename_extension?language=objc)
Use the .metal filename extension to gain access to Metal's build, profile, and debug tools.
>
> [Resolving Shader Issues with the Shader Debugger](https://developer.apple.com/documentation/metal/gpu_functions_libraries/resolving_shader_issues_with_the_shader_debugger?language=objc)
Step through shader execution with the ability to inspect variable values and update shader code in place.
>
> [Optimizing Performance with the Shader Profiler](https://developer.apple.com/documentation/metal/gpu_functions_libraries/optimizing_performance_with_the_shader_profiler?language=objc)
View the elapsed execution time of individual statements in your shader to understand where it spends the most time.

创建在 GPU 上运行的应用程序着色器。

[About the Metal Shading Language Filename Extension](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/About%20the%20Metal%20Shading%20Language%20Filename%20Extension.md)
使用 .metal 文件扩展名来访问 Metal 的构建，配置文件和调试工具。

[Resolving Shader Issues with the Shader Debugger](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Resolving%20Shader%20Issues%20with%20the%20Shader%20Debugger.md)
单步着色器执行，能够检查变量值并更新着色器代码。

[Optimizing Performance with the Shader Profiler](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Optimizing%20Performance%20with%20the%20Shader%20Profiler.md)
查看着色器中各个语句的已用执行时间，以了解花费最多时间的位置。

### Libraries

> Use the default library, or bundle multiple functions in a library you can share across apps.
>
> [Building a Library with Metal's Command-Line Tools](https://developer.apple.com/documentation/metal/gpu_functions_libraries/building_a_library_with_metal_s_command-line_tools?language=objc)
> Use command-line tools to run the Metal compiler toolchain.

使用默认库，或在可以跨应用程序共享的库中捆绑多个功能。

[Building a Library with Metal's Command-Line Tools](https://github.com/looperrwang/iOSSystemLibStudy/blob/master/Building%20a%20Library%20with%20Metal's%20Command-Line%20Tools.md)
使用命令行工具运行 Metal 编译器工具链。
