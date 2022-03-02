
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
    --outlinedText(400, 100, 6, "Metallicus", {255,255,255}, 3, 3, 0.5, 0.5)
    drawSprite(TITLE, 400, 100 + 20 * math.sin(globalTimer * 2))

    if PLAY_BUTTON:process() then sceneAt = "game"; transition = 1 end

    -- Mouse
    love.graphics.draw(mouse[mouseMode], xM, yM, 0, SPRSCL, SPRSCL, mouse[mouseMode]:getWidth() * mCentered, mouse[mouseMode]:getHeight() * mCentered)
    love.graphics.setCanvas(display)

    love.graphics.setCanvas(display)

    -- Return scene
    return sceneAt
end