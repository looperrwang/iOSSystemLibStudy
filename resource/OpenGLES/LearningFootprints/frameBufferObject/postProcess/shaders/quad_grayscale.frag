#version 300 es

precision mediump float;

in vec2 TextCoord;

uniform sampler2D text;

out vec4 color;

vec3 grayscale()
{
    vec4 color = texture(text, TextCoord);
    float average = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
    return vec3(average, average, average);
}

void main()
{
    color = vec4(grayscale(), 1.0);
}
