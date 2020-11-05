#version 320 es

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds)
uniform vec2 iMouse;

layout(location = 0) out vec4 color;

#define M_PI 3.1415926535897932384626433832795

vec2 rotate(vec2 vec, float angle) {
    vec2 res;
	res.x = vec.x * cos(angle) - vec.y * sin(angle);
    res.y = vec.x * sin(angle) + vec.y * cos(angle);

	return res;
}

float Band(float val, float a, float b, float blur) {
	return smoothstep(a - blur, a + blur, val) * smoothstep(b + blur, b - blur, val);
}

float Rect(vec2 uv, float bottom, float top, float left, float right, float blur) {
	float bandV = Band(uv.y, bottom, top, blur);
    float bandH = Band(uv.x, left, right, blur);

    return bandV * bandH;
}

float Circle(vec2 uv, vec2 center, float radius, float blur) {
    float dist = distance(uv, center);

    return smoothstep(radius+blur, radius-blur, dist);
}

float Ellipse(vec2 uv, vec2 center, float a, float b, float blur) {
    uv-= center;
    float leftSide = uv.x * uv.x / (a * a);
    float rightSide = 1.f - uv.y * uv.y / (b * b);
    float blur2 = sqrt(blur * 2.f) / 2.f;
    return smoothstep(leftSide - blur2, leftSide + blur2, rightSide);
}

float IsoscelesTriangle(vec2 uv, vec2 center, float height, float baseHalf, float blur) {
    uv -= center;
    float left = Rect(uv, 0.f, height, -(baseHalf - uv.y / height * baseHalf), 0.f, blur);
    float right = Rect(uv, 0.f, height, 0.f, baseHalf - uv.y / height * baseHalf, blur);

	return left + right;
}

float StarPoligon(vec2 uv, vec2 center, float radius, int n, int d, float blur) {
    uv -= center;
    uv /= radius;
    float beta = 2.f * M_PI * (float(d) - 1.f) / float(n);
	float pointAngleHalf = (M_PI - 2.f * beta) * 0.5f;

    float baseHalf = tan(pointAngleHalf);

    float star = 0.f;
    for (int i = 0; i < n; i += 1) {
        float angle = M_PI * 2.f / float(n) * float(i);
    	star = max(IsoscelesTriangle(rotate(uv, angle), vec2(0.f), 1.f, baseHalf, blur), star);
    }

    return star;
}

float Sickle(vec2 uv, vec2 center, float side, float blur) {
    uv -= center;

    float circleScale = 0.8f;
    float circleOffset = 1.f - circleScale;
    float radius = side * circleScale;
    vec2 circleCenter = vec2(0.f, side * circleOffset);

    // Blade
    float circle = Circle(uv, circleCenter, radius, blur);

    vec2 ellipseCenter = vec2(circleCenter.x - 0.19f * radius, circleCenter.y + 0.05f * radius);
    float ellipse = Ellipse(uv, ellipseCenter, radius * 0.9f, radius * 0.8f, blur);
    float rect = Rect(uv, -(radius + blur), 0.f, -(radius + blur), 0.f, blur);

    float blade = circle - ellipse - rect;

    // Handle
    float handleThickness = radius * 0.18f; // at the bottom
    float bottom = -side + handleThickness;
    float top = -radius * 0.47f;
    float height = bottom - top;
    float x = (uv.y - bottom) / height * 0.08f * radius;
    float left = -handleThickness - x;
    float right = handleThickness + x;
    rect = Rect(uv, bottom, top, left, right, blur);
   	circle = Circle(uv, vec2(0.f, bottom), handleThickness, blur);

    float handle = max(rect, circle);

    float frame = Rect(uv, -side, side, -side, side, blur);
    return max(handle, blade);
}

