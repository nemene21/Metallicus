
uniform float grayscale = 0.0;

extern float hurtVignetteIntensity;
extern Image hitVignetteMask;

extern Image vignetteMask;

extern Image lightImage;

float directions = 8.0;
float quality = 3.0;
float radius = 0.001;

float PI2 = 6.2831;

float iterations = directions * quality - 15;

float intensityBloom = 0.6;

extern float xRatio;

struct Shockwave {

    vec2 position;

    float size;

    float force;
    
    float lifetime;
    float lifetimeMax;

};

extern int ACTIVE_SHOCKWAVES;

extern Shockwave shockwaves[16];

vec2 screenDimensions = vec2(800, 600);

extern float motionBlur = 0.0;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{

    color.a = 1 - motionBlur;

    for (int i = 0; i < ACTIVE_SHOCKWAVES; i++) {

        Shockwave shockwaveOn = shockwaves[i];

        vec2 normalisedPos = shockwaveOn.position / screenDimensions;

        float multiplier = shockwaveOn.lifetime / shockwaveOn.lifetimeMax;

        vec2 diff = uvs - normalisedPos;

        diff.x /= xRatio;

        float dist = length(diff);

        diff.x /= dist;
        diff.y /= dist;

        float size = (1 - multiplier) * shockwaveOn.size;

        vec2 disp = diff * int(dist < size && dist > size * 0.25) * shockwaveOn.force;

        uvs -= disp * multiplier;

    }

    vec4 px = Texel(image,uvs);

    vec4 glow = px;

    float angle = PI2 / directions;
    float qualityDiv = 1.0 / quality;

    for (float directionOn = 0.0; directionOn < PI2; directionOn += angle) {

        for (float i = qualityDiv; i < quality; i += qualityDiv) {

            vec4 lookup = Texel(image, uvs + vec2(cos(directionOn) * xRatio, sin(directionOn)) * radius * i);
            glow += lookup * lookup * (i / quality);

        }

    }

    glow /= iterations;

    px += glow * intensityBloom;

    vec4 lightedImage = px * Texel(lightImage,uvs) * 2;

    vec4 pxf = (lightedImage + vec4(1, 0, 0, 1) * hurtVignetteIntensity * Texel(hitVignetteMask, uvs).r) * Texel(vignetteMask, uvs);
    float gsc = (pxf.r + pxf.g + pxf.b) * 0.33;

    return vec4(pxf.r + (gsc - pxf.r) * grayscale, pxf.g + (gsc - pxf.g) * grayscale, pxf.b + (gsc - pxf.b) * grayscale, 1) * color;
}