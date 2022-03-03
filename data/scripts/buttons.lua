
BUTTON_IMAGE = love.graphics.newImage("data/images/UI/button.png")

function newButton(x, y, text)
    return {x = x, y = y, text = text, animation = 0, process = processButton}
end

function processButton(btn)

    local pressed = false

    if xM > btn.x - 96 and xM < btn.x + 96 and yM > btn.y - 36 and yM < btn.y + 36 then

        btn.animation = lerp(btn.animation, 1, dt * 10)

        if mouseJustPressed(1) then pressed = true end

    else

        btn.animation = lerp(btn.animation, 0, dt * 10)

    end
    
    local scale = 1 + 0.2 * btn.animation
    local offsetY = - 16 * btn.animation

    SHADERS.FLASH:send("intensity", btn.animation * 0.2)
    love.graphics.setShader(SHADERS.FLASH)

    drawSprite(BUTTON_IMAGE, btn.x, btn.y + offsetY, scale, scale)
    outlinedText(btn.x, btn.y + offsetY - 6, 2, btn.text, {255, 255, 255}, scale + 0.8, scale + 0.8, 0.5, 0.5)

    love.graphics.setShader()
    return pressed
end