float Hammer(vec2 uv, vec2 center, float side, float blur) {
	uv -= center;
    float frame = Rect(uv, - side, side, -side, side, blur);

    // Handle
    float handleThickness = 0.13f * side; // at the bottom

    float height = side * 2.f - handleThickness;
    float bottom = -side + handleThickness;
    float top = side;
    float x = (uv.y - bottom) / height * side * 0.05f;
    float left = -handleThickness + x;
    float right = handleThickness - x;
    float rect = Rect(uv, bottom, top, left, right, blur);
    float circle = Circle(uv, vec2(0.f, -side + handleThickness), handleThickness, blur);
    float handle = max(rect, circle);

    // Head
    float headHeight = side * 0.45f;
    float headWidth = side * 0.5f; // at the bottom

   	bottom = side - headHeight;
    top = side;
    x = (uv.y - bottom) / headHeight * side * 0.2f;
    left =  -headWidth;
    right = headWidth - x;
    rect = Rect(uv, bottom, top, left, right, blur);

    return max(rect, handle);
}

float CoatOfArms(vec2 uv, vec2 center, float scale, float blur) {
    uv -= center;
    uv /= scale;
    float side = 0.5f;

	float sickle = Sickle(rotate(uv, 0.25f * M_PI), vec2(-0.1f * side, -0.15f * side), side, blur);
    float hammer = Hammer(rotate(uv, -0.25f * M_PI), vec2(0.02f, -0.1f), side * 0.9f, blur);

    float frame = Rect(uv, -0.5f, 0.5f, -0.5f, 0.5f, blur);
    return max(sickle, hammer);
}

vec4 Flag(vec2 uv, vec2 center, float scale, float blur) {
    uv -= center;
    uv /= scale;

    vec4 flagRed = vec4(0.78f, 0.f, 0.f, 1.f);
    vec4 flagYellow = vec4(1.f, 0.79f, 0.055f, 1.f);

    float flagLength = 0.8f;
    // The flag aspect ratio was 1/2
    float heightHalf = flagLength / 2.f;

    // construct sine wave
    float sinScaleX = 8.f;
    float tilt = uv.y * 2.f; // tilt the wave, so that it's not parallel to height
    float offset = -mod(iTime + tilt, 2.f * M_PI); // dynamic offset to make wave move
    float sinVal = sin(uv.x * sinScaleX + offset);
    // subtract sine value at flag base, so that base does not move
    float flagBaseSin = sin(-flagLength * sinScaleX + offset);

    float waveStrength = 0.033f;
    float wave = (sinVal - flagBaseSin) * waveStrength;

    uv.y -= wave; // apply wave

    // flag symbols
    float symbolsX = -flagLength + heightHalf * 2.f / 3.f;
    vec2 coatPosition = vec2(symbolsX, heightHalf * 0.37f);
    float coatOfArms = CoatOfArms(uv, coatPosition, heightHalf / 2.f, blur);

    vec2 starPosition = vec2(symbolsX, heightHalf *3.f / 4.f);
    float starOuter = StarPoligon(uv, starPosition, heightHalf / 8.f, 5, 2, blur * 3.f);
    float starInner = StarPoligon(uv, starPosition, heightHalf / 15.f, 5, 2, blur * 2.f);

    float symbols = coatOfArms + starOuter - starInner;

    // make right side of the flag wave
    float right = flagLength * (1.f + 0.05f * sinVal);
    float flag = Rect(uv, -heightHalf, heightHalf, -flagLength, right, blur);

    vec4 flagCol = flagRed * flag;
    vec4 symbolsCol = flagYellow * symbols;
    vec4 col = mix(flagCol, symbolsCol, symbolsCol.a);

    // add shadows and highlights based on sinusoid
    col.xyz -= (-sinVal * 0.11f) * flagCol.a;

    return col;
}

//void mainImage( out vec4 fragColor, in vec2 fragCoord )
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv -= 0.5f;
    uv.x *= iResolution.x / iResolution.y;

    vec4 skyBlue = vec4(0.53f, 0.81f, 0.92f, 1.f);
	vec4 flag = Flag(uv, vec2(0.f), 1.f, 0.01f);
    vec4 col = mix(skyBlue, flag, flag.a);

    // Output to screen
    color = col;
}
