
require "data.scripts.structures"

DECORATION_IMAGES = {}

BIOME_ORDER = {}

biomeOn = ""

occlusion = 1

LAST_ENEMY_DIE_PARTICLES = loadJson("data/particles/enemies/lastEnemyDie.json")

isBossFloor = false
assumedIsBossFloor = false

bosses = {newSkeletonBoss()}

function fetchNextBiome(degrade)
    local degrade = degrade or true

    if degrade then isBossFloor = assumedIsBossFloor end

    assumedIsBossFloor = false

    for id, B in ipairs(BIOME_ORDER) do

        if BIOME_ORDER[id][2] ~= 0 then

            if degrade and not isBossFloor then
                
                BIOME_ORDER[id][2] = BIOME_ORDER[id][2] - 1
                
                if BIOME_ORDER[id][2] == 0 then assumedIsBossFloor = true end
            
            end

            biomeOn = BIOME_ORDER[id][1]
            return BIOME_ORDER[id][1]

        end

    end

end

function resetBiomes()

    bosses = {newSkeletonBoss()}

    BIOME_ORDER = {
        {"cave", 3},
        {"sporeCavern", -1}
    }

    firstRoomEver = true
end

resetBiomes()

function newDecoration(name, images, offset, spawnCondition, distance, frequency, centering, wind, windSpeed, particles, light, shader, setPos)

    -- LIGHT:
    --    1 = x offset
    --    2 = y offset
    --    3 = radius
    --    4 = sine intensity
    --    5 = sine speed
    --    6 = color

    -- PARTICLES
    --    1 = x offset
    --    2 = y offset
    --    3 = path to data

    DECORATION_IMAGES[name] = {}
    for id, S in ipairs(images) do

        local image = love.graphics.newImage("data/images/levelDecorations/" .. S)
        image:setWrap("repeat")
        
        table.insert(DECORATION_IMAGES[name], image)
    
    end
    if particles ~= nil then particles = {xO = particles[1], yO = particles[2], data = loadJson(particles[3])} end

    return {
        problematic = problematic, setPos = setPos, shader = shader, particles = particles, offset = offset, name = name, distance = distance, frequency = frequency, spawnCondition = spawnCondition, centering = centering, wind = wind, windSpeed = windSpeed, light = light
    }
end

