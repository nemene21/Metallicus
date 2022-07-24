
SKELETON_BOSS_HEAD = love.graphics.newImage("data/images/bosses/skeletonBossHead.png")
SKELETON_BOSS_ARM_SLAM = love.graphics.newImage("data/images/bosses/skeletonBossFist.png")
SKELETON_BOSS_ARM_SHOOT = love.graphics.newImage("data/images/bosses/skeletonBossHand.png")

function newSkeletonBoss()

    return {

        states = {steletonBossAttack2Hands},

        state = 1,

        draw = drawSkeletonBoss,
        drawBar = drawBossBarDefault,

        pos = newVec(300, 300),

        handSlamPos = newVec(270, 330),
        handShootPos = newVec(330, 330),

        maxHp = 1500,
        hp = 1500,

        barDelay = 306,

        flash = 0,

        hitbox = newRect(300, 300, 96, 96),

        id = 3.141592,

        -- Attack timers
        armShootingUp = 0,

        isArmShootingUpTimer = 0,

        smoke = newParticleSystem(300, 300, loadJson("data/particles/enemies/skeletonBossSmoke.json")),

        handSlamSmoke = newParticleSystem(270, 330, loadJson("data/particles/enemies/skeletonBossArmSmoke.json")),
        handShootSmoke = newParticleSystem(330, 330, loadJson("data/particles/enemies/skeletonBossArmSmoke.json"))

    }

end

function steletonBossAttack2Hands(boss)

    boss.pos.x = 380 + 210 * math.sin(globalTimer)
    boss.pos.y = 240 + 96 * math.sin(globalTimer * 0.5)

    boss.smoke.x = boss.pos.x; boss.smoke.y = boss.pos.y

    boss.smoke.x = boss.pos.x; boss.smoke.y = boss.pos.y
    boss.smoke.x = boss.pos.x; boss.smoke.y = boss.pos.y

    boss.handSlamSmoke.x = boss.handSlamPos.x; boss.handSlamSmoke.y = boss.handSlamPos.y
    boss.handShootSmoke.x = boss.handShootPos.x; boss.handShootSmoke.y = boss.handShootPos.y

    boss.handSlamPos.x = lerp(boss.handSlamPos.x, boss.pos.x - 64, dt * 5)
    boss.handSlamPos.y = lerp(boss.handSlamPos.y, boss.pos.y + 64, dt * 5)

    boss.handShootPos.x = lerp(boss.handShootPos.x, boss.pos.x + 64, dt * 5)
    boss.handShootPos.y = lerp(boss.handShootPos.y, boss.pos.y + 30 - 128 * boolToInt(boss.isArmShootingUpTimer < 0), dt * 3)

    boss.hitbox.x = boss.pos.x
    boss.hitbox.y = boss.pos.y

    boss.isArmShootingUpTimer = boss.isArmShootingUpTimer - dt

    if boss.isArmShootingUpTimer < - 1 then
        boss.armShootingUp = boss.armShootingUp - dt
    end

    if boss.isArmShootingUpTimer < - 6 then boss.isArmShootingUpTimer = 4 end

    if boss.armShootingUp < 0 then

        boss.armShootingUp = 0.2

        local projectile = newEnemyProjectile("mediumOrb", newVec(boss.handShootPos.x, boss.handShootPos.y), 200, 90 + love.math.random(-33, 33), 24, 10, {255,200,200})

        projectile.acceleration.y = 300

        table.insert(enemyProjectiles, projectile)

    end

    boss.smoke:process()

    boss.handSlamSmoke:process()
    boss.handShootSmoke:process()

end

function drawSkeletonBoss(boss)

    setColor(255, 255, 255)

    if boss.flash > 0.8 then love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", 1) end

    local distortion = clamp((boss.flash - 0.8) / 0.2, 0, 1) * 0.2

    drawSprite(SKELETON_BOSS_HEAD, boss.pos.x, boss.pos.y, 1 + distortion, 1 - distortion)

    love.graphics.setShader()

    drawSprite(SKELETON_BOSS_ARM_SLAM, boss.handSlamPos.x, boss.handSlamPos.y)

    local shootingAnim = clamp(boss.isArmShootingUpTimer, -1, 0) * -1

    if boss.isArmShootingUpTimer > 3 then shootingAnim = boss.isArmShootingUpTimer - 3 end

    love.graphics.setColor(1, 0.75 - shootingAnim + 0.25, 0.75 - shootingAnim + 0.25)
    drawSprite(SKELETON_BOSS_ARM_SHOOT, boss.handShootPos.x, boss.handShootPos.y)

    shine(boss.handShootPos.x, boss.handShootPos.y, 144, {255, 60, 60, 80 * shootingAnim})

end