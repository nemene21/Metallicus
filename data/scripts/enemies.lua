
PARTICLES_ENEMY_HIT = loadJson("data/particles/enemies/enemyhit.json")

-- Build and process functions

ENEMY_ID = 0

ENEMY_NAMES = {
slime="slime",
giantFirefly="giant firefly",
battlefly="battlefly",
skeletonMiner="skeleton miner"
}

ENEMY_HP_SCALE = 1

function buildEnemy(name, x, y)

    local enemy = enemies[name](x, y)
    enemy.process = processEnemy
    enemy.hit = hitEnemy; enemy.flash = 0
    
    enemy.name = ENEMY_NAMES[name]

    enemy.stringKey = name

    enemy.ID = ENEMY_ID
    ENEMY_ID = ENEMY_ID + 1

    enemy.hp = math.floor(enemy.hp * ENEMY_HP_SCALE)

    return enemy
end

function processEnemy(enemy)
    SHADERS.FLASH:send("intensity", 0)

    enemy.knockback.x = lerp(enemy.knockback.x, 0, dt * 2)
    enemy.knockback.y = lerp(enemy.knockback.y, 0, dt * 2)

    if enemy.collider.touching.x ~= 0 then enemy.knockback.x = enemy.knockback.x * -0.5 end
    if enemy.collider.touching.y ~= 0 then enemy.knockback.y = enemy.knockback.y * -0.5 end

    enemy.flash = lerp(enemy.flash, 0, dt * 6)

    setColor(255, 255, 255)

    if enemy.hp <= 0 and enemy.onDeath ~= nil then enemy:onDeath() end

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

    addNewText(tostring(damage), enemy.collider.x + love.math.random(-24, 24), enemy.collider.y + love.math.random(-24, 24), {255, 0, 0})

    -- Add to active item charge
    local activeItemSlot = player.wearing.slots["1,2"]
    if activeItemSlot ~= nil then
        local activeItem = activeItemSlot.item

        if activeItem ~= nil then
            activeItem.charge = clamp(activeItem.charge + damage / activeItem.chargeSpeed, 0, 1)
        end
    end
    
end

--                                                                   IMAGES AND STUFF

ENEMY_IMAGES = {
SLIME = love.graphics.newImage("data/images/enemies/slime/slime.png"),

GIANT_FIREFLY = {
    head = love.graphics.newImage("data/images/enemies/giantFirefly/head.png"),
    wing = love.graphics.newImage("data/images/enemies/giantFirefly/wing.png"),
    body = love.graphics.newImage("data/images/enemies/giantFirefly/body.png")
},

BATTLEFLY = {
    body = love.graphics.newImage("data/images/enemies/battlefly/body.png"),
    wing = love.graphics.newImage("data/images/enemies/battlefly/wing.png")
},
SKELETON_MINER = {
    body = love.graphics.newImage("data/images/enemies/skeletonMiner/body.png"),
    arm = love.graphics.newImage("data/images/enemies/skeletonMiner/arm.png"),
    head = love.graphics.newImage("data/images/enemies/skeletonMiner/head.png"),
    pickaxe = love.graphics.newImage("data/images/enemies/skeletonMiner/pickaxe.png"),
}
}

PARTICLES_SLIME_JUMP = loadJson("data/particles/enemies/slimeJumpAndHit.json")
PARTICLES_FIREFLY = loadJson("data/particles/decorations/fireflies.json")

--                                                           BUILDS AND STATES FOR EVERY ENEMY

-- Cave
require "data.scripts.enemies.slime"; require "data.scripts.enemies.giantFirefly"; require "data.scripts.enemies.battlefly"; require "data.scripts.enemies.skeletonMiner"

enemies = {
slime = buildSlime,
giantFirefly = buildGiantFirefly,
battlefly = buildBattlefly,
skeletonMiner = buildSkeletonMiner
}

-- Bosses

require "data.scripts.enemies.bosses.skeleton"

BOSS_BAR = love.graphics.newImage("data/images/UI/bossBar.png")

function drawBossBarDefault(boss)

    local animationI = 1 - bossAnimationTimer
    local yOffset = animationI * - 100

    drawSprite(BOSS_BAR, 400, 28 + yOffset, 1, 1, 0, 0)

    local barLenght = boss.hp / boss.maxHp * 306
    if boss.flash < 0 then boss.barDelay = lerp(boss.barDelay, barLenght, dt * 3) end

    setColor(255, 255, 255)
    love.graphics.rectangle("fill", 247, 19 + yOffset, boss.barDelay, 18) -- Delayed bar
    
    setColor(228, 59, 68)
    love.graphics.rectangle("fill", 247, 19 + yOffset, barLenght, 18) -- Hp bar

    setColor(158, 40, 53)
    love.graphics.rectangle("fill", 247, 31 + yOffset, barLenght, 6)  -- Shadow

    setColor(255, 255, 255)

end