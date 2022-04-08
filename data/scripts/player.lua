
PLAYER_HEAD = love.graphics.newImage("data/images/player/head.png")
PLAYER_BODY = love.graphics.newImage("data/images/player/body.png")
PLAYER_ARM = love.graphics.newImage("data/images/player/arm.png")
PLAYER_LEG = love.graphics.newImage("data/images/player/arm.png")

PLAYER_DEAD = love.graphics.newImage("data/images/player/playerDie.png")

PARTICLES_DIE_SPARK = loadJson("data/particles/player/playerDieSparkParticles.json")
PARTICLES_DIE_CIRCLE = loadJson("data/particles/player/playerDieCircleParticles.json")

HP_BAR = love.graphics.newImage("data/images/UI/hpBar.png")

function newPlayer(x,y,stats)

    local inventory = newInventory(42,600 - INVENTORY_SPACING - 154,5,3)
    local hotbar = newInventory(42,600 - 42,5,1,"hotbarSlot")
    local wearing = newInventory(42 + INVENTORY_SPACING * 4 + 2,600 - INVENTORY_SPACING - 154,0,0)
    
    local startingWeapon = deepcopyTable(ITEMS["steelDagger"]); startingWeapon.amount = 1
    hotbar:addItem(startingWeapon)

    local startingWeapon = deepcopyTable(ITEMS["quiver"]); startingWeapon.amount = 1
    hotbar:addItem(startingWeapon)

    local startingWeapon = deepcopyTable(ITEMS["goldenHelmet"]); startingWeapon.amount = 1
    hotbar:addItem(startingWeapon)
    
    -- Adding slots to the equipment section
    wearing = addSlot(wearing,1,0,"headArmor","headArmor","equipmentSlot")
    wearing = addSlot(wearing,1,1,"bodyArmor","bodyArmor","equipmentSlot")
    wearing = addSlot(wearing,1,2,"activeItem","shield","equipmentSlot")

    wearing = addSlot(wearing,2,0,"ring","ring","equipmentSlot")
    wearing = addSlot(wearing,2,1,"ring","ring","equipmentSlot")
    wearing = addSlot(wearing,2,2,"amulet","amulet","equipmentSlot")

    local player = {
        vel=newVec(0, 0), knockback = newVec(0, 0), stats=stats, inventory=inventory, hotbar=hotbar, wearing=wearing, process=processPlayer, say=sayPlayer, draw=drawPlayer, drawUI=drawPlayerUI, resetStats = resetPlayerStats,

        collider=newRect(x,y,30,46), justLanded = false,

        inventoryOpen=false, slotOn = 1,

        hasActiveItem=false, activeItemOffset=0, activeItemAppear=0,
        
        text = "", lettersLoaded = "", letterTimer = 0, speakTimer = 0, textFadeTimer = 0, textPriority = 0, textPos = newVec(0, 0),

        walkSoundTimer = newTimer(0.2), speed = 300, float = 0, floatParticles = newParticleSystem(x, y, loadJson("data/particles/player/playerFly.json")),
 
        dashingFrames = 0, dashForce = 0, dashTimer = 0, dashJustRecharged = 1, dashSpeed = 700, dashInputTimer = 0,

        lastJoystickMousePos = newVec(0, 0), lastInventoryJoystickMousePos = newVec(0, 0), lastInventoryJoystickMousePosLerp = newVec(INVENTORY_SPACING * 0.5 + 12, 600 - 0.5 * INVENTORY_SPACING - 12),

        iFrames = 0,
        
        damageReduction = 0, magicDamage = 0,

        hp = 100, hpMax = 100, hpBarDelayed = 0,

        downPressedTimer=0, jumpPressedTimer=0, coyoteTime=0, canCutJump = false,

        armL=newVec(-15,15), armR=newVec(15,15), legL=newVec(-6,24), legR=newVec(6,24), body=newVec(0,9), head=newVec(0,-6),
        armLR=0,armRR=0,legLR=0,legRR=0,bodyR=0,headR=0,

        bonusForce = newVec(0, 0), flyMode = false,

        animation="idle", dashParticles=newParticleSystem(x,y,loadJson("data/particles/player/playerDash.json")), walkParticles=newParticleSystem(x,y,loadJson("data/particles/player/playerWalk.json")); jumpParticles=loadJson("data/particles/player/playerJump.json"),
        
        hit = hitPlayer
    }

    return player
