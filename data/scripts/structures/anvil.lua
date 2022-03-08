CRAFTING_RECEPIES = loadJson("data/craftingRecipies.json")

function newAnvil(x, y)

    local anvil = {
        take = takeAwayMaterialsAnvil, x = x, y = y, process = processAnvil, draw = drawAnvil, open = false, slots = {}, checkCrafts = checkAnvilCrafts, onEnter = checkAnvilCrafts, scroll = 0, scrollVel = 0
    }

    for id, C in ipairs(CRAFTING_RECEPIES) do

        local slot = deepcopyTable(C); slot.scale = 1; slot.craftable = false

        for idS, S in ipairs(slot.materials) do table.insert(S, false) end

        table.insert(anvil.slots, slot)

    end

    anvil:checkCrafts()

    return anvil

end

function checkAnvilCrafts(anvil)

    for idC, C in ipairs(anvil.slots) do -- For crafts

        local materialsMet = 0

        for idM, M in ipairs(C.materials) do -- For materials

            local itemsLeft = M[2]

            for idS, S in ipairs(player.hotbar.slotIndexes) do -- For slots in inventory
                idS = S; S = player.hotbar.slots[S]

                if S.item ~= nil then -- If item exists and has the same name as the material

                    if S.item.index == M[1] then

                        itemsLeft = itemsLeft - S.item.amount -- Decrease the amount of x item that has to be met

                    end
                end

            end

            for idS, S in ipairs(player.inventory.slotIndexes) do -- For slots in hotbar
                idS = S; S = player.inventory.slots[S]

                if S.item ~= nil then -- If item exists and has the same name as the material

                    if S.item.index == M[1] then

                        itemsLeft = itemsLeft - S.item.amount -- Decrease the amount of x item that has to be met

                    end
                end

            end

            if itemsLeft <= 0 then materialsMet = materialsMet + 1; M[3] = true else M[3] = false end -- If there are enough items than the material is met

        end

        if materialsMet == #C.materials then C.craftable = true -- If all materials are met the craft is craftable, else...
        else C.craftable = false end

    end
end

function takeAwayMaterialsAnvil(anvil, slotId)

    for idM, M in ipairs(anvil.slots[slotId].materials) do -- For materials

        local itemsLeft = M[2]

        for idS, S in ipairs(player.hotbar.slotIndexes) do -- For slots in inventory
            idS = S; S = player.hotbar.slots[S]

            if S.item ~= nil then -- If item exists and has the same name as the material

                if S.item.index == M[1] then

                    S.item.amount = S.item.amount - itemsLeft

                    if S.item.amount <= 0 then -- If the slot is empty or in a minus

                        itemsLeft = math.abs(S.item.amount) -- Set the amounts
                        S.item = nil
                    else
                        itemsLeft = 0
                    end

                end
            end

        end

        for idS, S in ipairs(player.inventory.slotIndexes) do -- For slots in inventory
            idS = S; S = player.inventory.slots[S]

            if S.item ~= nil then -- If item exists and has the same name as the material

                if S.item.index == M[1] then

                    S.item.amount = S.item.amount - itemsLeft

                    if S.item.amount <= 0 then -- If the slot is empty or in a minus

                        itemsLeft = math.abs(S.item.amount) -- Set the amounts
                        S.item = nil
                    else
                        itemsLeft = 0
                    end

                end
            end

        end

    end
end

function processAnvil(anvil)

    if player.hotbar.justUpdated or player.inventory.justUpdated then

        anvil:checkCrafts()

    end

    if anvil.open then

        love.graphics.setCanvas(UI_LAYER)

        drawSprite(IMAGE_F, anvil.x + 3, anvil.y - 86 + math.sin(globalTimer * 2) * 9)

        if justPressed("f") or not (math.abs(player.collider.x - anvil.x) < 64 and math.abs(player.collider.y - anvil.y) < 64) or not player.inventoryOpen then anvil.open = false; player.inventoryOpen = false end

        anvil.scrollVel = lerp(anvil.scrollVel, 0, dt * 10)
        anvil.scrollVel = anvil.scrollVel + getScroll() * 12

        anvil.scroll = anvil.scroll + anvil.scrollVel
        anvil.scroll = lerp(anvil.scroll, clamp(anvil.scroll, clamp(- 21 - 56 * (#anvil.slots - 10), -600, 0), 0), dt * 30)

        -- Draw crafting slots
        for id, S in ipairs(anvil.slots) do
            
            local posY = 56 * id + anvil.scroll

            if posY < 624 and posY > -24 then

                setColor(255, 255 * boolToInt(S.craftable), 255 * boolToInt(S.craftable))
                drawSprite(SLOT_IMAGES["equipmentSlot"], 744, posY, S.scale, S.scale, 0, 0) -- Draw slot
                drawSprite(ITEM_IMGES[S.name], 744, posY, S.scale, S.scale, 0, 0)

                if S.amount ~= 1 then

                    outlinedText(768, posY + 5, 2, S.amount, {255,255,255}, 1, 1, 1)

                end
                
                for idMat, M in ipairs(S.materials) do -- Draw materials

                    setColor(255, 255, 255)
                    drawSprite(ITEM_IMGES[M[1]], 744 - 21 - 56 * idMat, posY, 1, 1, 0, 0)

                    outlinedText(768 - 21 - 56 * idMat, posY + 5, 2, M[2], {255, 255 * boolToInt(M[3]), 255 * boolToInt(M[3])}, 1, 1, 1)

                end

                if xM > 720 and xM < 768 and yM > posY - 24 and yM < posY + 24 then -- If hovering over slot

                    S.scale = lerp(S.scale, 1.2, dt * 20)

                    if mouseJustPressed(1) and S.craftable then -- I pressed
                        
                        S.scale = 1.4

                        -- Give the item
                        local item = ITEMS[S.name]; item.amount = S.amount

                        item = player.hotbar:addItem(item)

                        if item.amount ~= 0 then player.inventory:addItem(item) end

                        if item.amount ~= 0 then table.insert(ROOM.items, newItem(player.collider.x + 24 * (boolToInt(player.collider.x - camera[1] < xM) * 2 - 1), player.collider.y, item)) end
                        
                        -- Remove the requrements

                        anvil:take(id)

                        -- Cheeck crafts again
                        anvil:checkCrafts()
                    end

                else

                    S.scale = lerp(S.scale, 1, dt * 20)

                end
            end
        end

        love.graphics.setCanvas(display)
    else

    if  math.abs(player.collider.x - anvil.x) < 64 and math.abs(player.collider.y - anvil.y) < 64 then

        love.graphics.setCanvas(UI_LAYER)
        drawSprite(IMAGE_F, anvil.x + 3, anvil.y - 86 + math.sin(globalTimer * 2) * 9)
        love.graphics.setCanvas(display)

        if justPressed("f") then player.inventoryOpen = false; anvil.open = true; player.inventoryOpen = true; anvil.scroll = 0; anvil.scrollVel = 0 end

    end

    end
end

function drawAnvil(anvil)

    drawSprite(IMAGE_ANVIL, anvil.x, anvil.y, 1, 1, 0, 1, 0.5, 1)
    drawSprite(IMAGE_ANVIL_LANTERN, anvil.x + 64, anvil.y, 1, 1, 0, 1, 0.5, 1)

    shine(anvil.x + 52, anvil.y - 96, 400 + math.sin(globalTimer) * 12, {230,180,80,160})

end