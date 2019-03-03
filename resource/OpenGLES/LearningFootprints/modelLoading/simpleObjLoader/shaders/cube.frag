#version 300 es

precision mediump float;

in vec2 TextCoord;
uniform sampler2D tex;

out vec4 color;

void main()
{
	color = texture(tex, TextCoord);
}
