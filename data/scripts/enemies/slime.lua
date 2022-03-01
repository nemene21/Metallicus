
--                                                                         SLIME

function buildSlime(x, y)
    return {
        hp = 100,

        knockback = newVec(0,0), knockBackResistance = 1,

        image = "SLIME",

        collider = newRect(x,y,48,30), vel = newVec(0,200),
        
        state = "idle", nextStateTimer = love.math.random(3,5),

        scaleX = 1, scaleY = 1,

        drops = {jello = 250},

        states = {
            idle = slimeStateIdle, prepare = slimeStatePrepare, jump = slimeStateJump
        }
    }
end

function slimeStateIdle(slime, player)

    slime.vel.y = slime.vel.y + dt * 600

    slime.collider = moveRect(slime.collider,newVec(slime.vel.x + slime.knockback.x, slime.vel.y + slime.knockback.y),ROOM.tilemap.collidersWithFalltrough)

    if slime.collider.touching.y == 1 then

        slime.vel.y = 0

    end

    slime.scaleX = lerp(slime.scaleX, 1 + math.sin(globalTimer * 10) * 0.15, dt * 4)
    slime.scaleY = lerp(slime.scaleY, 1 + math.sin(globalTimer * 10 + 3.14) * 0.15, dt * 4)

    SHADERS.FLASH:send("intensity", boolToInt(slime.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)
    drawSprite(ENEMY_IMAGES[slime.image], slime.collider.x, slime.collider.y, slime.scaleX * (boolToInt(player.collider.x > slime.collider.x) * 2 - 1), slime.scaleY, slime.knockback.x * 0.002) -- Draw
    love.graphics.setShader()

    -- Go to prepare state
    slime.nextStateTimer = slime.nextStateTimer - dt

    if slime.nextStateTimer < 0 then
        slime.state = "prepare"; slime.nextStateTimer = 1
    end

    shine(slime.collider.x, slime.collider.y, 120, {0, 255, 80, 35})
    love.graphics.setCanvas(display)
    
    return slime
end

function slimeStatePrepare(slime, player)

    slime.vel.y = slime.vel.y + dt * 600

    slime.collider = moveRect(slime.collider,newVec(slime.vel.x + slime.knockback.x, slime.vel.y + slime.knockback.y),ROOM.tilemap.collidersWithFalltrough)

    if slime.collider.touching.y == 1 then

        slime.vel.y = 0

    end

    slime.scaleX = lerp(slime.scaleX, 1.5, dt)
    slime.scaleY = lerp(slime.scaleY, 0.5, dt)

    setColor(255, 255 * slime.nextStateTimer, 255 * slime.nextStateTimer)

    SHADERS.FLASH:send("intensity", boolToInt(slime.flash > 0.5))
    if slime.flash > 0.5 then love.graphics.setShader(SHADERS.FLASH); setColor(255, 255, 255) end

    drawSprite(ENEMY_IMAGES[slime.image], slime.collider.x, slime.collider.y + (30 - 30 * slime.scaleY) * 0.5, slime.scaleX * (boolToInt(player.collider.x > slime.collider.x) * 2 - 1), slime.scaleY, slime.knockback.x * 0.002)
    love.graphics.setShader()

    -- Go to prepare state
    slime.nextStateTimer = slime.nextStateTimer - dt

    if slime.nextStateTimer < 0 then
        slime.state = "jump"

        slime.vel.x = (boolToInt(player.collider.x > slime.collider.x) * 2 - 1) * 200

        slime.vel.y = -600
    end

    local lightTimer = 1 - slime.nextStateTimer
    shine(slime.collider.x, slime.collider.y, 120, {255 * lightTimer, 255 * (1 - lightTimer), 80 * (1 - lightTimer), 35})

    return slime
end

function slimeStateJump(slime, player)

    slime.scaleX = lerp(slime.scaleX, 0.65, dt * 5)
    slime.scaleY = lerp(slime.scaleY, 1.5, dt * 5)

    slime.vel.y = slime.vel.y + dt * 600

    slime.collider = moveRect(slime.collider,newVec(slime.vel.x + slime.knockback.x, slime.vel.y + slime.knockback.y),ROOM.tilemap.collidersWithFalltrough)

    if slime.collider.touching.x ~= 0 then slime.vel.x = slime.vel.x * -1 end
    if slime.collider.touching.y == -1 then slime.vel.y = 0; slime.knockback.y = 0 end

    if slime.collider.touching.y == 1 then

        if slime.vel.y > 300 then
            table.insert(ROOM.particleSystems, newParticleSystem(slime.collider.x, slime.collider.y + 15, deepcopyTable(PARTICLES_SLIME_JUMP)))
        end

        -- Set state to idle
        slime.vel.y = 0

        slime.state = "idle"; slime.nextStateTimer = love.math.random(3,5)
        shake(12, 2, 0.12); playSound("slimeHitGround", love.math.random(80, 120) * 0.01)

        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 0, 24, 10, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 90, 24, 10, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 180, 24, 10, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 270, 24, 10, {255,200,200}))

        slime.vel.x = 0

        slime.scaleX = 1.6; slime.scaleY = 0.5
    end

    SHADERS.FLASH:send("intensity", boolToInt(slime.flash > 0.3))
    love.graphics.setShader(SHADERS.FLASH)
    drawSprite(ENEMY_IMAGES[slime.image], slime.collider.x, slime.collider.y, slime.scaleX * (boolToInt(slime.vel.x > 0) * 2 - 1), slime.scaleY, slime.knockback.x * 0.002) -- Draw
    love.graphics.setShader()

    shine(slime.collider.x, slime.collider.y, 120, {0, 255, 80, 35})
    love.graphics.setCanvas(display)

    return slime
end