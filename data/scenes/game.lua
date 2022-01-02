
function gameReload()
    particleSystems = {}
    
    player = newPlayer(400,300,{})
    roomOn = 1

    postPro = "GLOW_AND_LIGHT"

    ROOMS = generate(8,"cave")
    ROOM = ROOMS[roomOn]

    playerProjectiles = {}; enemyProjectiles = {}
    IMG = love.graphics.newImage("data/images/enemies/slime/slime.png")
end

function gameDie()
end

function game()
    -- Reset
    sceneAt = "game"
    
    setColor(255, 255, 255)
    clear(24, 20, 37)

    -- Loop
    ROOM:drawBg()

    player:process()

    ROOM:processEnemies()

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