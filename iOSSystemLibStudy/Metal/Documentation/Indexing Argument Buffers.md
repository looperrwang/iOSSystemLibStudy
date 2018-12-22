#  Indexing Argument Buffers

> Assign resource indices within an argument buffer.

在参数缓冲区中分配资源索引。

## Overview

> You can index an argument buffer similarly to buffers, textures, and samplers. However, you index individual argument buffer resources with a generic [[id(n)]] attribute instead of the specific type [[buffer(n)]], [[texture(n)]], and [[sampler(n)]] attributes.
>
> Note - Because argument buffers are represented by [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) objects, they can be explicitly distinguished from regular buffers in the Metal shading language if they contain any resources indexed with the [[id(n)]] attribute. If any member of a Metal shading language structure has an [[id(n)]] attribute, the whole structure is treated as an argument buffer.
>
> Manually assigned argument buffer resource indices do not need to be contiguous, but they must be unique and arranged in an increasing order. The following example shows manual and automatic index assignment:

你可以像使用缓冲区，纹理和采样器那样索引参数缓冲区。但是，你使用通用 [[id(n)]] 属性而不是特定类型 [[buffer(n)]] ，[[texture(n)]] 和 [[sampler(n)]] 属性来索引单个参数缓冲区资源。

注意 - 因为参数缓冲区由 [MTLBuffer](https://developer.apple.com/documentation/metal/mtlbuffer?language=objc) 对象表示，所以如果它们包含使用 [[id(n)]] 属性索引的任何资源，则 Metal 着色语言中，可以明确将它们与常规缓冲区区分开来。如果 Metal 着色语言结构的任何成员具有 [[id(n)]] 属性，则整个结构将被视为参数缓冲区。

手动分配的参数缓冲区资源索引不需要是连续的，但它们必须是唯一的并按递增顺序排列。以下示例显示了手动和自动索引分配：

```objc
struct My_Indexed_AB {
    texture2d<float> texA [[id(1)]];
    texture2d<float> texB [[id(3)]];
};
struct My_Aggregate_AB {
    My_Indexed_AB abX; // abX = id(0); texA = id(1); texB = id(3)
    My_Indexed_AB abY; // abY = id(4); texA = id(5); texB = id(7)
};
```

## Automatically Assigned Index IDs

> If the [[id(n)]] attribute is omitted for any argument buffer resource, an index ID is automatically assigned according to preset rules:

如果参数缓冲区资源省略 [[id(n)]] 属性，则会根据预设规则自动分配索引 ID ：

### Structure Members

> IDs are assigned to structure members in order, starting at 0, by adding 1 to the highest ID used by the previous structure member. The following example shows automatically assigned index IDs for structure members:

通过在前一个结构成员使用的最高 ID 基础上增加 1 ，从 0 开始按顺序将 ID 分配给结构体成员。以下示例显示了为结构成员自动分配的索引 ID ：

```objc
struct MaterialTexture {
    texture2d<float> tex; // Assigned to index 0
    float4 uvScaleOffset; // Assigned to index 1
};
```

### Array Elements

> IDs are assigned to array elements in order, starting at 0, by adding 1 to the highest ID used by the previous array elements. The following example shows automatically assigned index IDs for array elements:

通过在前一个数组元素使用的最高 ID 基础上增加 1 ，从 0 开始按顺序将 ID 分配给数组元素。以下示例显示了为数组元素自动分配的索引 ID ：

```objc
struct Material {
    float4 diffuse;                     // Assigned to index 0
    array<texture2d<float>, 3> texSet1; // Assigned to indices 1-3
    texture2d<float> texSet2[3];        // Assigned to indices 4-6
    MaterialTexture materials[3];       // Assigned to indices 7-12
    int constants[4] [[id(20)]];        // Assigned to indices 20-23
};
```

### Nested Structs and Arrays

> If a structure member or array element is itself a structure or array, its own structure members or array elements are assigned indices according to the previous rules. If an ID is provided for a top-level structure or array, this ID becomes the starting index for nested structure members or array elements. The following example shows automatically assigned index IDs for nested structures and arrays:

如果结构成员或数组元素本身是结构或数组，则根据先前的规则为其自己的结构成员或数组元素分配索引。如果为顶级结构或数组提供了 ID ，则此 ID 将成为嵌套结构成员或数组元素的起始索引。以下示例显示可嵌套的结构和数组的自动分配的索引 ID ：

```objc
struct Material {
    MaterialTexture diffuse;          // Assigned to indices 0-1
    MaterialTexture normal [[id(4)]]; // Assigned to indices 4-5
    MaterialTexture specular;         // Assigned to indices 6-7
}
```

### Combined Argument Buffer Resources and Regular Resources

> Argument buffer resources are assigned generic indices according to the previous rules. Regular resources are assigned type indices in their respective resource argument tables. The following example shows automatically assigned index IDs for combined argument buffer resources and regular resources:

根据先前的规则为参数缓冲区资源分配通用索引。常规资源在其各自的资源参数表中分配类型索引。以下示例显示了为组合的参数缓冲区资源及常规资源自动分配的索引 ID 。
以下示例显示组合参数缓冲区资源和常规资源的自动分配的索引ID：

```objc
fragment float4 my_fragment(
    constant texture2d<float> & texturesAB1 [[buffer(0)]],     // Assigned to generic index 0 and buffer index 0
    constant texture2d<float> & texturesAB2[10] [[buffer(1)]], // Assigned to generic indices 0-9 and buffer index 1
    array<texture2d<float>, 10> texturesArray [[texture(0)]]    // Assigned to texture indices 0-9
)
{...}
```
