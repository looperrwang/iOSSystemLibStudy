#version 300 es

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;
layout (location = 2) in vec2 textCoord;

out vec3 vertColor;
out vec2 TextCoord;

void main()
{
	gl_Position = vec4(position, 1.0);
    vertColor = color;
    TextCoord = textCoord;
}
