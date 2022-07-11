local discordRPC = require("discordRPC")

local appId = require("applicationId")

function discordRPC.ready(userId, username, discriminator, avatar)
    print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username, discriminator, avatar))
end

function discordRPC.disconnected(errorCode, message)
    print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

function discordRPC.errored(errorCode, message)
    print(string.format("Discord: error (%d: %s)", errorCode, message))
end

function discordRPC.joinGame(joinSecret)
    print(string.format("Discord: join (%s)", joinSecret))
end

function discordRPC.spectateGame(spectateSecret)
    print(string.format("Discord: spectate (%s)", spectateSecret))
end

function discordRPC.joinRequest(userId, username, discriminator, avatar)
    print(string.format("Discord: join request (%s, %s, %s, %s)", userId, username, discriminator, avatar))
    discordRPC.respond(userId, "yes")
end

-- All global values used in all scenes (display, textures, options, etc.)
function love.load()

    UI_ALPHA = 255
    postPro = ""

    -- Get screenRes
    screenRes = {love.graphics.getWidth(),love.graphics.getHeight()}

    -- Window and defaulting
    globalTimer = 0; love.graphics.setDefaultFilter("nearest","nearest")

    fullscreen = false; title = "Metallicus"

    WS = {800, 600}; wFlags = {resizable=true}; UI_LAYER = love.graphics.newCanvas(WS[1],WS[2])
    aspectRatio = {WS[1]/WS[2], WS[2]/WS[1]}
    love.graphics.setBackgroundColor(0,0,0,1); love.window.setMode(WS[1], WS[2], wFlags); display = love.graphics.newCanvas(WS[1], WS[2]); displayScale = 1
    particleCanvas = love.graphics.newCanvas(WS[1], WS[2])
    postProCanvas = love.graphics.newCanvas(WS[1],WS[2])

    -- Imports
    json = require "data.scripts.json"; require "data.scripts.misc"; require "data.scripts.loading"; require "data.scripts.shaders"; require "data.scripts.mathPlus"; require "data.scripts.input"; require "data.scripts.sprites"; require "data.scripts.particles"
    require "data.scripts.buttons"; require "data.scripts.enemies"; require "data.scripts.projectiles"; require "data.scripts.audio"; require "data.scripts.generation"; require "data.scripts.tiles"; require "data.scripts.text"; require "data.scripts.timer"; require "data.scripts.camera"; require "data.scripts.inventory"; require "data.scripts.player"
    require "data.scripts.debugLine"; require "data.scripts.lootTables"

    transitionSurf = love.graphics.newCanvas(WS[1] / 4, WS[2] / 4) -- Making the transition noise
    love.graphics.setCanvas(transitionSurf)

    for x = 0, WS[1] / 4 do

        for y = 0, WS[2] / 4 do
            
            local noise = math.abs(love.math.noise(x * 0.03, y * 0.03))

            love.graphics.setColor(noise, noise, noise)

            love.graphics.points(x, y)

        end

    end

    SHADERS.SCENE_TRANSITION:send("transitionNoise", transitionSurf)
    love.graphics.setCanvas()
    transitionSurf:release()

    love.window.setTitle(title)

    local icon = love.image.newImageData("data/images/icon.png")
    love.window.setIcon(icon); icon = nil

    -- Mouse
    love.mouse.setVisible(false)
    mouseMode = "pointer"

    mouse = {["pointer"] = love.graphics.newImage("data/images/mouse/pointer.png"), ["aimer"] = love.graphics.newImage("data/images/mouse/aimer.png"), ["crafter"] = love.graphics.newImage("data/images/mouse/craftingPointer.png")}; mCentered = 0
    mouseOffset = {0,0}

    -- Scenes
    require "data.scenes.blank"; require "data.scenes.splashScreen"; require "data.scenes.game"; require "data.scenes.menu"
    scenes = {
    ["splash"] = {splashScreen,splashScreenReload,splashScreenDie},
    ["game"] = {game,gameReload,gameDie},
    ["menu"] = {menu,menuReload,menuDie}
    }

    -- Set default scene (the first one)
    scene = "menu"; firstScene = "menu"
    scenes[scene][2]()

    -- Discord rpc

    discordRPC.initialize(appId, true)
    local now = os.time(os.date("*t"))
    presence = {
        state = "",
        details = "Bullet-Hell Action Rougelike!",
        startTimestamp = nil,
        endTimestamp = nil,
        partyId = "",
        partyMax = 2,
        matchSecret = "",
        joinSecret = "",
        spectateSecret = "",
        largeImageKey = "icon"
    }

    nextPresenceUpdate = 0

    -- Set joysticks
    JOYSTICKS = love.joystick.getJoysticks()
    JOYSTICK_LAST_PRESSES = {}
    for id,J in pairs(JOYSTICKS) do JOYSTICK_LAST_PRESSES[id] = "none" end

    -- Transitions
    transition = 1; transitionTime = 0.35

    MIN_DELTA = 1 / 30

    drawUi = true

    textInputed = ""

    timeMult = 1
    showStats = false

    zoomInEffect = 1

    screenshotAnim = 0
    SS_FOLDER = love.filesystem.getSaveDirectory() .. "/screenshots"