end

function hitPlayer(player, damage, knockback)

    if player.iFrames == 0 and player.dashingFrames == 0 and not playerDied then

        local knockback = knockback or newVec(0, 0)
        player.knockback.x = player.knockback.x + knockback.x
        player.knockback.y = player.knockback.y + knockback.y

        player.iFrames = 1

        ROOM.playerTookHits = (ROOM.playerTookHits or 0) + 1

        damage = math.floor(damage * (1 - player.damageReduction * 0.01))

        player.hp = player.hp - damage

        table.insert(ROOM.textPopUps.particles,{
            x = player.collider.x + love.math.random(-12, 12), y = player.collider.y + love.math.random(-12, 12),
            vel = newVec(0, -100), width = tostring(damage),
            lifetime = 1, lifetimeStart = 1,
            color = {r=255,g=0,b=0,a=1},
            rotation = 0

        })

        return true
    else
        return false
    end

end

function processPlayer(player)

    player.knockback.x = lerp(player.knockback.x, 0, dt * 3)
    player.knockback.y = lerp(player.knockback.y, 0, dt * 3)

    -- Update stats
    for id, S in pairs(player.wearing.slots) do

        if S.item ~= nil then
            if S.item.stats ~= nil then
                player.damageReduction = player.damageReduction + (S.item.stats.def or 0)
                player.magicDamage = player.magicDamage + (S.item.stats.mag or 0)
            end
        end
    end

    player.hp = clamp(player.hp, 0, player.hpMax)

    -- Particles
    
    player.floatParticles.x = player.collider.x; player.floatParticles.y = player.collider.y
    player.floatParticles:process()

    player.walkParticles:process()

    player.dashParticles.x = player.collider.x; player.dashParticles.y = player.collider.y
    player.dashParticles.spawning = player.dashingFrames > 0
    player.dashParticles:process()

    player.iFrames = clamp(player.iFrames - dt, 0, 1)

    -- Controller mouse
    local mouseJoyAxis = joystickGetAxis(1, 2)

    if not player.inventoryOpen then
        if mouseJoyAxis.x ~= 0 and mouseJoyAxis.y ~= 0 then

            xM = player.lastJoystickMousePos.x; yM = player.lastJoystickMousePos.y

            if mouseJoyAxis:getLen() > 0.65 then

                local mouseOffset = newVec(200, 0):rotate(mouseJoyAxis:getRot())
                xM = player.collider.x - camera[1] + mouseOffset.x
                yM = player.collider.y - camera[2] + mouseOffset.y

                player.lastJoystickMousePos = newVec(xM, yM)

            end

        end

    end

    -- Movement X
    local moveJoyAxis = joystickGetAxis(1, 1)
    local joyMoveX = 0

    local joyMoveXExists = moveJoyAxis ~= nil

    local xInput = 0

    if joyMoveXExists then
        local joyMoveX = moveJoyAxis.x

        if math.abs(joyMoveX) < 0.15 then

            xInput = boolToInt(pressed("d")) - boolToInt(pressed("a"))
        else

            xInput = boolToInt(joyMoveX > 0) * 2 - 1

        end
    
    else

        xInput = boolToInt(pressed("d")) - boolToInt(pressed("a"))

    end

    xInput = xInput * (1 - boolToInt(player.dashingFrames > 0)) * boolToInt(not debugLineOpen)

    player.walkParticles.spawning = xInput ~= 0; player.walkParticles.x = player.collider.x; player.walkParticles.y = player.collider.y + 16

    player.vel.x = lerp(player.vel.x, xInput * player.speed, dt * 8)



    player.walkSoundTimer:process() -- Walking sound
    if player.walkSoundTimer:isDone() and xInput ~= 0 and player.collider.touching.y == 1 then player.walkSoundTimer:reset(); playSound("walk", love.math.random(30, 170) * 0.01) end
    


    player.dashingFrames = clamp(player.dashingFrames - dt, 0, 1) -- Dashing
    player.dashTimer = clamp(player.dashTimer - dt, 0, 1)
    player.dashInputTimer = player.dashInputTimer - dt

    if mouseJustPressed(2) or joystickJustPressed(1, 8) then player.dashInputTimer = 0.3 end

    if player.dashInputTimer > 0 and player.dashTimer == 0 and xInput ~= 0 then

        player.dashingFrames = 0.2

        player.dashTimer = 1

        player.dashForce = xInput * player.dashSpeed

        player.dashParticles.rotation = 180 * boolToInt(xInput > 0)

        player.dashJustRecharged = 0

    end

    if player.dashingFrames == 0 then -- Slow down dash

        player.dashForce = lerp(player.dashForce, 0, dt * 20)

    else

        player.vel.y = 0

        if player.collider.touching.x == clamp(player.dashForce, -1, 1) then player.dashingFrames = 0 end

    end
    
    -- Movement Y

    player.float = player.float - dt

    local flying = player.flyMode or (player.float > 0)

    player.floatParticles.spawning = flying

    if flying then

        local yInput = boolToInt(pressed("s") and not debugLineOpen) - boolToInt(pressed("w") and not debugLineOpen)
        player.vel.y = lerp(player.vel.y, yInput * 300, dt * 8)

    end

    player.downPressedTimer = player.downPressedTimer - dt -- Fall trough platform
    if (pressed("s") or moveJoyAxis.y > 0.8) and not debugLineOpen then player.downPressedTimer = 0.3 end

    player.vel.y = math.min(player.vel.y + 1200 * dt * boolToInt(not flying),600) -- Gravity
    
    if player.collider.touching.y == -1 then player.vel.y = player.vel.y * boolToInt(flying); player.canCutJump = false end -- Grounded

    player.jumpPressedTimer = player.jumpPressedTimer - dt             -- Jump time

    local jumpPressed = justPressed("space") or justPressedTrigger[1] and not player.inventoryOpen
    if jumpPressed and not debugLineOpen and not flying then player.jumpPressedTimer = 0.15 end

    if player.vel.y > 0 then player.canCutJump = false end

    player.coyoteTime = player.coyoteTime - dt                             -- Coyote time
    if player.collider.touching.y == 1 and not flying then
        player.canCutJump = false

        if player.justLanded == false then

            local impulse = player.vel.y / 600

            --playSound("fall", love.math.random(80, 120) * 0.01, None, impulse)

            player.justLanded = true
            if impulse > 0.1 then table.insert(ROOM.particleSystems,newParticleSystem(player.collider.x,player.collider.y + 16,deepcopyTable(player.jumpParticles))) end -- Fall particles

            -- Move body parts due to force
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

        player.canCutJump = true; playSound("jump", love.math.random(80, 120) * 0.01)

        table.insert(ROOM.particleSystems,newParticleSystem(player.collider.x,player.collider.y + 16,deepcopyTable(player.jumpParticles)))
    end

    if not (pressed("space") or (joystickGetAxis(1, 3).x > 0.4)) and not debugLineOpen and player.canCutJump and player.vel.y < 0 then player.vel.y = player.vel.y * 0.5; player.canCutJump = false end


    -- Move rect

    local velocity = newVec(player.vel.x + player.bonusForce.x + player.dashForce + player.knockback.x, player.vel.y + player.bonusForce.y + player.knockback.x)

    if player.downPressedTimer > 0 then player.collider = moveRect(player.collider, velocity, ROOM.tilemap.colliders)
    else player.collider = moveRect(player.collider, velocity, ROOM.tilemap.collidersWithFalltrough) end

    if player.collider.touching.x ~= 0 then player.knockback.x = -0.8 * player.knockback.x end
    if player.collider.touching.y ~= 0 then player.knockback.y = -0.8 * player.knockback.y end

    -- Set animation
    if player.collider.touching.y ~= 1 or flymode then
        if player.vel.y > 0 then player.animation="fall" else player.animation="jump" end
    else
    if xInput ~= 0 then player.animation="run" else player.animation="idle" end
    end

    SHADERS.GLOW_AND_LIGHT:send("hurtVignetteIntensity", clamp(player.iFrames - 0.75, 0, 1) * 3)

