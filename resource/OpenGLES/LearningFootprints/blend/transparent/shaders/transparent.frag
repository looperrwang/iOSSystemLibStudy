#version 300 es

precision mediump float;

in vec2 TextCoord;
uniform sampler2D text;

out vec4 color;

void main()
{
	vec4 textColor = texture(text, TextCoord);
    if (textColor.a < 0.1)
        discard;
    
    color = textColor;
}
