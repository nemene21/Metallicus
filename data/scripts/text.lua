
FONT = love.graphics.newFont("data/font.ttf",16)
FONT:setFilter("nearest","nearest")

love.graphics.setFont(FONT)

function outlinedText(x,y,w,text,color,cX,cY)
    local color = color or {255,255,255}
    local width = FONT:getWidth(text)
    local cX = cX or 0; local cY = cY or 0

    setColor(0,0,0)
    love.graphics.print(text,x - w,y, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x + w,y, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x,y - w, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x,y + w, 0, 1, 1, width * cX, width * cY)

    love.graphics.print(text,x - w,y - w, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x + w,y + w, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x + w,y - w, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x - w,y + w, 0, 1, 1, width * cX, width * cY)

    love.graphics.print(text,x + w * 2,y, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x,y + w * 2, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x + w * 2,y + w * 2, 0, 1, 1, width * cX, width * cY)
    love.graphics.print(text,x + w,y + w * w, 0, 1, 1, width * cX, width * cY)
    
    setColor(color[1],color[2],color[3])
    love.graphics.print(text,x,y, 0, 1, 1, width * cX, width * cY)
end