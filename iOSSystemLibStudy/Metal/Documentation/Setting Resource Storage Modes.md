#  Setting Resource Storage Modes

> Set a storage mode that defines the memory location and access permissions of a resource.

设置存储模式，以定义资源的内存位置和访问权限。

## Overview

> [MTLStorageMode](https://developer.apple.com/documentation/metal/mtlstoragemode?language=objc) and [MTLResourceOptions](https://developer.apple.com/documentation/metal/mtlresourceoptions?language=objc) values allow you to define the memory location and access permissions of your [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) and [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture?language=objc) objects. By choosing an appropriate storage mode, you can configure these resources to benefit from fast memory access and driver-level performance optimizations.
>
> For [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) objects, create a new buffer with the [newBufferWithLength:options:](https://developer.apple.com/documentation/metal/mtldevice/1433375-newbufferwithlength?language=objc) method and set a storage mode in the method's options parameter.
>
> For [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture?language=objc) objects, create a new [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor?language=objc) and set a storage mode in the descriptor's [storageMode](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516262-storagemode?language=objc) property. Then create a new texture with the [newTextureWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433425-newtexturewithdescriptor?language=objc) method.

[MTLStorageMode](https://developer.apple.com/documentation/metal/mtlstoragemode?language=objc) 和 [MTLResourceOptions](https://developer.apple.com/documentation/metal/mtlresourceoptions?language=objc) 值允许你定义 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) 和 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture?language=objc) 对象的内存位置和访问权限。通过选择适当的存储模式，你可以配置这些资源以从快速内存访问和驱动级性能优化中受益。

对于 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) 对象，使用 [newBufferWithLength:options:](https://developer.apple.com/documentation/metal/mtldevice/1433375-newbufferwithlength?language=objc) 方法创建一个新缓冲区，并在方法的 options 参数中设置存储模式。

对于 [MTLTexture](https://developer.apple.com/documentation/metal/mtltexture?language=objc) 对象，创建新的 [MTLTextureDescriptor](https://developer.apple.com/documentation/metal/mtltexturedescriptor?language=objc) 并在描述符的 [storageMode](https://developer.apple.com/documentation/metal/mtltexturedescriptor/1516262-storagemode?language=objc) 属性中设置存储模式。然后使用 [newTextureWithDescriptor:](https://developer.apple.com/documentation/metal/mtldevice/1433425-newtexturewithdescriptor?language=objc) 方法创建一个新纹理。

## Topics

### Resource Storage Modes per Platform

> [Choosing a Resource Storage Mode in iOS and tvOS](https://developer.apple.com/documentation/metal/resource_objects/setting_resource_storage_modes/choosing_a_resource_storage_mode_in_ios_and_tvos?language=objc)
> Choose an appropriate storage mode for your iOS and tvOS resources.
>
> [Choosing a Resource Storage Mode in macOS](https://developer.apple.com/documentation/metal/resource_objects/setting_resource_storage_modes/choosing_a_resource_storage_mode_in_macos?language=objc)
> Choose an appropriate storage mode for your macOS resources.

[Choosing a Resource Storage Mode in iOS and tvOS](https://github.com/looperrwang/iOSSystemLibStudy/blob/Choosing%20a%20Resource%20Storage%20Mode%20in%20iOS%20and%20tvOS.md)
为 iOS 和 tvOS 资源选择合适的存储模式。

[Choosing a Resource Storage Mode in macOS](https://developer.apple.com/documentation/metal/resource_objects/setting_resource_storage_modes/choosing_a_resource_storage_mode_in_macos?language=objc)
为 macOS 资源选择合适的存储模式。
