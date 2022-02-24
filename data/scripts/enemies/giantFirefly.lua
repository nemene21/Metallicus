
function buildGiantFirefly(x, y)
    return {
        hp = 50,

        knockback = newVec(0,0), knockBackResistance = 1,

        image = "GIANT_FIREFLY",

        collider = newRect(x,y,48,30), vel = newVec(0,0),
        
        state = "circle", nextStateTimer = love.math.random(3,5),

        scaleX = 1, scaleY = 1,

        drops = {jello = 250},

        rotation = 1, shootDir = 0, flash = 0,

        hasNoBodyOnDeath = true,

        ambientParticles = newParticleSystem(x, y, deepcopyTable(PARTICLES_FIREFLY)),

        shootTimer = newTimer(love.math.random(4,6)),
        burst = 0, burstTimer = newTimer(0.2),

        states = {
            circle = giantFireflyStateCircle
        }
    }
end

function giantFireflyStateCircle(giantFirefly)

    -- Move
    giantFirefly.vel = newVec(player.collider.x - giantFirefly.collider.x, player.collider.y - giantFirefly.collider.y)
    giantFirefly.vel:normalize(); giantFirefly.vel:rotate(90 * giantFirefly.rotation)

    local speed = 120
    giantFirefly.vel.x = giantFirefly.vel.x * speed; giantFirefly.vel.y = giantFirefly.vel.y * speed

    giantFirefly.collider = moveRect(giantFirefly.collider, newVec(giantFirefly.vel.x + giantFirefly.knockback.x, giantFirefly.vel.y + giantFirefly.knockback.y),ROOM.tilemap.collidersWithFalltrough)
   
    if giantFirefly.collider.touching.y ~= 0 then giantFirefly.rotation = - giantFirefly.rotation end

    -- Shoot
    giantFirefly.shootTimer:process()
    
    if giantFirefly.shootTimer:isDone() then

        giantFirefly.shootDir = newVec(player.collider.x - giantFirefly.collider.x, player.collider.y - giantFirefly.collider.y):getRot() + 180

        giantFirefly.shootTimer.tiemMax = love.math.random(4,6)
        giantFirefly.shootTimer:reset()
        giantFirefly.burst = 2

    end

    giantFirefly.burstTimer:process()
    if giantFirefly.burst > 0 and giantFirefly.burstTimer:isDone() then

        playSound("giantFireflyShoot", love.math.random(90, 110) * 0.01)

        giantFirefly.burstTimer:reset()
        giantFirefly.burst = giantFirefly.burst - 1

        local offset = newVec(32, 0); offset:rotate(giantFirefly.shootDir + 180)

        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(giantFirefly.collider.x + offset.x, giantFirefly.collider.y + offset.y), 200, giantFirefly.shootDir, 18, 10, {255,200,200}))

    end

    -- Particles
    giantFirefly.ambientParticles.x = giantFirefly.collider.x
    giantFirefly.ambientParticles.y = giantFirefly.collider.y
    giantFirefly.ambientParticles:process()

    -- Draw
    local turned = boolToInt(player.collider.x > giantFirefly.collider.x) * 2 - 1
    local headTurn = newVec(player.collider.x - giantFirefly.collider.x, player.collider.y - giantFirefly.collider.y):getRot() / 180 * 3.14
    headTurn = headTurn + 3.14 * boolToInt(player.collider.x < giantFirefly.collider.x)

    setColor(255, 255, 255)

    local flap = math.sin(globalTimer * 20)
    local headScalePlus = 0.5 * boolToInt(giantFirefly.shootTimer.time < 1) * (1 - giantFirefly.shootTimer.time)

    SHADERS.FLASH:send("intensity", boolToInt(giantFirefly.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)
    drawSprite(ENEMY_IMAGES[giantFirefly.image].wing, giantFirefly.collider.x + (- 6 + flap) * turned, giantFirefly.collider.y - 4, flap * turned, 1, -1 - flap, 1, 0)

    drawSprite(ENEMY_IMAGES[giantFirefly.image].body, giantFirefly.collider.x - 9 * turned, giantFirefly.collider.y, turned)
    drawSprite(ENEMY_IMAGES[giantFirefly.image].head, giantFirefly.collider.x + 10 * turned, giantFirefly.collider.y + 6, turned + headScalePlus * turned, 1 + headScalePlus, headTurn + math.sin(globalTimer * 3) * 0.2)

    drawSprite(ENEMY_IMAGES[giantFirefly.image].wing, giantFirefly.collider.x + (- 6 + flap) * turned, giantFirefly.collider.y - 4, flap * turned, 1, -2 - flap, 1, 0)
    love.graphics.setShader()

    shine(giantFirefly.collider.x - 9 * turned, giantFirefly.collider.y, 100, {255, 170, 50, 40})
end