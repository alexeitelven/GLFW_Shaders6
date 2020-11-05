#version 320 es

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds)
uniform vec4      iMouse;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform int       iFrame;

layout(location = 0) out vec4 fragColor;

// Created by Shadertoy - iq/2017
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const int[] font = int[](0x75557, 0x22222, 0x74717, 0x74747, 0x11574, 0x71747, 0x71757, 0x74444, 0x75757, 0x75747);
const int[] powers = int[](1, 10, 100, 1000, 10000, 100000, 1000000);

int PrintInt( in vec2 uv, in int value, const int maxDigits )
{
    if( abs(uv.y-0.5)<0.5 )
    {
        int iu = int(floor(uv.x));
        if( iu>=0 && iu<maxDigits )
        {
            int n = (value/powers[maxDigits-iu-1]) % 10;
            uv.x = fract(uv.x);//(uv.x-float(iu));
            ivec2 p = ivec2(floor(uv*vec2(4.0,5.0)));
            return (font[n] >> (p.x+p.y*4)) & 1;
        }
    }
    return 0;
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}


//oid mainImage( out vec4 fragColor, in vec2 fragCoord )
void main()
{

    vec2 fragCoord = gl_FragCoord.xy;

    //------------------------------
    // coords (-1,1) with 10% paddin
    //------------------------------

    vec2  uv = 1.1 * (-iResolution.xy+2.0*fragCoord)/iResolution.y;
    float px = 1.1 * 2.0/iResolution.y;


    //------------------------------
    // animation
    //------------------------------

    float t = (iMouse.z<0.001) ? iTime : 6.2831*iMouse.x/iResolution.x;
    vec2 p = cos( t - vec2(0.0,3.1415927/2.0) );


    //------------------------------
    // rendering
    //------------------------------

    vec3 col = vec3(0.0);
    // grid
    col = vec3( 0.2 ) + 0.01*mod(floor(uv.x*10.0)+floor(uv.y*10.0),2.0);
	// circle
    col = mix( col, vec3(0.0,0.0,0.0), 1.0-smoothstep( 0.0, px, abs(length(uv)-1.0) ) );
	// axes
    col = mix( col, vec3(0.0,0.0,0.0), 1.0-smoothstep( 0.0, px, abs(uv.x) ) );
    col = mix( col, vec3(0.0,0.0,0.0), 1.0-smoothstep( 0.0, px, abs(uv.y) ) );
    // orage lines
    col = mix( col, vec3(1.0,0.7,0.0), 1.0-smoothstep( 0.0, px, sdSegment(uv, vec2(p.x,0.0), p) ) );
    col = mix( col, vec3(1.0,0.7,0.0), 1.0-smoothstep( 0.0, px, sdSegment(uv, vec2(0.0,p.y), p) ) );
    col = mix( col, vec3(1.0,0.7,0.0), 1.0-smoothstep( 0.0, px, sdSegment(uv, vec2(0.0,0.0), p) ) );
    // red point
    col = mix( col, vec3(1.0,0.3,0.0), 1.0-smoothstep( 0.0, px, abs(length(uv-p)-0.03)-0.002 ) );
    // numbers
    col += vec3(0.7,0.4,0.1)*float( PrintInt( (uv-vec2(1.3,-0.95))*10.0, int(round(abs(10000.0*p.x))), 5 ) );


    fragColor = vec4( col, 1.0 );
}

