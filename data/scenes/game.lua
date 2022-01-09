
function gameReload()
    
    player = newPlayer(400,300,{})
    roomOn = 1

    postPro = "GLOW_AND_LIGHT"

    ROOMS = generate(8,"cave")
    ROOM = ROOMS[roomOn]

    playerProjectiles = {}; enemyProjectiles = {}

    paused = false

    PAUSED_SCREEN_BG = love.graphics.newCanvas(WS[1], WS[2])
    
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
        ROOM:drawBg()

        player:process()

        ROOM:processItems()

        ROOM:processEnemies()

        ROOM:processEnemyBodies()
        ROOM:processParticles()

        player:draw()
        player:drawUI()

        ROOM:process()

        ROOM:drawTiles()

        -- Projectiles

        processPlayerProjectiles(playerProjectiles)
        processEnemyProjectiles(enemyProjectiles)

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

        waveText(400, 300, 6, "Game Paused", {255,255,255}, 3, 3, 1, 1, 4, 5)

        if justPressed("escape") then paused = false end

    end

    love.window.setTitle(tostring(love.timer.getFPS()))

    -- Return scene
    return sceneAt
end

function swtichRoom(num)
    transition = 1

    roomOn = roomOn + num
    ROOM = ROOMS[roomOn]

    if num > 0 then
        player.collider.x = ROOM.entranceParticles.x + 16; player.collider.y = ROOM.entranceParticles.y + 48
    else
        player.collider.x = ROOM.exitParticles.x - 16; player.collider.y = ROOM.exitParticles.y + 48
    end

    camera[1] = player.collider.x - 400; camera[2] = player.collider.y - 300

    playerProjectiles = {}; enemyProjectiles = {}

end