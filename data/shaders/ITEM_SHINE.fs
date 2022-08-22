
extern vec4 shineColor;
extern float xRatio;

extern float anim;

vec4 effect( vec4 color, Image tex, vec2 uvs, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, uvs);

    float diagonalPos = uvs.x * xRatio + uvs.y;

    int shining = int(abs(diagonalPos - anim) < 0.33);
    int notShining = - shining + 1;

    vec4 px = texcolor * notShining + shineColor * shining;
    px.a = texcolor.a;

    return px;
}