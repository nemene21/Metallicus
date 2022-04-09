
-- Add float
function ACTIVE_ITEM_EFFECT_ADD_FLOAT(item)

    player.float = item.floatAdding

end

-- Projectile burst

function ACTIVE_ITEM_EFFECT_PROJECTILE_BURST(item)

    item.burst = item.burstAdding

end

function ACTIVE_ITEM_PROCESS_PROJECTILE_BURST(item)

    item.burstTimer = item.burstTimer - dt

    if item.burstTimer < 0 and item.burst ~= 0 then

        local rotation = newVec(player.collider.x - camera[1] - xM, player.collider.y - camera[2] - yM + 8); rotation = rotation:getRot() + 180
        local pos = newVec(-24, 0); pos:rotate(rotation)

        item.burst = item.burst - 1
        item.burstTimer = item.burstSpeed

        -- Summon projectile
        local rotation = newVec(player.collider.x - camera[1] - xM + pos.x, player.collider.y - camera[2] - yM + 8 + pos.y); rotation = rotation:getRot() + 180 + love.math.random(-30, 30)
        local projectile = newPlayerProjectile(item.projectile.texture, PLAYER_PROJECTILE_IMAGES[item.projectile.texture].w, "lerp", newVec(player.collider.x, player.collider.y), item.projectile.gravity, item.projectile.speed, rotation + 180 + love.math.random(-item.projectile.spread, item.projectile.spread), round(item.stats.dmg), item.projectile.range, item.projectile.followPlayer, item.projectile.radius, item.projectile.pirice, item.projectile.knockback, item.projectile.collides, item.projectile.bounces)
    
        if item.explosion ~= nil then
    
            projectile.explosion = deepcopyTable(item.explosion)
    
        end
    
        if item.projectile.particlesDie ~= nil then projectile.particlesDie = item.projectile.particlesDie end
    
        if item.projectile.particles ~= nil then projectile.particles = newParticleSystem(player.collider.x, player.collider.y, deepcopyTable(PLAYER_PROJECTILE_PARTICLES[item.projectile.particles])) end
    
        shake(2, 1, 0.15, rotation)
        if item.projectile.sound ~= nil then playSound(item.projectile.sound, love.math.random(80, 120) * 0.01) end
    
        table.insert(playerProjectiles,projectile)

    end

end

ACTIVE_ITEM_EFFECTS = {

addFloat = ACTIVE_ITEM_EFFECT_ADD_FLOAT,

projectileBurst = ACTIVE_ITEM_EFFECT_PROJECTILE_BURST

}

ACTIVE_ITEM_PROCESSES = {

projectileBurst = ACTIVE_ITEM_PROCESS_PROJECTILE_BURST

}