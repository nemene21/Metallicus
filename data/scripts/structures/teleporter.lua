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
        drawInteract(teleporter.x + 3, teleporter.y - 86 + math.sin(globalTimer * 2) * 9)
        love.graphics.setCanvas(display)

        if justPressed("f") then

            teleporter.pressed = true

            ENEMY_HP_SCALE = ENEMY_HP_SCALE + 0.1

            shake(8, 55, 0.1)

            playSound("teleport")

            shock(teleporter.x, teleporter.y - 24, 1.5, 0.03, 1)

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
        
        love.graphics.setCanvas(lightImage)
        setColor(255, 255, 255, 150)
        drawSprite(IMAGE_TELEPORTER_LASER, teleporter.x, teleporter.y - 53, (clamp((1 - teleporter.animTimer.time / teleporter.animTimer.timeMax) * 5, 0, 1)) + math.sin(globalTimer) * 0.1, 600, 0, 1, 0.5, 1)

        teleporter.teleportParticles:process()
        teleporter.teleportParticlesBurst:process()

        trackPitch = lerp(1, 4, 1 - teleporter.animTimer.time / teleporter.animTimer.timeMax)

        trackVolume = (teleporter.animTimer.time / teleporter.animTimer.timeMax) ^ 2

        shine(teleporter.x, teleporter.y - 50, 400 * ((clamp((1 - teleporter.animTimer.time / teleporter.animTimer.timeMax) * 3, 0, 1)) + math.sin(globalTimer) * 0.1), {0, 149, 233})
    end

    if teleporter.animTimer:isDone() then -- Animation done

        zoomInEffect = 1
        UI_ALPHA = 255

        player.bonusForce = newVec(0, 0)
        player.vel = newVec(0, 0)
        player.collider.x = 300; player.collider.y = 540

        roomOn = 1

        local biome = fetchNextBiome()
        biome = BIOMES[biome]

        if isBossFloor then -- GENERATE BOSS ROOM

            local bossRoom = {processItems=roomProcessItems,items={}, processEnemyBodies=roomProcessEnemyBodies, enemyBodies = {}, items = {}, cleared=false,enemies = {}, process=processRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, processParticles=roomParticles, particleSystems={}}

            -- Ambient particles
            bossRoom.ambientParticles = newParticleSystem(0, 0, loadJson(biome.ambientParticles))
    
            bossRoom.particleOffset = biome.particleOffset or newVec(0, 0)
    
            bossRoom.playerTookHits = 0
    
            bossRoom.structures = {newTeleporter(560, 580, false)}

            -- Layout

            local levelPreset = loadJson("data/layouts/bossRoom.json")
            bossRoom.tilemap = newTilemap(loadSpritesheet(biome.tilesetPath, 16, 16), 48, levelPreset.tiles)
    
            -- Place structures from the preset
    
            for _, S in ipairs(levelPreset.structures) do
    
                table.insert(bossRoom.structures, IN_ROOM_STRUCTURES[S[1]](S[2], S[3], S))
    
            end

            local first = true -- Place edges
            for id,T in pairs(bossRoom.tilemap.tiles) do
    
                -- Get pos and is tile collidable
                local pos = splitString(id,",")
                local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])
                
                if first then first = false -- Set the start value if its the first
    
                    bossRoom.endLeft = tileX; bossRoom.endRight = tileX
                    bossRoom.endUp = tileY; bossRoom.endDown = tileY
    
                else -- Look for a record
    
                    if bossRoom.endUp > tileY then bossRoom.endUp = tileY end
    
                    if bossRoom.endDown < tileY then bossRoom.endDown = tileY end
    
                    if bossRoom.endLeft > tileX then bossRoom.endLeft = tileX end
    
                    if bossRoom.endRight < tileX then bossRoom.endRight = tileX end
                end
    
            end

            -- Set bg
            bossRoom.bgTilemap = newTilemap(loadSpritesheet(biome.bgTilesetPath, 16, 16), 48)
            for x=bossRoom.endLeft,bossRoom.endRight do for y=bossRoom.endUp,bossRoom.endDown do

                if
                bossRoom.tilemap:getTile(x + 1, y) == nil or
                    bossRoom.tilemap:getTile(x - 1, y) == nil or
                    bossRoom.tilemap:getTile(x, y + 1) == nil or
                    bossRoom.tilemap:getTile(x, y - 1) == nil
                then

                    bossRoom.bgTilemap:setTile(x,y,{1,love.math.random(1,3)})

                end

            end end -- Place tiles

            -- Get the edges actual position and width

            bossRoom.endHeight = (bossRoom.endUp - bossRoom.endDown) * 48
            bossRoom.endWidth = (bossRoom.endLeft - bossRoom.endRight) * 48


            bossRoom.endLeft = newVec(bossRoom.endLeft * 48 - 48, bossRoom.endHeight * 0.5)

            bossRoom.endRight = newVec(bossRoom.endRight * 48 + 96, bossRoom.endHeight * 0.5)

            bossRoom.endUp = newVec(bossRoom.endWidth * 0.5, bossRoom.endUp * 48 - 48)

            bossRoom.endDown = newVec(bossRoom.endWidth * 0.5, bossRoom.endDown * 48 + 96)

            bossRoom.tilemap:buildColliders()
            bossRoom.tilemap:buildIndexes()
            bossRoom.bgTilemap:buildIndexes()

            bossRoom.boss = bosses[1]
            table.remove(bosses, 1)

            -- Place decoration
            decorateRoom(bossRoom, biome)

            ROOMS = {bossRoom} -- Construct a new room sequence that includes just the boss room

            timeUntillQuake = -1000

        else -- GENERATE NORMAL ROOM SEQUENCE

            ROOMS = generate(5,fetchNextBiome())

        end

        ROOM = ROOMS[roomOn]
    
        playerProjectiles = {}; enemyProjectiles = {}
        
        floorOn = floorOn + 1

        playTrack("cave", -1)

        trackVolume = 1
        trackPitch = 0.8

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