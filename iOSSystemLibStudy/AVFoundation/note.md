# AVFoundation Programming Guide - AVFoundation编程指引

## About AVFoundation - AVFoundation概述

> AVFoundation is one of several frameworks that you can use to play and create time-based audiovisual media. It provides an Objective-C interface you use to work on a detailed level with time-based audiovisual data. For example, you can use it to examine, create, edit, or reencode media files. You can also get input streams from devices and manipulate video during realtime capture and playback. Figure I-1 shows the architecture on iOS.

AVFoundation是可以用来播放并且创建基于时间的视听媒体的框架之一。框架提供了一系列Objective-C的接口，使用这些接口可以从非常全面的角度处理基于时间的视听媒体数据。例如，你可以用它来检查、创建、编辑或者重新编码媒体文件。甚至可以捕获硬件的输入流，可以在实时捕捉及回放的视频流中操纵视频数据。图I-1描述了其在iOS平台上的架构。

![iOS架构](../../resource/AVFoundation/Markdown/iOS架构.png)

> Figure I-2 shows the corresponding media architecture on OS X.

图I-2描述了OS X平台上媒体相关框架的架构。

![OS X架构](../../resource/AVFoundation/Markdown/OSX架构.png)

> You should typically use the highest-level abstraction available that allows you to perform the tasks you want.
> - If you simply want to play movies, use the AVKit framework.
> - On iOS, to record video when you need only minimal control over format, use the UIKit framework ([UIImagePickerController](https://developer.apple.com/documentation/uikit/uiimagepickercontroller)).
>
> Note, however, that some of the primitive data structures that you use in AV Foundation—including time-related data structures and opaque objects to carry and describe media data—are declared in the Core Media framework.

通常，你应该使用可用的最高级别的抽象框架来完成你想完成的任务。
- 如果只是想简单的播放movies，使用AVKit framework。
- iOS平台上，如果只需录制视频，同时对格式没有格外要求的情况下，使用UIKit framework的[UIImagePickerController](https://developer.apple.com/documentation/uikit/uiimagepickercontroller)。

需要注意的一点是，AV Foundation中的一些原始数据结构其实是定义在Core Media framework中，这其中包括时间相关的数据结构、承载及描述媒体数据的相关对象。

## At a Glance - 摘要

> There are two facets to the AVFoundation framework—APIs related to video and APIs related just to audio. The older audio-related classes provide easy ways to deal with audio.
>
> - To play sound files, you can use [AVAudioPlayer](https://developer.apple.com/documentation/avfoundation/avaudioplayer).
> - To record audio, you can use [AVAudioRecorder](https://developer.apple.com/documentation/avfoundation/avaudiorecorder).
>
> You can also configure the audio behavior of your application using [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession); this is described in [Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007875).

AVFoundation framework包含视频相关的API及音频相关的API。旧的音频相关的类提供了简便的方式去处理音频。
- 播放音频文件，可以使用[AVAudioPlayer](https://developer.apple.com/documentation/avfoundation/avaudioplayer)。
- 录制音频，可以使用[AVAudioRecorder](https://developer.apple.com/documentation/avfoundation/avaudiorecorder)。

你也可以使用[AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession)来配置应用程序的音频行为，[Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007875)提供了相关的描述。

### Representing and Using Media with AVFoundation - 通过AVFoundation表示以及使用媒体

> The primary class that the AV Foundation framework uses to represent media is [AVAsset](https://developer.apple.com/documentation/avfoundation/avasset). The design of the framework is largely guided by this representation. Understanding its structure will help you to understand how the framework works. An AVAsset instance is an aggregated representation of a collection of one or more pieces of media data (audio and video tracks). It provides information about the collection as a whole, such as its title, duration, natural presentation size, and so on. AVAsset is not tied to particular data format. AVAsset is the superclass of other classes used to create asset instances from media at a URL (see [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)) and to create new compositions (see [Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40010188-CH1-SW1)).

AVFoundation framework用来表示媒体的最主要的类是[AVAsset](https://developer.apple.com/documentation/avfoundation/avasset)。整个框架的设计很大程度上受到这种抽象表示方法的引导。理解它的结构将会有助于理解整个框架是如何工作的。一段或多段媒体数据（音频轨道与视频轨道）构成一个集合，一个AVAsset实例就是这样一个集合的汇总表示。AVAsset实例将整个集合作为一个整体，提供了一些诸如名称、时长、自然呈现大小等的信息。AVAsset独立于特定的数据格式。通过使用AVAsset的众多子类，根据URL指定的媒体数据(see [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1))，可以创建具体的asset实例、创建新的结构(see [Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40010188-CH1-SW1))。

> Each of the individual pieces of media data in the asset is of a uniform type and called a track. In a typical simple case, one track represents the audio component, and another represents the video component; in a complex composition, however, there may be multiple overlapping tracks of audio and video. Assets may also have metadata.

asset中媒体数据的每个单独的部分，被称为一个track，每个部分都是一个统一的类型。典型的简单情况下，其中一个track代表音频组件，另一个代表视频组件；然而，在复杂组合的情况下，可能存在多个重叠的音频和视频track。Assets也可能有元数据。

> A vital concept in AV Foundation is that initializing an asset or a track does not necessarily mean that it is ready for use. It may require some time to calculate even the duration of an item (an MP3 file, for example, may not contain summary information). Rather than blocking the current thread while a value is being calculated, you ask for values and get an answer back asynchronously through a callback that you define using a block.

AV Foundation中一个重要的概念是，初始化一个asset或者一个track通常并不意味着它已经处于可以使用的状态了。可能需要一些时间去计算某些数据，比如某个item的持续时间（例如，一个可能不包含摘要信息的MP3文件）。你应该在当前线程发起查询某个值的请求，在block实现的异步回调中获取所需要的数据，而不是采用阻塞当前线程的方式。

> Relevant Chapters: [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1), [Time and Media Representations](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW1)

相关章节：[Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1), [Time and Media Representations](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW1)

### Playback - 播放

> AVFoundation allows you to manage the playback of asset in sophisticated ways. To support this, it separates the presentation state of an asset from the asset itself. This allows you to, for example, play two different segments of the same asset at the same time rendered at different resolutions. The presentation state for an asset is managed by a player item object; the presentation state for each track within an asset is managed by a player item track object. Using the player item and player item tracks you can, for example, set the size at which the visual portion of the item is presented by the player, set the audio mix parameters and video composition settings to be applied during playback, or disable components of the asset during playback.

AVFoundation允许用户以多种复杂的方式来管理asset的播放。为了支持这一点，框架将asset的呈现状态从asset自身中分离出来。举个例子，这样的设计允许用户将同一个asset的不同片段同时渲染在不同的分辨率下。一个asset的呈现状态由一个player item object管理；一个asset中各个track的呈现状态由一个player item track object管理。例如，使用player item与player item tracks，可以设置item呈现的可视区域的大小，可以改变播放过程中的音频混合参数以及视频合成设置，可以在播放过程中禁用需要禁用的组件。

> You play player items using a player object, and direct the output of a player to the Core Animation layer. You can use a player queue to schedule playback of a collection of player items in sequence.

你可以使用一个player object来播放多个player items，并且将该player的输出直接输出到Core Animation layer上面去。你可以使用一个player queue以串行的方式调度一系列player items的播放。

> Relevant Chapter: [Playback](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW1)

相关章节：[Playback](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW1)

### Reading, Writing, and Reencoding Assets - 读、写、重编码Assets

> AVFoundation allows you to create new representations of an asset in several ways. You can simply reencode an existing asset, or—in iOS 4.1 and later—you can perform operations on the contents of an asset and save the result as a new asset.

AVFoundation允许你以多种方式创建asset的新表现形式。你可以简单地重新编码已经存在的asset，除此之外，iOS 4.1及以后的版本，你可以操作asset的内容，然后将结果保存为新的asset。

> You use an export session to reencode an existing asset into a format defined by one of a small number of commonly-used presets. If you need more control over the transformation, in iOS 4.1 and later you can use an asset reader and asset writer object in tandem to convert an asset from one representation to another. Using these objects you can, for example, choose which of the tracks you want to be represented in the output file, specify your own output format, or modify the asset during the conversion process.

可以使用export session将一个已经存在的asset重新编码为少数常用预设格式之一。如果需要针对transformation进行更多的控制，那么在iOS 4.1及更高版本中，可以使用一个asset reader object和一个asset writer object将asset从一种表示转换为另一种。例如，使用这些对象，你可以选择最终输出文件中包含哪些想要的tracks，指定自己的输出格式，或者在转换过程中修改asset。

> To produce a visual representation of the waveform, you use an asset reader to read the audio track of an asset.

如果需要生成波形的可视化表示，可以使用一个asset reader读取asset的音频track。

> Relevant Chapter: [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

相关章节：[Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

### Thumbnails - 缩略图

> To create thumbnail images of video presentations, you initialize an instance of AVAssetImageGenerator using the asset from which you want to generate thumbnails. AVAssetImageGenerator uses the default enabled video tracks to generate images.

要创建视频演示文稿的缩略图图像，使用需要生成缩略图的asset初始化一个AVAssetImageGenerator实例。AVAssetImageGenerator使用可用的默认视频tracks来生成图像。

> Relevant Chapter: [Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

相关章节：[Using Assets](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html#//apple_ref/doc/uid/TP40010188-CH7-SW1)

### Editing - 编辑

> AVFoundation uses compositions to create new assets from existing pieces of media (typically, one or more video and audio tracks). You use a mutable composition to add and remove tracks, and adjust their temporal orderings. You can also set the relative volumes and ramping of audio tracks; and set the opacity, and opacity ramps, of video tracks. A composition is an assemblage of pieces of media held in memory. When you export a composition using an export session, it’s collapsed to a file.

AVFoundation使用compositions从现有的媒体片段（通常是一个或多个视频和音频tracks）创建新的assets。你可以使用一个可变的composition来添加和移除tracks，并调整它们的时间顺序。你也可以设置音频tracks的相对音量和波形，设置视频tracks的不透明度以及不透明变化趋势。一个composition是存储与内存中媒体片段的集合。当你使用export session导出一个composition时，这个composition将会以文件的形式存在。

> You can also create an asset from media such as sample buffers or still images using an asset writer.

你也可以使用asset writer从诸如sample buffers或者静态images之类的媒体中创建asset。

> Relevant Chapter: [Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html#//apple_ref/doc/uid/TP40010188-CH8-SW1)

相关章节：[Editing](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html#//apple_ref/doc/uid/TP40010188-CH8-SW1)

### Still and Video Media Capture - 静态和视频媒体捕捉

> Recording input from cameras and microphones is managed by a capture session. A capture session coordinates the flow of data from input devices to outputs such as a movie file. You can configure multiple inputs and outputs for a single session, even when the session is running. You send messages to the session to start and stop data flow.
>
> In addition, you can use an instance of a preview layer to show the user what a camera is recording.

从相机与麦克风记录输入是由capture session管理的。一个capture session协调输入设置到输出（如，电影文件）的数据流。即使session正在运行，你也可以为单个session配置多个输入和输出。发送消息给session可以控制数据流的开始和结束。

除此之外，可以使用preview layer的实例向用户展示相机正在录制的内容。

> Relevant Chapter: [Still and Video Media Capture](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html#//apple_ref/doc/uid/TP40010188-CH5-SW2)

相关章节：[Still and Video Media Capture](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html#//apple_ref/doc/uid/TP40010188-CH5-SW2)

## Concurrent Programming with AVFoundation - AVFoundation并发编程







































