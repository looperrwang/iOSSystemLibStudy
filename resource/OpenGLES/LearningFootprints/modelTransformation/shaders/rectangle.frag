#version 300 es

in mediump vec3 VertColor;
in mediump vec2 TextCoord;

uniform sampler2D tex;

out mediump vec4 color;

void main()
{
	color = texture(tex, vec2(TextCoord.s, 1.0f - TextCoord.t));
}
