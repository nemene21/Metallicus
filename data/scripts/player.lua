
PLAYER_HEAD = love.graphics.newImage("data/images/player/head.png")
PLAYER_BODY = love.graphics.newImage("data/images/player/body.png")
PLAYER_ARM = love.graphics.newImage("data/images/player/arm.png")
PLAYER_LEG = love.graphics.newImage("data/images/player/arm.png")

function newPlayer(x,y,stats)
    local inventory = newInventory(42,42 + INVENTORY_SPACING + 12,5,3)
    local hotbar = newInventory(42,42,5,1,"hotbarSlot")
    local wearing = newInventory(42 + INVENTORY_SPACING * 4 + 12,42 + INVENTORY_SPACING + 12,0,0)

    -- Adding slots to the equipment section
    wearing = addSlot(wearing,1,0,"headArmor","headArmor","equipmentSlot")
    wearing = addSlot(wearing,1,1,"bodyArmor","bodyArmor","equipmentSlot")
    wearing = addSlot(wearing,1,2,"shield","shield","equipmentSlot")

    wearing = addSlot(wearing,2,0,"ring","ring","equipmentSlot")
    wearing = addSlot(wearing,2,1,"ring","ring","equipmentSlot")
    wearing = addSlot(wearing,2,2,"amulet","amulet","equipmentSlot")

    return {
        vel=newVec(0,0), stats=stats, inventory=inventory, hotbar=hotbar, wearing=wearing, process=processPlayer, draw=drawPlayer, drawUI=drawPlayerUI,

        collider=newRect(x,y,30,46), justLanded = false,

        inventoryOpen=false, slotOn = 0,

        walkSoundTimer = newTimer(0.2),

        downPressedTimer=0, jumpPressedTimer=0, coyoteTime=0,

        armL=newVec(-15,15), armR=newVec(15,15), legL=newVec(-6,24), legR=newVec(6,24), body=newVec(0,9), head=newVec(0,-6),
        armLR=0,armRR=0,legLR=0,legRR=0,bodyR=0,headR=0,

        animation="idle", walkParticles=newParticleSystem(x,y,loadJson("data/particles/player/playerWalk.json")); jumpParticles=loadJson("data/particles/player/playerJump.json")
    }
end

function processPlayer(player)

    -- Movement X
    local xInput = boolToInt(pressed("d")) - boolToInt(pressed("a"))

    player.walkParticles.spawning = xInput ~= 0; player.walkParticles.x = player.collider.x; player.walkParticles.y = player.collider.y + 16

    player.vel.x = lerp(player.vel.x, xInput * 300, dt * 8)

    player.walkSoundTimer:process()
    if player.walkSoundTimer:isDone() and xInput ~= 0 and player.collider.touching.y == 1 then player.walkSoundTimer:reset(); playSound("walk", love.math.random(30, 170) * 0.01) end
    
    -- Movement Y

    player.downPressedTimer = player.downPressedTimer - dt -- Fall trough platform
    if pressed("s") then player.downPressedTimer = 0.3 end

    player.vel.y = math.min(player.vel.y + 1200 * dt,600) -- Gravity
    
    if player.downPressedTimer > 0 then player.collider = moveRect(player.collider, player.vel, ROOM.tilemap.colliders)
    else player.collider = moveRect(player.collider, player.vel, ROOM.tilemap.collidersWithFalltrough) end

    if player.collider.touching.y == -1 then player.vel.y = 0 end -- Grounded

    player.jumpPressedTimer = player.jumpPressedTimer - dt             -- Jump time
    if justPressed("space") then player.jumpPressedTimer = 0.15 end

    player.coyoteTime = player.coyoteTime - dt                             -- Coyote time
    if player.collider.touching.y == 1 then

        if player.justLanded == false then

            player.justLanded = true
            table.insert(ROOM.particleSystems,newParticleSystem(player.collider.x,player.collider.y + 16,deepcopyTable(player.jumpParticles))) -- Fall particles

            -- Move body parts due to force

            local impulse = player.vel.y / 600
            shake(4 * impulse, 1, 90)

            player.armL.y = player.armL.y + impulse * 13
            player.armR.y = player.armL.y + impulse * 13

            player.body.y = player.body.y + impulse * 13
            player.head.y = player.head.y + impulse * 13

        end

        player.coyoteTime = 0.15
        player.vel.y = 1
    
    else
        
        player.justLanded = false

    end

    if player.jumpPressedTimer > 0 and player.coyoteTime > 0 then -- Jump
        player.vel.y = -620; player.coyoteTime = 0

        table.insert(ROOM.particleSystems,newParticleSystem(player.collider.x,player.collider.y + 16,deepcopyTable(player.jumpParticles)))
    end

    -- Set animation
    if player.collider.touching.y ~= 1 then
        if player.vel.y > 0 then player.animation="fall" else player.animation="jump" end
    else
    if xInput ~= 0 then player.animation="run" else player.animation="idle" end
    end

