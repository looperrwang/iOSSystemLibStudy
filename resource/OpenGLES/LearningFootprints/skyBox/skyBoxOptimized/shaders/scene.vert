#version 300 es

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 textCoord;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec2 TextCoord;

void main()
{
	gl_Position = projection * view * model * vec4(position, 1.0);
	TextCoord = textCoord;
}
