
--                                                         <PLAYER PROJECTILES>

PLAYER_PROJECTILE_IMAGES = {
basicSlash = loadSpritesheet("data/images/projectiles/player/basicSlash.png",24,16),
slimeShot = loadSpritesheet("data/images/projectiles/player/slimeShot.png",8,8),
crystalShot = loadSpritesheet("data/images/projectiles/player/crystalShot.png",8,6),
mushboomShot = loadSpritesheet("data/images/projectiles/player/mushboomShot.png",12,10),
bullet = loadSpritesheet("data/images/projectiles/player/bullet.png",13,8),

woodenArrow = loadSpritesheet("data/images/projectiles/player/woodenArrow.png",14,5),
}

PLAYER_PROJECTILE_PARTICLES = {
slimeShot = loadJson("data/particles/playerProjectiles/slimeShot.json"),
mushboomShot = loadJson("data/particles/playerProjectiles/mushboomShot.json"),
crystalShot = loadJson("data/particles/playerProjectiles/crystalShot.json"),
arrowTrail = loadJson("data/particles/playerProjectiles/arrowTrail.json")
}

PLAYER_PROJECTILE_PARTICLES_DIE = {
slimeShot = loadJson("data/particles/playerProjectiles/slimeShotDie.json"),
bullet = loadJson("data/particles/playerProjectiles/bulletDie.json"),

mushboom = loadJson("data/particles/playerProjectiles/mushboomSpawn.json"),
mushboomDie = loadJson("data/particles/playerProjectiles/mushboomDie.json"),
mushboomExplosion = loadJson("data/particles/playerProjectiles/mushboomExplosion.json"),

arrow = loadJson("data/particles/playerProjectiles/arrow.json"),

crystalShot = loadJson("data/particles/playerProjectiles/crystalShotDie.json")
}

-- Init
function newPlayerProjectile(img, frames, interpolate, pos, gravity, speed, dir, damage, range, follow, radius, pirice, knockback, collides, bounces)
    local projectile = {
        draw = drawPlayerProjectile, bounces = bounces, collides = collides, gravity = gravity or 0, knockback = knockback, pirice = pirice, follow = follow,radius = radius, vel = newVec(speed,0), sheet = img, frames = frames, interpolation = interpolate, pos = pos, speed = speed, dir = dir, lifetimeStart = range / speed, lifetime = range / speed, damage = damage, hitlist = {}, process = processPlayerProjectile
    }

    projectile.vel:rotate(dir + 180)

    return projectile
end

-- Interpolations
function sineInterpolation(frames,lifetime,lifetimeStart)
    return math.sin(3.14 * lifetime / lifetimeStart) * (frames - 1) + 1
end

function lerpInterpolation(frames,lifetime,lifetimeStart)
    return lerp(0, frames, 1 - lifetime / lifetimeStart)
end

local interpolations = {lerp=lerpInterpolation, sine=sineInterpolation}

function interpolatePlayerProjectile(interpolation,frames,lifetime,lifetimeStart)
    return clamp(round(interpolations[interpolation](frames,lifetime,lifetimeStart)),1,frames)
end

-- Processing
function processPlayerProjectile(projectile)
    projectile.lifetime = projectile.lifetime - dt

    projectile.vel.y = projectile.vel.y + projectile.gravity * dt

    projectile.pos.x = projectile.pos.x + projectile.vel.x * dt + player.vel.x * dt * projectile.follow

    if projectile.collides then -- Bounce
        tile = ROOM.tilemap:getTile(math.floor(projectile.pos.x / 48), math.floor(projectile.pos.y / 48))
        if tile ~= nil then

            if tile[1] < 3 or tile[2] < 5 then

                projectile.bounces = projectile.bounces - 1

                projectile.pos.x = projectile.pos.x - projectile.vel.x * dt * 2 - player.vel.x * dt * projectile.follow * 2
                projectile.vel.x = projectile.vel.x * - 1

            end

        end
    end

    projectile.pos.y = projectile.pos.y + projectile.vel.y * dt + player.vel.y * dt * projectile.follow

    if projectile.collides then -- Bounce
        tile = ROOM.tilemap:getTile(math.floor(projectile.pos.x / 48), math.floor(projectile.pos.y / 48))
        if tile ~= nil then

            if tile[1] < 3 or tile[2] < 5 then

                projectile.bounces = projectile.bounces - 1

                projectile.pos.y = projectile.pos.y - projectile.vel.y * dt * 2 - player.vel.y * dt * projectile.follow * 2
                projectile.vel.y = projectile.vel.y * - 1

            end

        end
    end
end

