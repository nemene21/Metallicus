
uniform float timePassed = 0.0;

uniform float cameraX = 0.0;
uniform float cameraY = 0.0;

uniform int offset = 4;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{

    vertex_position.x += sin(timePassed + (vertex_position.x + cameraX)) * offset;
    vertex_position.y += sin(timePassed + (vertex_position.y + cameraY)) * offset;

    return transform_projection * vertex_position;

}

