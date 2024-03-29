--------------------------MISC

function lerp(a,b,c) return a+(b-a)*c end -- A + (B - A) * C

function clamp(val, min, max) -- Clamps a number between two threasholds
    return math.max(min, math.min(val, max))
end

function wrap(n,min,max) -- Wraps a number around two threasholds
    if n < min then n = max end
    if n > max then n = min end
    return n
end

function round(a) return math.floor(a+0.5) end -- floor(A + 0.5)

function floorSnap(a,b) return math.floor(a/b)*b end -- floor(A / B) * B
function snap(a,b) return round(a/b)*b end -- round(A / B) * B

function boolToInt(booleon)
    if booleon then return 1 end
    return 0
end
--------------------------PHYSICS

function newRect(x,y,w,h) return {x=x,y=y,w=w,h=h,touching=newVec(0,0),cR=true,cL=true,cUP=true,cDW=true} end -- Make a new rect

function isRectColliding(rect,R) -- Return if two rects are touching
    return R.x + R.w * 0.5 > rect.x - rect.w * 0.5 and R.x - R.w * 0.5 < rect.x + rect.w * 0.5 and R.y + R.h * 0.5 > rect.y - rect.h * 0.5 and R.y - R.h * 0.5 < rect.y + rect.h * 0.5
end

function checkCollisions(rect,motion,collidesWith) 
    local collided = {}

    -- Loop trough every rect you want to check collision with, if they are touching, add it to a list, return the list
    for id,R in ipairs(collidesWith) do

        if not isRectColliding({x = rect.x - motion.x * dt, y = rect.y - motion.y * dt, w = rect.w, h = rect.h},R) and isRectColliding(rect,R) then
            table.insert(collided,R)
        end
    end
    return collided
end

function moveRect(rect,motion,collidesWith)
    -- Reset touching
    rect.touching = newVec(0,0)

    -- Move x
    rect.x = rect.x + motion.x * dt

    -- Get rects colliding
    local collided = checkCollisions(rect,motion,collidesWith)

    -- Clamp rect according to the collided rects boundries
    for id,R in ipairs(collided) do
        if motion.x < 0 and R.cL then
            rect.x = R.x + R.w * 0.5 + rect.w * 0.5; rect.touching.x = -1
        else if motion.x > 0 and R.cR then
            rect.x = R.x - R.w * 0.5 - rect.w * 0.5; rect.touching.x = 1
        end end
    end

    -- Move y
    rect.y = rect.y + motion.y * dt

    -- Get rects colliding
    local collided = checkCollisions(rect,motion,collidesWith)
    
    -- Clamp rect according to the collided rects boundries
    for id,R in ipairs(collided) do
        if motion.y < 0 and R.cDW then
            rect.y = R.y + R.h * 0.5 + rect.h * 0.5; rect.touching.y = -1
        else if motion.y > 0 and R.cUP then
            rect.y = R.y - R.h * 0.5 - rect.h * 0.5; rect.touching.y = 1
        end end
    end

    return rect
end

-- Draw cool debug rects
function drawCollider(collider, color)
    local color = color or {0, 0, 255, 155}
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", collider.x - collider.w * 0.5 - camera[1], collider.y - collider.h * 0.5 - camera[2], collider.w, collider.h)
end

function drawColliders(colliders)
    setColor(255,100,255, 150)

    for id,C in pairs(colliders) do
        drawCollider(C)
    end
    
    setColor(255,255,255,255)
end

function rectCollidingCircle(rect,cX,cY,rad)
    local x = clamp(cX, rect.x - rect.w * 0.5, rect.x + rect.w * 0.5)
    local y = clamp(cY, rect.y - rect.h * 0.5, rect.y + rect.h * 0.5)
    return newVec(x - cX, y - cY):getLen() < rad
end

--------------------------VECTORS
function newVec(x,y) --Makes new table with x and y
    return {x=x,y=y,getRot=getRot,getLen=getLen,normalize=normalize,rotate=rotate}
end

function getRot(vec) --Do not flip y for some reason, and turn radiens returned to degrees
    return math.atan2(vec.y,vec.x)/math.pi*180
end

function getLen(vec) --Pythagorean theorem (x=a, y=b, len=c, c = sqrt(a^2 + b^2)
    return math.sqrt(vec.x*vec.x+vec.y*vec.y)
end

function normalize(vec) -- Axis / lenght
    local len = getLen(vec)
    if len > 0 then
        vec.x = vec.x / len; vec.y = vec.y / len
    end
    return vec
end

function rotate(vec,angle)

    --Turn degrees to radiens
    local angle = angle * math.pi / 180

    --X = X*cos(ang) - Y*sin(ang), Y = X*sin(ang) + Y*cos(ang)
    local X = vec.x*math.cos(angle) - vec.y*math.sin(angle)
    local Y = vec.x*math.sin(angle) + vec.y*math.cos(angle)

    --set values
    vec.x = X; vec.y = Y
    return vec
end