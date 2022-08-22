
BREWER_IMAGE = love.graphics.newImage("data/images/structures/brewer.png")

BREWER_RECIPES = loadJson("data/brewingRecpies.json")

BREWER_ARROW_DONE = love.graphics.newImage("data/images/UI/brewerArrow.png")

function newBrewer(x, y)

    local brewer = {
        x = x, y = y, process = processBrewer, draw = drawBrewer, open = false,

        inventory = newInventory(504, 64, 0, 0),

        brewAnimation = 0,
        brewTimer = 3,

        lastValidRecipe = 0,
        validRecipe = false
    }

    brewer.inventory = addSlot(brewer.inventory, 2, 0, "burnable", "brewerFuel", "equipmentSlot")

    brewer.inventory = addSlot(brewer.inventory, 0, 2, "item")
    brewer.inventory = addSlot(brewer.inventory, 4, 2, "item")

    brewer.inventory = addSlot(brewer.inventory, 2, 4, "bowl", "brewerBowl")

    return brewer

end

function processBrewer(brewer)

    if brewer.open then

        love.graphics.setCanvas(UI_LAYER)

        drawInteract(brewer.x + 3, brewer.y - 86)

        if justPressed("f") or not (math.abs(player.collider.x - brewer.x) < 64 and math.abs(player.collider.y - brewer.y) < 64) or not player.inventoryOpen then brewer.open = false; player.inventoryOpen = false end
        
        brewer.inventory = processInventory(brewer.inventory)
        drawInventory(brewer.inventory)

        love.graphics.setShader(SHADERS.BREWING_ARROWS); SHADERS.BREWING_ARROWS:send("progress", 1 - brewer.brewTimer / 3)
        drawSprite(BREWER_ARROW_DONE, 550, 240, 1, 1, 3.14 * 0.25, 0)
        drawSprite(BREWER_ARROW_DONE, 684, 240, 1, 1, 3.14 - 3.14 * 0.25, 0)
        love.graphics.setShader()

        love.graphics.setCanvas(display)

    else

        if  math.abs(player.collider.x - brewer.x) < 64 and math.abs(player.collider.y - brewer.y) < 64 then

            love.graphics.setCanvas(UI_LAYER)
            drawInteract(brewer.x + 3, brewer.y - 86)
            love.graphics.setCanvas(display)

            if justPressed("f") then player.inventoryOpen = false; brewer.open = true; player.inventoryOpen = true; brewer.scroll = 0; brewer.scrollVel = 0 end

        end

    end

    local itemA = brewer.inventory.slots["0,2"].item
    local itemB = brewer.inventory.slots["4,2"].item

    local anythingValid = false

    if itemA ~= nil and itemB ~= nil then -- Ingredient slots filled?

        for id, recipe in ipairs(BREWER_RECIPES) do

            local valid = recipe.a == itemA.index and recipe.b == itemB.index -- Valid recipe?

            valid = valid or recipe.a == itemB.index and recipe.b == itemA.index

            valid = valid and (itemA.amount > 0 and itemB.amount > 0)

            if valid then -- Set the valid recipe

                anythingValid = true

                brewer.lastValidRecipe = recipe

                if not brewer.validRecipe then
                    
                    brewer.validRecipe = true
                    
                    brewer.brewTimer = 3
                
                end

            end

        end

    end

    if not anythingValid then brewer.validRecipe = false end -- Reset valid recipe if there is no valid recipe

    local fuelItem = brewer.inventory.slots["2,0"].item
    local bowlItem = brewer.inventory.slots["2,4"].item

    if brewer.validRecipe then

        if fuelItem ~= nil and bowlItem ~= nil then -- Is there fuel and is there a bowl?

            if fuelItem.amount > 0 and bowlItem.amount > 0 and bowlItem.index == "bowl" then

                brewer.brewTimer = brewer.brewTimer - dt

                if brewer.brewTimer < 0 then -- Something brewed

                    fuelItem.amount = fuelItem.amount - 1
                    bowlItem.amount = bowlItem.amount - 1

                    brewer.brewTimer = 3

                    brewer.brewAnimation = 0.4

                    local item = deepcopyTable(ITEMS[brewer.lastValidRecipe.name])

                    itemA.amount = itemA.amount - 1
                    itemB.amount = itemB.amount - 1

                    item.amount = brewer.lastValidRecipe.amount

                    item = newItem(brewer.x, brewer.y - 56, item)

                    item.vel.x = love.math.random(-50, 50)
                    item.vel.y = - 400

                    table.insert(ROOM.items, item)

                    local particleData = deepcopyTable(PARTICLES_ENEMY_HIT)
                    particleData.rotation = 0
                
                    table.insert(ROOM.particleSystems, newParticleSystem(item.pos.x, item.pos.y, particleData))

                end

            end

        end

    end

end

function drawBrewer(brewer)

    brewer.brewAnimation = lerp(brewer.brewAnimation, 0, dt * 4)

    local scaleOffset = math.sin(globalTimer * 12) * 0.1 * boolToInt(brewer.brewTimer < 3)

    drawSprite(BREWER_IMAGE, brewer.x, brewer.y, 1 - brewer.brewAnimation + scaleOffset, 1 + brewer.brewAnimation - scaleOffset, math.sin(globalTimer * 8) * 0.1 * boolToInt(brewer.brewTimer < 3), 1, 0.5, 1)

end