
extern Image screen;

vec2 screenRes = vec2(800, 600);

float xRatio = 600 / 800;

uniform vec2 center = vec2(0.5, 0.5);

extern float intensity;

extern float time;

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{   
    uvs = screen_coords / screenRes;

    float dist = length(uvs - center);

    float offset = (max(sin( - dist * 50 + time * 35), 0) * 0.04) * intensity;

    vec4 texcolor = Texel(screen, uvs + vec2(offset * xRatio, offset));

    return texcolor;
}