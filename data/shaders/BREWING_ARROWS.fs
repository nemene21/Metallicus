
uniform float progress = 0.0;

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{   

    float grayscale = 0.5 + 0.5 * int(uvs.x < progress);

    vec4 modifiedColor = vec4(grayscale, grayscale, grayscale, 0.75);

    vec4 texcolor = Texel(tex, uvs);

    texcolor *= modifiedColor;
    
    return texcolor;
}