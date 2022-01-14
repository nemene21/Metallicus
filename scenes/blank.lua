
function blankReload()
end

function blankDie()
end

function blank()
    -- Reset
    sceneAt = "blank"
    
    setColor(255, 255, 255)
    clear(255, 20, 255)

    -- Return scene
    return sceneAt
end