#version 300 es

precision mediump float;

in vec3 VertColor;

out vec4 color;

void main()
{
	color = vec4(VertColor, 1.0);
}
