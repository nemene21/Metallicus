
function buildSkeletonMiner(x, y)
    local dashParticles = newParticleSystem(x, y, loadJson("data/particles/player/playerDash.json"))

    dashParticles.spawning = false
    dashParticles.particleData.lifetime = {a=0.2, b=0.4}

    return {
        hp = 100,

        knockback = newVec(0,0), knockBackResistance = 1,

        image = "SKELETON_MINER",

        collider = newRect(x,y,28,56),
        
        state = "idle",

        scaleX = 1, scaleY = 1,

        newState = love.math.random(2, 4),

        vel = newVec(0, 0),

        drops = {bone = 250, minerHelmet = 5},

        dashParticles = dashParticles,

        states = {
            attacking = skeletonMinerStateAttacking, idle = skeletonMinerStateIdle
        }
    }
end

function skeletonMinerStateIdle(enemy)

    enemy.collider = moveRect(enemy.collider, newVec(enemy.knockback.x, enemy.knockback.y + enemy.vel.y), ROOM.tilemap.collidersWithFalltrough)

    local spriteYOffset = 9
    local turn = boolToInt(enemy.collider.x < player.collider.x) * 2 - 1

    local prepAnim = math.sin(math.min(enemy.newState, 1) * 3.14)
    local prepAnimI = 1 - prepAnim

    enemy.dashParticles.x = enemy.collider.x; enemy.dashParticles.y = enemy.collider.y
    
    enemy.dashParticles:process()

    SHADERS.FLASH:send("intensity", boolToInt(enemy.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)
    
    setColor(255, 255 * prepAnimI, 255 * prepAnimI)
    drawSprite(ENEMY_IMAGES[enemy.image].pickaxe, enemy.collider.x + 16 * turn, enemy.collider.y + spriteYOffset - 16 * prepAnim, turn + 0.4 * prepAnim, 1 + 0.4 * prepAnim, prepAnim * -2 * turn, 1, 0.1, 0.9)

    setColor(255, 255, 255)

    drawSprite(ENEMY_IMAGES[enemy.image].body, enemy.collider.x, enemy.collider.y + math.sin(globalTimer * 2) * 2 + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].head, enemy.collider.x, enemy.collider.y - 20 + math.sin(globalTimer * 2 + 1.5) * 4 + spriteYOffset, turn)

    shine(enemy.collider.x, enemy.collider.y - 26 + math.sin(globalTimer * 2 + 1.5) * 4 + spriteYOffset, 200, {255, 170, 50, 40})

    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x - 16 * turn, enemy.collider.y + spriteYOffset + 8 * prepAnim, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x + 16 * turn, enemy.collider.y + spriteYOffset - 16 * prepAnim, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x - 12 * turn, enemy.collider.y + 16 + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x + 12 * turn, enemy.collider.y + 16 + spriteYOffset - 12 * prepAnim, turn)

    love.graphics.setShader()

    enemy.vel.y = math.min(enemy.vel.y + 1200 * dt, 600)

    if enemy.collider.touching.y == 1 then

        enemy.vel.y = 1

    end

    enemy.newState = enemy.newState - dt
    if enemy.newState < 0 then

        enemy.newState = 0.5
        enemy.state = "attacking"

        enemy.vel.x = turn * 800

        enemy.dashParticles.spawning = true

        enemy.dashParticles.rotation = 180 * boolToInt(enemy.collider.x < player.collider.x)

    end

end

function skeletonMinerStateAttacking(enemy)

    enemy.collider = moveRect(enemy.collider, newVec(enemy.vel.x * math.sin(enemy.newState / 0.5 * 3.14) + enemy.knockback.x, enemy.knockback.y + enemy.vel.y), ROOM.tilemap.collidersWithFalltrough)

    local spriteYOffset = 9
    local turn = boolToInt(enemy.vel.x > 0) * 2 - 1

    enemy.dashParticles.x = enemy.collider.x; enemy.dashParticles.y = enemy.collider.y
    
    enemy.dashParticles:process()

    SHADERS.FLASH:send("intensity", boolToInt(enemy.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)

    drawSprite(ENEMY_IMAGES[enemy.image].body, enemy.collider.x, enemy.collider.y + math.sin(globalTimer * 2) * 2 + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].head, enemy.collider.x, enemy.collider.y - 20 + math.sin(globalTimer * 2 + 1.5) * 4 + spriteYOffset, turn)

    drawSprite(ENEMY_IMAGES[enemy.image].pickaxe, enemy.collider.x + 16 * turn, enemy.collider.y + spriteYOffset, turn, 1, enemy.newState / 0.5 * 6.28 * 3 * -turn, 1, 0.1, 0.9)

    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x - 16 * turn, enemy.collider.y + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x + 16 * turn, enemy.collider.y + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x - 12 * turn, enemy.collider.y + 16 + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x + 12 * turn, enemy.collider.y + 16 + spriteYOffset, turn)

    local hitbox = newRect(enemy.collider.x + 16 * turn, enemy.collider.y + spriteYOffset, 48, 48)

    love.graphics.setShader()
    
    enemy.vel.y = math.min(enemy.vel.y + 800 * dt, 600)
    if enemy.collider.touching.y == 1 then

        enemy.vel.y = 1

    end

    if isRectColliding(hitbox, player.collider) then

        player:hit(20)

    end

    enemy.newState = enemy.newState - dt
    if enemy.newState < 0 then

        enemy.newState = love.math.random(2, 4)
        enemy.state = "idle"

        enemy.dashParticles.spawning = false

    end
    shine(enemy.collider.x, enemy.collider.y - 26 + math.sin(globalTimer * 2 + 1.5) * 4 + spriteYOffset, 200, {255, 170, 50, 40})

end

