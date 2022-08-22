
function newTextDisplayer(x, y, text)

    return {x = x, y = y, text = text, process = processTextDisplayer, draw = drawTextDisplayer}

end

function drawTextDisplayer(textDisplayer)

    love.graphics.setCanvas(UI_LAYER)
    outlinedText(textDisplayer.x - camera[1], textDisplayer.y - camera[2] + 12 * math.sin(globalTimer * 2), 3, textDisplayer.text, {255, 255, 255}, 1.5, 1.5, 0.5, 0.5)
    love.graphics.setCanvas(display)

end

function processTextDisplayer(textDisplayer) end