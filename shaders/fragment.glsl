#version 320 es

#ifdef GL_ES
    precision mediump float;
#endif

//layout(location = 0) out vec4 color;
out vec4 color;

void main()
{

    vec2 xy = gl_FragCoord.xy; // Pegamos a coordenada de cada pixel
    vec4 cor = vec4(0,0.0,0.0,1.0); // Cria uma nova cor zerada
    if(xy.x < 320.0){ // Metade vertical da tela, definido arbitrariamente
        cor.r = 1.0;  // vermelho máximo
        cor.b = 0.0;  // azul nada
    } else {
        cor.r = 0.0; // vermelho nada
        cor.b = 1.0; // azul máximo
    }
    if(xy.y > 240.0){ // Metade horizontal da tela, definido arbitrariamente
        cor.g = 1.0;  // verde máximo
    }
    color = cor;
};

