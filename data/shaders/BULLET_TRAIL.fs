

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{

    vec4 texcolor = Texel(tex, uvs);

    texcolor.a = (1 - uvs.x * 1.2);

    return texcolor * color;
}