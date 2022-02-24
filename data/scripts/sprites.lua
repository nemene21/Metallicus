
SPRSCL = 3

-- Spritesheets

function loadSpritesheet(filename,w,h)
    local h = h or w
    local sheet = love.graphics.newImage(filename)
    local x = sheet:getWidth()/w; local y = sheet:getHeight()/h

    local images = {}

    images.w = x; images.h = y

    for i=0,x do table.insert(images,{}) end

    for X=0,x do for Y=0,y do
        images[tostring(X+1)..","..tostring(Y+1)] = love.graphics.newQuad(X*w,Y*h,w,h,sheet)
    end end

    images.texture = sheet

    return images
end

function drawFrame(spritesheet,X,Y,x,y,sx,sy,r,offsetCamera,center)
    local sx = sx or 1; local sy = sy or 1; local r = r or 0; local offsetCamera = offsetCamera or 1; local center = center or 1
    local quad = spritesheet[tostring(X)..","..tostring(Y)]

    local qx,qy,qw,qh = quad:getViewport()

    love.graphics.draw(spritesheet.texture, quad, round(x - camera[1] * offsetCamera), round(y - camera[2] * offsetCamera), r, SPRSCL * sx, SPRSCL * sy, qw * 0.5 * center, qh * 0.5 * center)
end

-- Sprites

function drawSprite(tex,x,y,sx,sy,r,offsetCamera,centerX,centerY)
    local offsetCamera = offsetCamera or 1
    local sx = sx or 1; local sy = sy or 1; local r = r or 0
    love.graphics.draw(tex,round(x-camera[1]*offsetCamera),round(y-camera[2]*offsetCamera),r,SPRSCL*(sx + 0.001),SPRSCL*(sy + 0.001),tex:getWidth() * (centerX or 0.5),tex:getHeight() * (centerY or 0.5))
end