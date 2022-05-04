
uniform float grayscale = 0.0;

extern float hurtVignetteIntensity;
extern Image hitVignetteMask;

extern Image vignetteMask;

extern Image lightImage;

uniform int bloomCycles = 0;
uniform int bloomCyclesHalf = 0;

uniform float bloomSize = 0.0002;

uniform float bloomIntensity = 0.0;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,uvs);

    vec4 bloomV = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 bloomH = vec4(0.0, 0.0, 0.0, 1.0);

    float bloomCyclesHalfAbs = bloomCycles * 0.5;

    for (int x = bloomCyclesHalf; x < bloomCycles; x++) {

        vec4 pxGotten = Texel(image, vec2(uvs.x + bloomSize * x, uvs.y)) * (1.0 - abs(x) / bloomCycles);
        bloomH += pxGotten;

    }

    for (int y = bloomCyclesHalf; y < bloomCycles; y++) {
        
        vec4 pxGotten = Texel(image, vec2(uvs.x, uvs.y + bloomSize * y)) * (1.0 - abs(y) / bloomCycles);
        bloomV += pxGotten;

    }

    vec4 glow = bloomV * bloomH * bloomIntensity;

    px += glow;

    vec4 lightedImage = px * Texel(lightImage,uvs) * 2;

    vec4 pxf = (lightedImage + vec4(1, 0, 0, 1) * hurtVignetteIntensity * Texel(hitVignetteMask, uvs).r) * Texel(vignetteMask, uvs);
    float gsc = (pxf.r + pxf.g + pxf.b) * 0.33;

    return vec4(pxf.r + (gsc - pxf.r) * grayscale, pxf.g + (gsc - pxf.g) * grayscale, pxf.b + (gsc - pxf.b) * grayscale, 1);
}