
-- Draw boss die ray

function drawGodRay(pos, w, h, dir, lf)

    local points = {

        newVec(0, h * lf * 0.1),
        newVec(w, h * lf),
        newVec(w, - h * lf),
        newVec(0, - h * lf * 0.1)

    }

    for id, point in ipairs(points) do

        point:rotate(dir)

        point.x = point.x + pos.x - camera[1]
        point.y = point.y + pos.y - camera[2]

    end

    love.graphics.polygon("fill", points[1].x, points[1].y, points[2].x, points[2].y, points[3].x, points[3].y, points[4].x, points[4].y)

end

-- DRAW PARTICLES

OFFSET_PARTICLE_BY_CAMERA = 1

function drawParticleShockwave(P,w)

    love.graphics.setLineStyle("rough")

    love.graphics.setLineWidth(w)

    love.graphics.circle("line",P.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA,P.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA, w)
end

PARTICLE_LIGHT = love.graphics.newImage("data/images/particleLight.png")
function drawParticleCircle(P,w)
    love.graphics.circle("fill",P.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA,P.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA, w)
end

function drawParticleCircleGlow(P,w)

    shine(P.x + 2, P.y + 2, w * 3 + 3, {P.color.r * 255, P.color.g * 255, P.color.b * 255, P.color.a * 255})

    love.graphics.setColor(P.color.r,P.color.g,P.color.b,P.color.a)
    love.graphics.circle("fill",P.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA,P.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA, w)

end

function drawParticleSquare(P,data)
    local w = P.width
    local offset = w * 0.5
    love.graphics.rectangle("fill",P.x - offset - camera[1] * OFFSET_PARTICLE_BY_CAMERA,P.y - offset - camera[2] * OFFSET_PARTICLE_BY_CAMERA, w, w)
end

function drawParticleSpark(P,data)
    local point1 = newVec(P.width * P.lifetime / P.lifetimeStart, 0); local point2 = newVec(0, -P.width * 0.3 * P.lifetime / P.lifetimeStart)
    local point3 = newVec(-P.width * P.lifetime / P.lifetimeStart, 0); local point4 = newVec(0, P.width * 0.3 * P.lifetime / P.lifetimeStart)
    point1:rotate(P.vel:getRot()); point2:rotate(P.vel:getRot()); point3:rotate(P.vel:getRot()); point4:rotate(P.vel:getRot())

    love.graphics.polygon("fill",{
                                point1.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA + P.x, point1.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA + P.y, 
                                point2.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA + P.x, point2.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA + P.y, 
                                point3.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA + P.x, point3.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA + P.y, 
                                point4.x - camera[1] * OFFSET_PARTICLE_BY_CAMERA + P.x, point4.y - camera[2] * OFFSET_PARTICLE_BY_CAMERA + P.y})
end

