


function newEnterable(x, y, texture, room, doorCollider, process, draw)

    return {

        x = x, y = y, sprite = texture, tiles = tiles, doorCollider = newRect(doorCollider.x + x, doorCollider.y + y, doorCollider.w, doorCollider.h), process = process or processEnterable, draw = draw or drawEnterable

    }

end

function drawEnterable(enterable)
    drawSprite(enterable.sprite, enterable.x, enterable.y, 1, 1, 0, 1, 0.5, 1)

    if isRectColliding(enterable.doorCollider, player.collider) then

        drawSprite(IMAGE_F, enterable.doorCollider.x + 2, enterable.doorCollider.y - enterable.doorCollider.h * 0.5 - 24 + math.sin(globalTimer * 2) * 9)

        if justPressed("f") then

            ROOM = {}

        end

    end

end

function processEnterable(enterable)
    
end




function newHouse(x, y)

    return newEnterable(x, y, love.graphics.newImage("data/images/structures/house.png"), loadJson("data/layouts/structureRooms/house.json"), newRect(-39, -33, 24, 60))

end

ENTERABLES = {
    house = newHouse
}