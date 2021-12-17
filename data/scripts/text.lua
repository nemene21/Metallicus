
FONT = love.graphics.newFont("data/font.ttf",16)
FONT:setFilter("nearest","nearest")

love.graphics.setFont(FONT)

function outlinedText(x,y,w,text,color)
    local color = color or {255,255,255}
    local width = FONT:getWidth(text)

    setColor(0,0,0)
    love.graphics.print(text,x - w,y, 0, 1, 1, width)
    love.graphics.print(text,x + w,y, 0, 1, 1, width)
    love.graphics.print(text,x,y - w, 0, 1, 1, width)
    love.graphics.print(text,x,y + w, 0, 1, 1, width)
    
    setColor(color[1],color[2],color[3])
    love.graphics.print(text,x,y, 0, 1, 1, width)
end