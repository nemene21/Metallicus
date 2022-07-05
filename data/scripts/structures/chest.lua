
CHEST_IMAGE = {
    love.graphics.newImage("data/images/structures/chest/chest.png"),
    love.graphics.newImage("data/images/structures/chest/chestOpen.png")
}

function newChest(x, y, lootTable)

    return {

        x = x, y = y, open = false, lootTable = lootTable, rect = newRect(x - 24, y - 33, 48, 33), animation = 0,

        draw = drawChest, process = processChest

    }

end

function processChest(chest)

    if chest.open == false then

        for id, projectile in ipairs(playerProjectiles) do

            if rectCollidingCircle(chest.rect, projectile.pos.x, projectile.pos.y, projectile.radius) and chest.open == false then

                chest.open = true

                chest.animation = 1

                shock(chest.x, chest.y - 12, 0.25, 0.04, 0.4)

                for id, I in ipairs(getLootTable(biomeOn .. "Chest"):returnDrops()) do -- Drop items

                    table.insert(ROOM.items, newItem(chest.x + love.math.random(-16, 16), chest.y - 12, I, newVec(love.math.random(-400, 400), love.math.random(300, 600))))
    
                end

            end

        end

    end

end

function drawChest(chest)

    setColor(255, 255, 255)

    chest.animation = lerp(chest.animation, 0, dt * 6)

    love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", boolToInt(chest.animation > 0.4))

    drawSprite(CHEST_IMAGE[boolToInt(chest.open) + 1], chest.x, chest.y, 1 - chest.animation * 1.5, 1 + chest.animation * 1.5)

    love.graphics.setShader()

end