function drawPlayerProjectile(projectile)

    setColor(255, 255, 255)
    drawFrame(PLAYER_PROJECTILE_IMAGES[projectile.sheet], interpolatePlayerProjectile(projectile.interpolation, projectile.frames, projectile.lifetime, projectile.lifetimeStart), 1, projectile.pos.x, projectile.pos.y, 1, 1, projectile.vel:getRot() / 180 * 3.14)

end

-- Process player projectiles

function processPlayerProjectiles(playerProjectiles)
    setColor(255,255,255); kill = {}
    for id,P in ipairs(playerProjectiles) do

        if P.particles ~= nil then P.particles.x = P.pos.x; P.particles.y = P.pos.y; P.particles:process(); setColor(255,255,255) end
        P:process()

        if P.bounces < 0 then
            
            if P.particlesDie ~= nil then table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(PLAYER_PROJECTILE_PARTICLES_DIE[P.particlesDie]))) end
            table.insert(kill,id)

            if P.particles ~= nil then P.particles.ticks = 1; table.insert(ROOM.particleSystems, P.particles) end

            if P.explosion ~= nil then

                for id, E in ipairs(ROOM.enemies) do

                    if rectCollidingCircle(E.collider, P.pos.x, P.pos.y, P.explosion.radius) then

                        local vec = newVec(E.collider.x - P.pos.x, E.collider.y - P.pos.y)

                        E:hit(P.explosion.dmg, vec:getLen() * 3, vec:getRot())

                    end

                end

                for id, S in ipairs(ROOM.structures) do

                    if S.name ~= nil then if MATERIAL_CONSTRUCTORS[S.name] ~= nil then

                        if newVec(P.pos.x - S.x, P.pos.y - S.y):getLen() < (36 + P.explosion.radius) then
    
                            S.hp = S.hp - P.explosion.dmg
                            S.hitTimer = 0.2

                            table.insert(ROOM.textPopUps.particles,{
                                x = S.x + love.math.random(-24, 24), y = S.y + love.math.random(-24, 24) - 24,
                                vel = newVec(0, -100), width = tostring(P.explosion.dmg),
                                lifetime = 1, lifetimeStart = 1,
                                color = {r=255,g=0,b=0,a=1},
                                rotation = 0
                            
                            })
                            
                            playSound(S.hitSound, love.math.random(80, 120) * 0.01)

                        end

                    end end

                end

                if P.explosion.particles ~= nil then table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(PLAYER_PROJECTILE_PARTICLES_DIE[P.explosion.particles]))) end
                
            end

        else
            for enemyId,E in ipairs(ROOM.enemies) do

                local isInHitlist = false
                for hitId,H in ipairs(P.hitlist) do if H == E.ID then isInHitlist = true end end

                if not isInHitlist and rectCollidingCircle(E.collider,P.pos.x,P.pos.y,P.radius) and E.hp > 0 then

                    E:hit(P.damage, P.knockback, P.vel:getRot())
                    table.insert(P.hitlist, E.ID)

                    P.pirice = P.pirice - 1
                end

            end
        end

        if P.pirice <= 0 then
            if P.particlesDie ~= nil then table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(PLAYER_PROJECTILE_PARTICLES_DIE[P.particlesDie]))) end
            table.insert(kill,id)

            if P.particles ~= nil then P.particles.ticks = 1; table.insert(ROOM.particleSystems, P.particles) end

            if P.explosion ~= nil then

                for id, E in ipairs(ROOM.enemies) do

                    if rectCollidingCircle(E.collider, P.pos.x, P.pos.y, P.explosion.radius) then

                        local vec = newVec(E.collider.x - P.pos.x, E.collider.y - P.pos.y)

                        E:hit(P.explosion.dmg, vec:getLen() * 3, vec:getRot())

                    end

                end

                for id, S in ipairs(ROOM.structures) do

                    if S.name ~= nil then if MATERIAL_CONSTRUCTORS[S.name] ~= nil then

                        if newVec(P.pos.x - S.x, P.pos.y - S.y):getLen() < (36 + P.explosion.radius) then
    
                            S.hp = S.hp - P.explosion.dmg
                            S.hitTimer = 0.2

                            table.insert(ROOM.textPopUps.particles,{
                                x = S.x + love.math.random(-24, 24), y = S.y + love.math.random(-24, 24) - 24,
                                vel = newVec(0, -100), width = tostring(P.explosion.dmg),
                                lifetime = 1, lifetimeStart = 1,
                                color = {r=255,g=0,b=0,a=1},
                                rotation = 0
                            
                            })
                            
                            playSound(S.hitSound, love.math.random(80, 120) * 0.01)

                        end

                    end end

                end

                if P.explosion.particles ~= nil then table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(PLAYER_PROJECTILE_PARTICLES_DIE[P.explosion.particles]))) end
                
            end

        else
            if P.lifetime < 0 then
                table.insert(kill,id)
                if P.particles ~= nil then P.particles.ticks = 1; table.insert(ROOM.particleSystems, P.particles) end
                if P.particlesDie ~= nil then table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(PLAYER_PROJECTILE_PARTICLES_DIE[P.explosion.particles]))) end
        else
            if P.pos.x < ROOM.endLeft.x - 100 or P.pos.x > ROOM.endRight.x + 100 or P.pos.y < ROOM.endUp.y - 100 or P.pos.y > ROOM.endDown.y + 100 then table.insert(kill, id)
                if P.particles ~= nil then P.particles.ticks = 1; table.insert(ROOM.particleSystems, P.particles) end
            end
        end
        end

    end playerProjectiles = wipeKill(kill,playerProjectiles)
