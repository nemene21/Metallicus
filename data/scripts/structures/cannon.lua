
function newCannon(x, y, rotation)

    return {

        x = x, y = y, rotation = rotation,

        process = processCannon,
        draw = drawCannon,

        shootTimer = 0,

        animation = 0

    }

end

CANNON_SPRITE = love.graphics.newImage("data/images/structures/cannon.png")

function processCannon(cannon)

    cannon.shootTimer = cannon.shootTimer - dt

    cannon.animation = lerp(cannon.animation, 0, dt * 16)

    if cannon.shootTimer < 0 then

        cannon.shootTimer = 0.25

        local offset = newVec(24, 0):rotate(cannon.rotation + 180)

        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb", newVec(cannon.x + offset.x, cannon.y + offset.y), 200, cannon.rotation, 24, 10, {255,200,200}))

        local particleData = deepcopyTable(PARTICLES_ENEMY_HIT)
        particleData.rotation = 0
        
        playSound("cannonShoot", love.math.random(60, 120) * 0.01)

        cannon.animation = 0.5
                
        table.insert(ROOM.particleSystems, newParticleSystem(cannon.x + offset.x, cannon.y + offset.y, particleData))

    end

end

function drawCannon(cannon)

    drawSprite(CANNON_SPRITE, cannon.x, cannon.y, 1 + cannon.animation, 1 - cannon.animation, (cannon.rotation - 90) / 180 * 3.14)

end