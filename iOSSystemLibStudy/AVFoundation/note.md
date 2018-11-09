# AVFoundation Programming Guide - AVFoundation 编程指引

## About AVFoundation - AVFoundation 概述

> AVFoundation is one of several frameworks that you can use to play and create time-based audiovisual media. It provides an Objective-C interface you use to work on a detailed level with time-based audiovisual data. For example, you can use it to examine, create, edit, or reencode media files. You can also get input streams from devices and manipulate video during realtime capture and playback. Figure I-1 shows the architecture on iOS.

AVFoundation 是可以用来播放并且创建基于时间的视听媒体的框架之一。框架提供了一系列 Objective-C 的接口，使用这些接口可以从非常全面的角度处理基于时间的视听媒体数据。例如，你可以用它来检查、创建、编辑或者重新编码媒体文件。甚至可以捕获硬件的输入流，可以在实时捕捉及回放的视频流中操纵视频数据。图 I-1 描述了其在 iOS 平台上的架构。

![iOS架构](../../resource/AVFoundation/Markdown/iOS架构.png)

> Figure I-2 shows the corresponding media architecture on OS X.

图 I-2 描述了 OS X 平台上媒体相关框架的架构。

![OS X架构](../../resource/AVFoundation/Markdown/OSX架构.png)

