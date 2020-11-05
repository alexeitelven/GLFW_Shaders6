#version 320 es

#ifdef GL_ES
    precision mediump float;
#endif

in vec2 v_TexCoord;
layout(location = 0) out vec4 color;

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;


void main()
{
	//color = vec4(0.0,0.0,0.5,1.0);
	vec4 texColor = texture(iChannel0, v_TexCoord);
    color = texColor;
};

