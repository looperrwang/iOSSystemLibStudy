#version 300 es

precision mediump float;

in vec2 TextCoord;

uniform sampler2D text;

out vec4 color;

float edgeDetectionKernel[9] = float[](
                                       1.0, 1.0, 1.0,
                                       1.0, -8.0, 1.0,
                                       1.0, 1.0, 1.0
                                       );

const float offset = 1.0 / 300.0;
vec3 kernelEffect(float kernel[9])
{
    vec2 offsets[9] = vec2[](
                             vec2(-offset, offset),
                             vec2(0.0f,    offset),
                             vec2(offset,  offset),
                             vec2(-offset, 0.0f),
                             vec2(0.0f,    0.0f),
                             vec2(offset,  0.0f),
                             vec2(-offset, -offset),
                             vec2(0.0f,    -offset),
                             vec2(offset,  -offset)
                             );
    
    vec3 sampleText[9];
    for (int i = 0; i < 9; ++i)
    {
        sampleText[i] = vec3(texture(text, TextCoord.st + offsets[i]));
    }
    
    vec3 result = vec3(0.0);
    for (int i = 0; i < 9; ++i)
    {
        result += sampleText[i] * kernel[i];
    }
    
    return result;
}

void main()
{
    color = vec4(kernelEffect(edgeDetectionKernel), 1.0);
}
