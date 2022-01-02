
BIOMES = {

cave = {
tilesetPath = "data/images/tilesets/cave/tileset.png",
bgTilesetPath = "data/images/tilesets/cave/bg.png",

decorations = nil,

layoutPath = "data/layouts/cave/", nLayouts = 1
}

}

EDGE_IMAGE = love.graphics.newImage("data/images/roomEdge.png")

PARTICLES_ENEMY_DIE = loadJson("data/particles/enemyDie.json")
PARTICLES_ENEMY_DIE_BLAST = loadJson("data/particles/enemyDieBlast.json")

function generate(amount,biome)
    local rooms = {}
    local biome = BIOMES[biome]

    for num=0,amount - 1 do

        local room = {items = {}, cleared=false,enemies = {buildEnemy("slime",168 * SPRSCL,50 * SPRSCL)}, process=processRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, processParticles=roomParticles, particleSystems={}}

        -- Set bg
        room.bgTilemap = newTilemap(loadSpritesheet(biome.bgTilesetPath, 16, 16), 48)
        for x=-1,16 do for y=-1,13 do room.bgTilemap:setTile(x,y,{1,love.math.random(1,3)}) end end -- Place tiles

        -- Set tilemap
        local layout = nil
        if num == 0 then
            layout = "data/layouts/start.json"
        else if num == amount - 1 then

                layout = "data/layouts/end.json"

            else
                layout = biome.layoutPath..tostring(love.math.random(1,biome.nLayouts + 1))..".json"
        end end

        room.tilemap = newTilemap(loadSpritesheet(biome.tilesetPath, 16, 16), 48, loadJson(layout))
        
        -- Find the entrance and the exit
        local entrancePos = nil;  local exitPos = nil
        for id,T in pairs(room.tilemap.tiles) do
            
            -- Is tile entrance
            if T[1] == 5 and T[2] == 5 then
                local pos = splitString(id,",")
                local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])

                entrancePos = newVec(tileX * 48 + 24,tileY * 48 + 24)

                room.tilemap.tiles[id] = nil
            end

            -- Is tile exit
            if T[1] == 6 and T[2] == 5 then
                local pos = splitString(id,",")
                local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])

                exitPos = newVec(tileX * 48 + 24,tileY * 48 + 24)

                room.tilemap.tiles[id] = nil
            end
        end

        room.tilemap:buildColliders()

        -- Set entrance and exit particles
        if entrancePos ~= nil then room.entranceParticles = newParticleSystem(entrancePos.x,entrancePos.y,loadJson("data/particles/doorParticles.json"))

            local rectEntrance = newRect(entrancePos.x - 24,entrancePos.y,48,144)
            table.insert(room.tilemap.colliders, rectEntrance)
            table.insert(room.tilemap.collidersWithFalltrough, rectEntrance)

        end

        if exitPos ~= nil then room.exitParticles = newParticleSystem(exitPos.x,exitPos.y,loadJson("data/particles/doorParticles.json")); room.exitParticles.rotation = 180
        
            local rectExit = newRect(exitPos.x + 24,exitPos.y,48,144)
            table.insert(room.tilemap.colliders, rectExit)
            table.insert(room.tilemap.collidersWithFalltrough, rectExit)

        end

        rooms[num + 1] = room
    end

    return rooms
end

-- Drawing
function roomDrawBg(room) setColor(255,255,255); room.bgTilemap:draw() end

function roomDrawTiles(room) setColor(255,255,255); room.tilemap:draw() end

function roomDrawEdge(room)
    
    -- Edge
    setColor(255,255,255); drawSprite(EDGE_IMAGE,168 * SPRSCL - 102,104 * SPRSCL)

    -- Door particles
    if room.entranceParticles ~= nil then room.entranceParticles:process(); room.entranceParticles.spawning = #room.enemies ~= 0 end
    if room.exitParticles ~= nil then room.exitParticles:process(); room.exitParticles.spawning = #room.enemies ~= 0  end
end

-- Particles
function roomParticles(room)

    local kill = {}
    for id,P in ipairs(room.particleSystems) do
        P:process()

        if #P.particles == 0 and P.ticks == 0 and P.timer < 0 then table.insert(kill,id)end

    end room.particleSystems = wipeKill(kill,room.particleSystems)

end

-- Enemies
function roomProcessEnemies(room)

    kill = {}
    for id,E in ipairs(room.enemies) do
        E:process(player)

        if E.hp < 1 then table.insert(kill,id); table.insert(room.particleSystems,newParticleSystem(E.collider.x, E.collider.y, deepcopyTable(PARTICLES_ENEMY_DIE)))
        
            local particlesAdding = deepcopyTable(PARTICLES_ENEMY_DIE_BLAST)
            particlesAdding.rotation = E.knockback:getRot()

            table.insert(room.particleSystems, newParticleSystem(E.collider.x, E.collider.y, particlesAdding))
        end
        
    end room.enemies = wipeKill(kill,room.enemies)

end

-- Processing
function processRoom(room)

    -- Check if cleared
    if not room.cleared and #room.enemies == 0 then
        room.cleared = true

        room.tilemap:buildColliders()
    end

    -- Check if player entered door
    if room.entranceParticles ~= nil then
        if player.collider.x < room.entranceParticles.x - 3 then swtichRoom(-1) end
    end
    if room.exitParticles ~= nil then
        if player.collider.x > room.exitParticles.x + 3 then swtichRoom(1) end
    end

end