DRAWS = {
["circle"] = drawParticleCircle,
["circleGlow"] = drawParticleCircleGlow,
["square"] = drawParticleSquare,
["spark"] = drawParticleSpark,
["shockwave"] = drawParticleShockwave
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
function spawnParticlePoint(x,y,data,particleSystem,am,id)
    -- Make a vel var out the speed (range from a to b)
    local newVel = newVec(love.math.random(particleSystem.particleData.speed.a,particleSystem.particleData.speed.b),0)
    -- Rotate by rotation + random spread
    newVel:rotate(particleSystem.rotation + love.math.random(-particleSystem.spread,particleSystem.spread))

    return {newVec(x,y),newVel}
end

function spawnParticleCircle(x,y,data,particleSystem,am,id)
    local particlePos = newVec(love.math.random(0,data),0)

    -- Make a vel var out the speed (range from a to b)
    local newVel = newVec(love.math.random(particleSystem.particleData.speed.a,particleSystem.particleData.speed.b),0)
    -- Rotate by rotation + random spread
    newVel:rotate(particleSystem.rotation + love.math.random(-particleSystem.spread,particleSystem.spread))

    particlePos:rotate(love.math.random(0,360))
    particlePos.x = particlePos.x + x; particlePos.y = particlePos.y + y

    return {particlePos,newVel}
end

function spawnParticleEven(x,y,data,particleSystem,am,id)
    local particlePos = newVec(love.math.random(0,data),0)

    -- Make a vel var out the speed (range from a to b)
    local newVel = newVec(love.math.random(particleSystem.particleData.speed.a, particleSystem.particleData.speed.b),0)
    -- Rotate by rotation + random spread
    newVel:rotate(360 / am * (id + 1) + particleSystem.rotation)

    particlePos:rotate(love.math.random(0,360))
    particlePos.x = particlePos.x + x; particlePos.y = particlePos.y + y
    return {particlePos,newVel}
end

function spawnParticleSquare(x,y,data,particleSystem,am,id)
    local particlePos = newVec(love.math.random(-data[1],data[1]),love.math.random(-data[2],data[2]))

    -- Make a vel var out the speed (range from a to b)
    local newVel = newVec(love.math.random(particleSystem.particleData.speed.a,particleSystem.particleData.speed.b),0)
    -- Rotate by rotation + random spread
    newVel:rotate(particleSystem.rotation + love.math.random(-particleSystem.spread,particleSystem.spread))

    particlePos.x = particlePos.x + x; particlePos.y = particlePos.y + y
    return {particlePos,newVel}
end

SPAWNS = {
["point"] = spawnParticlePoint,
["circle"] = spawnParticleCircle,
["square"] = spawnParticleSquare,
["even"] = spawnParticleEven
}

-- CONSTRUCT AND PROCESS

function newParticleSystem(x,y,data)
    data.x = x; data.y = y; data.particles = {}; data.process = processParticleSystem
    return data
end

function processParticleSystem(particleSystem)

    table.insert(ALL_PARTICLES, particleSystem)

end

ALL_PARTICLES = {}

function processParticleSystems()

    love.graphics.setCanvas(particleCanvas)

    for id, particleSystem in ipairs(ALL_PARTICLES) do

        OFFSET_PARTICLE_BY_CAMERA = particleSystem.offsetByCamera or 1

        particleSystem.timer = particleSystem.timer - dt
    
        if particleSystem.timer < 0 and particleSystem.ticks ~= 0 and particleSystem.spawning then
            
            particleSystem.ticks = particleSystem.ticks - 1
            particleSystem.timer = love.math.random(particleSystem.tickSpeed.a*100,particleSystem.tickSpeed.b*100)*0.01
    
            particlesGoingToSpawn = love.math.random(particleSystem.amount.a,particleSystem.amount.b)
    
            for i=0,particlesGoingToSpawn do
                
                -- Make pos
                local data = SPAWNS[particleSystem.spawnShape.mode](particleSystem.x,particleSystem.y,particleSystem.spawnShape.data,particleSystem,particlesGoingToSpawn,i)
    
                local particlePos = data[1]; local newVel = data[2]
    
                -- Make lifetime
                newLf = love.math.random(particleSystem.particleData.lifetime.a*100,particleSystem.particleData.lifetime.b*100)/100
                -- Rgba
                local r=love.math.random(particleSystem.particleData.color.r.a*100,particleSystem.particleData.color.r.b*100)*0.01
                local g=love.math.random(particleSystem.particleData.color.g.a*100,particleSystem.particleData.color.g.b*100)*0.01
                local b=love.math.random(particleSystem.particleData.color.b.a*100,particleSystem.particleData.color.b.b*100)*0.01
                local a=love.math.random(particleSystem.particleData.color.a.a*100,particleSystem.particleData.color.a.b*100)*0.01
    
                -- Width
                local width = nil
                if type(particleSystem.particleData.width) == "table" then
                    width = love.math.random(particleSystem.particleData.width.a,particleSystem.particleData.width.b)
                else
                    width = particleSystem.particleData.width
                end
    
                -- SET ALL THE VALUES OF THE PARTICLE AND APPEND IT TO THE LIST
                table.insert(particleSystem.particles,{
                    x=particlePos.x, y=particlePos.y,
                    vel=newVel,
                    width=width, 
                    lifetime=newLf, lifetimeStart=newLf,
                    color={r=r,g=g,b=b,a=a},
                    rotation=love.math.random(particleSystem.particleData.rotation.a,particleSystem.particleData.rotation.b)
                })
            end
        end
    
        local kill = {}
    
        for id,P in ipairs(particleSystem.particles) do
    
            -- Set color to particles color
            love.graphics.setColor(P.color.r, P.color.g, P.color.b, P.color.a)
    
            -- Add velocity to position
    
            if particleSystem.lastX ~= nil and particleSystem.lastY ~= nil then
                P.x = P.x - (particleSystem.lastX - particleSystem.x)
                P.y = P.y - (particleSystem.lastY - particleSystem.y)
            end
    
            P.x = P.x + P.vel.x * dt; P.y = P.y + P.vel.y * dt
    
            -- Rotate vector by rotation and add force
            P.vel:rotate(P.rotation * dt) 
            P.vel.x = P.vel.x + particleSystem.force.x * dt
            P.vel.y = P.vel.y + particleSystem.force.y * dt
            
            -- Decrease lifetime
            P.lifetime = P.lifetime - dt
    
            -- Kill if lifetime < 0
            if P.lifetime < 0 then table.insert(kill,id)end
    
            -- Get width
            local particleWidth = INTERPOLATIONS[particleSystem.interpolation](P.width, P.lifetime, P.lifetimeStart)
            
            -- Draw
            DRAWS[particleSystem.particleData.drawMode](P, particleWidth)
            
        end particleSystem.particles = wipeKill(kill, particleSystem.particles)
    
        if particleSystem.following == true then
            particleSystem.lastX = particleSystem.x; particleSystem.lastY = particleSystem.y
        end
    
    end

    love.graphics.setCanvas(display)

    ALL_PARTICLES = {}
end