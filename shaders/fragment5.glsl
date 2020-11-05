#version 320 es
#ifdef GL_ES
	precision mediump float;
#endif

uniform vec2 iResolution;
uniform vec2 iMouse;
uniform float iTime;

layout(location = 0) out vec4 color;

void main() {
    vec2 st = gl_FragCoord.xy/iResolution.xy;
    st.x *= iResolution.x/iResolution.y;

    color = vec4(st.x,st.y,abs(sin(iTime)),1.0);
}