end

--                                                         <ENEMY PROJECTILES>

ENEMY_PROJECTILE_IMAGES = {
    mediumOrb = love.graphics.newImage("data/images/projectiles/enemies/mediumOrb.png"),
    smallOrb = love.graphics.newImage("data/images/projectiles/enemies/smallOrb.png")
}

ENEMY_PROJECTILE_PARTICLES = {
    smallOrb = loadJson("data/particles/enemyProjectiles/enemyBulletSpawned.json"),
    mediumOrb = loadJson("data/particles/enemyProjectiles/enemyBulletSpawned.json")
}

ENEMY_PROJECTILE_DIE_SHOCK = loadJson("data/particles/enemyProjectiles/enemyProjectileDieShock.json")
ENEMY_PROJECTILE_DIE_CIRCLE = loadJson("data/particles/enemyProjectiles/enemyProjectileDieCircle.json")

ENEMY_PROJECTILE_PARTICLES["mediumOrb"].spawnShape.data = 28
ENEMY_PROJECTILE_PARTICLES["mediumOrb"].particleData.width.a = 16
ENEMY_PROJECTILE_PARTICLES["mediumOrb"].particleData.width.b = 20

-- Init
function newEnemyProjectile(img, pos, speed, dir, radius, damage, glowColor)
    local projectile = {
        draw = drawEnemyProjectile, glowColor = glowColor, radius = radius, vel = newVec(speed,0), image = img, frames = frames, interpolation = interpolate, pos = pos, speed = speed, dir = dir, damage = damage, process = processEnemyProjectile
    }

    if ENEMY_PROJECTILE_PARTICLES[img] ~= nil then projectile.spawnParticles = newParticleSystem(pos.x, pos.y, deepcopyTable(ENEMY_PROJECTILE_PARTICLES[img])); projectile.spawnParticles.following = true end
    
    projectile.vel:rotate(dir + 180)
    
    return projectile
end

    -- Processing
function processEnemyProjectile(projectile)

    projectile.pos.x = projectile.pos.x + projectile.vel.x * dt
    projectile.pos.y = projectile.pos.y + projectile.vel.y * dt

    if projectile.spawnParticles ~= nil then
        projectile.spawnParticles.x = projectile.pos.x
        projectile.spawnParticles.y = projectile.pos.y
        projectile.spawnParticles:process()
    end
end

function drawEnemyProjectile(projectile)
    setColor(255, 255, 255)
    drawSprite(ENEMY_PROJECTILE_IMAGES[projectile.image], projectile.pos.x, projectile.pos.y, 1, 1, projectile.vel:getRot() / 180 * 3.14)

    shine(projectile.pos.x, projectile.pos.y, projectile.radius * 5 + math.sin(globalTimer * 3) * 24, projectile.glowColor)
    love.graphics.setCanvas(display)
end

-- Process enemy projectiles

function processEnemyProjectiles(enemyProjectiles)
    setColor(255,255,255); kill = {}

    for id,P in ipairs(enemyProjectiles) do

        P:process()

        if rectCollidingCircle(player.collider, P.pos.x, P.pos.y, P.radius * 0.8) then

            table.insert(kill, id)

            table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(ENEMY_PROJECTILE_DIE_SHOCK)))
            table.insert(ROOM.particleSystems, newParticleSystem(P.pos.x, P.pos.y, deepcopyTable(ENEMY_PROJECTILE_DIE_CIRCLE)))

            player:hit(P.damage)

        else if P.pos.x < ROOM.endLeft.x - 100 or P.pos.x > ROOM.endRight.x + 100 or P.pos.y < ROOM.endUp.y - 100 or P.pos.y > ROOM.endDown.y + 100 then table.insert(kill, id) end
        
        end

    end enemyProjectiles = wipeKill(kill,enemyProjectiles)
end