
MATERIAL_SPRITES = {
rock = {love.graphics.newImage("data/images/structures/rock3.png"), love.graphics.newImage("data/images/structures/rock2.png"), love.graphics.newImage("data/images/structures/rock1.png")},
wood = {love.graphics.newImage("data/images/structures/wood1.png"), love.graphics.newImage("data/images/structures/wood1.png"), love.graphics.newImage("data/images/structures/wood1.png")}
}

DESTROY_RESOURCE_PARTICLES = loadJson("data/particles/resourceDestroyed.json")

STRUCTURE_ID = 0.5

function newMaterial(x, y, name, drops, hitSound)
    STRUCTURE_ID = STRUCTURE_ID + 1
    local mat = {x = x, y = y, name = name, process = processMaterial, draw = drawMaterial, hp = 50, id = STRUCTURE_ID, sprite = love.math.random(1,3), hitTimer = 0, drops = drops, hitSound = hitSound}

    return mat
end

function processMaterial(mat)

    for id, P in ipairs(playerProjectiles) do

        if newVec(P.pos.x - mat.x, P.pos.y - mat.y):getLen() < 36 + P.radius then

            local isInHitlist = false

            for _, ID in ipairs(P.hitlist) do
                if ID == mat.id then isInHitlist = true end
            end

            if not isInHitlist then

                playSound(mat.hitSound, love.math.random(80, 120) * 0.01)

                table.insert(ROOM.textPopUps.particles,{
                    x = mat.x + love.math.random(-24, 24), y = mat.y + love.math.random(-24, 24) - 24,
                    vel = newVec(0, -100), width = tostring(P.damage),
                    lifetime = 1, lifetimeStart = 1,
                    color = {r=255,g=0,b=0,a=1},
                    rotation = 0
            
                })

                mat.hp = mat.hp - P.damage
                mat.hitTimer = 0.2
                P.pirice = P.pirice - 1

                table.insert(P.hitlist, mat.id)

            end
            
        end

    end

    if mat.hp <= 0 and mat.dead == nil then
        
        table.insert(ROOM.particleSystems, newParticleSystem(mat.x, mat.y - 20, deepcopyTable(DESTROY_RESOURCE_PARTICLES)))
        mat.dead = true

        for id,I in pairs(mat.drops) do

            local amount = 0
            local percentage = I

            while percentage > 100 do

                percentage = percentage - 100; amount = amount + 1

            end

            if love.math.random(1, 100) < percentage then amount = amount + 1 end

            for x=1,amount do
                local item = ITEMS[id]; item.amount = 1

                table.insert(ROOM.items, newItem(mat.x + love.math.random(-24, 24), mat.y + love.math.random(-24, 0), item))
            end
        end

    end
end

function drawMaterial(mat)

    mat.hitTimer = math.max(mat.hitTimer - dt, 0)
    if mat.hitTimer > 0.1 then SHADERS.FLASH:send("intensity", 1); love.graphics.setShader(SHADERS.FLASH) end

    local hitAnim = mat.hitTimer / 0.2
    drawSprite(MATERIAL_SPRITES[mat.name][mat.sprite], mat.x, mat.y, 1 - 0.25 * hitAnim, 1 + 0.25 * hitAnim, 0, 1, 0.5, 1)

    love.graphics.setShader()

end

-- Rock

function newRock(x, y)
    return newMaterial(x, y, "rock", {stone = 250}, "hitOre")
end

function newWood(x, y)
    return newMaterial(x, y, "wood", {wood = 250}, "hitOre")
end

MATERIAL_CONSTRUCTORS = {
    rock = newRock, wood = newWood
}

--                                                       TELEPORTER

IMAGE_F = love.graphics.newImage("data/images/UI/F.png")

IMAGE_TELEPORTER = love.graphics.newImage("data/images/structures/teleporter.png")
IMAGE_TELEPORTER_BROKEN = love.graphics.newImage("data/images/structures/teleporterBroken.png")

IMAGE_ANVIL = love.graphics.newImage("data/images/structures/anvil.png")
IMAGE_ANVIL_LANTERN = love.graphics.newImage("data/images/structures/anvilLantern.png")

IMAGE_TELEPORTER_LASER = love.graphics.newImage("data/images/structures/teleporterLaser.png")

PARTICLES_TELEPORT = loadJson("data/particles/teleport.json")
PARTICLES_TELEPORT_BURST = loadJson("data/particles/teleportBurst.json")

function newTeleporter(x, y, broken)
    local teleporter = {x = x, y = y}

    if broken then

        teleporter.process = processBrokenTeleporter
        teleporter.draw = drawBrokenTeleporter

    else

        teleporter.process = processTeleporter
        teleporter.draw = drawTeleporter
        teleporter.animTimer = newTimer(6)
        teleporter.teleportParticles = newParticleSystem(x, y - 300, deepcopyTable(PARTICLES_TELEPORT))
        teleporter.teleportParticlesBurst = newParticleSystem(x, y - 54, deepcopyTable(PARTICLES_TELEPORT_BURST))

    end

    return teleporter
