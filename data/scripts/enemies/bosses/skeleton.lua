
SKELETON_BOSS_HEAD = love.graphics.newImage("data/images/bosses/skeletonBossHead.png")
SKELETON_BOSS_ARM_SLAM = love.graphics.newImage("data/images/bosses/skeletonBossFist.png")
SKELETON_BOSS_ARM_SHOOT = love.graphics.newImage("data/images/bosses/skeletonBossHand.png")

function newSkeletonBoss()

    return {

        states = {steletonBossAttack2Hands},

        state = 1,

        draw = drawSkeletonBoss,

        pos = newVec(300, 300),

        handSlamPos = newVec(330, 330),
        handShootPos = newVec(270, 330)

    }

end

function steletonBossAttack2Hands(boss)

    boss.pos.x = 380 + 210 * math.sin(globalTimer * 1)

    boss.handSlamPos.x = lerp(boss.handSlamPos.x, boss.pos.x  + 64, dt * 5)

    boss.handShootPos.x = lerp(boss.handShootPos.x, boss.pos.x - 64, dt * 5)

end

function drawSkeletonBoss(boss)

    drawSprite(SKELETON_BOSS_HEAD, boss.pos.x, boss.pos.y)

    drawSprite(SKELETON_BOSS_ARM_SLAM, boss.handSlamPos.x, boss.handSlamPos.y)
    drawSprite(SKELETON_BOSS_ARM_SHOOT, boss.handShootPos.x, boss.handShootPos.y)

end