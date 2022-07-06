


function newEnterable(x, y, texture, roomData, tileTexture, doorCollider, process, draw, additionalProcess, particles, particleOffset, stopQuake, structures, track)
    -- GENERATE THE ROOM
    local enterableRoom = {processItems=roomProcessItems,items={}, processEnemyBodies=roomProcessEnemyBodies, enemyBodies = {}, items = {}, cleared=false,enemies = {}, process=processEnterableRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, additionalProcess = additionalProcess, processParticles=roomParticles, particleSystems={}}

    
    -- Ambient particles
    enterableRoom.ambientParticles = newParticleSystem(0, 0, loadJson(particles))

    enterableRoom.stopQuake = stopQuake
    enterableRoom.playerTookHits = 0

    enterableRoom.particleOffset = particleOffset or newVec(0, 0)
    
    enterableRoom.structures = structures or {} -- Structures and tilemaps

    enterableRoom.tilemap = newTilemap(loadSpritesheet(tileTexture[1], 16, 16), 48, roomData)
    enterableRoom.bgTilemap = newTilemap(loadSpritesheet(tileTexture[2], 16, 16), 48)

    local firstCheck = true 
    for id,T in pairs(enterableRoom.tilemap.tiles) do

        -- Get pos and is tile collidable
        local pos = splitString(id,",")
        local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])
        
        if firstCheck then firstCheck = false -- Set the start value if its the first

            enterableRoom.endLeft = tileX; enterableRoom.endRight = tileX
            enterableRoom.endUp = tileY; enterableRoom.endDown = tileY

        else -- Look for a record

            if enterableRoom.endUp > tileY then enterableRoom.endUp = tileY end

            if enterableRoom.endDown < tileY then enterableRoom.endDown = tileY end

            if enterableRoom.endLeft > tileX then enterableRoom.endLeft = tileX end

            if enterableRoom.endRight < tileX then enterableRoom.endRight = tileX end
        end

    end

    for x=enterableRoom.endLeft,enterableRoom.endRight do for y=enterableRoom.endUp,enterableRoom.endDown do

        if
            enterableRoom.tilemap:getTile(x + 1, y) == nil or
            enterableRoom.tilemap:getTile(x - 1, y) == nil or
            enterableRoom.tilemap:getTile(x, y + 1) == nil or
            enterableRoom.tilemap:getTile(x, y - 1) == nil
        then

            enterableRoom.bgTilemap:setTile(x,y,{1,love.math.random(1,3)})

        end

    end end -- Place tiles

    -- Get the edges actual position and width

    enterableRoom.endHeight = (enterableRoom.endUp - enterableRoom.endDown) * 48
    enterableRoom.endWidth = (enterableRoom.endLeft - enterableRoom.endRight) * 48


    enterableRoom.endLeft = newVec(enterableRoom.endLeft * 48 - 48, enterableRoom.endHeight * 0.5) 

    enterableRoom.endRight = newVec(enterableRoom.endRight * 48 + 96, enterableRoom.endHeight * 0.5)

    enterableRoom.endUp = newVec(enterableRoom.endWidth * 0.5, enterableRoom.endUp * 48 - 48)

    enterableRoom.endDown = newVec(enterableRoom.endWidth * 0.5, enterableRoom.endDown * 48 + 96)

    enterableRoom.decorations = {}
    enterableRoom.decorations.background = {}; enterableRoom.decorations.foreground = {} -- Blank decoration

    local entrancePos = nil
    for id,T in pairs(enterableRoom.tilemap.tiles) do
        
        -- Is tile entrance
        if T[1] == 5 and T[2] == 5 then
            local pos = splitString(id,",")
            local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])

            entrancePos = newVec(tileX * 48 + 24,tileY * 48 + 24)

            enterableRoom.tilemap.tiles[id] = nil
        end
    end
    enterableRoom.entranceParticles = newParticleSystem(entrancePos.x - 48,entrancePos.y,loadJson("data/particles/doorParticles.json"))

    enterableRoom.tilemap:buildColliders() -- Building tilemaps
    enterableRoom.tilemap:buildIndexes()
    enterableRoom.bgTilemap:buildIndexes()

    enterableRoom.outsideExit = newVec(doorCollider.x + x, doorCollider.y + y)

    return { -- RETURN THE TABLE

        x = x, y = y, room = enterableRoom, sprite = texture, tiles = tiles, doorCollider = newRect(doorCollider.x + x, doorCollider.y + y, doorCollider.w, doorCollider.h), process = process or processEnterable, draw = draw or drawEnterable,

        track = track

    }

end

-- Processing
function processEnterableRoom(room)

    room:additionalProcess()

    trackPitch = lerp(trackPitch, 0.8, dt * 3)

    -- Check if player entered door
    if room.entranceParticles ~= nil and transition < 0.1 then
        if player.collider.x < room.entranceParticles.x - 3 then swtichRoom(0)
        
            player.collider.x = room.outsideExit.x; player.collider.y = room.outsideExit.y

            if trackTransition > 0 then

                switchTracks()

            else
                
                playTrack("cave", 0.5)

            end

        end
    end

    kill = {}
    for id, S in ipairs(room.structures) do

        S:process()
        if S.dead then table.insert(kill, id) end

    end room.structures = wipeKill(kill, room.structures)

end

function drawEnterable(enterable)
    drawSprite(enterable.sprite, enterable.x, enterable.y, 1, 1, 0, 1, 0.5, 1)

    if isRectColliding(enterable.doorCollider, player.collider) then

        drawInteract(enterable.doorCollider.x + 2, enterable.doorCollider.y - enterable.doorCollider.h * 0.5 - 24)

        if justPressed("f") then
            
            playTrack(enterable.track or BIOMES[biomeOn].track, 0.5)

            ROOM = enterable.room
            ambientLight = enterable.ambientLight or BIOMES[biomeOn].ambientLight
            transition = 1

            player.collider.x = ROOM.entranceParticles.x + 12; player.collider.y = ROOM.entranceParticles.y + 48

            player.walkParticles.particles = {}
            player.dashParticles.particles = {}

            ALL_TEXT_PARTICLES = {}

            playerProjectiles = {}
            enemyProjectiles = {}

            player.inventory.justUpdated = true

            
            
        end

    end

end

function processEnterable(enterable)
    
end

function processCraftingArea(house)
    trackPitch = lerp(trackPitch, 1, dt * 6)
end

function newHouse(x, y)

    return newEnterable(x, y, love.graphics.newImage("data/images/structures/house.png"), loadJson("data/layouts/structureRooms/house.json"), {"data/images/tilesets/houseTileset.png", "data/images/tilesets/houseBg.png"}, newRect(-39, -33, 24, 60), drawEnterable, processEnterable, processCraftingArea, "data/particles/blankParticles.json", nil, true, {newTeleporter(560, 580), newAnvil(350, 580)}, "crafting")

end

ENTERABLES = {
    house = newHouse
}