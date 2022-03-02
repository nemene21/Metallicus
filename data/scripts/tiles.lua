
-- Tile functions
function getTilemapTile(tilemap,x,y) return tilemap.tiles[tostring(x)..","..tostring(y)] end

function setTilemapTile(tilemap,x,y,tile) tilemap.tiles[tostring(x)..","..tostring(y)] = {tile[1],tile[2]} end

function removeTilemapTile(tilemap,x,y) tilemap.tiles[tostring(x)..","..tostring(y)] = nil end

-- Drawing
function drawTilemap(tilemap)

    for id,T in ipairs(tilemap.indexes) do
        id = T; T = tilemap.tiles[id]
        
        local pos = splitString(id,",")
        local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])
        
        pos = newVec(tileX*tilemap.tileSize,tileY*tilemap.tileSize)

        if pos.x > camera[1] - 48 and pos.x < camera[1] + 800 and pos.y > camera[2] - 48 and pos.y < camera[2] + 600 then
            drawFrame(tilemap.sheet,T[1],T[2],pos.x,pos.y, 1, 1, 0, 1, 0)
        end
    end
    -- drawColliders(tilemap.colliders)
end

function buildTilemapIndexes(tilemap)
    tilemap.indexes = {}

    for id, T in pairs(tilemap.tiles) do table.insert(tilemap.indexes, id) end
end

-- Build colliders (goes trough all tiles, places a collider on them in the tilemap.collided if they dont have a neightbour somewhere)
function buildTilemapColliders(tilemap)
    tilemap.colliders = {}; tilemap.collidersWithFalltrough = {}
    
    for id,T in pairs(tilemap.tiles) do

        -- Get pos and is tile collidable
        local pos = splitString(id,",")
        local tileX = tonumber(pos[1]); local tileY = tonumber(pos[2])

        place = tilemap.tiles[tostring(tileX - 1)..","..tostring(tileY)] == nil or tilemap.tiles[tostring(tileX + 1)..","..tostring(tileY)] == nil or
                tilemap.tiles[tostring(tileX)..","..tostring(tileY - 1)] == nil or tilemap.tiles[tostring(tileX)..","..tostring(tileY + 1)] == nil

        if place then

            
            -- Is tile falltrough
            if T[1] > 3 and T[2] > 5 then

                -- rect.cDW = false; rect.cL = false; rect.cR = false; rect.h = 18; rect.y = rect.y - 15
                
                if T[1] == 4 and T[2] == 6 then

                    local done = false; local tileAt = 1; local width = 48

                    while done == false do

                        local index = tostring(tileX + tileAt)..","..tostring(tileY)

                        local TChecking = tilemap.tiles[index]

                        if TChecking ~= nil then
                            
                            if TChecking[1] == 5 and TChecking[2] == 6 then

                                tileAt = tileAt + 1; width = width + 48

                            else if TChecking[1] == 6 and TChecking[2] == 6 then

                                tileAt = tileAt + 1; width = width + 48
                                done = true

                            end end
                        end
                    end

                    local rect = newRect((tileX + math.floor(tileAt * 0.5)) * tilemap.tileSize + tilemap.tileSize * 0.5, tileY * tilemap.tileSize + tilemap.tileSize * 0.5, width, tilemap.tileSize)
                    rect.cDW = false; rect.cL = false; rect.cR = false
                     
                    table.insert(tilemap.collidersWithFalltrough,rect)

                end
            else
                local rect = newRect(tileX * tilemap.tileSize + tilemap.tileSize * 0.5, tileY * tilemap.tileSize + tilemap.tileSize * 0.5, tilemap.tileSize, tilemap.tileSize)
                table.insert(tilemap.colliders,rect); table.insert(tilemap.collidersWithFalltrough,rect)
            end
        end
    end
end

-- New tilemap
function newTilemap(texture,tileSize,tiles)
    local tilemap = {
        tiles=tiles or {},
        tileSize=tileSize,
        sheet=texture,

        getTile=getTilemapTile,
        setTile=setTilemapTile,
        removeTile=removeTilemapTile,
        draw=drawTilemap,

        colliders={}, collidersWithFalltrough={},
        buildColliders=buildTilemapColliders,
        buildIndexes=buildTilemapIndexes
    }

    tilemap:buildIndexes()

    return tilemap
end