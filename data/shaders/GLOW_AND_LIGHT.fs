uniform float xRatio = 0;
int size = 6;
float multiplier = 0.005;
int unintensity = 120;
int iterations = size * size + unintensity;

extern Image lightImage;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,uvs) * Texel(lightImage,uvs);
    vec4 glow = px;

    for (int x = -size; x < size; x++) {
    for (int y = -size; y < size; y++) {

        float len = 1-sqrt(x*x+y*y)/size;

        glow += Texel(image,uvs + vec2(x * multiplier * xRatio, y * multiplier)) * len * Texel(lightImage,uvs + vec2(x * multiplier * xRatio, y * multiplier));

    }
    }

    return px + vec4(glow.r/iterations, glow.g/iterations, glow.b/iterations, 1);
}