BIOMES = {

cave = {
    tilesetPath = "data/images/tilesets/cave/tileset.png",
    bgTilesetPath = "data/images/tilesets/cave/bg.png",

    name = "Shallow Caves",

    track = "cave",

    materials = {rock = 100, wood = 100},

    decorations = {
    background = {

        newDecoration("torch", {"cave/torch.png"}, {0,0}, {{0, 0, false}, {0, 1, false}, {0, 2, true}}, 6, 20, {0.5, 0.5}, 0, 0, {0, -10, "data/particles/decorations/torch.json"}, {0, -24, 180, 0.12, 2.4, {230,180,80,40}}),
        newDecoration("stalagmite", {"cave/stalagmite1.png", "cave/stalagmite2.png"}, {0,-24}, {{0,0,false}, {0,-1,false},{0,1,true}}, 0, 40, {0.5, 0}, 0, 0),
        newDecoration("fireflies", {}, {0, 0}, {{0,0,false}, {0,1,false}, {1,0,false}, {0,-1,false}, {-1,0,false}}, 5, 12, {0, 0}, 0, 0, {0, 0, "data/particles/decorations/fireflies.json"}, {0, -24, 230, 0.12, 2.4, {255,170,50,30}})

    },

    foreground = {

        newDecoration("vine", {"cave/vine1.png","cave/vine2.png","cave/vine3.png"}, {0,0}, {{0, 0, true}, {0, 1, false}}, 2, 50, {0.5, 0}, 0.2, 0.5, nil, nil, "WAVE"),
        newDecoration("waterfall", {"cave/waterfall1.png", "cave/waterfall2.png"}, {0, 0}, {}, 10, 0.015, {0.5, 0}, 0, 0, nil, nil, "CAVE_WATERFALL", {nil, -300})

    }
    },

    ambientLight = {120, 120, 120},

    layoutPath = "data/layouts/cave/", nLayouts = 5,

    ambientParticles = "data/particles/ambient/waterDrops.json", particleOffset = newVec(0, - 350),

    enemies = {
    slime = {spawnOn = "ground", frequency = 100},
    skeletonMiner = {spawnOn = "ground", frequency = 75},
    giantFirefly = {spawnOn = "air", frequency = 75}
    },

    nEnemies = {a = 2, b = 3},

},
sporeCavern = {
    tilesetPath = "data/images/tilesets/sporeCavern/tileset.png",
    bgTilesetPath = "data/images/tilesets/cave/bg.png",
    
    materials = {shroomOre = 150, wood = 100},

    name = "Spore Caverns",

    track = "cave",

    ambientLight = {30, 80, 180},
    
    decorations = {
    background = {
        
        newDecoration("shroom", {"sporeCavern/shroom1.png", "sporeCavern/shroom2.png", "sporeCavern/shroom3.png"}, {0,27}, {{0,0,false}, {0,-1,false},{0,1,true}}, 2, 40, {0.5, 1}, 0.1, 0.8, none, {0, -24, 90, 0.12, 2.4, {100,100,255,40}}),
        newDecoration("shroomLantern", {"sporeCavern/shroomLantern.png"}, {0,0}, {{0, 0, false}, {0, 1, false}, {0, 2, true}}, 6, 20, {0.5, 0.5}, 0, 0, {-2, 12, "data/particles/decorations/shroomLantern.json"}, {0, 0, 180, 0.12, 2.4, {180,180,255,40}}),

    },
    
    foreground = {

        newDecoration("shroomVine", {"sporeCavern/shroomVine1.png","sporeCavern/shroomVine2.png","sporeCavern/shroomVine3.png"}, {0,9}, {{0, 0, true}, {0, 1, false}}, 2, 33, {0.5, 0}, 0.2, 0.5)

    }
    },
    
    layoutPath = "data/layouts/cave/", nLayouts = 5,
    
    ambientParticles = "data/particles/ambient/spores.json",
    
    enemies = {
    slime = {spawnOn = "ground", frequency = 100},
    battlefly = {spawnOn = "air", frequency = 80}
    },
    
    nEnemies = {a = 3, b = 5},
    
    }

}

PARTICLES_ENEMY_DIE = loadJson("data/particles/enemies/enemyDie.json")
PARTICLES_ENEMY_DIE_BLAST = loadJson("data/particles/enemies/enemyDieBlast.json")

PARTICLES_BODY = loadJson("data/particles/enemies/bodyTravel.json")