end

function processTeleporter(teleporter)
    if math.abs(player.collider.x - teleporter.x) < 64 and math.abs(player.collider.y - teleporter.y) < 64 and not teleporter.pressed then

        love.graphics.setCanvas(UI_LAYER)
        drawSprite(IMAGE_F, teleporter.x + 3, teleporter.y - 86 + math.sin(globalTimer * 2) * 9)
        love.graphics.setCanvas(display)

        if justPressed("f") then

            teleporter.pressed = true
            shake(8, 55, 0.1)

            playSound("teleport")

        end

    end

    if teleporter.pressed then -- Teleporting animation

        bindCamera(clamp(teleporter.x, ROOM.endLeft.x + 400 - cameraWallOffset, ROOM.endRight.x - 400 + cameraWallOffset), clamp(teleporter.y + 300 - cameraWallOffset, ROOM.endUp.y, ROOM.endDown.y - 300 + cameraWallOffset), 2)

        UI_ALPHA = lerp(UI_ALPHA, 0, dt * 10)
        zoomInEffect = lerp(zoomInEffect, 1.2, dt * 2)

        player.bonusForce = newVec((teleporter.x - player.collider.x) * 1.5, (teleporter.y - player.collider.y) * 1.5)

        transition = 1 - teleporter.animTimer.time / teleporter.animTimer.timeMax
        teleporter.animTimer:process()

        love.graphics.setCanvas(particleCanvas)
        drawSprite(IMAGE_TELEPORTER_LASER, teleporter.x, teleporter.y - 53, (clamp((1 - teleporter.animTimer.time / teleporter.animTimer.timeMax) * 5, 0, 1)) + math.sin(globalTimer) * 0.1, 600, 0, 1, 0.5, 1)

        teleporter.teleportParticles:process()
        teleporter.teleportParticlesBurst:process()

        shine(teleporter.x, teleporter.y - 50, 400 * ((clamp((1 - teleporter.animTimer.time / teleporter.animTimer.timeMax) * 3, 0, 1)) + math.sin(globalTimer) * 0.1), {0, 149, 233})
    end

    if teleporter.animTimer:isDone() then -- Animation done

        zoomInEffect = 1
        UI_ALPHA = 255

        player.bonusForce = newVec(0, 0)
        player.vel = newVec(0, 0)
        player.collider.x = 300; player.collider.y = 540

        roomOn = 1

        ROOMS = generate(8,"cave")
        ROOM = ROOMS[roomOn]
    
        playerProjectiles = {}; enemyProjectiles = {}

    end
end

function drawTeleporter(teleporter)

    drawSprite(IMAGE_TELEPORTER, teleporter.x, teleporter.y - 3, 1, 1, 0, 1, 0.5, 1)

end

function processBrokenTeleporter(teleporter)

end

function drawBrokenTeleporter(teleporter)

    drawSprite(IMAGE_TELEPORTER_BROKEN, teleporter.x, teleporter.y - 3, 1, 1, 0, 1, 0.5, 1)

end

-- Anvil

CRAFTING_RECEPIES = loadJson("data/craftingRecipies.json")

function newAnvil(x, y)

    local anvil = {
        take = takeAwayMaterialsAnvil, x = x, y = y, process = processAnvil, draw = drawAnvil, open = false, slots = {}, checkCrafts = checkAnvilCrafts
    }

    for id, C in ipairs(CRAFTING_RECEPIES) do

        local slot = deepcopyTable(C); slot.scale = 1; slot.craftable = false

        for idS, S in ipairs(slot.materials) do table.insert(S, false) end

        table.insert(anvil.slots, slot)

    end

    anvil:checkCrafts()

    return anvil

end

function checkAnvilCrafts(anvil)

    for idC, C in ipairs(anvil.slots) do -- For crafts

        local materialsMet = 0

        for idM, M in ipairs(C.materials) do -- For materials

            local itemsLeft = M[2]

            for idS, S in ipairs(player.hotbar.slotIndexes) do -- For slots in inventory
                idS = S; S = player.hotbar.slots[S]

                if S.item ~= nil then -- If item exists and has the same name as the material

                    if S.item.index == M[1] then

                        itemsLeft = itemsLeft - S.item.amount -- Decrease the amount of x item that has to be met

                    end
                end

            end

            for idS, S in ipairs(player.inventory.slotIndexes) do -- For slots in hotbar
                idS = S; S = player.inventory.slots[S]

                if S.item ~= nil then -- If item exists and has the same name as the material

                    if S.item.index == M[1] then

                        itemsLeft = itemsLeft - S.item.amount -- Decrease the amount of x item that has to be met

                    end
                end

            end

            if itemsLeft <= 0 then materialsMet = materialsMet + 1; M[3] = true else M[3] = false end -- If there are enough items than the material is met

        end

        if materialsMet == #C.materials then C.craftable = true -- If all materials are met the craft is craftable, else...
        else C.craftable = false end

    end
