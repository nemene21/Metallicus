
function buildBattlefly(x, y)
    return {
        hp = 100,

        knockback = newVec(0,0), knockBackResistance = 1, flash = 0,

        collider = newRect(x, y, 40, 40), vel = newVec(0, 0),
        
        state = "float", nextStateTimer = newTimer(love.math.random(2,3)),

        drops = {flyDust = 250}, hasNoBodyOnDeath = true, mult = 0, shot = false,

        states = {
            float = battleflyStateFloat, move = battleflyStateMove
        }
    }
end

function battleflyStateFloat(battlefly)

    battlefly.collider = moveRect(battlefly.collider, newVec(battlefly.vel.x + battlefly.knockback.x, battlefly.vel.y + battlefly.knockback.y), ROOM.tilemap.collidersWithFalltrough)

    local flap = math.abs(math.sin(globalTimer * 3)) * 0.55 + 0.45

    SHADERS.FLASH:send("intensity", boolToInt(battlefly.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)

    setColor(255, 255 * battlefly.mult, 255 * battlefly.mult)

    drawSprite(ENEMY_IMAGES.BATTLEFLY.wing, battlefly.collider.x + 3, battlefly.collider.y, -flap, 1, 0, 1, 1)
    drawSprite(ENEMY_IMAGES.BATTLEFLY.wing, battlefly.collider.x - 3, battlefly.collider.y, flap, 1, 0, 1, 1)

    drawSprite(ENEMY_IMAGES.BATTLEFLY.body, battlefly.collider.x, battlefly.collider.y, 1 + math.sin(globalTimer * 3 + 3.14) * 0.2, 1 + math.sin(globalTimer * 3) * 0.1)

    love.graphics.setShader()

    shine(battlefly.collider.x, battlefly.collider.y, 128, {255 * (1 - battlefly.mult), 80 * battlefly.mult, 255 * battlefly.mult, 80})
    love.graphics.setCanvas(display)

    battlefly.mult = lerp(battlefly.mult, 1, dt * 6)

    battlefly.nextStateTimer:process()
    if battlefly.nextStateTimer:isDone() then

        battlefly.nextStateTimer.timeMax = 1
        battlefly.nextStateTimer:reset()

        local vel = newVec(200, 0); vel:rotate(love.math.random(0, 360))
        battlefly.velTo = vel

        battlefly.goingToShoot = love.math.random(0, 100) > 20

        battlefly.state = "move"
        battlefly.shot = false
        battlefly.mult = 1

    end

end

function battleflyStateMove(battlefly)

    battlefly.nextStateTimer:process()
    if not battlefly.nextStateTimer:isDone() then
        battlefly.vel.x = lerp(battlefly.vel.x, battlefly.velTo.x, dt * 2)
        battlefly.vel.y = lerp(battlefly.vel.y, battlefly.velTo.y, dt * 2)
    else
        battlefly.vel.x = lerp(battlefly.vel.x, 0, dt * 2)
        battlefly.vel.y = lerp(battlefly.vel.y, 0, dt * 2)
    end

    if battlefly.goingToShoot and not battlefly.nextStateTimer:isDone() then
        battlefly.mult = battlefly.nextStateTimer.time
    end

    if battlefly.vel:getLen() < 1 and battlefly.nextStateTimer:isDone() then

        battlefly.state = "float"

        battlefly.nextStateTimer.timeMax = love.math.random(2,3)
        battlefly.nextStateTimer:reset()

        battlefly.vel = newVec(0, 0)

        if battlefly.goingToShoot then
        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(battlefly.collider.x, battlefly.collider.y), 200, 45, 18, 10, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(battlefly.collider.x, battlefly.collider.y), 200, -45, 18, 10, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(battlefly.collider.x, battlefly.collider.y), 200, 135, 18, 10, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(battlefly.collider.x, battlefly.collider.y), 200, -135, 18, 10, {255,200,200}))
        end
    end

    battlefly.collider = moveRect(battlefly.collider, newVec(battlefly.vel.x + battlefly.knockback.x, battlefly.vel.y + battlefly.knockback.y), ROOM.tilemap.collidersWithFalltrough)

    local flap = math.abs(math.sin(globalTimer * 3)) * 0.55 + 0.45

    setColor(255, 255 * battlefly.mult, 255 * battlefly.mult)

    SHADERS.FLASH:send("intensity", boolToInt(battlefly.flash > 0.5))
    love.graphics.setShader(SHADERS.FLASH)

    drawSprite(ENEMY_IMAGES.BATTLEFLY.wing, battlefly.collider.x + 3, battlefly.collider.y, -flap, 1, 0, 1, 1)
    drawSprite(ENEMY_IMAGES.BATTLEFLY.wing, battlefly.collider.x - 3, battlefly.collider.y, flap, 1, 0, 1, 1)

    drawSprite(ENEMY_IMAGES.BATTLEFLY.body, battlefly.collider.x, battlefly.collider.y, 1 + math.sin(globalTimer * 3 + 3.14) * 0.2, 1 + math.sin(globalTimer * 3) * 0.1)
    love.graphics.setShader()

    shine(battlefly.collider.x, battlefly.collider.y, 128, {255 * (1 - battlefly.mult), 80 * battlefly.mult, 255 * battlefly.mult, 80})
    love.graphics.setCanvas(display)
end