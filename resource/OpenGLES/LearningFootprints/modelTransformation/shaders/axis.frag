#version 300 es

in mediump vec3 VertColor;

out mediump vec4 color;

void main()
{
	color = vec4(VertColor, 1.0);
}
