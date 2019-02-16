#version 300 es

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;

out vec3 VertColor;

void main()
{
	gl_Position = vec4(position, 1.0);
    VertColor = color;
}
