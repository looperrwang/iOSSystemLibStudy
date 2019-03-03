#version 300 es

layout (location = 0) in vec2 position;
layout (location = 1) in vec2 textCoord;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec2 TextCoord;

void main()
{
	gl_Position = vec4(position.x, position.y, 0.0, 1.0);
	TextCoord = textCoord;
}
