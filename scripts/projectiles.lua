
--                                                         <PLAYER PROJECTILES>

PLAYER_PROJECTILE_IMAGES = {
    basicSlash = loadSpritesheet("data/images/projectiles/player/basicSlash.png",24,16)
}

-- Init
function newPlayerProjectile(img, frames, interpolate, pos, speed, dir, damage, range, follow, radius, pirice, knockback)
    local projectile = {
        knockback = knockback, pirice = pirice, follow = follow,radius = radius, vel = newVec(speed,0), sheet = img, frames = frames, interpolation = interpolate, pos = pos, speed = speed, dir = dir, lifetimeStart = range / speed, lifetime = range / speed, damage = damage, hitlist = {}, process = processPlayerProjectile
    }

    projectile.vel:rotate(dir + 180)

    return projectile
end

-- Interpolations
function sineInterpolation(frames,lifetime,lifetimeStart)
    return math.sin(3.14 * lifetime / lifetimeStart) * (frames - 1) + 1
end

function lerpInterpolation(frames,lifetime,lifetimeStart)
    return lerp(0, frames, lifetime / lifetimeStart)
end

local interpolations = {lerp=lerpInterpolation, sine=sineInterpolation}

function interpolatePlayerProjectile(interpolation,frames,lifetime,lifetimeStart)
    return clamp(round(interpolations[interpolation](frames,lifetime,lifetimeStart)),1,frames)
end

-- Processing
function processPlayerProjectile(projectile)
    projectile.lifetime = projectile.lifetime - dt

    projectile.pos.x = projectile.pos.x + projectile.vel.x * dt + player.vel.x * dt * projectile.follow
    projectile.pos.y = projectile.pos.y + projectile.vel.y * dt + player.vel.y * dt * projectile.follow

    drawFrame(PLAYER_PROJECTILE_IMAGES[projectile.sheet], interpolatePlayerProjectile(projectile.interpolation, projectile.frames, projectile.lifetime, projectile.lifetimeStart), 1, projectile.pos.x, projectile.pos.y, 1, 1, projectile.vel:getRot() / 180 * 3.14)
end

-- Process player projectiles

function processPlayerProjectiles(playerProjectiles)
    setColor(255,255,255); kill = {}
    for id,P in ipairs(playerProjectiles) do
        P:process()

        for id,E in ipairs(ROOM.enemies) do

            local isInHitlist = false
            for id,H in ipairs(P.hitlist) do if H == E.ID then isInHitlist = true; break end end

            if not isInHitlist and rectCollidingCircle(E.collider,P.pos.x,P.pos.y,P.radius) and E.hp > 0 then

                E:hit(P.damage, P.knockback, P.vel:getRot())
                table.insert(P.hitlist, E.ID)

                P.pirice = P.pirice - 1

                if P.pirice == 0 then

                    table.insert(kill,id); break

                end
            end

        end

        if P.lifetime < 0 then table.insert(kill,id) end

    end playerProjectiles = wipeKill(kill,playerProjectiles)
end

--                                                         <ENEMY PROJECTILES>

ENEMY_PROJECTILE_IMAGES = {
    mediumOrb = love.graphics.newImage("data/images/projectiles/enemies/mediumOrb.png")
}
    
-- Init
function newEnemyProjectile(img, pos, speed, dir, radius, damage, glowColor)
    local projectile = {
        glowColor = glowColor, radius = radius, vel = newVec(speed,0), image = img, frames = frames, interpolation = interpolate, pos = pos, speed = speed, dir = dir, damage = damage, process = processEnemyProjectile
    }
    
    projectile.vel:rotate(dir + 180)
    
    return projectile
end

    -- Processing
function processEnemyProjectile(projectile)

    projectile.pos.x = projectile.pos.x + projectile.vel.x * dt
    projectile.pos.y = projectile.pos.y + projectile.vel.y * dt
    
    drawSprite(ENEMY_PROJECTILE_IMAGES[projectile.image], projectile.pos.x, projectile.pos.y, 1, 1, projectile.vel:getRot() / 180 * 3.14)

    shine(projectile.pos.x, projectile.pos.y, projectile.radius * 5 + math.sin(globalTimer * 3) * 4, projectile.glowColor)
end

-- Process enemy projectiles

function processEnemyProjectiles(enemyProjectiles)
    setColor(255,255,255); kill = {}
    for id,P in ipairs(enemyProjectiles) do

        P:process()

        if rectCollidingCircle(player.collider, P.pos.x, P.pos.y, P.radius - 3) then table.insert(kill, id) end

    end enemyProjectiles = wipeKill(kill,enemyProjectiles)
end