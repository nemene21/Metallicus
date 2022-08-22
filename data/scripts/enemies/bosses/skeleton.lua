
SKELETON_BOSS_HEAD = love.graphics.newImage("data/images/bosses/skeletonBossHead.png")
SKELETON_BOSS_JAW = love.graphics.newImage("data/images/bosses/skeletonBossJaw.png")
SKELETON_BOSS_ARM_SLAM = love.graphics.newImage("data/images/bosses/skeletonBossFist.png")
SKELETON_BOSS_ARM_SHOOT = love.graphics.newImage("data/images/bosses/skeletonBossHand.png")

function newSkeletonBoss()

    return {

        states = {steletonBossAttack2Hands},

        state = 1,

        lootTable = "skeleton",

        draw = drawSkeletonBoss,
        drawBar = drawBossBarDefault,

        pos = newVec(300, 300),

        handSlamPos = newVec(270, 330),
        handShootPos = newVec(330, 330),

        maxHp = 2400,
        hp = 2400,

        barDelay = 306,

        flash = 0,

        hitbox = newRect(300, 300, 96, 96),
        track = "skeletonBoss",

        id = 3.141592,

        -- Attack timers and stuff
        armShootingUp = 0,

        isArmShootingUpTimer = 3,

        armSlamTimer = 6,
        armGoingToSlamTimer = 3,
        slamming = false,
        slamArmBounceAnim = 0,

        spitAttackTimer = 2,
        spitAttackDelay = 2,
        jawOffset = 0,

        smoke = newParticleSystem(300, 300, loadJson("data/particles/enemies/skeletonBossSmoke.json")),

        handSlamSmoke = newParticleSystem(270, 330, loadJson("data/particles/enemies/skeletonBossArmSmoke.json")),
        handShootSmoke = newParticleSystem(330, 330, loadJson("data/particles/enemies/skeletonBossArmSmoke.json"))

    }

end

function steletonBossAttack2Hands(boss)

    boss.slamArmBounceAnim = lerp(boss.slamArmBounceAnim, 0, dt * 4)

    boss.pos.x = 380 + 210 * math.sin(globalTimer)
    boss.pos.y = 235 + 110 * math.sin(globalTimer * 0.4)

    boss.smoke.x = boss.pos.x; boss.smoke.y = boss.pos.y

    boss.smoke.x = boss.pos.x; boss.smoke.y = boss.pos.y
    boss.smoke.x = boss.pos.x; boss.smoke.y = boss.pos.y

    boss.handSlamSmoke.x = boss.handSlamPos.x; boss.handSlamSmoke.y = boss.handSlamPos.y
    boss.handShootSmoke.x = boss.handShootPos.x; boss.handShootSmoke.y = boss.handShootPos.y

    boss.handShootPos.x = lerp(boss.handShootPos.x, boss.pos.x + 64, dt * 5)
    boss.handShootPos.y = lerp(boss.handShootPos.y, boss.pos.y + 30 - 96 * boolToInt(boss.isArmShootingUpTimer < 0), dt * 3)

    boss.hitbox.x = boss.pos.x
    boss.hitbox.y = boss.pos.y

    boss.isArmShootingUpTimer = boss.isArmShootingUpTimer - dt

    if boss.isArmShootingUpTimer < - 1 then
        boss.armShootingUp = boss.armShootingUp - dt
    end

    if boss.isArmShootingUpTimer < - 6 then boss.isArmShootingUpTimer = 4 end -- Shoot from arm

    if boss.armShootingUp < 0 then

        boss.armShootingUp = 0.3

        local projectile = newEnemyProjectile("mediumOrb", newVec(boss.handShootPos.x, boss.handShootPos.y), 200, 90 + love.math.random(-33, 33), 24, 12, {255,200,200})
        if love.math.random(0, 100) > 50 then projectile = newEnemyProjectile("smallOrb", newVec(boss.handShootPos.x, boss.handShootPos.y), 250, 90 + love.math.random(-33, 33), 18, 12, {255,200,200}) end

        projectile.acceleration.y = 300

        table.insert(enemyProjectiles, projectile)

    end

    boss.spitAttackTimer = boss.spitAttackTimer - dt -- Spit attack

    boss.jawOffset = lerp(boss.jawOffset, 0, dt * 2)

    if boss.spitAttackTimer < 0 then
        
        boss.spitAttackDelay = boss.spitAttackDelay - dt

        boss.jawOffset = 48 * (1 - boss.spitAttackDelay / 2)
    
    end

    if boss.spitAttackDelay < 0 then

        boss.spitAttackTimer = 3 + love.math.random(1, 3)
        boss.spitAttackDelay = 2

        local dir = newVec(boss.pos.x - player.collider.x, boss.pos.y - player.collider.y):getRot()

        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(boss.pos.x, boss.pos.y + 36), 250, dir + 33, 18, 12, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("mediumOrb", newVec(boss.pos.x, boss.pos.y + 36), 250, dir, 24, 12, {255,200,200}))
        table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(boss.pos.x, boss.pos.y + 36), 250, dir - 33, 18, 12, {255,200,200}))

    end

    boss.armSlamTimer = boss.armSlamTimer - dt -- Start slam attack
    
    if boss.armSlamTimer < 0 then

        boss.armSlamTimer = 8 + love.math.random(1, 3)
        boss.armGoingToSlamTimer = 3

        boss.slamming = true

    end

    if boss.slamming then -- Slam attack processing

        boss.armGoingToSlamTimer = boss.armGoingToSlamTimer - dt

        if boss.armGoingToSlamTimer < 1 then boss.slamArmBounceAnim = math.sin(3.14 * 8 * boss.armGoingToSlamTimer) * 0.35 end

        if boss.armGoingToSlamTimer < 0 then -- Slam the arm down

            boss.handSlamPos.y = boss.handSlamPos.y + dt * 600
            
            if ROOM.tilemap:getTile(math.floor(boss.handSlamPos.x / 48), math.floor(boss.handSlamPos.y / 48)) ~= nil then -- See if the arm got slammed

                boss.slamming = false

                boss.slamArmBounceAnim = 0.6

                for i = 1, 8 do -- Summon bullets

                    table.insert(enemyProjectiles, newEnemyProjectile("smallOrb", newVec(boss.handSlamPos.x, boss.handSlamPos.y), 250, 45 * i, 18, 12, {255,200,200}))

                end

            end

        else

            boss.handSlamPos.x = lerp(boss.handSlamPos.x, player.collider.x, dt * 5) -- Arm not slammed, it locks to the player
            boss.handSlamPos.y = lerp(boss.handSlamPos.y, 280, dt * 5)

        end
    
    else

        boss.handSlamPos.x = lerp(boss.handSlamPos.x, boss.pos.x - 64, dt * 5) -- Slam attack not initiated, the arm follows the boss
        boss.handSlamPos.y = lerp(boss.handSlamPos.y, boss.pos.y + 64, dt * 5)

        boss.armGoingToSlamTimer = lerp(boss.armGoingToSlamTimer, 3, dt * 4)

    end

    boss.smoke:process()

    boss.handSlamSmoke:process()
    boss.handShootSmoke:process()

