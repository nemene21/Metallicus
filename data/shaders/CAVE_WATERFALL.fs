
extern Image noise;

extern Image screenImage;
uniform float time = 0.0;

vec2 screenSize = vec2(800, 600);

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{
    int inValid = int(abs(uvs.x - 0.5) < sin(uvs.y * 20 - time * 30) * 0.05 + 0.4);

    vec2 normalisedPos = screen_coords / screenSize;

    float offset = Texel(noise, vec2(uvs.x, uvs.y - time * 0.1)).r * 0.015;

    vec4 screenPixel = Texel(screenImage, normalisedPos + vec2(offset, offset));

    vec4 texturePixel = Texel(tex, vec2(uvs.x, uvs.y - time * 0.5));

    texturePixel = texturePixel + (vec4(0.173, 0.91, 0.961, 1.0) - texturePixel) * (- int(abs(uvs.x - 0.5) < sin(uvs.y * 20 - time * 30) * 0.05 + 0.35) * inValid + 1);

    return (screenPixel * 0.7 + texturePixel * 0.3) * color * inValid;
}