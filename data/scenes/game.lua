
function gameReload()
    
    
    player = newPlayer(400,300,{})
    open = false

    postPro = {"GLOW"}
end

function gameDie()
end

function game()
    -- Reset
    sceneAt = "game"
    
    setColor(255, 255, 255)
    clear(100, 100, 100)

    player:process()

    love.window.setTitle(tostring(love.timer.getFPS()))

    -- Return scene
    return sceneAt
end