function generate(amount, biome)
    local rooms = {}
    local biome = BIOMES[biome]

    player.text = ""; player.lettersLoaded = ""; player.letterTimer = 0; player.speakTimer = 0; player.textFadeTimer = 0; player.textPriority = 0

    ambientLight = biome.ambientLight

    timeUntillQuake = (18 * amount) * 0.22
    quakeWarnings = 3

    for num=0,amount - 1 do

        local room = {processItems=roomProcessItems,items={}, processEnemyBodies=roomProcessEnemyBodies, enemyBodies = {}, items = {}, cleared=false,enemies = {}, process=processRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, processParticles=roomParticles, particleSystems={}}

        -- Ambient particles
        room.ambientParticles = newParticleSystem(0, 0, loadJson(biome.ambientParticles))

        room.particleOffset = biome.particleOffset or newVec(0, 0)

        room.playerTookHits = 0

        room.structures = {}

        -- Set tilemap
        local layout = nil
        if num == 0 then 
            layout = "data/layouts/start.json"

        else if num == amount - 1 then

                layout = "data/layouts/end.json"
                table.insert(room.structures, ENTERABLES.house(420, 579))

                table.insert(room.structures, newChest(220, 563))

            else
                layout = biome.layoutPath..tostring(love.math.random(1, biome.nLayouts))..".json"
        end end

        if firstRoomEver then

            firstRoomEver = false
            layout = "data/layouts/firstRoom.json"

            --room.boss = bosses[1]

            playSound("enter")

            player.collider.x = 276; player.collider.y = -360

            bindCamera(276, -360)
            camera = (boundCamPos)

        end

        if OPT.tutorial == true then

            OPT.tutorial = false

            table.insert(room.structures, newTextDisplayer(400, 250, "This is the first floor, finish it quickly"))
            table.insert(room.structures, newTextDisplayer(400, 350, "before the earthquake, you are now alone :)"))

        end

        local levelPreset = loadJson(layout)
        room.tilemap = newTilemap(loadSpritesheet(biome.tilesetPath, 16, 16), 48, levelPreset.tiles)

        -- Place structures from the preset
        for _, S in ipairs(levelPreset.structures) do

            table.insert(room.structures, IN_ROOM_STRUCTURES[S[1]](S[2], S[3], S))

        end

        
        local first = true
        for id,T in pairs(room.tilemap.tiles) do

            -- Get pos and is tile collidable
            local pos = splitString(id,",")
            local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])
            
            if first then first = false -- Set the start value if its the first

                room.endLeft = tileX; room.endRight = tileX
                room.endUp = tileY; room.endDown = tileY

            else -- Look for a record

                if room.endUp > tileY then room.endUp = tileY end

                if room.endDown < tileY then room.endDown = tileY end

                if room.endLeft > tileX then room.endLeft = tileX end

                if room.endRight < tileX then room.endRight = tileX end
            end

        end

        -- Place decoration
        decorateRoom(room, biome)

        -- Place enemies
        placeEnemies(biome, room, num, amount)

        -- Set bg
        room.bgTilemap = newTilemap(loadSpritesheet(biome.bgTilesetPath, 16, 16), 48)
        for x=room.endLeft,room.endRight do for y=room.endUp,room.endDown do

            if
                room.tilemap:getTile(x + 1, y) == nil or
                room.tilemap:getTile(x - 1, y) == nil or
                room.tilemap:getTile(x, y + 1) == nil or
                room.tilemap:getTile(x, y - 1) == nil
            then

                room.bgTilemap:setTile(x,y,{1,love.math.random(1,3)})

            end

        end end -- Place tiles

        -- Get the edges actual position and width

        room.endHeight = (room.endUp - room.endDown) * 48
        room.endWidth = (room.endLeft - room.endRight) * 48


        room.endLeft = newVec(room.endLeft * 48 - 48, room.endHeight * 0.5)

        room.endRight = newVec(room.endRight * 48 + 96, room.endHeight * 0.5)

        room.endUp = newVec(room.endWidth * 0.5, room.endUp * 48 - 48)

        room.endDown = newVec(room.endWidth * 0.5, room.endDown * 48 + 96)


        if num == 0 then
            table.insert(room.structures, newTeleporter(300, 580, true))
        else if num == amount - 1 then

        else
            placeMaterials(room, biome)
        end end
        
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
        room.tilemap:buildIndexes()
        room.bgTilemap:buildIndexes()

        -- Set entrance and exit particles
        if entrancePos ~= nil then room.entranceParticles = newParticleSystem(entrancePos.x - 48,entrancePos.y,loadJson("data/particles/doorParticles.json"))

            local rectEntrance = newRect(entrancePos.x - 72,entrancePos.y,48,144)
            table.insert(room.tilemap.colliders, rectEntrance)
            table.insert(room.tilemap.collidersWithFalltrough, rectEntrance)

        end

        if exitPos ~= nil then room.exitParticles = newParticleSystem(exitPos.x + 24,exitPos.y,loadJson("data/particles/doorParticles.json")); room.exitParticles.rotation = 180
        
            local rectExit = newRect(exitPos.x + 48,exitPos.y,48,144)
            table.insert(room.tilemap.colliders, rectExit)
            table.insert(room.tilemap.collidersWithFalltrough, rectExit)

        end

        rooms[num + 1] = room
    end

    return rooms
