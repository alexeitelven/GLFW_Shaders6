#version 320 es

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec3      iResolution;              // viewport resolution (in pixels)
uniform float     iTime;                    // shader playback time (in seconds)
uniform vec4      iMouse;                   // mouse pixel coords. xy: current (if MLB down), zw: click

layout(location = 0) out vec4 color;

#define CONTROL_POINTS_COUNT 2
#define POINT_SIZE 5
#define EPS 1e-8
#define LINE_SIZE 0.01

//*****Adjustable parameters****/////
const vec2 cp1 = vec2(0.2, 0.5);
const vec2 cp2 = vec2(0.8, 0.5);

const vec4 control_point_color = vec4(0.2, 0.3, 0.8, 1.);
const vec4 mouse_point_color = vec4(0.9, 0.8, 0.2, 1.);
const vec4 bezier_color = vec4(0.3, 0.95, 0.2, 1.);
//******************************/////


bool point(vec2 coord, vec2 center, vec2 resolution)
{
 	return int(length(coord * resolution - center * resolution)) < POINT_SIZE;
}

vec2 solve_quadratic(float a, float b, float c)
{
    vec2 result;
    float D = b * b - 4. * a * c;
    result[0] = D >= 0. ? (-b + sqrt(D)) / (2. * a) : -1.;
    result[1] = D >= 0. ? (-b - sqrt(D)) / (2. * a) : -1.;
    return result;
}

bool is_on_bezier_curve(vec2 point, vec2 p0, vec2 p1, vec2 p2)
{
 	vec2 x_solutions, y_solutions;
    x_solutions = solve_quadratic(p0.x - 2. * p1.x + p2.x,
                                  2. * (p1.x - p0.x),
                                  p0.x - point.x);

    y_solutions = solve_quadratic(p0.y - 2. * p1.y + p2.y,
                                  2. * (p1.y - p0.y),
                                  p0.y - point.y);
    bool cond_1 = abs(x_solutions[0] - y_solutions[0]) < LINE_SIZE &&
        abs(y_solutions[0] + 1.) > EPS && abs(x_solutions[0] + 1.) > EPS;
    bool cond_2 = abs(x_solutions[0] - y_solutions[1]) < LINE_SIZE &&
        abs(y_solutions[1] + 1.) > EPS && abs(x_solutions[0] + 1.) > EPS;
    bool cond_3 = abs(x_solutions[1] - y_solutions[0]) < LINE_SIZE &&
        abs(y_solutions[0] + 1.) > EPS && abs(x_solutions[1] + 1.) > EPS;
    bool cond_4 = abs(x_solutions[1] - y_solutions[1]) < LINE_SIZE &&
        abs(y_solutions[0] + 1.) > EPS && abs(x_solutions[0] + 1.) > EPS;
    return cond_1 || cond_2 || cond_3 || cond_4;
}

//void mainImage( out vec4 fragColor, in vec2 fragCoord )
void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 res = iResolution.xy;
    vec2 point_size = vec2(POINT_SIZE, POINT_SIZE) / iResolution.xy;
    vec2 mouse_pos = iMouse.xy / iResolution.xy;
//	vec2 line_size = vec2(LINE_WIDTH, LINE_WIDTH) / iResolution.xy;


	color = point(uv, cp1, res) || point(uv, cp2, res) ?
        control_point_color : vec4(1, 1, 1, 1);

    color = point(uv, mouse_pos, iResolution.xy) ? mouse_point_color : color;

    color = is_on_bezier_curve(uv, cp1, mouse_pos, cp2) ? bezier_color : color;

}
