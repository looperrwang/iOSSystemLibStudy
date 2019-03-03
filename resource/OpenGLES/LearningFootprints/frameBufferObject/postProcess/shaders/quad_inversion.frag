#version 300 es

precision mediump float;

in vec2 TextCoord;

uniform sampler2D text;

out vec4 color;

vec3 inversion()
{
    return vec3(1.0 - texture(text, TextCoord));
}

void main()
{
    color = vec4(inversion(), 1.0);
}
