#define NUM_LIGHTS 32

struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};

extern Light lights[NUM_LIGHTS];

extern vec2 screen;
extern int numLights;

extern float xRatio;
extern vec2 offset;

const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,uvs);

    vec2 norm_screen_pos = screen_coords / screen;

    vec3 diffuse = vec3(0);

    for (int i = 0; i < numLights; i++) {
        Light light = lights[i];

        vec2 norm_pos = (light.position + offset) / screen;

        float distance = length(vec2(norm_pos.x*xRatio,norm_pos.y) - vec2(norm_screen_pos.x*xRatio,norm_screen_pos.y)) * light.power;
        float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));

        diffuse += light.diffuse * attenuation;
    }

    diffuse = clamp(diffuse,0.0,1.1);

    return px * vec4(diffuse, 1.0);
}