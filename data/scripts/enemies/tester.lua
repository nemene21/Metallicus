
function buildTester(x, y)
    return {
        hp = 999999999,

        knockback = newVec(0,0), knockBackResistance = 0,

        image = "TESTER",

        collider = newRect(x,y,48,30),
        
        state = "idle",

        scaleX = 1, scaleY = 1,

        drops = {},

        damageResistance = 10,

        states = {
            idle = testerStateIdle
        }
    }
end

function testerStateIdle(tester)

    tester.hp = 999999999

    SHADERS.FLASH:send("intensity", boolToInt(tester.flash > 0.5))

    love.graphics.setShader(SHADERS.FLASH)

    drawSprite(ENEMY_IMAGES[tester.image], tester.collider.x, tester.collider.y, tester.scaleX, tester.scaleY, tester.knockback.x * 0.002) -- Draw
    
    love.graphics.setShader()

end