end

function drawPlayer(player)
    
    -- Particles
    player.walkParticles:process()

    player = PLAYER_ANIMATIONS[player.animation](player)

    -- Drawing the player

    setColor(255,255,255)
    lookAt = boolToInt(xM > (player.collider.x - camera[1])) * 2 - 1

    -- LEGS
    drawSprite(PLAYER_ARM, player.collider.x + player.legL.x * lookAt, player.collider.y + player.legL.y, lookAt, 1, player.legLR)
    drawSprite(PLAYER_ARM, player.collider.x + player.legR.x * lookAt, player.collider.y + player.legR.y, lookAt, 1, player.legRR)

    -- HEAD AND BODY
    drawSprite(PLAYER_BODY, player.collider.x + player.body.x * lookAt, player.collider.y + player.body.y, lookAt, 1, player.bodyR)
    if player.wearing.slots["1,1"].item ~= nil then drawSprite(ITEM_IMGES[player.wearing.slots["1,1"].item.texture],player.collider.x + player.body.x * lookAt, player.collider.y + player.body.y, lookAt, 1, player.bodyR) end

    drawSprite(PLAYER_HEAD, player.collider.x + player.head.x * lookAt, player.collider.y + player.head.y, lookAt, 1, player.headR)
    if player.wearing.slots["1,0"].item ~= nil then drawSprite(ITEM_IMGES[player.wearing.slots["1,0"].item.texture],player.collider.x + player.head.x * lookAt, player.collider.y + player.head.y, lookAt, 1, player.headR) end

    -- ITEM IN HAND
    local holding = tostring(player.slotOn)..",0"
    local handed = 0

    if player.hotbar.slots[holding].item ~= nil then
        player.hotbar.slots[holding].item = holdItem(player,lookAt,player.hotbar.slots[holding].item)
        handed = handed + boolToInt(player.hotbar.slots[holding].item.armRTaken)
        handed = handed + boolToInt(player.hotbar.slots[holding].item.armLTaken)
    end

    -- ARMS
    if handed < 1 then drawSprite(PLAYER_ARM, player.collider.x + player.armR.x * lookAt, player.collider.y + player.armR.y, lookAt, 1, player.armRR) end
    if handed < 2 then drawSprite(PLAYER_ARM, player.collider.x + player.armL.x * lookAt, player.collider.y + player.armL.y, lookAt, 1, player.armLR) end

    -- drawCollider(player.collider)
end

function drawPlayerUI(player)
    -- Inventory and camera

    love.graphics.setCanvas(UI_LAYER)

    -- Draw hotbar
    drawInventory(player.hotbar)
    drawSprite(HOLDING_ARROW,42 + INVENTORY_SPACING * player.slotOn, 76.5 + math.sin(globalTimer * 4) * 2, 1, 1, 0, 0)

    -- Scroll

    if getScroll() ~= 0 then

        -- playSound("scroll")
        player.slotOn = wrap(player.slotOn + getScroll(), 0, 4)

    end

    -- Open / close
    if justPressed("e") then
        
        player.inventoryOpen = not player.inventoryOpen

        if not player.inventoryOpen and IN_HAND ~= nil then

            local lookAt = boolToInt(xM > (player.collider.x - camera[1])) * 2 - 1
            local item = newItem(player.collider.x + 36 * lookAt, player.collider.y, IN_HAND)

            item.vel.x = 60 * lookAt
            table.insert(ROOM.items, item)

            IN_HAND = nil
        end
    
    end

    -- Process inventory when open
    if player.inventoryOpen then
        mouseMode = "pointer"; mCentered = 0
        player.inventory = processInventory(player.inventory); drawInventory(player.inventory)
        player.wearing = processInventory(player.wearing); drawInventory(player.wearing)
        player.hotbar = processInventory(player.hotbar)

        processMouseSlot()

        -- Drop items
        if not player.inventory.hovered and not player.hotbar.hovered and not player.wearing.hovered and IN_HAND ~= nil then

            if mouseJustPressed(1) then

                local lookAt = boolToInt(xM > (player.collider.x - camera[1])) * 2 - 1
                local item = newItem(player.collider.x + 36 * lookAt, player.collider.y, IN_HAND)

                item.vel.x = 60 * lookAt
                table.insert(ROOM.items, item)

                IN_HAND = nil

            end

        end

        processTooltip(player.inventory); processTooltip(player.hotbar); processTooltip(player.wearing)

        bindCamera(player.collider.x, player.collider.y) -- Camera to the middle

    else
        mouseMode = "aimer"; mCentered = 0.5

        local zoom = 0.35
        bindCamera(clamp(player.collider.x + (xM - WS[1] * 0.5) * zoom, 200, 600), clamp(player.collider.y + (yM - WS[2] * 0.5) * zoom, 200, 500)) -- Camera to the mouse
    end

    shine(player.collider.x,player.collider.y,300 + math.sin(globalTimer * 3) * 30,{255,200,100}) -- Light

