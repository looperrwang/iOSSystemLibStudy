#version 300 es

in mediump vec3 vertColor;
out mediump vec4 color;

void main()
{
	color = vec4(vertColor, 1.0);
}
