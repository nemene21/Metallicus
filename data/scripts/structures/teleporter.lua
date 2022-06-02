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

        shine(teleporter.x, teleporter.y - 50, 400 * ((clamp((1 - teleporter.animTimer.time / teleporter.animTimer.timeMax) * 3, 0, 1)) + math.sin(globalTimer) * 0.1), {0, 149, 233})
    end

    if teleporter.animTimer:isDone() then -- Animation done

        zoomInEffect = 1
        UI_ALPHA = 255

        player.bonusForce = newVec(0, 0)
        player.vel = newVec(0, 0)
        player.collider.x = 300; player.collider.y = 540

        roomOn = 1

        ROOMS = generate(5,fetchNextBiome())
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