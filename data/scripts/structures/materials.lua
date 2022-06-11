MATERIAL_SPRITES = {
    rock = {love.graphics.newImage("data/images/structures/rock3.png"), love.graphics.newImage("data/images/structures/rock2.png"), love.graphics.newImage("data/images/structures/rock1.png")},
    wood = {love.graphics.newImage("data/images/structures/wood1.png"), love.graphics.newImage("data/images/structures/wood1.png"), love.graphics.newImage("data/images/structures/wood1.png")},
    shroomOre = {love.graphics.newImage("data/images/structures/shroomOre1.png"),love.graphics.newImage("data/images/structures/shroomOre1.png")}
    }
    
    DESTROY_RESOURCE_PARTICLES = loadJson("data/particles/resourceDestroyed.json")
    
    STRUCTURE_ID = 0.5
    
    function newMaterial(x, y, name, drops, hitSound)
        STRUCTURE_ID = STRUCTURE_ID + 1
        local mat = {x = x, y = y, name = name, process = processMaterial, draw = drawMaterial, hp = 50, id = STRUCTURE_ID, sprite = love.math.random(1,#MATERIAL_SPRITES[name]), hitTimer = 0, drops = drops, hitSound = hitSound}
    
        return mat
    end
    
function processMaterial(mat)
    
    for id, P in ipairs(playerProjectiles) do
    
        if newVec(P.pos.x - mat.x, P.pos.y - mat.y):getLen() < 36 + P.radius then
    
            local isInHitlist = false
    
            for _, ID in ipairs(P.hitlist) do
                if ID == mat.id then isInHitlist = true end
            end
    
            if not isInHitlist then
    
                playSound(mat.hitSound, love.math.random(80, 120) * 0.01)

                addNewText(tostring(P.damage), mat.x + love.math.random(-24, 24), mat.y + love.math.random(-24, 24) - 24, {255, 0, 0})
    
                mat.hp = mat.hp - P.damage
                mat.hitTimer = 0.2
                P.pirice = P.pirice - 1

                local activeItemSlot = player.wearing.slots["1,2"]
                if activeItemSlot ~= nil then
                    local activeItem = activeItemSlot.item
            
                    if activeItem ~= nil then
                        activeItem.charge = clamp(activeItem.charge + P.damage / activeItem.chargeSpeed, 0, 1)
                    end
                end
    
                table.insert(P.hitlist, mat.id)
    
            end
                
        end
    
    end
    
    if mat.hp <= 0 and mat.dead == nil then
            
        table.insert(ROOM.particleSystems, newParticleSystem(mat.x, mat.y - 20, deepcopyTable(DESTROY_RESOURCE_PARTICLES)))
        mat.dead = true
    
        for id,I in pairs(mat.drops) do
    
            local amount = 0
            local percentage = I
    
            while percentage > 100 do
    
                percentage = percentage - 100; amount = amount + 1
    
            end
    
            if love.math.random(1, 100) < percentage then amount = amount + 1 end
    
            for x=1,amount do
                local item = ITEMS[id]; item.amount = 1
    
                table.insert(ROOM.items, newItem(mat.x + love.math.random(-24, 24), mat.y + love.math.random(-24, 0), item))
            end
        end
    
    end
 end
    
function drawMaterial(mat)
    
    mat.hitTimer = math.max(mat.hitTimer - dt, 0)
    if mat.hitTimer > 0.1 then SHADERS.FLASH:send("intensity", 1); love.graphics.setShader(SHADERS.FLASH) end
    
    local hitAnim = mat.hitTimer / 0.2
    drawSprite(MATERIAL_SPRITES[mat.name][mat.sprite], mat.x, mat.y, 1 - 0.25 * hitAnim, 1 + 0.25 * hitAnim, 0, 1, 0.5, 1)
    
    love.graphics.setShader()
    
end
    
function newRock(x, y)
    return newMaterial(x, y, "rock", {stone = 350}, "hitOre")
end
    
function newWood(x, y)
    return newMaterial(x, y, "wood", {wood = 350}, "hitOre")
end
    
function newShroomOre(x, y)
    return newMaterial(x, y, "shroomOre", {shroomOre = 350}, "hitOre")
end
    
MATERIAL_CONSTRUCTORS = {
    rock = newRock, wood = newWood, shroomOre = newShroomOre
}