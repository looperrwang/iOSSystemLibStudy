#version 300 es

layout (location = 0) in vec3 position;

uniform mat4 projection;
uniform mat4 view;

out vec3 TextCoord;

void main()
{
	vec4 pos = projection * view * vec4(position, 1.0);
	gl_Position = pos.xyww;
    TextCoord = position;
}
