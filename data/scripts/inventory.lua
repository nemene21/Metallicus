
INVENTORY_SPACING = 64

HOLDING_ARROW = love.graphics.newImage("data/images/UI/inventory/holdingArrow.png")

IN_HAND = nil

ITEMS = loadJson("data/items.json")
for id,I in pairs(ITEMS) do I.name = id; I.amount = 1 end

-- Init
function newInventory(ox,oy,w,h,image)
    local inventory = {x=ox,y=oy,slots={}}
    local image = image or "slot"

    for x=0,w-1 do
    for y=0,h-1 do
        inventory.slots[tostring(x)..","..tostring(y)] = {
            item=nil,
            scale=1, scaleTo=1,
            type="item",
            image=image
        }

        POSSIBLE_ITEMS = {"wood","stone","sword","bodyArmor","none"}

        inventory.slots[tostring(x)..","..tostring(y)].item = deepcopyTable(ITEMS[POSSIBLE_ITEMS[love.math.random(0,#POSSIBLE_ITEMS)]])

        if inventory.slots[tostring(x)..","..tostring(y)].item ~= nil then
            inventory.slots[tostring(x)..","..tostring(y)].item.amount = love.math.random(1,inventory.slots[tostring(x)..","..tostring(y)].item.maxStack)
        end

    end end

    return inventory
end

-- Processing an inventory
function processInventory(inventory)

    for id,S in pairs(inventory.slots) do

        -- PROCESSING

        -- If getting hovered
        if S.on then 

            S.scaleTo = 1.2

            -- Left click
            if mouseJustPressed(1) then
                S.scale = 1.5

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
            if mouseJustPressed(2) then
                S.scale = 1.5

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

    return inventory 
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
            outlinedText(math.floor(slotX * INVENTORY_SPACING + inventory.x) + 24, math.floor(slotY * INVENTORY_SPACING + inventory.y) + 10, 2, count)
        end

        setColor(255,255,255)
    end

    S.scale = lerp(S.scale,S.scaleTo,dt*20)
    S.scaleTo = 1

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
            outlinedText(xM + 74, yM + 58, 2, count)

        end

        if IN_HAND.amount == 0 then
            IN_HAND = nil
        end
    end
end

-- HOLDING STUFF

-- Play hold state
function holdItem(player,headed,item) return HOLD_MODES[item.holdMode](player,headed,item) end

-- Hold states

function MODE_HOLD(player,headed,item)
    drawSprite(ITEM_IMGES[item.texture], (player.armR.x + 9) * headed + player.collider.x, player.armR.y + player.collider.y - 9, headed)

    return item
end

HOLD_MODES = {
hold=MODE_HOLD
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
stone = love.graphics.newImage("data/images/items/stone.png"),
sword = love.graphics.newImage("data/images/items/sword.png"),
bodyArmor = love.graphics.newImage("data/images/items/bodyArmor.png")
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