end

function takeAwayMaterialsAnvil(anvil, slotId)

    for idM, M in ipairs(anvil.slots[slotId].materials) do -- For materials

        local itemsLeft = M[2]

        for idS, S in ipairs(player.hotbar.slotIndexes) do -- For slots in inventory
            idS = S; S = player.hotbar.slots[S]

            if S.item ~= nil then -- If item exists and has the same name as the material

                if S.item.index == M[1] then

                    S.item.amount = S.item.amount - itemsLeft

                    if S.item.amount <= 0 then -- If the slot is empty or in a minus

                        itemsLeft = math.abs(S.item.amount) -- Set the amounts
                        S.item = nil
                    else
                        itemsLeft = 0
                    end

                end
            end

        end

        for idS, S in ipairs(player.inventory.slotIndexes) do -- For slots in inventory
            idS = S; S = player.inventory.slots[S]

            if S.item ~= nil then -- If item exists and has the same name as the material

                if S.item.index == M[1] then

                    S.item.amount = S.item.amount - itemsLeft

                    if S.item.amount <= 0 then -- If the slot is empty or in a minus

                        itemsLeft = math.abs(S.item.amount) -- Set the amounts
                        S.item = nil
                    else
                        itemsLeft = 0
                    end

                end
            end

        end

    end
end

function processAnvil(anvil)

    if player.hotbar.justUpdated or player.inventory.justUpdated then

        anvil:checkCrafts()

    end

    if anvil.open then

        love.graphics.setCanvas(UI_LAYER)

        drawSprite(IMAGE_F, anvil.x + 3, anvil.y - 86 + math.sin(globalTimer * 2) * 9)

        if justPressed("f") or not (math.abs(player.collider.x - anvil.x) < 64 and math.abs(player.collider.y - anvil.y) < 64) or not player.inventoryOpen then anvil.open = false; player.inventoryOpen = false end

        -- Draw crafting slots
        for id, S in ipairs(anvil.slots) do
            
            local posY = 21 + 56 * id

            setColor(255, 255 * boolToInt(S.craftable), 255 * boolToInt(S.craftable))
            drawSprite(SLOT_IMAGES["equipmentSlot"], 744, posY, S.scale, S.scale, 0, 0) -- Draw slot
            drawSprite(ITEM_IMGES[S.name], 744, posY, S.scale, S.scale, 0, 0)

            if S.amount ~= 1 then

                outlinedText(768, posY + 5, 2, S.amount, {255,255,255}, 1, 1, 1)

            end
            
            for idMat, M in ipairs(S.materials) do -- Draw materials

                setColor(255, 255, 255)
                drawSprite(ITEM_IMGES[M[1]], 744 - 21 - 56 * idMat, posY, 1, 1, 0, 0)

                outlinedText(768 - 21 - 56 * idMat, posY + 5, 2, M[2], {255, 255 * boolToInt(M[3]), 255 * boolToInt(M[3])}, 1, 1, 1)

            end

            if xM > 720 and xM < 768 and yM > posY - 24 and yM < posY + 24 then -- If hovering over slot

                S.scale = lerp(S.scale, 1.2, dt * 20)

                if mouseJustPressed(1) and S.craftable then -- I pressed
                    
                    S.scale = 1.4

                    -- Give the item
                    local item = ITEMS[S.name]; item.amount = S.amount

                    item = player.hotbar:addItem(item)

                    if item.amount ~= 0 then player.inventory:addItem(item) end

                    if item.amount ~= 0 then table.insert(ROOM.items, newItem(player.collider.x + 24 * (boolToInt(player.collider.x - camera[1] < xM) * 2 - 1), player.collider.y, item)) end
                    
                    -- Remove the requrements

                    anvil:take(id)

                    -- Cheeck crafts again
                    anvil:checkCrafts()
                end

            else

                S.scale = lerp(S.scale, 1, dt * 20)

            end

        end

        love.graphics.setCanvas(display)
    else

    if  math.abs(player.collider.x - anvil.x) < 64 and math.abs(player.collider.y - anvil.y) < 64 then

        love.graphics.setCanvas(UI_LAYER)
        drawSprite(IMAGE_F, anvil.x + 3, anvil.y - 86 + math.sin(globalTimer * 2) * 9)
        love.graphics.setCanvas(display)

        if justPressed("f") then player.inventoryOpen = false; anvil.open = true; player.inventoryOpen = true end

    end

    end
end

function drawAnvil(anvil)

    drawSprite(IMAGE_ANVIL, anvil.x, anvil.y, 1, 1, 0, 1, 0.5, 1)
    drawSprite(IMAGE_ANVIL_LANTERN, anvil.x + 64, anvil.y, 1, 1, 0, 1, 0.5, 1)

    shine(anvil.x + 52, anvil.y - 96, 400 + math.sin(globalTimer) * 12, {230,180,80,160})

end