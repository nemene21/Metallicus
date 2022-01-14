uniform float snapX = 0.005;
uniform float snapY = 0.005;

vec4 effect( vec4 color, Image image, vec2 uvs, vec2 screen_coords )
{
    vec4 px = Texel(image,vec2(int(uvs.x/snapX)*snapX, int(uvs.y/snapY)*snapY));

    return px;
}