end

function drawSkeletonBoss(boss)

    setColor(255, 255, 255, 255 * bossAnimationTimer)

    if boss.flash > 0.8 then love.graphics.setShader(SHADERS.FLASH); SHADERS.FLASH:send("intensity", 1) end -- Flash

    local distortion = clamp((boss.flash - 0.8) / 0.2, 0, 1) * 0.2 -- Draw head and jaw

    drawSprite(SKELETON_BOSS_HEAD, boss.pos.x, boss.pos.y - 12 * (1 - distortion), (1 + distortion) * bossAnimationTimer, (1 - distortion) * bossAnimationTimer)

    drawSprite(SKELETON_BOSS_JAW, boss.pos.x, boss.pos.y + boss.jawOffset + 36 * (1 - distortion), (1 + distortion) * bossAnimationTimer, (1 - distortion) * bossAnimationTimer)

    shine(boss.pos.x, boss.pos.y + 36, 144 * (boss.jawOffset / 48), {255, 30, 30, 150 * (boss.jawOffset / 48)})

    love.graphics.setShader()

    local slammingAnim = 1 - boss.armGoingToSlamTimer / 3
    shine(boss.handSlamPos.x, boss.handSlamPos.y, 144, {255, 60, 60, 80 * slammingAnim * bossAnimationTimer}) -- Draw slamming hand
    
    love.graphics.setColor(1, 0.75 - slammingAnim + 0.25, 0.75 - slammingAnim + 0.25, bossAnimationTimer)
    drawSprite(SKELETON_BOSS_ARM_SLAM, boss.handSlamPos.x, boss.handSlamPos.y, (1 + boss.slamArmBounceAnim) * bossAnimationTimer, (1 - boss.slamArmBounceAnim) * bossAnimationTimer)

    local shootingAnim = clamp(boss.isArmShootingUpTimer, -1, 0) * -1 -- Draw shooting hand

    if boss.isArmShootingUpTimer > 3 then shootingAnim = boss.isArmShootingUpTimer - 3 end

    love.graphics.setColor(1, 0.75 - shootingAnim + 0.25, 0.75 - shootingAnim + 0.25, bossAnimationTimer)
    drawSprite(SKELETON_BOSS_ARM_SHOOT, boss.handShootPos.x, boss.handShootPos.y, bossAnimationTimer, bossAnimationTimer)

    shine(boss.handShootPos.x, boss.handShootPos.y, 144, {255, 60, 60, 80 * shootingAnim * bossAnimationTimer})

    shine(boss.pos.x, boss.pos.y, 444, {255, 255, 255, 20 * bossAnimationTimer}) -- 

end