end




function drawPlayer(player)
    shine(player.collider.x,player.collider.y,300 + math.sin(globalTimer * 3) * 30,{255,200,100,90}) -- Light

    love.graphics.setCanvas(display)

    player = PLAYER_ANIMATIONS[player.animation](player)

    -- Drawing the player

    if player.dashTimer == 0 and player.dashJustRecharged < 0.1 then -- Flash at the dash recharge
        player.dashJustRecharged = player.dashJustRecharged + dt

        if player.iFrames == 0 then SHADERS.FLASH:send("intensity", 1); love.graphics.setShader(SHADERS.FLASH) end

    end

    if player.dashingFrames > 0 then
        local intensity = player.dashingFrames / 0.2
        SHADERS.FLASH:send("intensity", intensity * intensity); love.graphics.setShader(SHADERS.FLASH)
    end

    setColor(255,255,255, 255 * (1 - math.abs(math.sin(3.14 * player.iFrames * 5))))
    local lookAt = boolToInt(xM > (player.collider.x - camera[1])) * 2 - 1

    -- LEGS
    drawSprite(PLAYER_ARM, player.collider.x + player.legL.x * lookAt, player.collider.y + player.legL.y, lookAt, 1, player.legLR)
    drawSprite(PLAYER_ARM, player.collider.x + player.legR.x * lookAt, player.collider.y + player.legR.y, lookAt, 1, player.legRR)

    -- HEAD AND BODY
    drawSprite(PLAYER_BODY, player.collider.x + player.body.x * lookAt, player.collider.y + player.body.y, lookAt, 1, player.bodyR)
    if player.wearing.slots["1,1"].item ~= nil then drawSprite(ITEM_IMGES[player.wearing.slots["1,1"].item.texture],player.collider.x + player.body.x * lookAt + (player.wearing.slots["1,1"].item.xOffset or 0) * lookAt, player.collider.y + player.body.y + (player.wearing.slots["1,1"].item.yOffset or 0), lookAt, 1, player.bodyR) end

    drawSprite(PLAYER_HEAD, player.collider.x + player.head.x * lookAt, player.collider.y + player.head.y, lookAt, 1, player.headR)
    if player.wearing.slots["1,0"].item ~= nil then drawSprite(ITEM_IMGES[player.wearing.slots["1,0"].item.texture],player.collider.x + player.head.x * lookAt + (player.wearing.slots["1,0"].item.xOffset or 0) * lookAt, player.collider.y + player.head.y + (player.wearing.slots["1,0"].item.yOffset or 0), lookAt, 1, player.headR) end

    -- ITEM IN HAND
    local holding = tostring(player.slotOn)..",0"
    local handed = 0

    local inHandItem = player.hotbar.slots[holding].item

    if inHandItem ~= nil then
        handed = handed + boolToInt(inHandItem.armRTaken)
        handed = handed + boolToInt(inHandItem.armLTaken)
        inHandItem = holdItem(player,lookAt,inHandItem)

        if inHandItem.holdData ~= nil then if inHandItem.holdData.attackTimer ~= nil then
            
            attackMouseLine = inHandItem.holdData.attackTimer / inHandItem.stats.attackTime

        end end
    end

    -- ARMS
    if handed < 1 then drawSprite(PLAYER_ARM, player.collider.x + player.armR.x * lookAt, player.collider.y + player.armR.y, lookAt, 1, player.armRR) end
    if handed < 2 then drawSprite(PLAYER_ARM, player.collider.x + player.armL.x * lookAt, player.collider.y + player.armL.y, lookAt, 1, player.armLR) end

    love.graphics.setShader()

    -- drawCollider(player.collider)
