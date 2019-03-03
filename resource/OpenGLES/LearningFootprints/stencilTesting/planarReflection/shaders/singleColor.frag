#version 300 es

precision mediump float;

in vec2 TextCoord;

uniform sampler2D text;

out vec4 color;

void main()
{
    color = vec4(0.1f, 0.0f, 0.0f, 0.6f);
}
