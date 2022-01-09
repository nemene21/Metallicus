
-- All global values used in all scenes (display, textures, options, etc.)
function love.load()

    -- Get screenRes
    screenRes = {love.graphics.getWidth(),love.graphics.getHeight()}

    -- Window and defaulting
    globalTimer = 0; love.graphics.setDefaultFilter("nearest","nearest")

    fullscreen = false; title = "¨Gaem"

    WS = {800, 600}; wFlags = {resizable=true}; UI_LAYER = love.graphics.newCanvas(WS[1],WS[2])
    aspectRatio = {WS[1]/WS[2], WS[2]/WS[1]}
    love.graphics.setBackgroundColor(0,0,0,1); love.window.setMode(WS[1], WS[2], wFlags); display = love.graphics.newCanvas(WS[1], WS[2]); displayScale = 1
    postProCanvas = love.graphics.newCanvas(WS[1],WS[2])

    love.window.setTitle(title.."                   [F1 for fullscreen]")

    -- Imports
    json = require "data.scripts.json"; require "data.scripts.misc"; require "data.scripts.loading"; require "data.scripts.shaders"; require "data.scripts.mathPlus"; require "data.scripts.input"; require "data.scripts.sprites"; require "data.scripts.particles"
    require "data.scripts.enemies"; require "data.scripts.projectiles"; require "data.scripts.audio"; require "data.scripts.generation"; require "data.scripts.tiles"; require "data.scripts.text"; require "data.scripts.timer"; require "data.scripts.camera"; require "data.scripts.inventory"; require "data.scripts.player"
    
    -- Mouse
    love.mouse.setVisible(false)
    mouseMode = "pointer"
    mouse = {["pointer"] = love.graphics.newImage("data/images/mouse/pointer.png"), ["aimer"] = love.graphics.newImage("data/images/mouse/aimer.png")}; mCentered = 0
    mouseOffset = {0,0}

    -- Scenes
    require "data.scenes.blank"; require "data.scenes.splashScreen"; require "data.scenes.game"
    scenes = {
    ["splash"] = {splashScreen,splashScreenReload,splashScreenDie},
    ["game"] = {game,gameReload,gameDie}
    }

    -- Set default scene (the first one)
    scene = "game"; firstScene = "game"
    scenes[scene][2]()

    -- Set joysticks
    JOYSTICKS = love.joystick.getJoysticks()
    JOYSTICK_LAST_PRESSES = {}
    for id,J in pairs(JOYSTICKS) do JOYSTICK_LAST_PRESSES[id] = "none" end

    -- Transitions
    transition = 1; transitionSpeed = 0.75

    MIN_DELTA = 1 / 30
end

-- Play scenes
function love.draw()

    -- Time and resetting
    dt = math.min(love.timer.getDelta(), MIN_DELTA)
    globalTimer = globalTimer + dt
    
    -- Mouse pos
    xM, yM = love.mouse.getPosition()

    w, h = love.graphics.getDimensions()
    dw, dh = display:getDimensions()

    xM = clamp(xM,w*0.5-dw*0.5*displayScale,w*0.5+dw*0.5*displayScale)
    yM = clamp(yM,h*0.5-dh*0.5*displayScale,h*0.5+dh*0.5*displayScale)
    xM = xM - (w*0.5-dw*0.5*displayScale)
    yM = yM - (h*0.5-dh*0.5*displayScale)
    xM = xM/displayScale; yM = yM/displayScale

    -- Bg and canvas resetting
    love.graphics.setCanvas(UI_LAYER)
    love.graphics.clear(0,0,0,0)

    love.graphics.setColor(1,1,1,1); love.graphics.setCanvas(display)
    love.graphics.clear(0,0,0,1)

    --------------------------------------------------------------------------SCENE CALLED
    sceneNew = scenes[scene][1]()

    if sceneNew ~= scene then
        scenes[scene][3]()
        scene = sceneNew; scenes[scene][2]()
        transition = 1
    end

    transition = clamp(transition - dt * transitionSpeed,0,1)
    setColor(0,0,0,255 * transition)
    love.graphics.rectangle("fill",0,0,800,600)


    processCamera(); processLight()

    love.graphics.setCanvas(postProCanvas)
    love.graphics.setShader(SHADERS[postPro])

    love.graphics.draw(display)

    love.graphics.setShader()
    
    love.graphics.setColor(1,1,1)
    love.graphics.draw(UI_LAYER)

    -- Mouse
    love.graphics.setColor(1,1,1)
    love.graphics.draw(mouse[mouseMode],xM,yM,0,SPRSCL,SPRSCL,mouse[mouseMode]:getWidth() * mCentered,mouse[mouseMode]:getHeight() * mCentered)

    -- Draw display
    love.graphics.setCanvas()

    love.graphics.draw(postProCanvas, w * 0.5 - dw * 0.5 * displayScale - screenshake[1] * displayScale, h * 0.5 - dh * 0.5 * displayScale - screenshake[2] * displayScale, 0, displayScale, displayScale)
    
    love.graphics.setColor(1,1,1)

    -- Check for fullscreen
    if justPressed("f1") then changeFullscreen() end

    -- Reset stuff
    lastKeyPressed = "none"; lastMouseButtonPressed = -1
    for id,J in pairs(JOYSTICKS) do JOYSTICK_LAST_PRESSES[id] = "none" end
    scroll = 0; processSound(); resetLight()
end

-- Display resizing
function love.resize(w, h)
    displayScale = math.min(w/WS[1], h/WS[2])

    love.graphics.setCanvas(display)
    love.graphics.scale(zoom)
end

function changeFullscreen()
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen)
    if fullscreen == false then
        love.window.width = WS[1]; love.window.height = WS[2]; displayScale = 1
    end
end

-- Keyboard
function love.keypressed(k) setJustPressed(k) end

-- Mouse
function love.mousepressed(x,y,button) setMouseJustPressed(button) end

function love.wheelmoved(x,y) scroll = y end

-- Joysticks
function love.joystickadded(joystick) table.insert(JOYSTICKS,joystick); table.insert(JOYSTICK_LAST_PRESSES,"none") end

function love.joystickremoved(joystick)
    id = elementIndex(JOYSTICKS,joystick)
    table.remove(JOYSTICKS,id); table.remove(JOYSTICK_LAST_PRESSES,id)
end

function love.joystickpressed(joystick,button)
    id = elementIndex(JOYSTICKS,joystick)
    JOYSTICK_LAST_PRESSES[id] = button
end