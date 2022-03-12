


function newEnterable(x, y, texture, roomData, tileTexture, doorCollider, process, draw, particles, particleOffset, stopQuake)
    -- GENERATE THE ROOM
    local enterableRoom = {textPopUps = newParticleSystem(0, 0, loadJson("data/particles/textParticles.json")),processItems=roomProcessItems,items={}, processEnemyBodies=roomProcessEnemyBodies, enemyBodies = {}, items = {}, cleared=false,enemies = {}, process=processEnterableRoom, drawBg=roomDrawBg, drawTiles=roomDrawTiles, drawEdge=roomDrawEdge, processEnemies=roomProcessEnemies, processParticles=roomParticles, particleSystems={}}

    -- Ambient particles
    enterableRoom.ambientParticles = newParticleSystem(0, 0, loadJson(particles))

    enterableRoom.stopQuake = stopQuake
    enterableRoom.playerTookHits = 0

    enterableRoom.particleOffset = particleOffset or newVec(0, 0)
    
    enterableRoom.structures = {} -- Structures and tilemaps

    enterableRoom.tilemap = newTilemap(loadSpritesheet(tileTexture, 16, 16), 48, roomData)
    enterableRoom.bgTilemap = newTilemap(loadSpritesheet(tileTexture, 16, 16), 48)

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

        x = x, y = y, room = enterableRoom, sprite = texture, tiles = tiles, doorCollider = newRect(doorCollider.x + x, doorCollider.y + y, doorCollider.w, doorCollider.h), process = process or processEnterable, draw = draw or drawEnterable

    }

end

-- Processing
function processEnterableRoom(room)

    -- Check if player entered door
    if room.entranceParticles ~= nil then
        if player.collider.x < room.entranceParticles.x - 3 then swtichRoom(0)
        
            player.collider.x = room.outsideExit.x; player.collider.y = room.outsideExit.y

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

        drawSprite(IMAGE_F, enterable.doorCollider.x + 2, enterable.doorCollider.y - enterable.doorCollider.h * 0.5 - 24 + math.sin(globalTimer * 2) * 9)

        if justPressed("f") then

            ROOM = enterable.room
            ambientLight = enterable.ambientLight or {200, 200, 200}
            transition = 1
            player.collider.x = ROOM.entranceParticles.x + 12; player.collider.y = ROOM.entranceParticles.y + 48
            player.walkParticles.particles = {}
            playerProjectiles = {}
            enemyProjectiles = {}
            
        end

    end

end

function processEnterable(enterable)
    
end




function newHouse(x, y)

    return newEnterable(x, y, love.graphics.newImage("data/images/structures/house.png"), loadJson("data/layouts/structureRooms/house.json"), "data/images/tilesets/houseTileset.png", newRect(-39, -33, 24, 60), drawEnterable, processEnterable, "data/particles/blankParticles.json",nil, true)

end

ENTERABLES = {
    house = newHouse
}