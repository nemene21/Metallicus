uniform float intensity = 0;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,uvs);
    px.r = px.r + (1 - px.r) * intensity;
    px.g = px.g + (1 - px.g) * intensity;
    px.b = px.b + (1 - px.b) * intensity;

    return px;
}