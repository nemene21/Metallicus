
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

        handSlamPos = newVec(330, 330),
        handShootPos = newVec(270, 330),

        maxHp = 1500,
        hp = 1000,

        barDelay = 306,

        flash = 0,

        hitbox = newRect(300, 300, 96, 96),

        id = 3.141592

    }

end

function steletonBossAttack2Hands(boss)

    boss.pos.x = 380 + 210 * math.sin(globalTimer * 1)

    boss.handSlamPos.x = lerp(boss.handSlamPos.x, boss.pos.x  + 64, dt * 5)

    boss.handShootPos.x = lerp(boss.handShootPos.x, boss.pos.x - 64, dt * 5)

    boss.hitbox.x = boss.pos.x
    boss.hitbox.y = boss.pos.y

end

function drawSkeletonBoss(boss)

    if boss.flash > 0.8 then love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", 1) end

    drawSprite(SKELETON_BOSS_HEAD, boss.pos.x, boss.pos.y)

    drawSprite(SKELETON_BOSS_ARM_SLAM, boss.handSlamPos.x, boss.handSlamPos.y)
    drawSprite(SKELETON_BOSS_ARM_SHOOT, boss.handShootPos.x, boss.handShootPos.y)

    love.graphics.setShader()

end