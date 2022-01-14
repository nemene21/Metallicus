
INVENTORY_SPACING = 56

HOLDING_ARROW = love.graphics.newImage("data/images/UI/inventory/holdingArrow.png")

IN_HAND = nil

CRAFTING_RECIPIES = loadJson("data/craftingRecipies.json")

ITEMS = loadJson("data/items.json")
for id,I in pairs(ITEMS) do I.amount = 1; I.index = id end

-- Init
function newInventory(ox,oy,w,h,image)
    local inventory = {hovered = false, addItem = inventoryAddItem, x=ox,y=oy,slots={},slotIndexes={}}
    local image = image or "slot"

    for y=0,h-1 do
    for x=0,w-1 do
        inventory.slots[tostring(x)..","..tostring(y)] = {
            item=nil,
            scale=1, scaleTo=1,
            type="item",
            image=image
        }

        table.insert(inventory.slotIndexes, tostring(x)..","..tostring(y))

        POSSIBLE_ITEMS = {"wood","stone","sword","bodyArmor","headArmor","none"}

        inventory.slots[tostring(x)..","..tostring(y)].item = deepcopyTable(ITEMS[POSSIBLE_ITEMS[love.math.random(0,#POSSIBLE_ITEMS)]])

        if inventory.slots[tostring(x)..","..tostring(y)].item ~= nil then
            inventory.slots[tostring(x)..","..tostring(y)].item.amount = love.math.random(1,inventory.slots[tostring(x)..","..tostring(y)].item.maxStack)
        end

    end end

    return inventory
end

-- Putting an item in an inventory
function inventoryAddItem(inventory, item)
    
    for id,S in ipairs(inventory.slotIndexes) do
        id = S; S = inventory.slots[S]

        if S.item == nil then

            S.item = deepcopyTable(item); item.amount = 0

        else if S.item.index == item.index then

            S.item.amount = S.item.amount + item.amount
            
            if S.item.amount > S.item.maxStack then

                item.amount = S.item.amount - S.item.maxStack
                S.item.amount = S.item.maxStack

            else

                item.amount = 0

            end

        end end

        if item.amount == 0 then break end

    end

    return item
end

-- Processing an inventory
function processInventory(inventory)

    inventory.hovered = false
    local slotHovered = nil

    for id,S in pairs(inventory.slots) do
        -- PROCESSING

        -- If getting hovered
        if S.on then
            slotHovered = S

            inventory.hovered = true

            S.scaleTo = 1.15

            -- Left click
            if mouseJustPressed(1) and not pressed("lshift") then
                S.scale = 1.3; playSound("inventoryClick")

                if IN_HAND ~= nil and S.item ~= nil then
                if IN_HAND.name == S.item.name then
                -- Same items, it tries to sum the items count
                    
                    S.item.amount = S.item.amount + IN_HAND.amount

                    -- Over max stack, leaves the rest to the hand
                    if S.item.amount > S.item.maxStack then

                        local left = S.item.maxStack - S.item.amount
                        IN_HAND.amount = math.abs(left); S.item.amount = S.item.maxStack
                    
                    -- Under the max stack or max stack, it nills the hand
                    else
                        IN_HAND = nil
                    end

                -- Different items, it swaps
                else if elementIndex(IN_HAND.types,S.type) ~= -1 then
                    hold = S.item
                    S.item = IN_HAND
                    IN_HAND = hold
                end end
                
                else
                    -- Hand empty, it switches
                    if IN_HAND == nil then
                        hold = S.item
                        S.item = IN_HAND
                        IN_HAND = hold
                    
                    -- Hand not empty, it switches
                    else if elementIndex(IN_HAND.types,S.type) ~= -1 then
                        hold = S.item
                        S.item = IN_HAND
                        IN_HAND = hold
                    end end
                end
            end
            
            -- Right click
            if mouseJustPressed(2) and not pressed("lshift") then
                S.scale = 1.3; playSound("inventoryClick")

                -- If hand is empty and the slot is not empty, split slot
                if IN_HAND == nil then
                if S.item ~= nil then
                if S.item.amount ~= 1 then
                
                    local half = math.floor(S.item.amount * 0.5)
                    local left = S.item.amount - half
                    IN_HAND = deepcopyTable(S.item); IN_HAND.amount = left
                    S.item.amount = half

                end end

                else
                    -- If hand is not empty and the slot is empty, place one item in the slot
                    if S.item == nil then
                    if elementIndex(IN_HAND.types,S.type) ~= -1 then
                        S.item = deepcopyTable(IN_HAND)
                        S.item.amount = 1

                        IN_HAND.amount = IN_HAND.amount - 1
                    end
                    -- If hand is not empty and the slot is not empty and their name is the same, place one item in the slot
                    else if S.item.amount ~= S.item.maxStack and S.item.name == IN_HAND.name then
                        S.item.amount = S.item.amount + 1

                        IN_HAND.amount = IN_HAND.amount - 1
                    end end
                end
            end

        else S.scaleTo = 1 end

        S.on = false

    -- Hover over slot
    local mouseSlotX = math.floor(((xM-inventory.x) / INVENTORY_SPACING) + 0.5); local mouseSlotY = math.floor(((yM-inventory.y) / INVENTORY_SPACING) + 0.5)

    if inventory.slots[tostring(mouseSlotX)..","..tostring(mouseSlotY)] ~= nil then
        inventory.slots[tostring(mouseSlotX)..","..tostring(mouseSlotY)].on = true
    end
    end
    
    return inventory, slotHovered
end

-- Drawing an inventory
function drawInventory(inventory)

    -- DRAW
    for id,S in pairs(inventory.slots) do

    -- Get pos
    local pos = splitString(id,",")
    local slotX = tonumber(pos[1]); local slotY = tonumber(pos[2])

    -- Draw slot
    if S.item == nil then setColor(140,140,140) else setColor(255,255,255) end

    drawSprite(SLOT_IMAGES[S.image], slotX * INVENTORY_SPACING + inventory.x, slotY * INVENTORY_SPACING + inventory.y, snap(S.scale,0.02), snap(S.scale,0.02), 0, 0)

    if S.icon ~= nil then drawSprite(SLOT_ICONS[S.icon], slotX * INVENTORY_SPACING + inventory.x, slotY * INVENTORY_SPACING + inventory.y, snap(S.scale,0.02), snap(S.scale,0.02), 0, 0) end

    -- Draw item and item count, if there is one
    if S.item ~= nil then
        setColor(255,255,255)
        drawSprite(ITEM_IMGES[S.item.texture], slotX * INVENTORY_SPACING + inventory.x, slotY * INVENTORY_SPACING + inventory.y, snap(S.scale,0.02), snap(S.scale,0.02), 0, 0)

        if S.item.amount ~= 1 then
            local count = tostring(S.item.amount)
            outlinedText(math.floor(slotX * INVENTORY_SPACING + inventory.x) + 24, math.floor(slotY * INVENTORY_SPACING + inventory.y) + 5, 2, count, {255,255,255}, 1, 1, 1)
        end

        setColor(255,255,255)
    end

    S.scale = lerp(S.scale,S.scaleTo,dt*20)
    S.scaleTo = 1

    end
end

function processTooltip(inventory)
    -- Hover over slot
    local mouseSlotX = math.floor(((xM-inventory.x) / INVENTORY_SPACING) + 0.5); local mouseSlotY = math.floor(((yM-inventory.y) / INVENTORY_SPACING) + 0.5)

    if inventory.slots[tostring(mouseSlotX)..","..tostring(mouseSlotY)] ~= nil then

        -- Draw tooltip if there is an item
        if inventory.slots[tostring(mouseSlotX)..","..tostring(mouseSlotY)].item ~= nil then drawTooltip(inventory.slots[tostring(mouseSlotX)..","..tostring(mouseSlotY)].item) end
    end
end

function processMouseSlot()

    -- If not empty
    if IN_HAND ~= nil then
        setColor(255,255,255)

        -- Draw
        drawSprite(ITEM_IMGES[IN_HAND.texture],xM + 48,yM + 48, 1, 1, 0, 0)

        if IN_HAND.amount ~= 1 and IN_HAND.amount ~= 0 then

            local count = tostring(IN_HAND.amount)
            outlinedText(xM + 74, yM + 58, 2, count, {255,255,255}, 1, 1, 1)

        end

        if IN_HAND.amount == 0 then
            IN_HAND = nil
        end
    end
end

-- TOOLTIP
STAT_NAMES = {
dmg = "damage", def = "defense"
}

TOOLTIP_OFFSET = 80
RARITY_COLORS = {common={255,255,255},uncommon={0,255,0},rare={44,255,255},epic={142,0,154},mythic={255,0,68}}

function drawTooltip(item)
    
    -- If the item is equippable
    if item.tooltipEquipName ~= nil then

        -- Get width of rect
        local textDraws = {}; colors = {}
        local width = 0

        local STAT_OFFSET = 15
        
        for id,S in pairs(item.stats) do
            local text = STAT_NAMES[id]..":  "
            if S > 0 then text = text.."+"; table.insert(colors,{0,255,0}) else table.insert(colors,{255,0,0}) end
            text = text..S

            table.insert(textDraws,text)

            local textWidth = FONT:getWidth(text)
            if textWidth + STAT_OFFSET > width then width = textWidth + STAT_OFFSET end
        end

        local fontHeight = FONT:getHeight("text lol") + 4

        -- Draw rect
        setColor(0,0,0,150)
        love.graphics.rectangle("fill",xM + TOOLTIP_OFFSET - 6, yM + 38, width + 12, fontHeight * (#textDraws + 1) + 18,8, 8)

        -- Draw stats
        outlinedText(xM + TOOLTIP_OFFSET,yM + 38 + 8,2,item.tooltipEquipName,{120,120,120})

        for id,T in ipairs(textDraws) do
            outlinedText(xM + TOOLTIP_OFFSET + STAT_OFFSET,yM + 38 + 12 + id * fontHeight,2,T,colors[id])
        end
    end
    -- Draw rect
    setColor(0,0,0,150)
    love.graphics.rectangle("fill",xM + TOOLTIP_OFFSET - 6, yM - 6, FONT:getWidth(item.name)+12, 38,8, 8)

    -- Draw name
    outlinedText(xM + TOOLTIP_OFFSET,yM,2,item.name,RARITY_COLORS[item.rarity])
end

-- HOLDING STUFF

-- Play hold state
function holdItem(player,headed,item) return HOLD_MODES[item.holdMode](player,headed,item) end

-- Hold states

function MODE_HOLD(player,headed,item)
    -- Draw
    drawSprite(ITEM_IMGES[item.texture], (player.armR.x + 9) * headed + player.collider.x, player.armR.y + player.collider.y - 9, headed)

    return item
end

function MODE_SLASH(player,headed,item)
    -- Rotate anchor and sprite
    item.holdData.rotation = lerp(item.holdData.rotation,item.holdData.rotateTo,dt * 8)
    item.holdData.spriteRotation = lerp(item.holdData.spriteRotation,item.holdData.spriteRotateTo,dt * 8)

    -- Slash
    item.holdData.attackTimer = item.holdData.attackTimer - dt
    if mousePressed(1) and player.inventoryOpen ~= true and item.holdData.attackTimer < 0 then
        -- Reset attack timer
        item.holdData.attackTimer = item.holdData.attackTime
        -- Reverse turn
        item.holdData.turnTo = item.holdData.turnTo * -1
        -- Set anchor rotator
        item.holdData.rotateTo = item.holdData.rotateTo + (360 - 2 * item.holdData.roatationDefault) * item.holdData.turnTo
        -- Set sprite rotator
        item.holdData.spriteRotateTo = 270 * (item.holdData.turnTo + 1) * 0.5

        -- Summon projectile
        local rotation = newVec(player.collider.x - camera[1] - xM, player.collider.y - camera[2] - yM); rotation = rotation:getRot()

        local pos = newVec(item.holdData.distance,0); pos:rotate(rotation + 180)    

        local projectile = newPlayerProjectile("basicSlash", 6, "sine", newVec(player.collider.x + pos.x, player.collider.y + pos.y), item.projectile.speed, rotation, 2, item.projectile.range, item.projectile.followPlayer, item.projectile.radius, item.projectile.pirice, item.projectile.knockback)

        shake(4, 1, 0.15, rotation)
        if item.projectile.sound ~= nil then playSound(item.projectile.sound, love.math.random(80, 120) * 0.01) end

        table.insert(playerProjectiles,projectile)
    end

    -- Get draw pos and rotation
    local rotation = newVec(player.collider.x - camera[1] - xM, player.collider.y - camera[2] - yM); rotation = rotation:getRot()

    local pos = newVec(item.holdData.distance,0); pos:rotate(rotation + item.holdData.rotation)

    -- Draw
    drawSprite(ITEM_IMGES[item.texture], player.collider.x + pos.x, player.collider.y + pos.y, 1, item.holdData.flip, (rotation + item.holdData.spriteRotation) / 180 * 3.14)
    return item
end

HOLD_MODES = {
hold=MODE_HOLD, slash=MODE_SLASH
}

-- Images for all items and icons in the game currently!

SLOT_ICONS = {
bodyArmor = love.graphics.newImage("data/images/UI/inventory/icons/body.png"),
headArmor = love.graphics.newImage("data/images/UI/inventory/icons/head.png"),
ring = love.graphics.newImage("data/images/UI/inventory/icons/ring.png"),
shield = love.graphics.newImage("data/images/UI/inventory/icons/shield.png"),
amulet = love.graphics.newImage("data/images/UI/inventory/icons/amulet.png")
}

SLOT_IMAGES = {
slot=love.graphics.newImage("data/images/UI/inventory/slot.png"),
hotbarSlot=love.graphics.newImage("data/images/UI/inventory/hotbarSlot.png"),
equipmentSlot=love.graphics.newImage("data/images/UI/inventory/equipmentSlot.png")
}

ITEM_IMGES = {
wood = love.graphics.newImage("data/images/items/wood.png"),
stick = love.graphics.newImage("data/images/items/stick.png"),
jello = love.graphics.newImage("data/images/items/jello.png"),
stone = love.graphics.newImage("data/images/items/stone.png"),
sword = love.graphics.newImage("data/images/items/sword.png"),
bodyArmor = love.graphics.newImage("data/images/items/bodyArmor.png"),
headArmor = love.graphics.newImage("data/images/items/helmet.png")
}

-- Add slot function

function addSlot(inventory,x,y,type,icon,image)
    local type = type or "item"
    local image = image or "slot"

    inventory.slots[tostring(x)..","..tostring(y)] = {
        item=nil,
        scale=1, scaleTo=1,
        type=type, icon=icon,

        image=image
    }

    return inventory
end

--                                                            ITEMS ON FLOOR

function newItem(x,y,item)

    return {
        pos = newVec(x, y), vel = newVec(0, 0),

        data = item,

        process = processDroppedItem, draw = drawDroppedItem
    }

end

function processDroppedItem(item, room)

    item.vel.y = math.min(item.vel.y + dt * 1200, 600)
    item.vel.x = lerp(item.vel.x, 0, dt)

    item.pos.x = item.pos.x + item.vel.x * dt

    local tilePos = newVec(math.floor(item.pos.x / 48), math.floor((item.pos.y + 28) / 48))
    local tile = room.tilemap:getTile(tilePos.x, tilePos.y)

    if tile ~= nil then

        item.pos.x = item.pos.x - item.vel.x * dt * 1.2
        item.vel.x = item.vel.x * - 0.4

    end

    item.pos.y = item.pos.y + item.vel.y * dt

    local tilePos = newVec(math.floor(item.pos.x / 48), math.floor((item.pos.y + 28) / 48))
    local tile = room.tilemap:getTile(tilePos.x, tilePos.y)

    if tile ~= nil then

        item.pos.y = item.pos.y - item.vel.y * dt * 1.2
        item.vel.y = item.vel.y * - 0.4

    end

end

function drawDroppedItem(item)

    local sine =  math.sin(globalTimer * 3) * 8

    love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", 1)
    setColor(RARITY_COLORS[item.data.rarity][1], RARITY_COLORS[item.data.rarity][2], RARITY_COLORS[item.data.rarity][3])

    drawSprite(ITEM_IMGES[item.data.texture], item.pos.x - 1, item.pos.y + sine)
    drawSprite(ITEM_IMGES[item.data.texture], item.pos.x + 1, item.pos.y + sine)
    drawSprite(ITEM_IMGES[item.data.texture], item.pos.x, item.pos.y + sine - 1)
    drawSprite(ITEM_IMGES[item.data.texture], item.pos.x, item.pos.y + sine + 1)

    love.graphics.setShader(); setColor(255, 255, 255)

    drawSprite(ITEM_IMGES[item.data.texture], item.pos.x, item.pos.y + sine)

end