end





function resetPlayerStats(player)

    -- Update stats
    for id, S in pairs(player.wearing.slots) do

        if S.item ~= nil then
            if S.item.stats ~= nil then
                player.damageReduction = player.damageReduction - (S.item.stats.def or 0)
                player.magicDamage = player.magicDamage - (S.item.stats.mag or 0)
            end
        end
    end

end




function sayPlayer(player, text, priority)

    if player.textPriority < (priority or 1) then
        player.textPriority = priority or 1

        player.text = text
        player.speakTimer = #splitString(text) * 1.6
        player.lettersLoaded = ""
        player.letterTimer = 0
        player.textFadeTimer = 0
    end

end

function drawPlayerUI(player)

    love.graphics.setCanvas(UI_LAYER)
    -- Player talking

    player.speakTimer = player.speakTimer - dt
    if player.speakTimer < 0 then

        player.textFadeTimer = player.textFadeTimer - dt * 6
    else

        player.textFadeTimer = clamp(player.textFadeTimer + dt * 6, 0, 1)

        player.textPriority = 0

    end

    player.textPos.x = lerp(player.textPos.x, player.collider.x - camera[1], dt * 6)
    player.textPos.y = lerp(player.textPos.y, player.collider.y - 80 - camera[2], dt * 6)

    player.letterTimer = player.letterTimer + dt * 20
    if player.text ~= "" then

        if #player.lettersLoaded < player.letterTimer and #player.text ~= #player.lettersLoaded then

            player.lettersLoaded = player.text:sub(1, round(player.letterTimer))

        end

        local offset = 6
        local w = FONT:getWidth(player.text) + offset * 2; local h = FONT:getHeight(player.text) + offset * 2

        setColor(0, 0, 0, 255 * player.textFadeTimer)
        love.graphics.rectangle("fill", player.textPos.x, player.textPos.y, w, h, 8, 8)

        love.graphics.circle("fill", player.textPos.x + 18, player.textPos.y + 30, 12 + math.sin(globalTimer * 4 + 1.14))
        love.graphics.circle("fill", player.textPos.x + 8, player.textPos.y + 50, 6 + math.sin(globalTimer * 4) * 2)
        
        normalText(player.textPos.x + offset, player.textPos.y + offset, player.lettersLoaded, {255, 255, 255, 255 * player.textFadeTimer}, 1, 1, 0, 0)

        setColor(255, 255, 255)

    end

    -- Inventory and camera

    -- Draw hotbar
    setColor(255, 255, 255)
    drawSprite(HOLDING_ARROW, 42 + INVENTORY_SPACING * player.slotOn, 558, 1, 1, 0, 0)
    drawInventory(player.hotbar)

    -- Draw active item

    local activeItemSlot = player.wearing.slots["1,2"]
    if activeItemSlot ~= nil then
        local activeItem = activeItemSlot.item

        if activeItem ~= nil then

            local process = ACTIVE_ITEM_PROCESSES[activeItem.effectProcess or "NONE"]
            if process ~= nil then

                process(activeItem)

            end

            if player.hasActiveItem == false then

                player.hasActiveItem = true

                activeItem.charge = 0; player.activeItemAppear = 0

            end

            if justPressed("lshift") and activeItem.charge == 1 and activeItem.noChargeTimer < 0 then

                activeItem.charge = 0
                ACTIVE_ITEM_EFFECTS[activeItem.effect](activeItem)
                activeItem.noChargeTimer = activeItem.noChargeTimerMax

            end

            player.activeItemAppear = lerp(player.activeItemAppear, 1, dt * 6)

            setColor(255, 255, 255)

            activeItem.flashTimer = clamp(activeItem.flashTimer - dt * 4, 0, 1)

            if activeItem.charge == 1 and not activeItem.alreadyActivated then activeItem.alreadyActivated = true; activeItem.flashTimer = 1 end -- Activate animation

            if activeItem.charge < 1 then activeItem.alreadyActivated = false end

            drawSprite(ITEM_IMGES[activeItem.texture], 730 + player.activeItemOffset, 530, 3 + 0.25 * math.sin(globalTimer * 2 + 1) + activeItem.flashTimer + (1 - player.activeItemAppear), (3 + 0.25 * math.sin(globalTimer * 2 + 2) + activeItem.flashTimer) * player.activeItemAppear, math.sin(globalTimer * 2) * 0.2, 0)
            
            love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", 1)
            drawSprite(ITEM_IMGES[activeItem.texture], 730 + player.activeItemOffset - 3, 530 - 3, 3 + 0.25 * math.sin(globalTimer * 2 + 1) + activeItem.flashTimer + (1 - player.activeItemAppear), (3 + 0.25 * math.sin(globalTimer * 2 + 2) + activeItem.flashTimer) * player.activeItemAppear, math.sin(globalTimer * 2) * 0.2, 0)
            drawSprite(ITEM_IMGES[activeItem.texture], 730 + player.activeItemOffset - 3, 530 + 3, 3 + 0.25 * math.sin(globalTimer * 2 + 1) + activeItem.flashTimer + (1 - player.activeItemAppear), (3 + 0.25 * math.sin(globalTimer * 2 + 2) + activeItem.flashTimer) * player.activeItemAppear, math.sin(globalTimer * 2) * 0.2, 0)
            drawSprite(ITEM_IMGES[activeItem.texture], 730 + player.activeItemOffset + 3, 530 - 3, 3 + 0.25 * math.sin(globalTimer * 2 + 1) + activeItem.flashTimer + (1 - player.activeItemAppear), (3 + 0.25 * math.sin(globalTimer * 2 + 2) + activeItem.flashTimer) * player.activeItemAppear, math.sin(globalTimer * 2) * 0.2, 0)
            drawSprite(ITEM_IMGES[activeItem.texture], 730 + player.activeItemOffset + 3, 530 + 3, 3 + 0.25 * math.sin(globalTimer * 2 + 1) + activeItem.flashTimer + (1 - player.activeItemAppear), (3 + 0.25 * math.sin(globalTimer * 2 + 2) + activeItem.flashTimer) * player.activeItemAppear, math.sin(globalTimer * 2) * 0.2, 0)
            
            if activeItem.flashTimer > 0.2 then

                love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", 1)

            else

                SHADERS.ACTIVE_ITEM:send("ratio", 1 - activeItem.charge); love.graphics.setShader(SHADERS.ACTIVE_ITEM)
                
                if activeItem.noChargeTimer >= 0 then

                    activeItem.noChargeTimer = activeItem.noChargeTimer - dt

                    activeItem.charge = 0
                    setColor(100, 100, 100)
                    SHADERS.ACTIVE_ITEM:send("ratio", 1 - activeItem.noChargeTimer / activeItem.noChargeTimerMax); love.graphics.setShader(SHADERS.ACTIVE_ITEM)

                end
            
            end
            drawSprite(ITEM_IMGES[activeItem.texture], 730 + player.activeItemOffset, 530, 3 + 0.25 * math.sin(globalTimer * 2 + 1) + activeItem.flashTimer + (1 - player.activeItemAppear), (3 + 0.25 * math.sin(globalTimer * 2 + 2) + activeItem.flashTimer) * player.activeItemAppear, math.sin(globalTimer * 2) * 0.2, 0)
            love.graphics.setShader()

        else

            player.hasActiveItem = false

        end

    end

    player.activeItemOffset = lerp(player.activeItemOffset, 0, dt * 2)
    
    -- Draw hp bar
    local barLenght = 186 * player.hp / player.hpMax

    if barLenght > player.hpBarDelayed then player.hpBarDelayed = barLenght
    else if player.iFrames == 0 then player.hpBarDelayed = lerp(player.hpBarDelayed, barLenght, dt * 10) end end

    setColor(255, 255, 255)
    love.graphics.rectangle("fill", 7, 7, player.hpBarDelayed, 42)

    setColor(200, 40, 40)
    love.graphics.rectangle("fill", 7, 7, barLenght, 42)
    setColor(255, 255, 255)
    drawSprite(HP_BAR, 4, 4, 1, 1, 0, 0, 0, 0)

    outlinedText(12 + 10 * math.sin(3.14 * player.iFrames), 28, 2, tostring(player.hp).."/"..tostring(player.hpMax), {255, 255, 255}, 1.25, 1.25, 0, 0.5)

    -- Scroll
    local joystickScroll = boolToInt(joystickJustPressed(1, 10)) - boolToInt(joystickJustPressed(1, 11))

    local scrolling = getScroll() ~= 0 or joystickScroll ~= 0

    if scrolling and not player.inventoryOpen then

        player.slotOn = wrap(player.slotOn - getScroll(), 0, 4)
        player.slotOn = wrap(player.slotOn - joystickScroll, 0, 4)

        local holding = tostring(player.slotOn)..",0"

        if player.hotbar.slots[holding].item ~= nil then

            if player.hotbar.slots[holding].item.holdData ~= nil then

                -- Reset weapon cooldown and animation
                if player.hotbar.slots[holding].item.holdData.attackTimer ~= nil then player.hotbar.slots[holding].item.holdData.attackTimer = player.hotbar.slots[holding].item.stats.attackTime end

                if player.hotbar.slots[holding].item.holdData.rotation ~= nil then player.hotbar.slots[holding].item.holdData.rotation = player.hotbar.slots[holding].item.holdData.rotateTo end

                if player.hotbar.slots[holding].item.holdData.spriteRotation ~= nil then player.hotbar.slots[holding].item.holdData.spriteRotation = player.hotbar.slots[holding].item.holdData.spriteRotateTo end

            end

        end

    end

    -- Open / close
    if (justPressed("e") or joystickJustPressed(1, 4)) and not debugLineOpen then
        
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

        if JOYSTICKS[1] ~= nil then
            player.lastInventoryJoystickMousePos.x = lerp(player.lastInventoryJoystickMousePos.x, player.lastInventoryJoystickMousePosLerp.x, dt * 10)
            player.lastInventoryJoystickMousePos.y = lerp(player.lastInventoryJoystickMousePos.y, player.lastInventoryJoystickMousePosLerp.y, dt * 10)

            if joystickJustPressed(1, 12) then player.lastInventoryJoystickMousePosLerp.y = player.lastInventoryJoystickMousePosLerp.y - INVENTORY_SPACING end
            if joystickJustPressed(1, 13) then player.lastInventoryJoystickMousePosLerp.y = player.lastInventoryJoystickMousePosLerp.y + INVENTORY_SPACING end
            if joystickJustPressed(1, 14) then player.lastInventoryJoystickMousePosLerp.x = player.lastInventoryJoystickMousePosLerp.x - INVENTORY_SPACING end
            if joystickJustPressed(1, 15) then player.lastInventoryJoystickMousePosLerp.x = player.lastInventoryJoystickMousePosLerp.x + INVENTORY_SPACING end

            if JOYSTICKS[1] ~= nil then

                xM = player.lastInventoryJoystickMousePos.x; yM = player.lastInventoryJoystickMousePos.y

            end
        end

        mouseMode = "pointer"; mCentered = 0

        local hoveredSlot = nil
        player.inventory, hoveredSlot = processInventory(player.inventory); drawInventory(player.inventory)

        player.wearing, hold = processInventory(player.wearing); drawInventory(player.wearing)
        hoveredSlot = hoveredSlot or hold

        player.hotbar, hold = processInventory(player.hotbar)
        hoveredSlot = hoveredSlot or hold

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

        bindCamera(clamp(player.collider.x, ROOM.endLeft.x + 400 - cameraWallOffset, ROOM.endRight.x - 400 + cameraWallOffset), clamp(player.collider.y, ROOM.endUp.y + 300 - cameraWallOffset, ROOM.endDown.y - 300 + cameraWallOffset)) -- Camera to the mouse

    else
        mouseMode = "aimer"; mCentered = 0.5

        local zoom = 0.35
        bindCamera(clamp(player.collider.x + (xM - WS[1] * 0.5) * zoom, ROOM.endLeft.x + 400 - cameraWallOffset, ROOM.endRight.x - 400 + cameraWallOffset), clamp(player.collider.y + (yM - WS[2] * 0.5) * zoom, ROOM.endUp.y + 300 - cameraWallOffset, ROOM.endDown.y - 300 + cameraWallOffset)) -- Camera to the mouse
    end

    love.graphics.setCanvas(display)
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