> You should typically use the highest-level abstraction available that allows you to perform the tasks you want.
> - If you simply want to play movies, use the AVKit framework.
> - On iOS, to record video when you need only minimal control over format, use the UIKit framework ([UIImagePickerController](https://developer.apple.com/documentation/uikit/uiimagepickercontroller)).
>
> Note, however, that some of the primitive data structures that you use in AV Foundation—including time-related data structures and opaque objects to carry and describe media data—are declared in the Core Media framework.

通常，你应该使用可用的最高级别的抽象框架来完成你想完成的任务。
- 如果只是想简单的播放 movies ，使用 AVKit framework 。
- iOS 平台上，如果只需录制视频，同时对格式没有格外要求的情况下，使用 UIKit framework 的 [UIImagePickerController](https://developer.apple.com/documentation/uikit/uiimagepickercontroller) 。

需要注意的一点是，AV Foundation 中的一些原始数据结构其实是定义在 Core Media framework 中，这其中包括时间相关的数据结构、承载及描述媒体数据的相关对象。

### At a Glance - 摘要

> There are two facets to the AVFoundation framework—APIs related to video and APIs related just to audio. The older audio-related classes provide easy ways to deal with audio.
>
> - To play sound files, you can use [AVAudioPlayer](https://developer.apple.com/documentation/avfoundation/avaudioplayer).
> - To record audio, you can use [AVAudioRecorder](https://developer.apple.com/documentation/avfoundation/avaudiorecorder).
>
> You can also configure the audio behavior of your application using [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession); this is described in [Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007875).

AVFoundation framework 包含视频相关的 API 及音频相关的 API 。旧的音频相关的类提供了简便的方式去处理音频。
- 播放音频文件，可以使用 [AVAudioPlayer](https://developer.apple.com/documentation/avfoundation/avaudioplayer) 。
- 录制音频，可以使用 [AVAudioRecorder](https://developer.apple.com/documentation/avfoundation/avaudiorecorder) 。

你也可以使用 [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession) 来配置应用程序的音频行为，[Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007875) 提供了相关的描述。

#### Representing and Using Media with AVFoundation - 通过 AVFoundation 表示以及使用媒体

> The primary class that the AV Foundation framework uses to represent media is [AVAsset](https://developer.apple.com/documentation/avfoundation/avasset). The design of the framework is largely guided by this representation. Understanding its structure will help you to understand how the framework works. An AVAsset instance is an aggregated representation of a collection of one or more pieces of media data (audio and video tracks). It provides information about the collection as a whole, such as its title, duration, natural presentation size, and so on. AVAsset is not tied to particular data format. AVAsset is the superclass of other classes used to create asset instances from media at a URL (see [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)) and to create new compositions (see [Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40010188-CH1-SW1)).

AVFoundation framework 用来表示媒体的最主要的类是 [AVAsset](https://developer.apple.com/documentation/avfoundation/avasset) 。整个框架的设计很大程度上受到这种抽象表示方法的引导。理解它的结构将会有助于理解整个框架是如何工作的。一段或多段媒体数据（音频轨道与视频轨道）构成一个集合，一个 AVAsset 实例就是这样一个集合的汇总表示。AVAsset 实例将整个集合作为一个整体，提供了一些诸如名称、时长、自然呈现大小等的信息。AVAsset 独立于特定的数据格式。通过使用 AVAsset 的众多子类，根据 URL 指定的媒体数据（see [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1) ），可以创建具体的 asset 实例、创建新的结构（see [Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40010188-CH1-SW1) ）。

> Each of the individual pieces of media data in the asset is of a uniform type and called a track. In a typical simple case, one track represents the audio component, and another represents the video component; in a complex composition, however, there may be multiple overlapping tracks of audio and video. Assets may also have metadata.

asset 中媒体数据的每个单独的部分，被称为一个 track ，每个部分都是一个统一的类型。典型的简单情况下，其中一个 track 代表音频组件，另一个代表视频组件；然而，在复杂组合的情况下，可能存在多个重叠的音频和视频 track 。Assets 也可能有元数据。

> A vital concept in AV Foundation is that initializing an asset or a track does not necessarily mean that it is ready for use. It may require some time to calculate even the duration of an item (an MP3 file, for example, may not contain summary information). Rather than blocking the current thread while a value is being calculated, you ask for values and get an answer back asynchronously through a callback that you define using a block.

AV Foundation 中一个重要的概念是，初始化一个 asset 或者一个 track 通常并不意味着它已经处于可以使用的状态了。可能需要一些时间去计算某些数据，比如某个 item 的持续时间（例如，一个可能不包含摘要信息的 MP3 文件）。你应该在当前线程发起查询某个值的请求，在 block 实现的异步回调中获取所需要的数据，而不是采用阻塞当前线程的方式。

> Relevant Chapters: [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1), [Time and Media Representations](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW1)

相关章节：[Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)，[Time and Media Representations](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW1)

#### Playback - 播放

> AVFoundation allows you to manage the playback of asset in sophisticated ways. To support this, it separates the presentation state of an asset from the asset itself. This allows you to, for example, play two different segments of the same asset at the same time rendered at different resolutions. The presentation state for an asset is managed by a player item object; the presentation state for each track within an asset is managed by a player item track object. Using the player item and player item tracks you can, for example, set the size at which the visual portion of the item is presented by the player, set the audio mix parameters and video composition settings to be applied during playback, or disable components of the asset during playback.

AVFoundation 允许用户以多种复杂的方式来管理 asset 的播放。为了支持这一点，框架将 asset 的呈现状态从 asset 自身中分离出来。举个例子，这样的设计允许用户将同一个 asset 的不同片段同时渲染在不同的分辨率下。一个 asset 的呈现状态由一个 player item object 管理；一个 asset 中各个 track 的呈现状态由一个 player item track object 管理。例如，使用 player item 与 player item tracks ，可以设置 item 呈现的可视区域的大小，可以改变播放过程中的音频混合参数以及视频合成设置，可以在播放过程中禁用需要禁用的组件。

> You play player items using a player object, and direct the output of a player to the Core Animation layer. You can use a player queue to schedule playback of a collection of player items in sequence.

你可以使用一个 player object 来播放多个 player items ，并且将该 player 的输出直接输出到 Core Animation layer 上面去。你可以使用一个 player queue 以串行的方式调度一系列 player items 的播放。

> Relevant Chapter: [Playback](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW1)

相关章节：[Playback](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW1)

#### Reading, Writing, and Reencoding Assets - 读、写、重编码 Assets

> AVFoundation allows you to create new representations of an asset in several ways. You can simply reencode an existing asset, or—in iOS 4.1 and later—you can perform operations on the contents of an asset and save the result as a new asset.

AVFoundation 允许你以多种方式创建 asset 的新表现形式。你可以简单地重新编码已经存在的 asset ，除此之外，iOS 4.1 及以后的版本，你可以操作 asset 的内容，然后将结果保存为新的 asset 。

> You use an export session to reencode an existing asset into a format defined by one of a small number of commonly-used presets. If you need more control over the transformation, in iOS 4.1 and later you can use an asset reader and asset writer object in tandem to convert an asset from one representation to another. Using these objects you can, for example, choose which of the tracks you want to be represented in the output file, specify your own output format, or modify the asset during the conversion process.

可以使用 export session 将一个已经存在的 asset 重新编码为少数常用预设格式之一。如果需要针对 transformation 进行更多的控制，那么在 iOS 4.1 及更高版本中，可以使用一个 asset reader object 和一个 asset writer object 将 asset 从一种表示转换为另一种。例如，使用这些对象，你可以选择最终输出文件中包含哪些想要的 tracks ，指定自己的输出格式，或者在转换过程中修改 asset 。

> To produce a visual representation of the waveform, you use an asset reader to read the audio track of an asset.

如果需要生成波形的可视化表示，可以使用一个 asset reader 读取 asset 的音频 track 。

> Relevant Chapter: [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

相关章节：[Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

#### Thumbnails - 缩略图

> To create thumbnail images of video presentations, you initialize an instance of AVAssetImageGenerator using the asset from which you want to generate thumbnails. AVAssetImageGenerator uses the default enabled video tracks to generate images.

要创建视频演示文稿的缩略图图像，使用需要生成缩略图的 asset 初始化一个 AVAssetImageGenerator 实例。AVAssetImageGenerator 使用可用的默认视频 tracks 来生成图像。

> Relevant Chapter: [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

相关章节：[Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

#### Editing - 编辑

> AVFoundation uses compositions to create new assets from existing pieces of media (typically, one or more video and audio tracks). You use a mutable composition to add and remove tracks, and adjust their temporal orderings. You can also set the relative volumes and ramping of audio tracks; and set the opacity, and opacity ramps, of video tracks. A composition is an assemblage of pieces of media held in memory. When you export a composition using an export session, it’s collapsed to a file.

AVFoundation 使用 compositions 从现有的媒体片段（通常是一个或多个视频和音频 tracks ）创建新的 assets 。你可以使用一个可变的 composition 来添加和移除 tracks ，并调整它们的时间顺序。你也可以设置音频 tracks 的相对音量和波形，设置视频 tracks 的不透明度以及不透明变化趋势。一个 composition 是存储与内存中媒体片段的集合。当你使用 export session 导出一个 composition 时，这个 composition 将会以文件的形式存在。

> You can also create an asset from media such as sample buffers or still images using an asset writer.

你也可以使用 asset writer 从诸如 sample buffers 或者静态 images 之类的媒体中创建 asset 。

> Relevant Chapter: [Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html#//apple_ref/doc/uid/TP40010188-CH8-SW1)

相关章节：[Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html#//apple_ref/doc/uid/TP40010188-CH8-SW1)

#### Still and Video Media Capture - 静态和视频媒体捕捉

> Recording input from cameras and microphones is managed by a capture session. A capture session coordinates the flow of data from input devices to outputs such as a movie file. You can configure multiple inputs and outputs for a single session, even when the session is running. You send messages to the session to start and stop data flow.
>
> In addition, you can use an instance of a preview layer to show the user what a camera is recording.

从相机与麦克风记录输入是由 capture session 管理的。一个 capture session 协调输入设置到输出（如，电影文件）的数据流。即使 session 正在运行，你也可以为单个 session 配置多个输入和输出。发送消息给 session 可以控制数据流的开始和结束。

除此之外，可以使用 preview layer 的实例向用户展示相机正在录制的内容。

> Relevant Chapter: [Still and Video Media Capture](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html#//apple_ref/doc/uid/TP40010188-CH5-SW2)

相关章节：[Still and Video Media Capture](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html#//apple_ref/doc/uid/TP40010188-CH5-SW2)

### Concurrent Programming with AVFoundation - AVFoundation 并发编程

> Callbacks from AVFoundation—invocations of blocks, key-value observers, and notification handlers—are not guaranteed to be made on any particular thread or queue. Instead, AVFoundation invokes these handlers on threads or queues on which it performs its internal tasks.

AVFoundation 返回的回调不能保证在任何特定的线程或队列中进行，这样的回调包括 blocks 、key-value observers 以及 notification handlers 。相反，AVFoundation 在执行其内部任务的线程或者队列上进行这些回调。

> There are two general guidelines as far as notifications and threading:
>
> - UI related notifications occur on the main thread.
> - Classes or methods that require you create and/or specify a queue will return notifications on that queue.

就通知和线程而言，有两条一般性的准则：

- UI 相关的 notifications 发生在主线程。
- 那些需要调用方创建或者指定 queue 的类或方法，相关的 notifications 会在对应的 queue 上执行。

> Beyond those two guidelines (and there are exceptions, which are noted in the reference documentation) you should not assume that a notification will be returned on any specific thread.

除上面提到的两条准则之外，你不应该假设 notification 将在任何指定的线程上执行。

> If you’re writing a multithreaded application, you can use the NSThread method [isMainThread](https://developer.apple.com/documentation/foundation/thread/1408455-ismainthread) or [[NSThread currentThread] isEqual:] to test whether the invocation thread is a thread you expect to perform your work on. You can redirect messages to appropriate threads using methods such as [performSelectorOnMainThread:withObject:waitUntilDone:](https://developer.apple.com/documentation/objectivec/nsobject/1414900-performselector) and [performSelector:onThread:withObject:waitUntilDone:modes:](https://developer.apple.com/documentation/objectivec/nsobject/1417922-perform). You could also use [dispatch_async](https://developer.apple.com/documentation/dispatch/1453057-dispatch_async) to “bounce” to your blocks on an appropriate queue, either the main queue for UI tasks or a queue you have up for concurrent operations. For more about concurrent operations, see [Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091); for more about blocks, see [Blocks Programming Topics](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40007502). The [AVCam-iOS: Using AVFoundation to Capture Images and Movies](https://developer.apple.com/library/archive/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112) sample code is considered the primary example for all AVFoundation functionality and can be consulted for examples of thread and queue usage with AVFoundation.

如果你正在开发一款多线程应用，你可以使用 NSThread 的方法 [isMainThread](https://developer.apple.com/documentation/foundation/thread/1408455-ismainthread) 或者 [[NSThread currentThread] isEqual:] 判断当前的调用线程是否是你期待的线程。你可以使用诸如 [performSelectorOnMainThread:withObject:waitUntilDone:](https://developer.apple.com/documentation/objectivec/nsobject/1414900-performselector) 或者 [performSelector:onThread:withObject:waitUntilDone:modes:](https://developer.apple.com/documentation/objectivec/nsobject/1417922-perform) 类似的方法重定向消息到合适的线程。你也可以使用 [dispatch_async](https://developer.apple.com/documentation/dispatch/1453057-dispatch_async) 调度你的 blocks 到合适的 queue ，UI 相关操作调度到 main queue ，并发操作调度到创建的并发queue 。了解 concurrent operations 的更多信息，可以查阅 [Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091) ；了解 blocks 的更多知识，查阅 [Blocks Programming Topics](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40007502) 。[AVCam-iOS: Using AVFoundation to Capture Images and Movies](https://developer.apple.com/library/archive/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112) 示例代码是使用 AVFoundation 进行功能开发最主要的例子，也可以作为 AVFoundation 并发编程的重要参考。

### Prerequisites - 预备知识

> AVFoundation is an advanced Cocoa framework. To use it effectively, you must have:
>
> - A solid understanding of fundamental Cocoa development tools and techniques
> - A basic grasp of blocks
> - A basic understanding of key-value coding and key-value observing
> - For playback, a basic understanding of Core Animation (see [Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514) or, for basic playback, the [AVKit Framework Reference](https://developer.apple.com/documentation/avkit)) .

AVFoundation 是一个高级的 Cocoa framework 。要想有效地使用它，你必须掌握下面的知识：
- 对基础 Cocoa 开发工具与技术有扎实的理解
- 掌握 blocks 的基本知识
- 对 key-value coding 与 key-value observing 拥有基础的理解
- 播放方面，需要对 Core Animation 具有一个基本的理解（参考 [Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514) 或者 [AVKit Framework Reference](https://developer.apple.com/documentation/avkit) ）。

### See Also - 参考

>  There are several AVFoundation examples including two that are key to understanding and implementation Camera capture functionality:
>
> - [AVCam-iOS: Using AVFoundation to Capture Images and Movies](https://developer.apple.com/library/archive/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112) is the canonical sample code for implementing any program that uses the camera functionality. It is a complete sample, well documented, and covers the majority of the functionality showing the best practices.
> - [AVCamManual: Extending AVCam to Use Manual Capture API](https://developer.apple.com/library/archive/samplecode/AVCamManual/Introduction/Intro.html#//apple_ref/doc/uid/TP40014578) is the companion application to AVCam. It implements Camera functionality using the manual camera controls. It is also a complete example, well documented, and should be considered the canonical example for creating camera applications that take advantage of manual controls.
> - [RosyWriter](https://developer.apple.com/library/archive/samplecode/RosyWriter/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011110) is an example that demonstrates real time frame processing and in particular how to apply filters to video content. This is a very common developer requirement and this example covers that functionality.
> - [AVLocationPlayer: Using AVFoundation Metadata Reading APIs](https://developer.apple.com/library/archive/samplecode/AVLocationPlayer/Introduction/Intro.html#//apple_ref/doc/uid/TP40014495) demonstrates using the metadata APIs.

以下是几个 AVFoundation 的示例程序，其中的两个示例非常有助于理解和实现相机捕捉这样的功能：
- [AVCam-iOS: Using AVFoundation to Capture Images and Movies](https://developer.apple.com/library/archive/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112) 是那些需要使用相机功能程序的规范示例代码。是一个完整的示例，文档齐全，并且涵盖了大部分主要的功能。
- [AVCamManual: Extending AVCam to Use Manual Capture API](https://developer.apple.com/library/archive/samplecode/AVCamManual/Introduction/Intro.html#//apple_ref/doc/uid/TP40014578) 是 AVCam 的配套应用。使用手动相机控制实现相机功能。它也是一个完整的例子，文档齐全，应该被认为是创建利用手动控制的相机应用程序的典型示例。
- [RosyWriter](https://developer.apple.com/library/archive/samplecode/RosyWriter/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011110) 是一个演示实时帧处理的示例，特别是如何将滤镜应用于视频内容。这些功能点对开发人员来讲可以说是非常普遍的要求，这个示例程序涵盖了这些功能的实现。
- [AVLocationPlayer: Using AVFoundation Metadata Reading APIs](https://developer.apple.com/library/archive/samplecode/AVLocationPlayer/Introduction/Intro.html#//apple_ref/doc/uid/TP40014495) 演示 metadata APIs 的使用。

## Using Assets - 使用 Assets

> Assets can come from a file or from media in the user’s iPod library or Photo library. When you create an asset object all the information that you might want to retrieve for that item is not immediately available. Once you have a movie asset, you can extract still images from it, transcode it to another format, or trim the contents.

Assets 可以来自文件或者用户 iPod library/Photo library 中的媒体。当你创建一个 asset 对象后，你想要检索的所有该 item 的信息并不是立即可用的。一旦你拥有了一个 movie asset ，你可以从里面提取静态图像、将它转码成另外的格式或者修建它的内容。

### Creating an Asset Object - 创建 Asset 对象

> To create an asset to represent any resource that you can identify using a URL, you use [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset). The simplest case is creating an asset from a file:

你可以使用 [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset) 创建一个 asset 对象来表示可以使用 URL 唯一标识的任何资源。从文件创建一个 asset 是最简单的例子。

```objc
NSURL *url = <#A URL that identifies an audiovisual asset such as a movie file#>;
AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
```

#### Options for Initializing an Asset - 初始化 Asset 的选项

> The AVURLAsset initialization methods take as their second argument an options dictionary. The only key used in the dictionary is [AVURLAssetPreferPreciseDurationAndTimingKey](https://developer.apple.com/documentation/avfoundation/avurlassetpreferprecisedurationandtimingkey). The corresponding value is a Boolean (contained in an NSValue object) that indicates whether the asset should be prepared to indicate a precise duration and provide precise random access by time.

AVURLAsset 的初始化方法第二个参数是一个选项字典。该字典中唯一可以使用的 key 是 [AVURLAssetPreferPreciseDurationAndTimingKey](https://developer.apple.com/documentation/avfoundation/avurlassetpreferprecisedurationandtimingkey) 。该 key 相应的值是一个 Boolean 值（包含在 NSValue 对象中），该值指出该 asset 是否应该准备一个表明精确持续时间的值以及是否提供基于时间进行精确随机访问的能力。

> Getting the exact duration of an asset may require significant processing overhead. Using an approximate duration is typically a cheaper operation and sufficient for playback. Thus:
>
> - If you only intend to play the asset, either pass nil instead of a dictionary, or pass a dictionary that contains the AVURLAssetPreferPreciseDurationAndTimingKey key and a corresponding value of NO (contained in an NSValue object).
> - If you want to add the asset to a composition ([AVMutableComposition](https://developer.apple.com/documentation/avfoundation/avmutablecomposition)), you typically need precise random access. Pass a dictionary that contains the AVURLAssetPreferPreciseDurationAndTimingKey key and a corresponding value of YES (contained in an NSValue object—recall that [NSNumber](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSNumber/Description.html#//apple_ref/occ/cl/NSNumber) inherits from NSValue):

获取一个 asset 的精确持续时间可能需要大量的处理开销。使用一个近似的持续时间通常是个更轻量的操作，并且近似的持续时间足以用于播放。因此：
- 如果你只是打算播放这个 asset ，那么，传递 nil 或者传递包含 AVURLAssetPreferPreciseDurationAndTimingKey 键和一个相应的 NO 值（包含在 NSValue 对象中）。
- 如果你想要将 asset 添加到 composition（ [AVMutableComposition](https://developer.apple.com/documentation/avfoundation/avmutablecomposition) ）中，通常你需要精确的随机访问。传递一个包含 AVURLAssetPreferPreciseDurationAndTimingKey 键值和一个相应的 YES 值（包含在一个 NSValue 对象中，回忆下继承于 NSValue 的 [NSNumber](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSNumber/Description.html#//apple_ref/occ/cl/NSNumber) ）的字典。

```objc
NSURL *url = <#A URL that identifies an audiovisual asset such as a movie file#>;
NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
AVURLAsset *anAssetToUseInAComposition = [[AVURLAsset alloc] initWithURL:url options:options];
```

#### Accessing the User’s Assets - 访问用户的 Assets

> To access the assets managed by the iPod library or by the Photos application, you need to get a URL of the asset you want.

> - To access the iPod Library, you create an [MPMediaQuery](https://developer.apple.com/documentation/mediaplayer/mpmediaquery) instance to find the item you want, then get its URL using [MPMediaItemPropertyAssetURL](https://developer.apple.com/documentation/mediaplayer/mpmediaitempropertyasseturl).
> For more about the Media Library, see [Multimedia Programming Guide](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009767).
>
> - To access the assets managed by the Photos application, you use [ALAssetsLibrary](https://developer.apple.com/documentation/assetslibrary/alassetslibrary).
The following example shows how you can get an asset to represent the first video in the Saved Photos Album.

要访问由 iPod library 或者 Photos application 管理的 assets 的话，你需要获取你想要访问 asset 的 URL 。

- 要访问 iPod Library 的话，你需要创建 [MPMediaQuery](https://developer.apple.com/documentation/mediaplayer/mpmediaquery) 的一个示例找到你想访问的 item ，然后使用 [MPMediaItemPropertyAssetURL](https://developer.apple.com/documentation/mediaplayer/mpmediaitempropertyasseturl) 获得它的 URL 。关于 Media Library 的更多信息，查阅 [Multimedia Programming Guide](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009767) 。
- 要访问 Photos application 管理的 assets 的话，使用 [ALAssetsLibrary](https://developer.apple.com/documentation/assetslibrary/alassetslibrary) 。

下面的例子展示了了如何生成一个 asset 以呈现 Saved Photos Album 中的第一个视频。

```objc
ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

// Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
[library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

    // Within the group enumeration block, filter to enumerate just videos.
    [group setAssetsFilter:[ALAssetsFilter allVideos]];
    
    // For this example, we're only interested in the first item.
    [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0]
                            options:0
                         usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {

                                // The end of the enumeration is signaled by asset == nil.
                                if (alAsset) {
                                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                    NSURL *url = [representation url];
                                    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                                    // Do something interesting with the AV asset.
                                }
    }];
                                                                    }
                                                                    failureBlock: ^(NSError *error) {
                                                                        // Typically you should handle an error more gracefully than this.
                                                                        NSLog(@"No groups");
                                                                    }];
```

### Preparing an Asset for Use - 准备 Asset 以供使用

> Initializing an asset (or track) does not necessarily mean that all the information that you might want to retrieve for that item is immediately available. It may require some time to calculate even the duration of an item (an MP3 file, for example, may not contain summary information). Rather than blocking the current thread while a value is being calculated, you should use the [AVAsynchronousKeyValueLoading](https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading)  protocol to ask for values and get an answer back later through a completion handler you define using a block. (AVAsset and AVAssetTrack conform to the AVAsynchronousKeyValueLoading protocol.)

初始化一个 asset 并不意味着你想要获取的有关该item的所有信息是立即可用的。可能需要一些时间去计算诸如 item 持续时间（例如，一个 MP3 文件，可能并不包含摘要信息）之类的数据。你应该使用 [AVAsynchronousKeyValueLoading](https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading) protocol 请求数据，之后通过使用 block 定义的 completion handler 来获取数据，而不是采用阻塞当前线程等待着数据的计算。

> You test whether a value is loaded for a property using [statusOfValueForKey:error:](https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading/1386816-statusofvalueforkey). When an asset is first loaded, the value of most or all of its properties is [AVKeyValueStatusUnknown](https://developer.apple.com/documentation/avfoundation/avkeyvaluestatus/avkeyvaluestatusunknown). To load a value for one or more properties, you invoke [loadValuesAsynchronouslyForKeys:completionHandler:](https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading/1387321-loadvaluesasynchronouslyforkeys). In the completion handler, you take whatever action is appropriate depending on the property’s status. You should always be prepared for loading to not complete successfully, either because it failed for some reason such as a network-based URL being inaccessible, or because the load was canceled.

使用 [statusOfValueForKey:error:](https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading/1386816-statusofvalueforkey) 测试是否为某个 property 加载了某个值。当一个 asset 首次被加载时，其大部分或者全部 properties 的值均为 [AVKeyValueStatusUnknown](https://developer.apple.com/documentation/avfoundation/avkeyvaluestatus/avkeyvaluestatusunknown) 。调用 [loadValuesAsynchronouslyForKeys:completionHandler:](https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading/1387321-loadvaluesasynchronouslyforkeys) 来加载一个或者多个 properties 的值。在 completion handler 中，依据 property 的状态采取适当的动作。你应该始终准备好处理加载不完全成功的情形，加载失败可能有很多原因，例如基于网络的 URL 无法访问，或者加载被取消掉。

```objc
NSURL *url = <#A URL that identifies an audiovisual asset such as a movie file#>;
AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
NSArray *keys = @[@"duration"];

[asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {

    NSError *error = nil;
    AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"duration" error:&error];
    switch (tracksStatus) {
        case AVKeyValueStatusLoaded:
             [self updateUserInterfaceForDuration];
             break;
        case AVKeyValueStatusFailed:
             [self reportError:error forAsset:asset];
             break;
        case AVKeyValueStatusCancelled:
             // Do whatever is appropriate for cancelation.
             break;
    }
}];
```

> If you want to prepare an asset for playback, you should load its tracks property. For more about playing assets, see [Playback](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW1).

如果你想要准备一个 asset 去播放，你应该加载它的 tracks property 。关于播放 assets 的更多信息，参阅 [Playback](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW1) 。

### Getting Still Images From a Video - 从视频中获取静态图像

> To get still images such as thumbnails from an asset for playback, you use an [AVAssetImageGenerator](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator) object. You initialize an image generator with your asset. Initialization may succeed, though, even if the asset possesses no visual tracks at the time of initialization, so if necessary you should test whether the asset has any tracks with the visual characteristic using [tracksWithMediaCharacteristic:](https://developer.apple.com/documentation/avfoundation/avasset/1389554-tracks).

使用 [AVAssetImageGenerator](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator) 对象从用于播放的 asset 中获取诸如缩略图之类的静态图像。使用 asset 初始化一个 image generator 。即使在初始化时 asset 没有视觉 tracks ，初始化也可能成功，因此如果有必要，你应该使用 [tracksWithMediaCharacteristic:](https://developer.apple.com/documentation/avfoundation/avasset/1389554-tracks) 测试 asset 是否存在任何具有视觉特征的 tracks 。

```objc
AVAsset anAsset = <#Get an asset#>;
if ([[anAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
    AVAssetImageGenerator *imageGenerator =
        [AVAssetImageGenerator assetImageGeneratorWithAsset:anAsset];
        // Implementation continues...
}
```

> You can configure several aspects of the image generator, for example, you can specify the maximum dimensions for the images it generates and the aperture mode using [maximumSize](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1387560-maximumsize) and [apertureMode](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1389314-aperturemode) respectively.You can then generate a single image at a given time, or a series of images. You must ensure that you keep a strong reference to the image generator until it has generated all the images.

你可以配置 image generator 的多个方面，例如，你可以分别使用 [maximumSize](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1387560-maximumsize) 和 [apertureMode](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1389314-aperturemode) 指定其生成图像的最大尺寸和光圈模式。你可以生成给定时间点的一副单独图像或者一系列图像。你必须保证在生成完所有图像之前，对 image generator 保持强引用。

#### Generating a Single Image - 生成单幅图像

> You use [copyCGImageAtTime:actualTime:error:](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1387303-copycgimageattime) to generate a single image at a specific time. AVFoundation may not be able to produce an image at exactly the time you request, so you can pass as the second argument a pointer to a CMTime that upon return contains the time at which the image was actually generated.

使用 [copyCGImageAtTime:actualTime:error:](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1387303-copycgimageattime) 生成指定时间处的单幅图像。AVFoundation 可能无法准确地在你发起请求的时刻生成图像，所以你可以将指向 CMTime 的指针作为第二个参数传递过去，当调用返回时，这个结构体将记录图像真正生成的时间。

```objc
AVAsset *myAsset = <#An asset#>];
AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:myAsset];

Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
NSError *error;
CMTime actualTime;

CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];

if (halfWayImage != NULL) {

    NSString *actualTimeString = (NSString *)CMTimeCopyDescription(NULL, actualTime);
    NSString *requestedTimeString = (NSString *)CMTimeCopyDescription(NULL, midpoint);
    NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);

    // Do something interesting with the image.
    CGImageRelease(halfWayImage);
}
```
#### Generating a Sequence of Images - 生成图像序列

> To generate a series of images, you send the image generator a [generateCGImagesAsynchronouslyForTimes:completionHandler:](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1388100-generatecgimagesasynchronously) message. The first argument is an array of [NSValue](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSValue/Description.html#//apple_ref/occ/cl/NSValue) objects, each containing a CMTime structure, specifying the asset times for which you want images to be generated. The second argument is a block that serves as a callback invoked for each image that is generated. The block arguments provide a result constant that tells you whether the image was created successfully or if the operation was canceled, and, as appropriate:
>
> - The image
> - The time for which you requested the image and the actual time for which the image was generated
> - An error object that describes the reason generation failed

为了生成一系列图像，你需要向 image generator 发送 [generateCGImagesAsynchronouslyForTimes:completionHandler:](https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1388100-generatecgimagesasynchronously) 消息。第一个参数是一个元素为 [NSValue](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Classes/NSValue/Description.html#//apple_ref/occ/cl/NSValue) 的数组，其每个元素包含一个 CMTime 结构体，指定在 asset 的哪些时间点生成所需要的图像。第二个参数是一个 block ，作为每个图像生成的回调。block 参数提供了一个常量，该常量表明图像是否创建成功或者操作是否被取消，block 中参数如下：
- 生成的图像
- 请求生成图像的时间与图像实际生成的时间
- 一个error对象描述生成失败的原因

> In your implementation of the block, check the result constant to determine whether the image was created. In addition, ensure that you keep a strong reference to the image generator until it has finished creating the images.

在 block 的实现中，检查回调回来的常量以确定图像是否被创建。此外，确保在完成所有图像的创建之前，对 image generator 保持一个强引用。

```objc
AVAsset *myAsset = <#An asset#>];
// Assume: @property (strong) AVAssetImageGenerator *imageGenerator;
self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];

Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
CMTime firstThird = CMTimeMakeWithSeconds(durationSeconds/3.0, 600);
CMTime secondThird = CMTimeMakeWithSeconds(durationSeconds*2.0/3.0, 600);
CMTime end = CMTimeMakeWithSeconds(durationSeconds, 600);
NSArray *times = @[NSValue valueWithCMTime:kCMTimeZero],
[NSValue valueWithCMTime:firstThird], [NSValue valueWithCMTime:secondThird],
[NSValue valueWithCMTime:end]];

[imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                     completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
AVAssetImageGeneratorResult result, NSError *error) {

                                NSString *requestedTimeString = (NSString *)
                                        CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
                                NSString *actualTimeString = (NSString *)
                                        CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                                NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);

                                if (result == AVAssetImageGeneratorSucceeded) {
                                    // Do something interesting with the image.
                                }

                                if (result == AVAssetImageGeneratorFailed) {
                                    NSLog(@"Failed with error: %@", [error localizedDescription]);
                                }
                                if (result == AVAssetImageGeneratorCancelled) {
                                    NSLog(@"Canceled");
                                }
}];
```

> You can cancel the generation of the image sequence by sending the image generator a [cancelAllCGImageGeneration]( https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1385859-cancelallcgimagegeneration) message.

 发送 [cancelAllCGImageGeneration]( https://developer.apple.com/documentation/avfoundation/avassetimagegenerator/1385859-cancelallcgimagegeneration) 消息给 image generator 可以取消图像序列的生成操作。

### Trimming and Transcoding a Movie - 修剪和转码电影

> You can transcode a movie from one format to another, and trim a movie, using an [AVAssetExportSession](https://developer.apple.com/documentation/avfoundation/avassetexportsession) object. The workflow is shown in Figure 1-1. An export session is a controller object that manages asynchronous export of an asset. You initialize the session using the asset you want to export and the name of a export preset that indicates the export options you want to apply (see [allExportPresets](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1387150-allexportpresets)). You then configure the export session to specify the output URL and file type, and optionally other settings such as the metadata and whether the output should be optimized for network use.

使用 [AVAssetExportSession](https://developer.apple.com/documentation/avfoundation/avassetexportsession) 对象，你可以将电影由一个格式转码成另一个格式，还可以修剪电影。图 1-1 展示了其工作流程。export session 是个管理 asset 异步导出的控制器对象。使用想要导出的 asset 和导出预设格式名称初始化 session 对象，这个导出预设名称表明你想应用的导出选项（见 [allExportPresets](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1387150-allexportpresets) ）。然后，配置 export session 以指定输出 URL 、文件类型以及其他可选的设置项，比如元数据、是否将输出优化以用于网络使用。

![export session workflow](../../resource/AVFoundation/Markdown/exportSessionWorkflow.png)

> You can check whether you can export a given asset using a given preset using [exportPresetsCompatibleWithAsset:](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1390567-exportpresetscompatiblewithasset) as illustrated in this example:

如下例所示，可以使用 [exportPresetsCompatibleWithAsset:](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1390567-exportpresetscompatiblewithasset) 检查是否可以使用给定的 preset 导出给定的 asset 。

```objc
AVAsset *anAsset = <#Get an asset#>;
NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
        initWithAsset:anAsset presetName:AVAssetExportPresetLowQuality];
    // Implementation continues.
}
```

> You complete the configuration of the session by providing the output URL (The URL must be a file URL.) AVAssetExportSession can infer the output file type from the URL’s path extension; typically, however, you set it directly using [outputFileType](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1387110-outputfiletype). You can also specify additional properties such as the time range, a limit for the output file length, whether the exported file should be optimized for network use, and a video composition. The following example illustrates how to use the [timeRange](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1388728-timerange) property to trim the movie:

你可以通过提供输出 URL（必须是文件 URL ）来完成 session 的配置。AVAssetExportSession 可以从 URL 的路径扩展名推断出输出文件的类型，然后，你也可以使用 [outputFileType](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1387110-outputfiletype) 直接设置输出文件的类型。你还可以指定其他的属性，比如时间范围、输出文件长度的限制、导出文件是否需要优化以供网络使用以及视频的成分。下面的示例程序演示了如何使用 [timeRange](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1388728-timerange) 属性以修剪 movie 。

```objc
    exportSession.outputURL = <#A file URL#>;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    CMTime start = CMTimeMakeWithSeconds(1.0, 600);
    CMTime duration = CMTimeMakeWithSeconds(3.0, 600);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
```

> To create the new file, you invoke [exportAsynchronouslyWithCompletionHandler:](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1388005-exportasynchronouslywithcompleti). The completion handler block is called when the export operation finishes; in your implementation of the handler, you should check the session’s [status](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1390528-status) value to determine whether the export was successful, failed, or was canceled:

调用 [exportAsynchronouslyWithCompletionHandler:](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1388005-exportasynchronouslywithcompleti) 可以创建新文件。当导出操作完成之后 completion handler 会被执行，在该回调中，你应该检查 session 的 [status](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1390528-status) 以了解导出是成功还是失败亦或是操作被取消掉了。

```objc
[exportSession exportAsynchronouslyWithCompletionHandler:^{

    switch ([exportSession status]) {
        case AVAssetExportSessionStatusFailed:
            NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
            break;
        case AVAssetExportSessionStatusCancelled:
            NSLog(@"Export canceled");
        break;
        default:
            break;
    }
}];
```

> You can cancel the export by sending the session a [cancelExport](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1387794-cancelexport) message.
>
> The export will fail if you try to overwrite an existing file, or write a file outside of the application’s sandbox. It may also fail if:
>
> - There is an incoming phone call
> - Your application is in the background and another application starts playback
>
> In these situations, you should typically inform the user that the export failed, then allow the user to restart the export.

你可以向 session 发送 [cancelExport](https://developer.apple.com/documentation/avfoundation/avassetexportsession/1387794-cancelexport) 消息取消一个导出操作。

如果你试图复写现有文件或者写位于应用程序沙盒之外的文件，导出操作会失败。其他可能导致失败的原因有：
- 导出操作正在进行时，有来电
- 你的应用程序正在后台并且其他应用程序开始播放

遇到以上这些场景，你通常应该通知用户导出失败，并且允许用户重新启动导出操作。

## Playback - 播放

> To control the playback of assets, you use an AVPlayer object. During playback, you can use an [AVPlayerItem](https://developer.apple.com/documentation/avfoundation/avplayeritem) instance to manage the presentation state of an asset as a whole, and an AVPlayerItemTrack object to manage the presentation state of an individual track. To display video, you use an AVPlayerLayer object.

### Playing Assets - 播放 Assets

> A player is a controller object that you use to manage playback of an asset, for example starting and stopping playback, and seeking to a particular time. You use an instance of [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer) to play a single asset. You can use an [AVQueuePlayer](https://developer.apple.com/documentation/avfoundation/avqueueplayer) object to play a number of items in sequence (AVQueuePlayer is a subclass of AVPlayer). On OS X you have the option of the using the AVKit framework’s AVPlayerView class to play the content back within a view.
>
> A player provides you with information about the state of the playback so, if you need to, you can synchronize your user interface with the player’s state. You typically direct the output of a player to a specialized Core Animation layer (an instance of [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer) or [AVSynchronizedLayer](https://developer.apple.com/documentation/avfoundation/avsynchronizedlayer)). To learn more about layers, see Core Animation Programming Guide.

> Multiple player layers: You can create many AVPlayerLayer objects from a single AVPlayer instance, but only the most recently created such layer will display any video content onscreen.

> Although ultimately you want to play an asset, you don’t provide assets directly to an AVPlayer object. Instead, you provide an instance of [AVPlayerItem](https://developer.apple.com/documentation/avfoundation/avplayeritem). A player item manages the presentation state of an asset with which it is associated. A player item contains player item tracks—instances of [AVPlayerItemTrack](https://developer.apple.com/documentation/avfoundation/avplayeritemtrack)—that correspond to the tracks in the asset. The relationship between the various objects is shown in Figure 2-1.





















