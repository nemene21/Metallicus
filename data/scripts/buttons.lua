
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

    if btn.animation > 0.01 then

        setColor(38, 43, 68)
        love.graphics.rectangle("fill", 0, btn.y - 32 * btn.animation, 800, 64 * btn.animation)

    end

    outlinedText(btn.x, btn.y, 2, btn.text, {255, 255, 255}, scale + 0.8, scale + 0.8, 0.5, 0.5)

    return pressed
end


interactIconScale = 0; interacting = false

interactLastPos = newVec(0, 0)

function processInteract()

    interactIconScale = lerp(interactIconScale, boolToInt(interacting), dt * 20)

    if interactIconScale > 0 and not interacting then

        drawInteract(interactLastPos.x, interactLastPos.y)

    end

    interacting = false

end

function drawInteract(x, y, fromProcess)

    interacting = true; interactLastPos = newVec(x, y)
    
    local sine = math.sin(globalTimer * 2)
    drawSprite(IMAGE_F, x, y + sine * 10, (1 + math.sin(globalTimer * 10) * 0.1) * interactIconScale, (1 + math.sin(globalTimer * 10 + 3.14) * 0.1) * interactIconScale)

end