end


--                          <DO NOT, I REPEAT, DO NOT LOOK AT THIS EVER, AND WHEN I SAY EVER, I MEAN EVEEEEEEEEEEER, AGAIN!!!1111!11!!

--                                                                            ANIMATIONS

-- IDLE
function playerIdleAnimation(player)
    local armYOffset = math.sin(globalTimer * 6) * 3
    local headYOffset = math.sin(globalTimer * 6 + 0.37) * 3
    local bodyYOffset = math.sin(globalTimer * 6 + 0.75) * 2

    local lerpSpeed = 5

    -- Left arm
    player.armL.x = lerp(player.armL.x, -15, dt * lerpSpeed)
    player.armL.y = lerp(player.armL.y, 10 + armYOffset, dt * lerpSpeed)
    player.armLR = lerp(player.armLR, 0, dt * lerpSpeed)

    -- Right arm
    player.armR.x = lerp(player.armR.x, 15, dt * lerpSpeed)
    player.armR.y = lerp(player.armR.y, 10 + armYOffset, dt * lerpSpeed)
    player.armRR = lerp(player.armRR, 0, dt * lerpSpeed)

    -- Left leg
    player.legL.x = lerp(player.legL.x, -7, dt * lerpSpeed)
    player.legL.y = lerp(player.legL.y, 19, dt * lerpSpeed)
    player.legLR = lerp(player.legLR, 0, dt * lerpSpeed)

    -- Right leg
    player.legR.x = lerp(player.legR.x, 7, dt * lerpSpeed)
    player.legR.y = lerp(player.legR.y, 19, dt * lerpSpeed)
    player.legRR = lerp(player.legRR, 0, dt * lerpSpeed)

    -- Body
    player.body.x = lerp(player.body.x, 0, dt * lerpSpeed)
    player.body.y = lerp(player.body.y, 4 + headYOffset, dt * lerpSpeed)
    player.bodyR = lerp(player.bodyR, 0, dt * lerpSpeed)

    -- Head
    player.head.x = lerp(player.head.x, 0, dt * lerpSpeed)
    player.head.y = lerp(player.head.y, -11 + bodyYOffset, dt * lerpSpeed)
    player.headR = lerp(player.headR, 0, dt * lerpSpeed)

    return player
end 

-- JUMP
function playerJumpAnimation(player)
    local armYOffset = math.sin(globalTimer * 6) * 3
    local headYOffset = math.sin(globalTimer * 6 + 0.37) * 3
    local bodyYOffset = math.sin(globalTimer * 6 + 0.75) * 2

    local lerpSpeed = 5

    -- Left arm
    player.armL.x = lerp(player.armL.x, -15, dt * lerpSpeed)
    player.armL.y = lerp(player.armL.y, 10 + armYOffset, dt * lerpSpeed)
    player.armLR = lerp(player.armLR, 0, dt * lerpSpeed)

    -- Right arm
    player.armR.x = lerp(player.armR.x, 15, dt * lerpSpeed)
    player.armR.y = lerp(player.armR.y, 10 + armYOffset, dt * lerpSpeed)
    player.armRR = lerp(player.armRR, 0, dt * lerpSpeed)

    -- Left leg
    player.legL.x = lerp(player.legL.x, -7, dt * lerpSpeed)
    player.legL.y = lerp(player.legL.y + 0.5, 19, dt * lerpSpeed)
    player.legLR = lerp(player.legLR, 0, dt * lerpSpeed)

    -- Right leg
    player.legR.x = lerp(player.legR.x, 7, dt * lerpSpeed)
    player.legR.y = lerp(player.legR.y - 0.5, 19, dt * lerpSpeed)
    player.legRR = lerp(player.legRR, 0.26, dt * lerpSpeed)

    -- Body
    player.body.x = lerp(player.body.x, 0, dt * lerpSpeed)
    player.body.y = lerp(player.body.y, 4 + headYOffset, dt * lerpSpeed)
    player.bodyR = lerp(player.bodyR, 0, dt * lerpSpeed)

    -- Head
    player.head.x = lerp(player.head.x, 0, dt * lerpSpeed)
    player.head.y = lerp(player.head.y, -11 + bodyYOffset, dt * lerpSpeed)
    player.headR = lerp(player.headR, 0, dt * lerpSpeed)

    return player
