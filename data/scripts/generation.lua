
BIOMES = {

cave = {
tilesetPath = "data/images/tilesets/cave/tileset.png",
bgTilesetPath = "data/images/tilesets/cave/bg.png",

decorations = nil,

layoutPath = "data/layouts/cave/", nLayouts = 1,

ambientParticles = "data/particles/ambient/waterDrops.json",
particlesPosition = {396, -100}
}

}

EDGE_IMAGE = love.graphics.newImage("data/images/roomEdge.png")

PARTICLES_ENEMY_DIE = loadJson("data/particles/enemies/enemyDie.json")
PARTICLES_ENEMY_DIE_BLAST = loadJson("data/particles/enemies/enemyDieBlast.json")

PARTICLES_BODY = loadJson("data/particles/enemies/bodyTravel.json")

function generate(amount,biome)
    local rooms = {}
    local biome = BIOMES[biome]

    for num=0,amount - 1 do

        local room = {textPopUps = newParticleSystem(0, 0, loadJson("data/particles/textParticles.json")),processItems=roomProcessItems,items={}, processEnemyBodies=roomProcessEnemyBodies, enemyBodies = {}, items = {}, cleared=false,enemies = {buildEnemy("slime",168 * SPRSCL,50 * SPRSCL)}, process=processRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, processParticles=roomParticles, particleSystems={}}

        -- Ambient particles
        room.ambientParticles = newParticleSystem(biome.particlesPosition[1], biome.particlesPosition[2], loadJson(biome.ambientParticles))

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

function roomDrawTiles(room) setColor(255,255,255); room.tilemap:draw(); room.textPopUps:process() end

function roomDrawEdge(room)
    
    -- Edge
    setColor(255,255,255); drawSprite(EDGE_IMAGE,168 * SPRSCL - 102,104 * SPRSCL)

    -- Door particles
    if room.entranceParticles ~= nil then room.entranceParticles:process(); room.entranceParticles.spawning = #room.enemies ~= 0 end
    if room.exitParticles ~= nil then room.exitParticles:process(); room.exitParticles.spawning = #room.enemies ~= 0  end

    -- Ambient particles
    room.ambientParticles:process()
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

        if E.hp < 1 then table.insert(kill,id)

            shake(12 * E.knockBackResistance, 2, 0.1)
        
            local particlesAdding = deepcopyTable(PARTICLES_ENEMY_DIE_BLAST)
            particlesAdding.rotation = E.knockback:getRot()

            for id,I in pairs(E.drops) do

                local amount = 0
                local percentage = I

                while percentage > 100 do

                    percentage = percentage - 100; amount = amount + 1

                end

                if love.math.random(1, 100) < percentage then amount = amount + 1 end

                local item = ITEMS[id]; item.amount = amount

                table.insert(room.items, newItem(E.collider.x + love.math.random(-24, 24), E.collider.y + love.math.random(-24, 0), item))

            end

            table.insert(room.particleSystems, newParticleSystem(E.collider.x, E.collider.y, particlesAdding))

            table.insert(room.enemyBodies, {image=E.image, collider=E.collider, vel=newVec(E.knockback.x * 2, E.knockback.y * 2), hp=1, particles=newParticleSystem(E.collider.x, E.collider.y, deepcopyTable(PARTICLES_BODY))})
        end
        
    end room.enemies = wipeKill(kill,room.enemies)

end

function roomProcessEnemyBodies(room)

    kill = {}

    SHADERS.FLASH:send("intensity", 1); love.graphics.setShader(SHADERS.FLASH)
    for id,E in ipairs(room.enemyBodies) do

        E.collider = moveRect(E.collider, E.vel, room.tilemap.collidersWithFalltrough)

        E.particles.x = E.collider.x; E.particles.y = E.collider.y
        E.particles:process()

        E.vel.x = lerp(E.vel.x, 0, dt * 0.1)
        E.vel.y = math.min(E.vel.y + dt * 1200, 800)

        if E.collider.touching.x ~= 0 then E.collider.x = E.collider.x - E.vel.x * dt; E.vel.x = E.vel.x * -1; E.hp = E.hp - 1 end
        if E.collider.touching.y ~= 0 then E.collider.y = E.collider.y - E.vel.y * dt; E.vel.y = E.vel.y * -0.8; E.hp = E.hp - 1 end

        drawSprite(ENEMY_IMAGES[E.image], E.collider.x, E.collider.y, 1, 1, E.vel:getLen() * 0.001 * (boolToInt(E.vel.x > 0) * 2 - 1))

        if E.hp <= 0 then
            
            table.insert(kill, id)
            table.insert(room.particleSystems,newParticleSystem(E.collider.x, E.collider.y, deepcopyTable(PARTICLES_ENEMY_DIE)))

            local particlesAdding = deepcopyTable(PARTICLES_ENEMY_DIE_BLAST)
            local velocity = newVec(E.vel.x * (boolToInt(E.collider.touching.x ~= 0) * 2 - 1), E.vel.y * (boolToInt(E.collider.touching.x ~= 0) * 2 - 1))
            particlesAdding.rotation = velocity:getRot() + 180

            table.insert(room.particleSystems, newParticleSystem(E.collider.x, E.collider.y, particlesAdding))

            shake(6, 2, 0.05)

        end

    end room.enemyBodies = wipeKill(kill, room.enemyBodies)
    love.graphics.setShader()

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

function roomProcessItems(room)

    kill = {}
    for id,I in ipairs(room.items) do

        I:process(room)
        I:draw()

        if rectCollidingCircle(player.collider, I.pos.x, I.pos.y, 8) then 
            
            local startAmount = I.data.amount
            I.data = player.hotbar:addItem(I.data)

            if I.data.amount ~= 0 then I.data = player.inventory:addItem(I.data) end

            if I.data.amount ~= startAmount then
                playSound("pickup", love.math.random(60,140) * 0.01, 3)

                local text = tostring(I.data.name)
                local difference = startAmount - I.data.amount
                if difference ~= 1 then text = text .. " x" .. tostring(difference) end

                table.insert(room.textPopUps.particles,{
                    x = I.pos.x + love.math.random(-24, 24), y = I.pos.y + love.math.random(-24, 24),
                    vel = newVec(0, -100), width = text,
                    lifetime = 1, lifetimeStart = 1,
                    color = {r=RARITY_COLORS[I.data.rarity][1],g=RARITY_COLORS[I.data.rarity][2],b=RARITY_COLORS[I.data.rarity][3],a=1},
                    rotation = 0
                })
            end

            if I.data.amount == 0 then table.insert(kill, id) end

        end

    end room.items = wipeKill(kill, room.items)

end