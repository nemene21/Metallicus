
SPIN_TRAP_BALL = love.graphics.newImage("data/images/structures/spinTrap/ball.png")
SPIN_TRAP_WOOD_BLOCK = love.graphics.newImage("data/images/structures/spinTrap/woodBlock.png")
SPIN_TRAP_CHAIN = love.graphics.newImage("data/images/structures/spinTrap/chain.png")

SPIN_TRAP_PARTICLES = loadJson("data/particles/structures/spinTrap.json")

function newSpinTrap(x, y, data)
    local spinTrap = {

        x = x, y = y,
        rotation = 0,
        lenght = data[4] or 3,

        draw = drawSpinTrap,
        process = processSpinTrap,

        particles = newParticleSystem(x, y, deepcopyTable(SPIN_TRAP_PARTICLES))

    }

    return spinTrap
end

function processSpinTrap(spinTrap)

    spinTrap.rotation = spinTrap.rotation + dt * 3.8

    if spinTrap.rotation > 6.28 then spinTrap.rotation = spinTrap.rotation - 6.28 end

end

function drawSpinTrap(spinTrap)

    local ballPos = newVec(spinTrap.lenght * 48, 0):rotate(spinTrap.rotation / 3.14 * 180)
    local len = ballPos:getLen() / 24
    local chainOffset = newVec(ballPos.x / len, ballPos.y / len)


    ballPos.x = ballPos.x * (1 + math.sin(spinTrap.rotation) * 0.2)
    ballPos.y = ballPos.y * (1 + math.sin(spinTrap.rotation) * 0.2)

    for i=0, len - 2 do

        drawSprite(SPIN_TRAP_CHAIN, spinTrap.x + chainOffset.x * i, spinTrap.y + chainOffset.y * i, 1, 1, spinTrap.rotation, 1, 0)

    end

    ballPos.x = ballPos.x + spinTrap.x; ballPos.y = ballPos.y + spinTrap.y
    drawSprite(SPIN_TRAP_WOOD_BLOCK, spinTrap.x, spinTrap.y)

    spinTrap.particles.x = ballPos.x; spinTrap.particles.y = ballPos.y
    spinTrap.particles:process()

    drawSprite(SPIN_TRAP_BALL, ballPos.x, ballPos.y)

    local offset = math.sin(globalTimer * 2) * 10
    shine(ballPos.x, ballPos.y, 160 + offset, {255, 255, 255, 80})
    shine(ballPos.x, ballPos.y, 130 + offset, {0, 0, 0})
    shine(ballPos.x, ballPos.y, 40 + offset, {255, 255, 255, 120})

    if rectCollidingCircle(player.collider, ballPos.x, ballPos.y, 26) then

        player:hit(12, newVec(1200, 0):rotate(spinTrap.rotation / 3.14 * 180 + 90))

    end

end
