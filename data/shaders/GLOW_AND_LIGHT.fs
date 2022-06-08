
uniform float grayscale = 0.0;

extern float hurtVignetteIntensity;
extern Image hitVignetteMask;

extern Image vignetteMask;

extern Image lightImage;

float directions = 8.0;
float quality = 3.0;
float radius = 0.0018;

float PI2 = 6.2831;

float iterations = directions * quality - 15;

float intensityBloom = 0.55;

extern float xRatio;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,uvs);

    vec4 glow = px;

    float angle = PI2 / directions;
    float qualityDiv = 1.0 / quality;

    for (float directionOn = 0.0; directionOn < PI2; directionOn += angle) {

        for (float i = qualityDiv; i < quality; i += qualityDiv) {

            vec4 lookup = Texel(image, uvs + vec2(cos(directionOn) * xRatio, sin(directionOn)) * radius * i);
            glow += lookup * lookup;

        }

    }

    glow /= iterations;

    px += glow * intensityBloom;

    vec4 lightedImage = px * Texel(lightImage,uvs) * 2;

    vec4 pxf = (lightedImage + vec4(1, 0, 0, 1) * hurtVignetteIntensity * Texel(hitVignetteMask, uvs).r) * Texel(vignetteMask, uvs);
    float gsc = (pxf.r + pxf.g + pxf.b) * 0.33;

    return vec4(pxf.r + (gsc - pxf.r) * grayscale, pxf.g + (gsc - pxf.g) * grayscale, pxf.b + (gsc - pxf.b) * grayscale, 1);
}