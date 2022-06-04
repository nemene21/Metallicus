
function gameReload()

    resetBiomes()
    
    player = newPlayer(300,540,{})

    roomOn = 1

    postPro = "GLOW_AND_LIGHT"

    timeUntillWarning = 0
    quakeWarnings = 3
    quakeProjectileTimer = 0

    ROOMS = generate(5,fetchNextBiome())
    ROOM = ROOMS[roomOn]

    playerProjectiles = {}; enemyProjectiles = {}

    paused = false

    PAUSED_SCREEN_BG = love.graphics.newCanvas(WS[1], WS[2])

    debugLine = ""
    debugLineOpen = false

    debugDeleteTimer = newTimer(0.1)

    diedTimer = newTimer(4)
    
    playerDied = false; UI_ALPHA = 255

    mouseRot = 0; mouseScale = 1

    trackVolume = 0
    
    occlusion = boolToInt(not challanges.lightsOff.active)

    playTrack("cave")
    shake(6, 5, 0.15)

    floorOn = 1

    ENEMY_HP_SCALE = 1
end

function gameDie()
end

function game()
    -- Reset
    sceneAt = "game"
    
    setColor(255, 255, 255)
    clear(24, 20, 37)

    -- Loop
    if not paused then

        -- Set mouse

        if player.inventoryOpen then

            if JOYSTICKS[1] ~= nil then
                player.lastInventoryJoystickMousePos.x = lerp(player.lastInventoryJoystickMousePos.x, player.lastInventoryJoystickMousePosLerp.x, dt * 10)
                player.lastInventoryJoystickMousePos.y = lerp(player.lastInventoryJoystickMousePos.y, player.lastInventoryJoystickMousePosLerp.y, dt * 10)
    
                if joystickJustPressed(1, 12) then player.lastInventoryJoystickMousePosLerp.y = player.lastInventoryJoystickMousePosLerp.y - INVENTORY_SPACING end
                if joystickJustPressed(1, 13) then player.lastInventoryJoystickMousePosLerp.y = player.lastInventoryJoystickMousePosLerp.y + INVENTORY_SPACING end
                if joystickJustPressed(1, 14) then player.lastInventoryJoystickMousePosLerp.x = player.lastInventoryJoystickMousePosLerp.x - INVENTORY_SPACING end
                if joystickJustPressed(1, 15) then player.lastInventoryJoystickMousePosLerp.x = player.lastInventoryJoystickMousePosLerp.x + INVENTORY_SPACING end
    
                if JOYSTICKS[1] ~= nil then
    
                    xM = player.lastInventoryJoystickMousePos.x; yM = player.lastInventoryJoystickMousePos.y
    
                end
            end

        end

        player:setStats()

        ROOM:drawBg()

        if player.hp > 0 then
            player:process()
            trackVolume = lerp(trackVolume, 1, dt * 5)

        else -- Death animation

            trackVolume = lerp(trackVolume, 0, dt * 5)

            bindCamera(camera[1] + 400, camera[2] + 300, 3) -- Camera to the middle
            player.collider.y = player.collider.y - dt * 80

            diedTimer:process()

            transition = 1 - (diedTimer.time / diedTimer.timeMax)

            local intensity = clamp(diedTimer.timeMax - diedTimer.time, 0, 1)

            SHADERS.GLOW_AND_LIGHT:send("grayscale", intensity)
            zoomInEffect = lerp(zoomInEffect, 1.2, dt * 2)

            UI_ALPHA = lerp(UI_ALPHA, 0, dt * 10)

            if not playerDied then -- Just died

                playerDied = true

                timeMult = 0.5

                table.insert(ROOM.particleSystems, newParticleSystem(player.collider.x, player.collider.y, deepcopyTable(PARTICLES_DIE_SPARK)))
                table.insert(ROOM.particleSystems, newParticleSystem(player.collider.x, player.collider.y, deepcopyTable(PARTICLES_DIE_CIRCLE)))

            end

            if diedTimer:isDone() then -- Death animation is done
                
                trackVolume = 0
                trackPitch = 0.8

                SOUNDS_PLAYING = {}

                timeMult = 1
                sceneAt = "menu"
                SHADERS.GLOW_AND_LIGHT:send("grayscale", 0)

            end

        end
        
        ROOM:processItems()

        ROOM:processEnemies()

        ROOM:process()

        processPlayerProjectiles(playerProjectiles)
        processEnemyProjectiles(enemyProjectiles)
        
        -- Projectiles

        ROOM:processParticles()

        attackMouseLine = nil
        if player.hp > 0 then -- Draw player
            player:draw()
        end

        player:resetStats()
        
        love.graphics.setCanvas(UI_LAYER)
        processTextParticles()
        player:drawUI()
        love.graphics.setCanvas(display)

        for id,P in ipairs(playerProjectiles) do P:draw() end

        ROOM:drawTiles()

        for id,P in ipairs(enemyProjectiles) do P:draw() end

        -- Earthquake
        timeUntillQuake = timeUntillQuake - dt
        if timeUntillQuake < 0 and quakeWarnings ~= 0 then
            
            timeUntillQuake = (18 * #ROOMS) * 0.33
            quakeWarnings = quakeWarnings - 1

            if quakeWarnings ~= 0 then
                local say = {"The ground is shaking D:", "Shiver me timbers!", "Oww thats a big shake :/"}
                player:say(say[love.math.random(1, #say)], 4)

                shake(10, 12, 0.15, 4)
            else

                local say = {"This time it is for real!", "The cave is going to collapse :(", "AAAAaaaaAAAAaaaa!!!"}
                player:say(say[love.math.random(1, #say)], 4)

            end
        end

        if quakeWarnings == 0 then

            shake(3 - 2 * boolToInt(ROOM.stopQuake), 2, 0.02, 4)

            quakeProjectileTimer = quakeProjectileTimer - dt

            if quakeProjectileTimer < 0 and not ROOM.stopQuake then

                quakeProjectileTimer = 0.25

                if love.math.random(1,2) == 2 then
                    
                    table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(love.math.random(ROOM.endLeft.x, ROOM.endRight.x), ROOM.endUp.y + 10), 200, -90, 24, 10, {255,200,200}))
                
                else

                    table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(love.math.random(ROOM.endLeft.x, ROOM.endRight.x), ROOM.endUp.y + 10), 200, -90, 18, 10, {255,200,200}))

                end
            end

        end

        -- Draw dead player
        if player.hp <= 0 then

            setColor(255, 255, 255)
            love.graphics.setCanvas(particleCanvas)
            drawSprite(PLAYER_DEAD, player.collider.x, player.collider.y, math.sin(globalTimer * 5), 1)
            love.graphics.setCanvas(display)
        end

        ROOM:drawEdge()

        setColor(255, 255, 255)

        if justPressed("escape") then

            love.graphics.setCanvas(PAUSED_SCREEN_BG)
            love.graphics.setShader(SHADERS.BLUR)
            love.graphics.draw(postProCanvas)
            love.graphics.setShader()
            love.graphics.setCanvas(display)
            
            paused = true

            mouseMode = "pointer"; mCentered = 0

        end
    else
        setColor(255, 255, 255)
        love.graphics.draw(PAUSED_SCREEN_BG, 0, 0)

        love.graphics.setCanvas(UI_LAYER)
        waveText(400, 300, 6, "Game Paused", {255,255,255}, 3, 3, 1, 1, 4, 5)

        if justPressed("escape") then paused = false end

        love.graphics.setCanvas(display)

    end

    -- Debug line

    if justPressed("l") and pressed("lalt") then debugLineOpen = not debugLineOpen end

    if debugLineOpen then
        love.graphics.setCanvas(UI_LAYER)
        
        debugDeleteTimer:process()

        debugLine = debugLine..textInputed
        outlinedText(12, 568, 2, ">> "..debugLine, {255, 255, 255}, 1, 1)

        if pressed("backspace") and debugDeleteTimer:isDone() then debugLine = debugLine:sub(1, -2); debugDeleteTimer:reset() end

        if justPressed("return") then handleCommand(debugLine); debugLine = "" end
        
        love.graphics.setCanvas(display)

    end

    -- Mouse
    love.graphics.setCanvas(UI_LAYER)
    love.graphics.setColor(1,1,1)

    mouseScale = lerp(mouseScale, 1, dt * 12)
    mouseRot = lerp(mouseRot, 0, dt * 12)

    love.graphics.draw(mouse[mouseMode], xM, yM, mouseRot, SPRSCL * mouseScale, SPRSCL * mouseScale, mouse[mouseMode]:getWidth() * mCentered, mouse[mouseMode]:getHeight() * mCentered)
    
    --print(attackMouseLine)
    if attackMouseLine ~= nil and not player.inventoryOpen then

        love.graphics.setLineWidth(5)

        attackMouseLine = clamp(attackMouseLine, 0, 1)

        setColor(100, 100, 100, 160)
        love.graphics.line(xM - 12, yM + 24, xM + 12, yM + 24)

        love.graphics.setLineWidth(4)
        setColor(255, 255, 255)
        love.graphics.line(xM - 12, yM + 24, xM - 12 + 24 * attackMouseLine, yM + 24)

    end
    
    
    love.graphics.setCanvas(display)

    processInteract()

    if showStats then SHOW_STATS() end

    -- Return scene
    return sceneAt
end

function swtichRoom(num)
    transition = 1

    ambientLight = BIOMES[biomeOn].ambientLight

    roomOn = roomOn + num
    ROOM = ROOMS[roomOn]

    if num > 0 then
        player.collider.x = ROOM.entranceParticles.x + 32; player.collider.y = ROOM.entranceParticles.y + 48
    else if num < 0 then
        player.collider.x = ROOM.exitParticles.x - 32; player.collider.y = ROOM.exitParticles.y + 48
    end end

    camera[1] = player.collider.x; camera[2] = player.collider.y - 300

    for id, S in ipairs(ROOM.structures) do

        if S.onEnter ~= nil then S:onEnter() end

    end

    playerProjectiles = {}; enemyProjectiles = {}
    ALL_TEXT_PARTICLES = {}

end