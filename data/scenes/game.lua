
function gameReload()
    particleSystems = {}
    
    player = newPlayer(400,300,{})
    open = false

    TILEMAP = newTilemap(loadSpritesheet("data/images/tilesets/caveTiles.png",16,16),48,{})
    for i=0,20 do
        TILEMAP:setTile(i,8,{2,1})
    end
    for x=0,20 do
        for y=0,8 do
            TILEMAP:setTile(x,y + 9,{2,2})
        end
    end
    TILEMAP:buildColliders()

    postPro = {"GLOW"}

end

function gameDie()
end

function game()
    -- Reset
    sceneAt = "game"
    
    setColor(255, 255, 255)
    clear(100, 100, 100)

    TILEMAP:draw()

    -- Particles
    kill = {}
    for id,P in pairs(particleSystems) do
        P:process()

        if #P.particles < 1 and P.ticks == 0 then table.insert(kill,id) end

    end particleSystems = wipeKill(kill,particleSystems)
    print(#particleSystems)

    -- Player
    player:process()

    love.window.setTitle(tostring(love.timer.getFPS()))

    -- Return scene
    return sceneAt
end