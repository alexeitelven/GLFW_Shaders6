#version 300 es

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;

layout(location = 0) out vec4 color;

void main()
{

  vec2 centro = iResolution.xy/2.0;

  float distCentro = distance(gl_FragCoord.xy,centro);
  float distBorda = distance(gl_FragCoord.xy,iResolution.xy);

  //float alpha = 1.0 - smoothstep( 0.0, 1.0, dist );
  float alpha = distCentro / distBorda;

  //if (alpha == 0.0) {
    //discard; // discard fully transparent pixels
  //}

    color = vec4( 1.0, 0.0, 0.0, alpha );
  // Não mais suportado
  //gl_FragColor = color;

};
