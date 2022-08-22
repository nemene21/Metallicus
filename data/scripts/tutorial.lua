
function generateTutorial()

    firstRoomEver = false

    timeUntillQuake = -1000
    quakeWarnings = 3

    biomeOn = "cave"
    ambientLight = BIOMES[biomeOn].ambientLight

    local rooms = {}

    player.collider.x = 276; player.collider.y = -360

    rooms[1] = generateTutorialRoom("data/layouts/firstRoom.json")

    table.insert(rooms[1].structures, newTextDisplayer(400, 250, "A and D to move."))
    table.insert(rooms[1].structures, newTextDisplayer(400, 350, "Space to jump!"))

    rooms[2] = generateTutorialRoom("data/layouts/tutorialPassage.json")

    table.insert(rooms[2].structures, newRock(200, 578))
    table.insert(rooms[2].structures, newRock(264, 578))

    table.insert(rooms[2].structures, newWood(364, 578))

    table.insert(rooms[2].structures, newRock(448, 578))

    table.insert(rooms[2].structures, newTextDisplayer(400, 300, "Right click to attack,"))
    table.insert(rooms[2].structures, newTextDisplayer(400, 400, "to harvest materials attack them!"))

    rooms[3] = generateTutorialRoom("data/layouts/tutorialPassage.json")

    table.insert(rooms[3].structures, newTextDisplayer(400, 300, "Open your inventory with E."))
    table.insert(rooms[3].structures, newTextDisplayer(400, 400, "Head to the anvil to craft!"))

    table.insert(rooms[3].structures, newAnvil(364, 578))

    rooms[4] = generateTutorialRoom("data/layouts/tutorialPassage.json")

    table.insert(rooms[4].structures, newTextDisplayer(400, 350, "Slay the enemies to open the door!"))

    table.insert(rooms[4].enemies, buildEnemy("slime", 264, 530))
    table.insert(rooms[4].enemies, buildEnemy("slime", 564, 530))

    rooms[5] = generateTutorialRoom("data/layouts/tutorialPassage.json")

    table.insert(rooms[5].structures, newTextDisplayer(400, 300, "Craft some bowls and put them in the brewer!"))
    table.insert(rooms[5].structures, newTextDisplayer(400, 364, "Put flamables in the fuel slot,"))
    table.insert(rooms[5].structures, newTextDisplayer(400, 428, "then put jello in the side slots!"))
    table.insert(rooms[5].structures, newTextDisplayer(400, 492, "Enjoy your soup by clicking right click!"))

    table.insert(rooms[5].structures, newWood(200, 578))
    table.insert(rooms[5].structures, newWood(280, 578))

    table.insert(rooms[5].structures, newAnvil(394, 578))
    table.insert(rooms[5].structures, newBrewer(500, 578))

    rooms[6] = generateTutorialRoom("data/layouts/end.json")

    table.insert(rooms[6].structures, newTextDisplayer(400, 364, "At the end of a room sequence there"))
    table.insert(rooms[6].structures, newTextDisplayer(400, 418, "will be a house (press F to enter)"))

    table.insert(rooms[6].structures, ENTERABLES.house(420, 579))

    table.insert(rooms[6].structures[3].room.structures, newTextDisplayer(400, 364, "In the house you get an anvil, a"))
    table.insert(rooms[6].structures[3].room.structures, newTextDisplayer(400, 418, "brewing station and a teleporter!"))

    return rooms

end

function generateTutorialRoom(layout)

    local biome = BIOMES.cave

    local room = {processItems=roomProcessItems,items={}, processEnemyBodies=roomProcessEnemyBodies, enemyBodies = {}, items = {}, cleared=false,enemies = {}, process=processRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, processParticles=roomParticles, particleSystems={}}

    -- Ambient particles
    room.ambientParticles = newParticleSystem(0, 0, loadJson(biome.ambientParticles))

    room.particleOffset = biome.particleOffset or newVec(0, 0)

    room.playerTookHits = 0

    room.structures = {}

    -- Set tilemap
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

    return room

end