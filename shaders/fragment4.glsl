#version 320 es

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds)
uniform vec2 iMouse;
//vec4 fragCoord = vec4(-1.0, 1.0, 1.0, -1.0);

layout(location = 0) out vec4 color;
//in vec2 fragCoord;

void main()
{

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy/iResolution.xy;
    //vec2 uv = fragCoord/iResolution.xy;

    float raio = iResolution.y / 3.0;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    if(distance(gl_FragCoord.xy,(iResolution.xy/2.0)) > raio)
        //color = vec4(col,1.0);
        color = vec4(fract((gl_FragCoord.xy - iMouse) / iResolution.xy), 0, 1);
    else
        color = vec4(1.0 - col, 1.0);
        //color = vec4(fract((gl_FragCoord.xy - iMouse) / iResolution.xy), 0, 1);
};
