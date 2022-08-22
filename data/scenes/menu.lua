
function menuReload()
    postPro = "GLOW_AND_LIGHT"

    -- Set bg
    BG = newTilemap(loadSpritesheet("data/images/tilesets/cave/bg.png", 16, 16), 48)
    for x=-1,33 do for y=-1,13 do BG:setTile(x,y,{1,love.math.random(1,3)}) end end -- Place tiles

    BG:buildIndexes()

    PLAY_BUTTON =    newButton(400, 250, "Play")
    OPTIONS_BUTTON = newButton(400, 350, "Options")
    QUIT_BUTTON =    newButton(400, 450, "Quit")

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

    mouseMode = "pointer"

    UIDist = 160

    optionsUI = {}
    optionsUI.masterVolume = newSlider(1200, 80 + UIDist, "Master Volume", OPT.masterVolume, 0.1, "%")
    optionsUI.SFXVolume = newSlider(1200, 80 + UIDist * 2, "Sound Effects Volume", OPT.SFXVolume, 0.1, "%")
    optionsUI.musicVolume = newSlider(1200, 80 + UIDist * 3, "Music Volume", OPT.musicVolume, 0.1, "%")

    optionsUI.screenShake = newSlider(1200, 80 + UIDist * 5, "Screen Shake", OPT.screenShake, 0.1, "%")
    optionsUI.brightness = newSlider(1200, 80 + UIDist * 6, "Brightness", OPT.brightness, 0.1, "%")
    optionsUI.fullscreen = new01Button(1200, 80 + UIDist * 7, "Fullscreen", OPT.fullscreen)
    optionsUI.textPopups = new01Button(1200, 80 + UIDist * 8, "Text Popups", OPT.textPopups)

    optionsUI.tutorial = new01Button(1200, 80 + UIDist * 9, "Tutorial", OPT.tutorial)

    optionsOpen = false

    optionsScroll = 0
    optionsScrollVel = 0

    lerpSpeed = 18

end

function menuDie()
end

function menu()

    lerpSpeed = 18

    -- Reset
    sceneAt = "menu"
    
    setColor(255, 255, 255)
    clear(255, 255, 255)

    BG:draw()

    love.graphics.setCanvas(UI_LAYER)

    drawSprite(TITLE, 400, 100 + 20 * math.sin(globalTimer * 2))

    local challangesYOffset = 600 - 80 + 80 * challangesOffset * challangesOffset - 27

    drawSprite(CHALLANGES_IMAGE, 0, challangesYOffset - 6, 1, 1, 0, 1, 0, 0)
    drawSprite(CHALLANGES_ARROW, 52, challangesYOffset + challangesArrowAnim + 21 - 21 * challangesOffset * challangesOffset, 1, challangesOffset * challangesOffset * 2 - 1, 0, 1, 0, 0)

    if challangesOffset < 0.98 then
        id = 0
        for stringId, C in pairs(challanges) do

            if C.active then love.graphics.setShader() else SHADERS.GRAYSCALE:send("intensity", 1); love.graphics.setShader(SHADERS.GRAYSCALE) end

            local x = 72 + 72 * id
            local y = challangesYOffset + 68

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

    if PLAY_BUTTON:process() then sceneAt = "game"; transition = 1; lerpSpeed = 2 end

    if OPTIONS_BUTTON:process() then optionsOpen = true end

    if QUIT_BUTTON:process() then love.event.quit() end

    if justPressed("escape") then optionsOpen = false; saveJson("OPTIONS.json", OPT) end

    bindCamera(400 + 800 * boolToInt(optionsOpen), 300, 1)

    if camera[1] > 410 then processOptions() end

    -- Mouse
    love.graphics.draw(mouse[mouseMode], xM, yM, 0, SPRSCL, SPRSCL, mouse[mouseMode]:getWidth() * mCentered, mouse[mouseMode]:getHeight() * mCentered)
    love.graphics.setCanvas(display)

    -- Return scene
    return sceneAt
end

function newChallange(sprite, active)

    return {sprite = sprite, active = active or false, anim = 0, scaleAnim = 0}

end

function processOptions()

    -- Scrolling
    optionsScrollVel = lerp(optionsScrollVel, 0, dt * 5)
    optionsScrollVel = optionsScrollVel + getScroll() * 300

    optionsScroll = optionsScroll + optionsScrollVel * dt

    optionsScroll = lerp(optionsScroll, clamp(optionsScroll, -1500, 0), dt * 20)

    outlinedText(1200 - camera[1], 120 - camera[2] + optionsScroll, 3, "Audio", {255, 255, 255}, 3, 3, 0.5, 0.5)

    optionsUI.masterVolume.displayValue = OPT.masterVolume * 100 -- Volume
    optionsUI.masterVolume:process()
    optionsUI.masterVolume:draw()

    OPT.masterVolume = optionsUI.masterVolume:value()

    optionsUI.SFXVolume.displayValue = OPT.SFXVolume * 100
    optionsUI.SFXVolume:process()
    optionsUI.SFXVolume:draw()

    OPT.SFXVolume = optionsUI.SFXVolume:value()

    optionsUI.musicVolume.displayValue = OPT.musicVolume * 100
    optionsUI.musicVolume:process()
    optionsUI.musicVolume:draw()

    OPT.musicVolume = optionsUI.musicVolume:value()

    outlinedText(1200 - camera[1], 120 + UIDist * 4 - camera[2] + optionsScroll, 3, "Graphics", {255, 255, 255}, 3, 3, 0.5, 0.5)

    optionsUI.screenShake.displayValue = OPT.screenShake * 100 -- Graphics
    optionsUI.screenShake:process()
    optionsUI.screenShake:draw()

    OPT.screenShake = optionsUI.screenShake:value()

    optionsUI.brightness.displayValue = OPT.brightness * 100
    optionsUI.brightness:process()
    optionsUI.brightness:draw()

    optionsUI.fullscreen:process()
    optionsUI.fullscreen:draw()
    OPT.fullscreen = optionsUI.fullscreen.value

    optionsUI.textPopups:process()
    optionsUI.textPopups:draw()
    OPT.textPopups = optionsUI.textPopups.value

    optionsUI.tutorial:process()
    optionsUI.tutorial:draw()
    OPT.tutorial = optionsUI.tutorial.value

    OPT.brightness = optionsUI.brightness:value()

end