end 

-- FALL
function playerFallAnimation(player)
    local headYOffset = math.sin(globalTimer * 6 + 0.37) * 3
    local bodyYOffset = math.sin(globalTimer * 6 + 0.75) * 2

    local lerpSpeed = 5

    -- Left arm
    player.armL.x = lerp(player.armL.x, -15, dt * lerpSpeed)
    player.armL.y = lerp(player.armL.y, -10, dt * 2)
    player.armLR = lerp(player.armLR, 0, dt * lerpSpeed)

    -- Right arm
    player.armR.x = lerp(player.armR.x, 15, dt * lerpSpeed)
    player.armR.y = lerp(player.armR.y, -10, dt * 2)
    player.armRR = lerp(player.armRR, 0, dt * lerpSpeed)

    -- Left leg
    player.legL.x = lerp(player.legL.x, -7, dt * lerpSpeed)
    player.legL.y = lerp(player.legL.y - 0.5, 19, dt * lerpSpeed)
    player.legLR = lerp(player.legLR, 0.26, dt * lerpSpeed)

    -- Right leg
    player.legR.x = lerp(player.legR.x, 7, dt * lerpSpeed)
    player.legR.y = lerp(player.legR.y + 0.5, 19, dt * lerpSpeed)
    player.legRR = lerp(player.legRR, 0, dt * lerpSpeed)

    -- Body
    player.body.x = lerp(player.body.x, 0, dt * lerpSpeed)
    player.body.y = lerp(player.body.y, 4 + headYOffset, dt * lerpSpeed)
    player.bodyR = lerp(player.bodyR, 0, dt * lerpSpeed)

    -- Head
    player.head.x = lerp(player.head.x, 0, dt * lerpSpeed)
    player.head.y = lerp(player.head.y, -11 + bodyYOffset, dt * lerpSpeed)
    player.headR = lerp(player.headR, 0, dt * lerpSpeed)

    return player
end 

-- RUN
function playerRunAnimation(player)
    local armLXOffset = math.sin(globalTimer * 12) * 4
    local armRXOffset = math.sin(globalTimer * 12 + 1.57) * 4

    local headYOffset = math.sin(globalTimer * 12 + 0.37) * 5

    local bodyYOffset = math.sin(globalTimer * 12 + 0.75) * 3

    local legRROffset = (math.sin(globalTimer * 12) + 1) * 0.5 * 0.7
    local legLROffset = (math.sin(globalTimer * 12) + 1) * 0.5 * -0.7

    local legLYOffset = math.cos(globalTimer * 12) * 5
    local legRYOffset = math.cos(globalTimer * 12 + 3.14) * 5

    local lerpSpeed = 15

    -- Left arm
    player.armL.x = lerp(player.armL.x, -15 + armLXOffset, dt * lerpSpeed)
    player.armL.y = lerp(player.armL.y, 10, dt * lerpSpeed)
    player.armLR = lerp(player.armLR, 0, dt * lerpSpeed)

    -- Right arm
    player.armR.x = lerp(player.armR.x, 15 + armRXOffset, dt * lerpSpeed)
    player.armR.y = lerp(player.armR.y, 10, dt * lerpSpeed)
    player.armRR = lerp(player.armRR, 0, dt * lerpSpeed)

    -- Left leg
    player.legL.x = lerp(player.legL.x, -7, dt * lerpSpeed)
    player.legL.y = lerp(player.legL.y, 19 + legLYOffset, dt * lerpSpeed)
    player.legLR = lerp(player.legLR, legLROffset, dt * 25)

    -- Right leg
    player.legR.x = lerp(player.legR.x, 7, dt * lerpSpeed)
    player.legR.y = lerp(player.legR.y, 19 + legRYOffset, dt * lerpSpeed)
    player.legRR = lerp(player.legRR, legRROffset, dt * 25)

    -- Body
    player.body.x = lerp(player.body.x, 0, dt * lerpSpeed)
    player.body.y = lerp(player.body.y, 4 + bodyYOffset, dt * lerpSpeed)
    player.bodyR = lerp(player.bodyR, 0, dt * lerpSpeed)

    -- Head
    player.head.x = lerp(player.head.x, 0, dt * lerpSpeed)
    player.head.y = lerp(player.head.y, -11 + headYOffset, dt * lerpSpeed)
    player.headR = lerp(player.headR, 0, dt * lerpSpeed)

    return player
end 

PLAYER_ANIMATIONS = {
idle=playerIdleAnimation, run=playerRunAnimation, jump=playerJumpAnimation, fall=playerFallAnimation
}