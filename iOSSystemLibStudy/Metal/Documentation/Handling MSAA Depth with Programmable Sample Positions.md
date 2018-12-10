#  Handling MSAA Depth with Programmable Sample Positions

> Use depth render targets and programmable sample positions effectively.

有效地使用深度渲染目标和可编程样本位置。

## Overview

> Depth data for render targets is usually stored in a compressed format that requires evaluation at specific sample positions for proper decompression. Depth render targets can now specify a [MTLStoreActionOptionCustomSamplePositions](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptioncustomsamplepositions?language=objc) option that stores depth data in a sample-position-agnostic representation.
>
> Setting the [MTLStoreActionOptionCustomSamplePositions](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptioncustomsamplepositions?language=objc) option indicates that the depth data will be read in a subsequent render pass, or blit operation, that's unaware of the programmable sample positions used to generate the data. For example, reading per-sample depth data within a fragment function that uses different programmable sample positions; or, issuing a copy operation from the MSAA depth data to another resource.
>
> If you specify a [MTLStoreActionOptionCustomSamplePositions](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptioncustomsamplepositions?language=objc) option, Metal may decompress the depth render target and store the resulting data in its decompressed form. If you don't change programmable sample positions in a subsequent render pass, specify a [MTLStoreActionStore](https://developer.apple.com/documentation/metal/mtlstoreaction/mtlstoreactionstore?language=objc) action instead with the [MTLStoreActionOptionNone](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptionnone?language=objc) option to improve performance.

渲染目标的深度数据通常以压缩格式存储，需要在特定样本位置进行评估以进行适当的解压缩。深度渲染目标现在可以指定 [MTLStoreActionOptionCustomSamplePositions](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptioncustomsamplepositions?language=objc) 选项，该选项将深度数据存储在与样本位置无关的表示中。

设置 [MTLStoreActionOptionCustomSamplePositions](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptioncustomsamplepositions?language=objc) 选项表示将在后续渲染过程或 blit 操作中读取深度数据，该过程不知道用于生成数据的可编程样本位置。例如，在使用不同可编程样本位置的片段函数内   读取每样本深度数据；或者，从 MSAA 深度数据向另一个资源发出复制操作。

如果指定 [MTLStoreActionOptionCustomSamplePositions](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptioncustomsamplepositions?language=objc) 选项，Metal 可能解压缩深度渲染目标并将结果数据存储在其解压缩形式中。如果在后续渲染过程中未更改可编程样本位置，请使用  [MTLStoreActionOptionNone](https://developer.apple.com/documentation/metal/mtlstoreactionoptions/mtlstoreactionoptionnone?language=objc) 选项指定 [MTLStoreActionStore](https://developer.apple.com/documentation/metal/mtlstoreaction/mtlstoreactionstore?language=objc) 操作以提高性能。
