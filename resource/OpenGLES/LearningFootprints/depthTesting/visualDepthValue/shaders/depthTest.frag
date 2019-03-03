#version 300 es

precision mediump float;

in vec2 TextCoord;
uniform sampler2D text;

out vec4 color;

//1、直接使用gl_FragCoord
float asDepth()
{
    return gl_FragCoord.z; //屏幕坐标系下的z即为深度值
    //gl_FragDepth的含义是什么
}

//2、线性
float near = 1.0f;
float far  = 100.0f;
float LinearizeDepth()
{
    float Zndc = gl_FragCoord.z * 2.0 - 1.0;
    float Zeye = (2.0 * near * far) / (far + near - Zndc * (far - near));
    return (Zeye - near)/ ( far - near);
}

//3、模拟gl_FragCoord
float nonLinearDepth()
{
    float Zndc = gl_FragCoord.z * 2.0 - 1.0; // º∆À„ndc◊¯±Í ’‚¿Ôƒ¨»œglDepthRange(0,1)
    float Zeye = (2.0 * near * far) / (far + near - Zndc * (far - near)); // ’‚¿Ô∑÷ƒ∏Ω¯––¡À∑¥◊™
    return (1.0 / near - 1.0 / Zeye) / (1.0 / near - 1.0 / far);
}

void main()
{
    float depth = asDepth(); //近黑远白，非线性
    //float depth = LinearizeDepth(); //几乎全黑
    //float depth = nonLinearDepth(); //与直接使用gl_FragCoord.z无异
	color = vec4(vec3(depth), 1.0f);
}
