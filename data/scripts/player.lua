
PLAYER_HEAD = love.graphics.newImage("data/images/player/head.png")
PLAYER_BODY = love.graphics.newImage("data/images/player/body.png")
PLAYER_ARM = love.graphics.newImage("data/images/player/arm.png")
PLAYER_LEG = love.graphics.newImage("data/images/player/arm.png")

function newPlayer(x,y,stats)
    local inventory = newInventory(42,120,5,3)
    local hotbar = newInventory(42,42,5,1,"hotbarSlot")
    local wearing = newInventory(312,120,0,0)

    -- Adding slots to the equipment section
    wearing = addSlot(wearing,1,0,"headArmor","headArmor","equipmentSlot")
    wearing = addSlot(wearing,1,1,"bodyArmor","bodyArmor","equipmentSlot")
    wearing = addSlot(wearing,1,2,"shield","shield","equipmentSlot")

    wearing = addSlot(wearing,2,0,"ring","ring","equipmentSlot")
    wearing = addSlot(wearing,2,1,"ring","ring","equipmentSlot")
    wearing = addSlot(wearing,2,2,"amulet","amulet","equipmentSlot")

    return {
        vel=newVec(0,0), stats=stats, inventory=inventory, hotbar=hotbar, wearing=wearing, process=processPlayer,

        collider=newRect(x,y,40,46),

        inventoryOpen=false, slotOn = 0,

        armL=newVec(-15,15), armR=newVec(15,15), legL=newVec(-6,24), legR=newVec(6,24), body=newVec(0,9), head=newVec(0,-6),
        armLR=0,armRR=0,legLR=0,legRR=0,bodyR=0,headR=0,

        animation="idle", walkParticles=newParticleSystem(x,y,loadJson("data/particles/playerWalk.json")); jumpParticles=newParticleSystem(x,y,loadJson("data/particles/playerJump.json"))
    }
end

function processPlayer(player)

    -- Movement
    local xInput = boolToInt(pressed("d")) - boolToInt(pressed("a"))

    player.vel.x = lerp(player.vel.x, xInput * 300, dt * 8)

    player.collider = moveRect(player.collider, player.vel, TILEMAP.colliders)

    player.vel.y = math.min(player.vel.y + 800 * dt,600)

    if player.collider.touching.y == 1 then
        player.vel.y = 1

        if justPressed("space") then
            player.vel.y = -400

            table.insert(particleSystems,deepcopyTable(player.jumpParticles))

        end
    end
    
    -- Particles
    player.walkParticles:process()

    player.walkParticles.spawning = xInput ~= 0; player.walkParticles.x = player.collider.x; player.walkParticles.y = player.collider.y + 16

    player.jumpParticles.x = player.collider.x; player.jumpParticles.y = player.collider.y + 16

    -- Animation
    if player.collider.touching.y ~= 1 then
        if player.vel.y > 0 then player.animation="fall" else player.animation="jump" end
    else
    if xInput ~= 0 then player.animation="run" else player.animation="idle" end
    end

    player = PLAYER_ANIMATIONS[player.animation](player)

    -- Drawing the player

    setColor(255,255,255)
    lookAt = boolToInt(xM > (player.collider.x - camera[1])) * 2 - 1

    -- LEGS
    drawSprite(PLAYER_ARM, player.collider.x + player.legL.x * lookAt, player.collider.y + player.legL.y, lookAt, 1, player.legLR)
    drawSprite(PLAYER_ARM, player.collider.x + player.legR.x * lookAt, player.collider.y + player.legR.y, lookAt, 1, player.legRR)

    -- HEAD AND BODY
    drawSprite(PLAYER_BODY, player.collider.x + player.body.x * lookAt, player.collider.y + player.body.y, lookAt, 1, player.bodyR)
    drawSprite(PLAYER_HEAD, player.collider.x + player.head.x * lookAt, player.collider.y + player.head.y, lookAt, 1, player.headR)

    -- ITEM IN HAND
    local holding = tostring(player.slotOn)..",0"

    if player.hotbar.slots[holding].item ~= nil then
        player.hotbar.slots[holding].item = holdItem(player,lookAt,player.hotbar.slots[holding].item)
    end

    -- ARMS
    drawSprite(PLAYER_ARM, player.collider.x + player.armR.x * lookAt, player.collider.y + player.armR.y, lookAt, 1, player.armRR)
    drawSprite(PLAYER_ARM, player.collider.x + player.armL.x * lookAt, player.collider.y + player.armL.y, lookAt, 1, player.armLR)

    drawCollider(player.collider)
    
    -- Inventory and camera

    love.graphics.setCanvas(UI_LAYER)

    drawInventory(player.hotbar)
    drawSprite(HOLDING_ARROW,42 + 64 * player.slotOn, 81 + math.sin(globalTimer * 4) * 4, 1, 1, 0, 0)

    player.slotOn = wrap(player.slotOn + getScroll(), 0, 4); mouseMode = "aimer"; mCentered = 0.5

    if justPressed("e") then inventoryOpen = not inventoryOpen end

    if inventoryOpen then
        mouseMode = "pointer"; mCentered = 0
        player.inventory = processInventory(player.inventory); drawInventory(player.inventory)
        player.wearing = processInventory(player.wearing); drawInventory(player.wearing)
        player.hotbar = processInventory(player.hotbar)

        processMouseSlot()

        bindCamera(player.collider.x, player.collider.y)

    else
        local zoom = 0.35
        bindCamera(player.collider.x + (xM - WS[1] * 0.5) * zoom, player.collider.y + (yM - WS[2] * 0.5) * zoom)
    end

    love.graphics.setCanvas(display)

end

--                                  ANIMATIONS

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