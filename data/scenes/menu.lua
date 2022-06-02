
function menuReload()
    postPro = "GLOW_AND_LIGHT"

    -- Set bg
    BG = newTilemap(loadSpritesheet("data/images/tilesets/cave/bg.png", 16, 16), 48)
    for x=-1,16 do for y=-1,13 do BG:setTile(x,y,{1,love.math.random(1,3)}) end end -- Place tiles

    BG:buildIndexes()

    PLAY_BUTTON = newButton(400, 300, "Play")

    camera = {0,0}; boundCamPos = {0,0}; zoomInEffect = 1; UI_ALPHA = 255
    cameraWallOffset = 100

    TITLE = love.graphics.newImage("data/images/TITLE.png")

    ambientLight = {120, 120, 120}

    occlusion = 1

    CHALLANGES_IMAGE = love.graphics.newImage("data/images/UI/challanges.png")
    CHALLANGES_ARROW = love.graphics.newImage("data/images/UI/challangesArrow.png")

    challangesOpen = false
    challangesOffset = 1

    challangesArrowAnim = 0

    challanges = {

        lightsOff = newChallange(love.graphics.newImage("data/images/UI/challanges/lightsOff.png"))

    }
end

function menuDie()
end

function menu()
    -- Reset
    sceneAt = "menu"
    
    setColor(255, 255, 255)
    clear(255, 255, 255)

    BG:draw()

    love.graphics.setCanvas(UI_LAYER)

    drawSprite(TITLE, 400, 100 + 20 * math.sin(globalTimer * 2))

    local challangesYOffset = 600 - 122 + 122 * challangesOffset * challangesOffset - 27

    drawSprite(CHALLANGES_IMAGE, 0, challangesYOffset - 6, 1, 1, 0, 1, 0, 0)
    drawSprite(CHALLANGES_ARROW, 52, challangesYOffset + challangesArrowAnim + 21 - 21 * challangesOffset * challangesOffset, 1, challangesOffset * challangesOffset * 2 - 1, 0, 1, 0, 0)

    if challangesOffset < 0.98 then
        id = 0
        for stringId, C in pairs(challanges) do

            if C.active then love.graphics.setShader() else SHADERS.GRAYSCALE:send("intensity", 1); love.graphics.setShader(SHADERS.GRAYSCALE) end

            local x = 72 + 72 * id
            local y = challangesYOffset + 88

            C.scaleAnim = math.max(C.scaleAnim - dt, 0)

            drawSprite(C.sprite, x, y + C.anim * - 12, C.scaleAnim + 1, C.scaleAnim + 1)

            if xM > x - 36 and xM < x + 36 and yM > y - 36 and yM < y + 36 then

                C.anim = lerp(C.anim, 1, dt * 12)

                if mouseJustPressed(1) then C.active = not C.active
                    
                    C.scaleAnim = 0.2
                
                end

            else

                C.anim = lerp(C.anim, 0, dt * 12)

            end

            id = id + 1

        end

        love.graphics.setShader()

    end

    if xM > 21 and xM < 120 and yM > challangesYOffset - 4 and yM < challangesYOffset + 26 then

        challangesArrowAnim =  math.max(challangesArrowAnim - dt * 100, - 12)
        
        if mouseJustPressed(1) then challangesOpen = not challangesOpen end

    else

        challangesArrowAnim = math.min(challangesArrowAnim + dt * 100, 0)

    end

    challangesOffset = clamp(challangesOffset + dt * 5 * (boolToInt(not challangesOpen) * 2 - 1), 0, 1)

    if PLAY_BUTTON:process() then sceneAt = "game"; transition = 1 end

    -- Mouse
    love.graphics.draw(mouse[mouseMode], xM, yM, 0, SPRSCL, SPRSCL, mouse[mouseMode]:getWidth() * mCentered, mouse[mouseMode]:getHeight() * mCentered)
    love.graphics.setCanvas(display)

    -- Return scene
    return sceneAt
end

function newChallange(sprite, active)

    return {sprite = sprite, active = active or false, anim = 0, scaleAnim = 0}

end