#version 300 es

precision mediump float;

in vec2 TextCoord;
uniform sampler2D text;

out vec4 color;

void main()
{
	color = vec4(vec3(texture(text, TextCoord)), 1.0);
}
