
uniform int colorBlindMode;

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, uvs);

    if (colorBlindMode == 1) {texcolor = texcolor.gbra;}
    if (colorBlindMode == 2) {texcolor = texcolor.brga;}
    if (colorBlindMode == 3) {texcolor = texcolor.bgra;}

    return texcolor * color;
}