
function buildSkeletonMiner(x, y)
    return {
        hp = 200,

        knockback = newVec(0,0), knockBackResistance = 1,

        image = "SKELETON_MINER",

        collider = newRect(x,y,28,56),
        
        state = "attacking", nextStateTimer = love.math.random(1,3),

        scaleX = 1, scaleY = 1,

        vel = 0,

        drops = {bone = 350},

        states = {
            attacking = skeletonMinerStateAttacking
        }
    }
end

function skeletonMinerStateAttacking(enemy)

    enemy.collider = moveRect(enemy.collider, newVec(enemy.vel + enemy.knockback.x, enemy.knockback.y), ROOM.tilemap.collidersWithFalltrough)

    local spriteYOffset = 9
    local turn = boolToInt(enemy.collider.x < player.collider.x) * 2 - 1

    drawSprite(ENEMY_IMAGES[enemy.image].body, enemy.collider.x, enemy.collider.y + math.sin(globalTimer * 2) * 2 + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].head, enemy.collider.x, enemy.collider.y - 20 + math.sin(globalTimer * 2 + 1.5) * 4 + spriteYOffset, turn)

    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x - 16 * turn, enemy.collider.y + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x + 16 * turn, enemy.collider.y + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x - 12 * turn, enemy.collider.y + 16 + spriteYOffset, turn)
    drawSprite(ENEMY_IMAGES[enemy.image].arm, enemy.collider.x + 12 * turn, enemy.collider.y + 16 + spriteYOffset, turn)

end

