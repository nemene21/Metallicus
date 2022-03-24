
uniform float ratio = 0.5;

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, uvs);

    int difference = int(uvs.y - ratio + 1);
    texcolor.r *= difference; texcolor.g *= difference; texcolor.b *= difference;

    return texcolor * color;
}