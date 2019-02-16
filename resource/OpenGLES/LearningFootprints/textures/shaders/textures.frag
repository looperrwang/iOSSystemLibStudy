#version 300 es

in mediump vec3 vertColor;
in mediump vec2 TextCoord;

uniform sampler2D tex1;
uniform sampler2D tex2;
uniform mediump float mixValue;

out mediump vec4 color;

void main()
{
    mediump vec4 color1 = texture(tex1, TextCoord);
    mediump vec4 color2 = texture(tex2, vec2(TextCoord.s, (1.0f - TextCoord.t)));
	color = mix(color1, color2, mixValue);
}
