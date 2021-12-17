
-- DRAW PARTICLES

function drawParticleCircle(P,w)
    love.graphics.circle("fill",P.x - camera[1],P.y - camera[2],w)
end

function drawParticleCircleGlow(P,w)
    love.graphics.circle("fill",P.x - camera[1],P.y - camera[2],w)
    love.graphics.setColor(P.color.r,P.color.g,P.color.b,P.color.a*0.4)
    love.graphics.circle("fill",P.x - camera[1],P.y - camera[2],w * 1.4)
end

function drawParticleSquare(P,w)
    offset = w*0.5
    love.graphics.rectangle("fill",P.x-offset - camera[1],P.y-offset - camera[2],w,w)
end

DRAWS = {
["circle"] = drawParticleCircle,
["circleGlow"] = drawParticleCircleGlow,
["square"] = drawParticleSquare
}
-- INTERPOLATE WIDTH
function interpolateParticleSine(w,lf,lfS)
    return w * math.sin(3.14 * lf / lfS)
end

function interpolateParticleLinear(w,lf,lfS)
    return w * lf / lfS
end

INTERPOLATIONS = {
["linear"] = interpolateParticleLinear,
["sine"] = interpolateParticleSine
}
-- SPAWN PARTICLES
function spawnParticlePoint(x,y,data)
    return newVec(x,y)
end

function spawnParticleCircle(x,y,data)
    particlePos = newVec(love.math.random(0,data),0)
    particlePos = rotateVec(particlePos,love.math.random(0,360))
    particlePos.x = particlePos.x + x; particlePos.y = particlePos.y + y
    return particlePos
end

function spawnParticleSquare(x,y,data)
    particlePos = newVec(love.math.random(-data[1],data[1]),love.math.random(-data[2],data[2]))
    particlePos.x = particlePos.x + x; particlePos.y = particlePos.y + y
    return particlePos
end

SPAWNS = {
["point"] = spawnParticlePoint,
["circle"] = spawnParticleCircle,
["square"] = spawnParticleSquare
}

-- CONSTRUCT AND PROCESS

function newParticleSystem(x,y,data)
    data.x = x; data.y = y; data.particles = {}; data.process = processParticleSystem
    return data
end

function processParticleSystem(particleSystem)
    particleSystem.timer = particleSystem.timer - dt

    if particleSystem.timer < 0 and particleSystem.ticks ~= 0 then
        
        particleSystem.ticks = particleSystem.ticks - 1
        particleSystem.timer = love.math.random(particleSystem.tickSpeed.a*100,particleSystem.tickSpeed.b*100)*0.01

        for i=0,love.math.random(particleSystem.amount.a,particleSystem.amount.b) do
            -- Make pos
            particlePos = SPAWNS[particleSystem.spawnShape.mode](particleSystem.x,particleSystem.y,particleSystem.spawnShape.data)
            -- Make lifetime
            newLf = love.math.random(particleSystem.particleData.lifetime.a*100,particleSystem.particleData.lifetime.b*100)/100
            -- Make a vel var out the speed (range from a to b)
            newVel = newVec(love.math.random(particleSystem.particleData.speed.a,particleSystem.particleData.speed.b),0)
            -- Rotate by rotation + random spread
            newVel:rotate(particleSystem.rotation + love.math.random(-particleSystem.spread,particleSystem.spread))
            -- Rgba
            r=love.math.random(particleSystem.particleData.color.r.a*100,particleSystem.particleData.color.r.b*100)*0.01
            g=love.math.random(particleSystem.particleData.color.g.a*100,particleSystem.particleData.color.g.b*100)*0.01
            b=love.math.random(particleSystem.particleData.color.b.a*100,particleSystem.particleData.color.b.b*100)*0.01
            a=love.math.random(particleSystem.particleData.color.a.a*100,particleSystem.particleData.color.a.b*100)*0.01

            -- SET ALL THE VALUES OF THE PARTICLE AND APPEND IT TO THE LIST
            table.insert(particleSystem.particles,{
                x=particlePos.x, y=particlePos.y, 
                vel=newVel, 
                width=love.math.random(particleSystem.particleData.width.a,particleSystem.particleData.width.b), 
                lifetime=newLf, lifetimeStart=newLf,
                color={r=r,g=g,b=b,a=a},
                rotation=love.math.random(particleSystem.particleData.rotation.a,particleSystem.particleData.rotation.b)
            })
        end
    end

    kill = {}
    for id,P in pairs(particleSystem.particles) do
        -- Set color to particles color
        love.graphics.setColor(P.color.r,P.color.g,P.color.b,P.color.a)

        -- Add velocity to position
        P.x = P.x + P.vel.x * dt; P.y = P.y + P.vel.y * dt

        -- Rotate vector by rotation and add force
        P.vel:rotate(P.rotation * dt)
        P.vel.x = P.vel.x + particleSystem.force.x * dt
        P.vel.y = P.vel.y + particleSystem.force.y * dt

        -- Decrease lifetime
        P.lifetime = P.lifetime - dt

        -- Kill if lifetime < 0
        if P.lifetime < 0 then table.insert(kill,id) end

        -- Get width
        particleWidth = INTERPOLATIONS[particleSystem.interpolation](P.width,P.lifetime,P.lifetimeStart)

        -- Draw
        DRAWS[particleSystem.particleData.drawMode](P,particleWidth)
    end

    killed = 0
    for id,P in pairs(kill) do
        table.remove(particleSystem.particles,P-killed)
        killed = killed + 1
    end
end