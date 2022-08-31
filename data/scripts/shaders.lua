-------- INIT SHADERS --------

SHADERS = {
    GLOW = love.graphics.newShader((love.filesystem.read("data/shaders/GLOW.fs")))
    ,
    PIXEL_PERFECT = love.graphics.newShader((love.filesystem.read("data/shaders/PIXEL_PERFECT.fs")))
    ,
    FLASH = love.graphics.newShader((love.filesystem.read("data/shaders/FLASH.fs")))
    ,
    GLOW_AND_LIGHT = love.graphics.newShader((love.filesystem.read("data/shaders/GLOW_AND_LIGHT.fs")))
    ,
    GLITCH = love.graphics.newShader((love.filesystem.read("data/shaders/GLITCH.fs")))
    ,
    EMPTY = love.graphics.newShader((love.filesystem.read("data/shaders/EMPTY.fs")))
    ,
    INVERT = love.graphics.newShader((love.filesystem.read("data/shaders/INVERT.fs")))
    ,
    GRAYSCALE = love.graphics.newShader((love.filesystem.read("data/shaders/GRAYSCALE.fs")))
    ,
    BLUR = love.graphics.newShader((love.filesystem.read("data/shaders/BLUR.fs")))
    ,
    ACTIVE_ITEM = love.graphics.newShader((love.filesystem.read("data/shaders/ACTIVE_ITEM.fs")))
    ,

    WAVE = love.graphics.newShader(nil, love.filesystem.read("data/shaders/WAVE.vs"))
    ,
    CAVE_WATERFALL = love.graphics.newShader((love.filesystem.read("data/shaders/CAVE_WATERFALL.fs")))

    ,
    SCENE_TRANSITION = love.graphics.newShader((love.filesystem.read("data/shaders/SCENE_TRANSITION.fs")))
    ,
    BREWING_ARROWS = love.graphics.newShader((love.filesystem.read("data/shaders/BREWING_ARROWS.fs")))
    ,
    ITEM_SHINE = love.graphics.newShader((love.filesystem.read("data/shaders/ITEM_SHINE.fs")))
    ,
    BULLET_TRAIL = love.graphics.newShader((love.filesystem.read("data/shaders/BULLET_TRAIL.fs")))
    ,
    UI = love.graphics.newShader((love.filesystem.read("data/shaders/UI.fs")))
    ,
    TELEPORTER_SWIRL = love.graphics.newShader((love.filesystem.read("data/shaders/TELEPORTER_SWIRL.fs")))
}

SHADERS.GLOW:send("xRatio",aspectRatio[2])
SHADERS.GLITCH:send("mask",love.graphics.newImage("data/images/shaderMasks/glitch.png"))

SHADERS.GLOW_AND_LIGHT:send("vignetteMask",love.graphics.newImage("data/images/shaderMasks/vignette.png"))
SHADERS.GLOW_AND_LIGHT:send("hitVignetteMask",love.graphics.newImage("data/images/shaderMasks/hitVignette.png"))

SHADERS.GLOW_AND_LIGHT:send("xRatio", aspectRatio[2])

SHADERS.GLOW_AND_LIGHT:send("hurtVignetteIntensity", 0)

SHADERS.GLOW_AND_LIGHT:send("ACTIVE_SHOCKWAVES", 0)

SHADERS.PIXEL_PERFECT:send("snapX", 1 / 800 * 3)
SHADERS.PIXEL_PERFECT:send("snapY", 1 / 600 * 3)

-------- LIGHT SHADER FUNCTIONS --------
lightImage = love.graphics.newCanvas(WS[1],WS[2])
ambientLight = {80,80,80}

LIGHT_ROUND = love.graphics.newImage("data/images/roundLight.png")

lights = {}

whitePixel = love.graphics.newImage("data/images/shaderMasks/whitePixel.png")

function processLight() SHADERS.GLOW_AND_LIGHT:send("lightImage",lightImage); lights = {} end

function resetLight()

    love.graphics.setCanvas(lightImage)
    clear(ambientLight[1] * 0.5 * occlusion, ambientLight[2] * 0.5 * occlusion, ambientLight[3] * 0.5 * occlusion)
    love.graphics.setCanvas()

end

function shine(x,y,r,color)
    table.insert(lights, {x, y, r, color})
end

function drawAllLights()

    love.graphics.setCanvas(lightImage)

    for id, L in ipairs(lights) do

        drawLight(L[1], L[2], L[3], L[4])

    end
end

function drawLight(x,y,r,color)

    local color = color or {255,255,255,255}
    setColor(color[1],color[2],color[3],color[4] or 255 * 0.5)
    love.graphics.draw(LIGHT_ROUND,x - camera[1],y - camera[2],0,r/300,r/300,LIGHT_ROUND:getWidth() * 0.5,LIGHT_ROUND:getHeight() * 0.5)

end

function newNoiseTexture(w, h, zoom, seed)

    local zoom = zoom or 1
    local seed = seed or love.math.random(0, 1000000)

    local noiseTexture = love.graphics.newCanvas(w, h)
    noiseTexture:setWrap("repeat")

    love.graphics.setCanvas(noiseTexture)

    for x = 0, w do

        for y = 0, h do

            local noise = math.abs(love.math.noise(x * zoom, y * zoom, seed))

            love.graphics.setColor(noise, noise, noise)

            love.graphics.points(x, y)

        end

    end

    love.graphics.setCanvas()

    return noiseTexture

end

SHOCKWAVES = {}

function processShockwaves()

    local kill = {}

    for id, shockwave in ipairs(SHOCKWAVES) do

        shockwave.lifetime = shockwave.lifetime - dt

        local idC = id - 1

        SHADERS.GLOW_AND_LIGHT:send("shockwaves[" .. tostring(idC) .. "].lifetime", shockwave.lifetime)

        SHADERS.GLOW_AND_LIGHT:send("shockwaves[" .. tostring(idC) .. "].lifetimeMax", shockwave.lifetimeMax)

        SHADERS.GLOW_AND_LIGHT:send("shockwaves[" .. tostring(idC) .. "].force", shockwave.force)

        SHADERS.GLOW_AND_LIGHT:send("shockwaves[" .. tostring(idC) .. "].position", {shockwave.position[1] - camera[1], shockwave.position[2] - camera[2]})
        
        SHADERS.GLOW_AND_LIGHT:send("shockwaves[" .. tostring(idC) .. "].size", shockwave.size)

        if shockwave.lifetime < 0 then

            table.insert(kill, id)

        end

    end SHOCKWAVES = wipeKill(kill, SHOCKWAVES)

    SHADERS.GLOW_AND_LIGHT:send("ACTIVE_SHOCKWAVES", clamp(#SHOCKWAVES, 0, 16))

end

function shock(x, y, size, force, lifetime)

    table.insert(SHOCKWAVES, {position = {x, y}, size = size, lifetime = lifetime, force = force, lifetimeMax = lifetime})

end

SHADERS.CAVE_WATERFALL:send("noise", newNoiseTexture(32, 540, 0.1))

SHADERS.BULLET_TRAIL:send("noise", newNoiseTexture(100, 32, 0.075))

-- Table of all post process effects you want, example: postPro = {"PIXEL_PERFECT","GLOW"}
postPro = {}