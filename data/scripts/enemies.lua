
PARTICLES_ENEMY_HIT = loadJson("data/particles/enemies/enemyhit.json")

-- Build and process functions

ENEMY_ID = 0

ENEMY_NAMES = {
slime="slime",
giantFirefly="giant firefly"
}

function buildEnemy(name, x, y)

    local enemy = enemies[name](x, y)
    enemy.process = processEnemy
    enemy.hit = hitEnemy; enemy.flash = 0
    
    enemy.name = ENEMY_NAMES[name]

    enemy.ID = ENEMY_ID
    ENEMY_ID = ENEMY_ID + 1

    return enemy
end

function processEnemy(enemy)
    SHADERS.FLASH:send("intensity", 0)

    enemy.knockback.x = lerp(enemy.knockback.x, 0, dt * 2)
    enemy.knockback.y = lerp(enemy.knockback.y, 0, dt * 2)

    enemy.flash = lerp(enemy.flash, 0, dt * 6)

    love.graphics.setCanvas(display)
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

    playSound(enemy.hitSound or "basicHit", love.math.random(80, 120) * 0.01)
    shake(3.5, 2, 0.1)

    table.insert(ROOM.textPopUps.particles,{
        x = enemy.collider.x + love.math.random(-24, 24), y = enemy.collider.y + love.math.random(-24, 24),
        vel = newVec(0, -100), width = tostring(damage),
        lifetime = 1, lifetimeStart = 1,
        color = {r=255,g=0,b=0,a=1},
        rotation = 0

    })
end

--                                                                   IMAGES AND STUFF

ENEMY_IMAGES = {
SLIME = love.graphics.newImage("data/images/enemies/slime/slime.png"),

GIANT_FIREFLY = {
    head = love.graphics.newImage("data/images/enemies/giantFirefly/head.png"),
    wing = love.graphics.newImage("data/images/enemies/giantFirefly/wing.png"),
    body = love.graphics.newImage("data/images/enemies/giantFirefly/body.png")
}
}

PARTICLES_SLIME_JUMP = loadJson("data/particles/enemies/slimeJumpAndHit.json")
PARTICLES_FIREFLY = loadJson("data/particles/decorations/fireflies.json")

--                                                           BUILDS AND STATES FOR EVERY ENEMY

-- Cave
require "data.scripts.enemies.slime"; require "data.scripts.enemies.giantFirefly"

enemies = {
slime = buildSlime,
giantFirefly = buildGiantFirefly
}