end

-- Play scenes
function love.update()

    if nextPresenceUpdate < love.timer.getTime() then

        if sceneAt == "game" then
            presence.state = BIOMES[biomeOn].name .. " - Floor " .. tostring(floorOn)
        else
            presence.state = ""
        end

        discordRPC.updatePresence(presence)
        nextPresenceUpdate = love.timer.getTime() + 2.0
    end
    discordRPC.runCallbacks()

end

function love.draw()
    
    events = {}

    joystickJustPressedTriggerProcess(1)

    -- Time and resetting
    dt = math.min(love.timer.getDelta(), MIN_DELTA) * timeMult
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
    love.graphics.clear (0,0,0,1)

    SHADERS.WAVE:send("timePassed", globalTimer)
    SHADERS.WAVE:send("cameraX", round(camera[1]))
    SHADERS.WAVE:send("cameraY", round(camera[2]))

    --------------------------------------------------------------------------SCENE CALLED
    
    processShockwaves()
    SHADERS.GLOW_AND_LIGHT:send("motionBlur", dt * 15)

    transition = clamp(transition - dt / transitionTime, 0, 1)
    
    sceneNew = scenes[scene][1]()

    if sceneNew ~= scene then
        scenes[scene][3]()
        scene = sceneNew; scenes[scene][2]()
        transition = 1
    end

    drawAllLights()
    processCamera(); processLight()

    setColor(255, 255, 255)

    love.graphics.setCanvas(postProCanvas)
    love.graphics.setShader(SHADERS[postPro])

    love.graphics.draw(display)

    love.graphics.setShader()
    
    if (drawUi or sceneAt ~= "game") and UI_ALPHA > 0.01 then
        love.graphics.setColor(1,1,1, UI_ALPHA / 255)
        love.graphics.draw(UI_LAYER)
    end

    -- Reset particles
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas(particleCanvas)
    clear(0,0,0,0)

    -- Draw display
    love.graphics.setCanvas()
    love.graphics.setShader(SHADERS.SCENE_TRANSITION)
    SHADERS.SCENE_TRANSITION:send("transition", 1 - transition * transition)
 
    local displayScaleNow = displayScale * zoomInEffect

    love.graphics.draw(postProCanvas, w * 0.5 + screenshake[1] * displayScaleNow, h * 0.5 + screenshake[2] * displayScaleNow, math.sin(math.max(shakeTimer.time / shakeTimer.timeMax, 0) * 3.14) * shakeStr * 0.0008, displayScaleNow, displayScaleNow, postProCanvas:getWidth() * 0.5, postProCanvas:getHeight() * 0.5)

    love.graphics.setColor(1,1,1)

    love.graphics.setShader()

    screenshotAnim = screenshotAnim - dt
    if screenshotAnim > 0 then

        normalText(16, 16, 'Screenshot saved at "' .. SS_FOLDER .. '" (copied)', {255, 255, 255, (screenshotAnim * 0.2) ^ 2 * 255}, 0.8, 0.8)
        
    end

    -- Check for fullscreen 
    if justPressed("f1") then changeFullscreen() end

    if justPressed("f2") then drawUi = not drawUi end
 
    if justPressed("f3") then love.graphics.captureScreenshot("screenshots/screenshot.png"); screenshotAnim = 5; love.system.setClipboardText(SS_FOLDER) end

    -- Reset stuff
    lastKeyPressed = "none"; lastMouseButtonPressed = -1
    for id,J in pairs(JOYSTICKS) do JOYSTICK_LAST_PRESSES[id] = "none" end
    scroll = 0; processSound(); resetLight()

    textInputed = ""
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

-- Text input

function love.textinput(text)

    textInputed = text

end

function love.quit()
    discordRPC.shutdown()
end