end

-- Place materials

function placeMaterials(room, biome)

    local maxFrequency = 0
    for id, S in pairs(biome.materials) do maxFrequency = maxFrequency + S end

    for x=0, love.math.random(0, 3) do

        local frequencyChosen = love.math.random(0, maxFrequency)

        local material = nil
        local frequencyAt = 0

        for id, S in pairs(biome.materials) do
            if frequencyChosen >= frequencyAt and frequencyChosen <= frequencyAt + S then material = id end

            frequencyAt = frequencyAt + S
        end

        local posX = 0; local posY = 0; valid = false

        while not valid do

            posX = love.math.random(4, 12)

            posY = love.math.random(0,10)

            valid = room.tilemap:getTile(posX, posY) == nil

            local validY = false
                
            while not validY do

                posY = posY + 1
                validY = room.tilemap:getTile(posX, posY) ~= nil

            end
            posY = posY - 2

        end
        table.insert(room.structures, MATERIAL_CONSTRUCTORS[material](posX * 48 + 24, posY * 48 + 100))

    end

end

-- Decorate biome

function decorateRoom(room, biome)

    room.decorations = {background = {}, foreground = {}}

    local positionsTaken = {}

    for id, B in ipairs(biome.decorations.background) do

        local tilesTaken = {}

        for posX = room.endLeft + 3, room.endRight - 3 do
        for posY = room.endUp + 3, room.endDown - 3 do

            local valid = true

            for id, P in ipairs(B.spawnCondition) do

                local tile = room.tilemap:getTile(posX + P[1], posY + P[2])

                local tileExists = tile ~= nil

                local tileIsDroptrough = false
                if tileExists then tileIsDroptrough = tile[1] > 3 and tile[2] > 5 end

                if (tileExists and (not tileIsDroptrough)) == not P[3] then valid = false end

            end

            if valid then

                local farEnough = true
                for id, P in ipairs(tilesTaken) do
                    if newVec(P[1] - posX, P[2] - posY):getLen() < B.distance then farEnough = false end
                end

                if farEnough and love.math.random(0, 100) < B.frequency then

                    local particles = nil
                    if B.particles ~= nil then particles = newParticleSystem(B.particles.xO + posX * 48 + 24 + B.offset[1], B.particles.yO + posY * 48 + 24 + B.offset[2], deepcopyTable(B.particles.data)) end

                    local decoration = {
                        shader = B.shader, particles = particles, light = B.light, x = posX * 48 + 24 + B.offset[1], y = posY * 48 + 24 + B.offset[2], name = B.name, textureId = love.math.random(1, #DECORATION_IMAGES[B.name]), centering = B.centering, windSpeed = B.windSpeed, wind = B.wind
                    }

                    if B.setPos ~= nil then

                        decoration.x = B.setPos[1] or decoration.x
                        decoration.y = B.setPos[2] or decoration.y

                    end

                    table.insert(room.decorations.background, decoration)

                    table.insert(tilesTaken, {posX, posY})

                end

            end

        end end

    end

    for id, F in ipairs(biome.decorations.foreground) do


        local tilesTaken = {}

        for posX = room.endLeft + 3, room.endRight - 3 do
        for posY = room.endUp + 3, room.endDown - 3 do

            local valid = true

            for id, P in ipairs(F.spawnCondition) do

                local tile = room.tilemap:getTile(posX + P[1], posY + P[2])

                local tileExists = tile ~= nil

                local tileIsDroptrough = false
                if tileExists then tileIsDroptrough = tile[1] > 3 and tile[2] > 5 end

                if (tileExists and (not tileIsDroptrough)) == not P[3] then valid = false end

            end

            if valid then

                local farEnough = true
                for id, P in ipairs(tilesTaken) do
                    if newVec(P[1] - posX, P[2] - posY):getLen() < F.distance then farEnough = false end
                end

                if farEnough and love.math.random(0, 100) < F.frequency then

                    local particles = nil
                    if F.particles ~= nil then particles = newParticleSystem(F.particles.xO + posX * 48 + 24 + F.offset[1], F.particles.yO + posY * 48 + 24 + F.offset[2], deepcopyTable(F.particles.data)) end
                    
                    local decoration = {
                        shader = F.shader, particles = particles, light = F.light, x = posX * 48 + 24 + F.offset[1], y = posY * 48 + 24 + F.offset[2], name = F.name, textureId = love.math.random(1, #DECORATION_IMAGES[F.name]), centering = F.centering, windSpeed = F.windSpeed, wind = F.wind
                    }

                    if F.setPos ~= nil then

                        decoration.x = F.setPos[1] or decoration.x
                        decoration.y = F.setPos[2] or decoration.y

                    end

                    table.insert(room.decorations.foreground, decoration)

                    table.insert(tilesTaken, {posX, posY})

                end

            end

        end end

    end

end

-- Place enemies
function placeEnemies(biome, room, num, amount)
    
    -- If its not at the start or the end
    if num ~= 0 and num ~= amount - 1 then

        -- Set the amount of enemies and the random enemy value
        local amount = love.math.random(biome.nEnemies.a, biome.nEnemies.b) - 1

        local maxFrequency = 0
        for id, E in pairs(biome.enemies) do maxFrequency = maxFrequency + E.frequency end

        -- For the number of enemies...
        for i = 0, amount do

            -- Choose enemy based on a random number (also his frequency)
            local frequencyAt = 0; local frequencyChosen = love.math.random(1, maxFrequency - 1)

            local enemyChosen = nil

            for id, E in pairs(biome.enemies) do frequencyAt = frequencyAt + E.frequency
                
                if frequencyChosen <= frequencyAt and frequencyChosen >= frequencyAt - E.frequency then enemyChosen = deepcopyTable(E); enemyChosen.name = id; break end

            end

            -- Get the enemy position
            local posX = 0; local posY = 0; valid = false

            while not valid do

                posX = love.math.random(4, room.endRight - 3)

                posY = love.math.random(room.endUp, room.endDown)

                valid = room.tilemap:getTile(posX, posY) == nil

                if valid and enemyChosen.spawnOn == "ground" then
                    local validY = false
                    
                    while not validY do

                        posY = posY + 1
                        validY = room.tilemap:getTile(posX, posY) ~= nil

                    end
                    posY = posY - 2
                        
                end

            end

            -- Spawn the enemy
            table.insert(room.enemies, buildEnemy(enemyChosen.name, posX * 48 + 24, posY * 48 + 24))
        end

    end
end






 
-----------------------------------------------PROCESSING

-- Drawing
function roomDrawBg(room)
    setColor(255,255,255); room.bgTilemap:draw()

    for id, B in ipairs(room.decorations.background) do
        setColor(255,255,255)

        love.graphics.setShader(SHADERS[B.shader])
        if #DECORATION_IMAGES[B.name] ~= 0 then drawSprite(DECORATION_IMAGES[B.name][B.textureId], B.x, B.y, 1, 1, math.sin(B.x + B.y + globalTimer * B.windSpeed) * B.wind, 1, B.centering[1], B.centering[2]) end
        love.graphics.setShader()

        if B.light ~= nil then shine(B.x + B.light[1], B.y + B.light[2], B.light[3] * math.sin(globalTimer * B.light[5]) * B.light[4] + B.light[3], B.light[6]); love.graphics.setCanvas(display) end
        if B.particles ~= nil then B.particles:process(); setColor(255, 255, 255) end

    end

    for id, S in ipairs(room.structures) do

        S:draw()

    end
end

function roomDrawTiles(room)
    
    setColor(255,255,255)
    
    room.tilemap:draw()

    -- drawColliders(room.tilemap.colliders)

    for id, F in ipairs(room.decorations.foreground) do
        
        setColor(255,255,255)
        love.graphics.setShader(SHADERS[F.shader])
        if #DECORATION_IMAGES[F.name] ~= 0 then drawSprite(DECORATION_IMAGES[F.name][F.textureId], F.x, F.y, 1, 1, math.sin(F.x + F.y + globalTimer * F.windSpeed) * F.wind, 1, F.centering[1], F.centering[2]) end
        love.graphics.setShader()

        if F.light ~= nil then shine(F.x + F.light.x, F.y + F.light.y, F.light[3] * math.sin(globalTimer * F.light[5]) * F.light[4] + F.light[3], F.light[6]) end

    end

    love.graphics.setCanvas(UI_LAYER)

    love.graphics.setCanvas(display)
end

EDGE_LEFT = love.graphics.newImage("data/images/roomEdge/left.png")
EDGE_RIGHT = love.graphics.newImage("data/images/roomEdge/right.png")
EDGE_UP = love.graphics.newImage("data/images/roomEdge/up.png")
EDGE_DOWN = love.graphics.newImage("data/images/roomEdge/down.png")

function roomDrawEdge(room)

    if room.boss ~= nil then room.boss:draw() end
    
    -- Door particles

    if room.entranceParticles ~= nil then room.entranceParticles:process(); room.entranceParticles.spawning = not room.cleared end
    if room.exitParticles ~= nil then room.exitParticles:process(); room.exitParticles.spawning = not room.cleared  end

    -- Ambient particles
    room.ambientParticles.x = camera[1] + 400 + room.particleOffset.x; room.ambientParticles.y = camera[2] + 300 + room.particleOffset.y

    room.ambientParticles:process()

    processParticleSystems()

    love.graphics.setShader(SHADERS.PIXEL_PERFECT)
    setColor(255, 255, 255)
    love.graphics.draw(particleCanvas)
    love.graphics.setShader()

    -- Edge

    drawSprite(EDGE_LEFT, room.endLeft.x, room.endLeft.y + 432 * 1.5, 1, room.endHeight + 432)
    drawSprite(EDGE_RIGHT, room.endRight.x, room.endRight.y + 432 * 1.5, 1, room.endHeight + 432)
    drawSprite(EDGE_DOWN, room.endDown.x + 432 * 2, room.endDown.y, room.endWidth + 432)
    drawSprite(EDGE_UP, room.endUp.x + 432 * 2, room.endUp.y, room.endWidth + 432)

    if ROOM.boss ~= nil then

        love.graphics.setCanvas(UI_LAYER)
        
        ROOM.boss:drawBar()

        love.graphics.setCanvas(display)
    
    end
end

-- Particles
function roomParticles(room)

    local kill = {}
    for id,P in ipairs(room.particleSystems) do
        P:process()

        if #P.particles == 0 and P.ticks == 0 and P.timer < 0 then table.insert(kill,id) end

    end room.particleSystems = wipeKill(kill,room.particleSystems)

    processParticleSystems()

    love.graphics.setShader(SHADERS.PIXEL_PERFECT)
    setColor(255, 255, 255)
    love.graphics.draw(particleCanvas)
    love.graphics.setShader()

    love.graphics.setCanvas(particleCanvas)
    clear(0,0,0,0)

end

-- Enemies
function roomProcessEnemies(room)

    kill = {}
    for id,E in ipairs(room.enemies) do
        E:process(player)

        if E.hp < 1 then table.insert(kill,id)

            shock(E.collider.x, E.collider.y, 0.14, 0.02, 0.4)

            shake(12 * E.knockBackResistance, 2, 0.1)
            if love.math.random(0, 100) > 75 then

                local say = {"That "..E.name.." stood no chance!", "Get rekt B)", "Destroyed >:D"}
                player:say(say[love.math.random(1, #say)])

            end
        
            local particlesAdding = deepcopyTable(PARTICLES_ENEMY_DIE_BLAST)
            particlesAdding.rotation = E.knockback:getRot()

            for id, I in ipairs(getLootTable(E.stringKey .. "Drop"):returnDrops()) do

                table.insert(room.items, newItem(E.collider.x + love.math.random(-16, 16), E.collider.y, I))

            end

            if #room.enemies - #kill == 0 then

                shake(20, 4, 0.1)
                shock(E.collider.x, E.collider.y, 0.8, 0.02, 0.3)

                table.insert(room.particleSystems, newParticleSystem(E.collider.x, E.collider.y, deepcopyTable(LAST_ENEMY_DIE_PARTICLES)))

                local say = {
                    {"That was easy!", "Sweeped >:D", "Wooosh!"},
                    {"Alright clear :I", "I got hit :(", "Ow, that hurt :("},
                    {"I should avoid bullets...", "I am in bad at dodging :(", "I should get better at the game!"}
                }

                if room.playerTookHits == 0 then

                    player:say(say[1][love.math.random(1, 3)])

                else if room.playerTookHits < 3 then

                    player:say(say[2][love.math.random(1, 3)])

                else

                    player:say(say[3][love.math.random(1, 3)])

                end end

            end

            table.insert(room.particleSystems, newParticleSystem(E.collider.x, E.collider.y, particlesAdding))

            if E.hasNoBodyOnDeath == nil then table.insert(room.enemyBodies, {image=E.image, collider=E.collider, vel=newVec(E.knockback.x * 2, E.knockback.y * 2), hp=1, particles=newParticleSystem(E.collider.x, E.collider.y, deepcopyTable(PARTICLES_BODY))}) end
        end
        
    end room.enemies = wipeKill(kill,room.enemies)

end

-- Bodies
function roomProcessEnemyBodies(room)
    love.graphics.setCanvas(particleCanvas)

    kill = {}

    SHADERS.FLASH:send("intensity", 1); love.graphics.setShader(SHADERS.FLASH)

    for id,E in ipairs(room.enemyBodies) do

        E.collider = moveRect(E.collider, E.vel, room.tilemap.collidersWithFalltrough)

        E.vel.x = lerp(E.vel.x, 0, dt * 0.1)
        E.vel.y = math.min(E.vel.y + dt * 1200, 800)

        if E.collider.touching.x ~= 0 then E.collider.x = E.collider.x - E.vel.x * dt; E.vel.x = E.vel.x * -1; E.hp = E.hp - 1 end
        if E.collider.touching.y ~= 0 then E.collider.y = E.collider.y - E.vel.y * dt; E.vel.y = E.vel.y * -0.8; E.hp = E.hp - 1 end

        drawSprite(ENEMY_IMAGES[E.image], E.collider.x, E.collider.y, 1, 1, E.vel:getLen() * 0.001 * (boolToInt(E.vel.x > 0) * 2 - 1))

        E.particles.x = E.collider.x; E.particles.y = E.collider.y
        E.particles:process()

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

    love.graphics.setCanvas(display)
end

-- Processing
function processRoom(room)

    trackPitch = lerp(trackPitch, lerp(0.8, 1.4, 1 - quakeWarnings / 3), dt * 3)

    local testers = 0
    for id, enemy in ipairs(room.enemies) do if enemy.image == "TESTER" then testers = testers + 1 end end

    -- Check if cleared
    if not room.cleared and #room.enemies - testers == 0 then
        room.cleared = true

        room.tilemap:buildColliders()
    end

    -- Check if player entered door
    if room.entranceParticles ~= nil then
        if player.collider.x < room.entranceParticles.x - 3 then swtichRoom(-1) end
    end
    if room.exitParticles ~= nil then
        if player.collider.x > room.exitParticles.x + 24 then swtichRoom(1) end
    end

    kill = {}
    for id, S in ipairs(room.structures) do

        S:process()
        if S.dead then table.insert(kill, id) end

    end room.structures = wipeKill(kill, room.structures)

    if room.boss ~= nil and not bossDead then -- Process boss if he exists and is alive

        room.boss.flash = room.boss.flash - dt

        room.boss.states[room.boss.state](room.boss)

        for id, P in ipairs(playerProjectiles) do -- Hit the boss with any player projectiles
    
            if rectCollidingCircle(room.boss.hitbox, P.pos.x, P.pos.y, P.radius) then

                local isInHitlist = false
        
                for _, ID in ipairs(P.hitlist) do
                    if ID == room.boss.id then isInHitlist = true end
                end
        
                if not isInHitlist then
    
                    P.hit = true
        
                    playSound("basicHit", love.math.random(80, 120) * 0.01)
    
                    addNewText(tostring(P.damage), room.boss.pos.x + love.math.random(-24, 24), room.boss.pos.y + love.math.random(-24, 24) - 24, {255, 0, 0})
        
                    room.boss.hp = clamp(room.boss.hp - P.damage, 0, room.boss.maxHp)
                    room.boss.flash = 1
                    P.pirice = P.pirice - 1
    
                    local activeItemSlot = player.wearing.slots["1,2"]
                    if activeItemSlot ~= nil then
                        local activeItem = activeItemSlot.item
                
                        if activeItem ~= nil then
                            activeItem.charge = clamp(activeItem.charge + P.damage / activeItem.chargeSpeed, 0, 1)
                        end
                    end
        
                    table.insert(P.hitlist, room.boss.id)
        
                end
                    
            end
        
        end

    end

end

-- Items

ITEM_PICKUP_PARTICLES = loadJson("data/particles/itemPickup.json")

function roomProcessItems(room)
    love.graphics.setCanvas(display)

    kill = {}
    for id,I in ipairs(room.items) do

        I:process(room)
        I:draw()

        if rectCollidingCircle(player.collider, I.pos.x, I.pos.y, 20) then 
            
            local startAmount = I.data.amount
            I.data = player.hotbar:convenientlyAddItem(I.data)

            if I.data.amount ~= 0 then I.data = player.inventory:convenientlyAddItem(I.data) end

            if I.data.amount ~= 0 then I.data = player.hotbar:addItem(I.data) end

            if I.data.amount ~= 0 then I.data = player.inventory:addItem(I.data) end

            if I.data.amount ~= startAmount then
                playSound("pickup", love.math.random(60,140) * 0.01, 3)

                
                local pickupParticles = newParticleSystem(I.pos.x, I.pos.y, deepcopyTable(ITEM_PICKUP_PARTICLES))

                pickupParticles.particleData.color.r.a = RARITY_COLORS[I.data.rarity][1] / 255
                pickupParticles.particleData.color.r.b = RARITY_COLORS[I.data.rarity][1] / 255

                pickupParticles.particleData.color.g.a = RARITY_COLORS[I.data.rarity][2] / 255
                pickupParticles.particleData.color.g.b = RARITY_COLORS[I.data.rarity][2] / 255

                pickupParticles.particleData.color.b.a = RARITY_COLORS[I.data.rarity][3] / 255
                pickupParticles.particleData.color.b.b = RARITY_COLORS[I.data.rarity][3] / 255

                table.insert(room.particleSystems, pickupParticles)

                local text = tostring(I.data.name)
                local difference = startAmount - I.data.amount
                if difference ~= 1 then text = text .. " x" .. tostring(difference) end

                addNewText(text, I.pos.x + love.math.random(-24, 24), I.pos.y + love.math.random(-24, 24), {RARITY_COLORS[I.data.rarity][1], RARITY_COLORS[I.data.rarity][2], RARITY_COLORS[I.data.rarity][3]})
            end

            if I.data.amount == 0 then table.insert(kill, id) end

        end

    end room.items = wipeKill(kill, room.items)

end