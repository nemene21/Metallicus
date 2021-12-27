
function gameReload()
    particleSystems = {}
    
    player = newPlayer(400,300,{})
    open = false

    TILEMAP = newTilemap(loadSpritesheet("data/images/tilesets/caveTiles.png",16,16),48,loadJson("data/layouts/cave/1.json"))
    TILEMAP:buildColliders()

    BACKGROUND = newTilemap(loadSpritesheet("data/images/tilesets/bg.png",16,16),48)
    for x=-1,16 do for y=-1,13 do BACKGROUND:setTile(x,y,{1,love.math.random(1,3)}) end end

    EDGE_IMAGE = love.graphics.newImage("data/images/roomEdge.png")

    postPro = "GLOW_AND_LIGHT"

end

function gameDie()
end

function game()
    -- Reset
    sceneAt = "game"
    
    setColor(255, 255, 255)
    clear(24, 20, 37)

    BACKGROUND:draw()
    TILEMAP:draw()

    -- Particles
    local kill = {}
    for id,P in ipairs(particleSystems) do
        P:process()

        if #P.particles == 0 and P.ticks == 0 and P.timer < 0 then table.insert(kill,id)end

    end particleSystems = wipeKill(kill,particleSystems)

    -- Player
    player:process()

    love.window.setTitle(tostring(love.timer.getFPS()))

    setColor(255,255,255)
    drawSprite(EDGE_IMAGE,412,320)

    shine(player.collider.x,player.collider.y,300 + math.sin(globalTimer * 3) * 30,{255,200,100})

    -- Return scene
    return sceneAt
end