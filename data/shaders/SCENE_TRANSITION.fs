
extern Image transitionNoise;

extern float transition;

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{
    vec4 noise = Texel(transitionNoise, uvs);

    return Texel(tex, uvs) * clamp(noise + (transition * 2 - 1), 0, 1);

}

