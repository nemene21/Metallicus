uniform float xRatio = 0;
int size = 6;
float multiplier = 0.005;
int unintensity = 80;
int iterations = size * size + unintensity;

uniform float blurrSize = 1 / 600 * 24;
uniform float bloomIntensity = 0.075;

uniform float grayscale = 0.0;

extern float hurtVignetteIntensity;
extern Image hitVignetteMask;

extern Image vignetteMask;

extern Image lightImage;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,uvs + xRatio * 0);

    px += Texel(image, vec2(uvs.x + blurrSize, uvs.y + blurrSize)) * bloomIntensity; // Bloom
    px += Texel(image, vec2(uvs.x - blurrSize, uvs.y + blurrSize)) * bloomIntensity;
    px += Texel(image, vec2(uvs.x + blurrSize, uvs.y - blurrSize)) * bloomIntensity;
    px += Texel(image, vec2(uvs.x - blurrSize, uvs.y - blurrSize)) * bloomIntensity;
    px += Texel(image, vec2(uvs.x, uvs.y + blurrSize)) * bloomIntensity;
    px += Texel(image, vec2(uvs.x, uvs.y - blurrSize)) * bloomIntensity;
    px += Texel(image, vec2(uvs.x + blurrSize, uvs.y)) * bloomIntensity;
    px += Texel(image, vec2(uvs.x - blurrSize, uvs.y)) * bloomIntensity;

    vec4 glow = px;

    vec4 lightedImage = px * Texel(lightImage,uvs) * 2;

    vec4 pxf = (lightedImage + (vec4(1, 0, 0, 1) - lightedImage) * hurtVignetteIntensity * Texel(hitVignetteMask, uvs).r) * Texel(vignetteMask, uvs);
    float gsc = (pxf.r + pxf.g + pxf.b) * 0.33;

    return vec4(pxf.r + (gsc - pxf.r) * grayscale, pxf.g + (gsc - pxf.g) * grayscale, pxf.b + (gsc - pxf.b) * grayscale, 1);
}