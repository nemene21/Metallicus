
PARTICLES_ENEMY_HIT = loadJson("data/particles/enemyhit.json")

-- Build and process functions

ENEMY_ID = 0

function buildEnemy(name, x, y)

    local enemy = enemies[name](x, y)
    enemy.process = processEnemy
    enemy.hit = hitEnemy; enemy.flash = 0
    
    enemy.ID = ENEMY_ID
    ENEMY_ID = ENEMY_ID + 1

    return enemy
end

function processEnemy(enemy)
    enemy.knockback.x = lerp(enemy.knockback.x, 0, dt * 2)
    enemy.knockback.y = lerp(enemy.knockback.y, 0, dt * 2)

    enemy.flash = lerp(enemy.flash, 0, dt * 6)

    return enemy.states[enemy.state](enemy, player)
end

function hitEnemy(enemy,damage,strenght,dir)
    enemy.hp = enemy.hp - damage
    local knockback = newVec(strenght * enemy.knockBackResistance,0); knockback:rotate(dir)

    enemy.knockback.x = enemy.knockback.x + knockback.x
    enemy.knockback.y = enemy.knockback.y + knockback.y

    enemy.flash = 1

    local particleData = deepcopyTable(PARTICLES_ENEMY_HIT)
    particleData.rotation = dir + 90

    table.insert(ROOM.particleSystems, newParticleSystem(enemy.collider.x, enemy.collider.y, particleData))
end

--                                                                   IMAGES AND STUFF

ENEMY_IMAGES = {
SLIME = love.graphics.newImage("data/images/enemies/slime/slime.png")
}

PARTICLES_SLIME_JUMP = loadJson("data/particles/slimeJumpAndHit.json")

--                                                           BUILDS AND STATES FOR EVERY ENEMY


--                                                                         SLIME

function buildSlime(x, y)
    return {
        hp = 10,

        knockback = newVec(0,0), knockBackResistance = 1,

        image = "SLIME",

        collider = newRect(x,y,48,30), vel = newVec(0,200),
        
        state = "idle", nextStateTimer = love.math.random(3,5),

        scaleX = 1, scaleY = 1,

        drop = {{"wood",3,6}, {"sword",1,1}},

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

    SHADERS.FLASH:send("intensity", boolToInt(slime.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)
    drawSprite(ENEMY_IMAGES[slime.image], slime.collider.x, slime.collider.y + (30 - 30 * slime.scaleY) * 0.5, slime.scaleX * (boolToInt(player.collider.x > slime.collider.x) * 2 - 1), slime.scaleY, slime.knockback.x * 0.002)
    love.graphics.setShader()

    -- Go to prepare state
    slime.nextStateTimer = slime.nextStateTimer - dt

    if slime.nextStateTimer < 0 then
        slime.state = "jump"

        slime.vel.x = (boolToInt(player.collider.x > slime.collider.x) * 2 - 1) * 200

        slime.vel.y = -600
    end

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

        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 0, 24, 1, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 90, 24, 1, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 180, 24, 1, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb",newVec(slime.collider.x, slime.collider.y), 200, 270, 24, 1, {255,200,200}))

        slime.vel.x = 0

        slime.scaleX = 1.6; slime.scaleY = 0.5
    end

    SHADERS.FLASH:send("intensity", boolToInt(slime.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)
    drawSprite(ENEMY_IMAGES[slime.image], slime.collider.x, slime.collider.y, slime.scaleX * (boolToInt(slime.vel.x > 0) * 2 - 1), slime.scaleY, slime.knockback.x * 0.002) -- Draw
    love.graphics.setShader()

    return slime
end

enemies = {
slime = buildSlime
}

