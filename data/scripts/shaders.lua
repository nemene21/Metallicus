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
}

SHADERS.GLOW:send("xRatio",aspectRatio[2])
SHADERS.BLUR:send("xRatio",aspectRatio[2])
SHADERS.GLITCH:send("mask",love.graphics.newImage("data/images/shaderMasks/glitch.png"))

SHADERS.GLOW_AND_LIGHT:send("vignetteMask",love.graphics.newImage("data/images/shaderMasks/vignette.png"))
SHADERS.GLOW_AND_LIGHT:send("hitVignetteMask",love.graphics.newImage("data/images/shaderMasks/hitVignette.png"))

bloomCycles = 24

SHADERS.GLOW_AND_LIGHT:send("bloomCycles", bloomCycles)
SHADERS.GLOW_AND_LIGHT:send("bloomCyclesHalf", math.floor(bloomCycles / 2) * -1)
SHADERS.GLOW_AND_LIGHT:send("bloomIntensity", (1 / (bloomCycles * 2)) * 0.25)

SHADERS.GLOW_AND_LIGHT:send("hurtVignetteIntensity", 0)

SHADERS.PIXEL_PERFECT:send("snapX", 1 / 800 * 3)
SHADERS.PIXEL_PERFECT:send("snapY", 1 / 600 * 3)

-------- LIGHT SHADER FUNCTIONS --------
lightImage = love.graphics.newCanvas(WS[1],WS[2])
ambientLight = {80,80,80}

LIGHT_ROUND = love.graphics.newImage("data/images/roundLight.png")

lights = {}

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

-- Table of all post process effects you want, example: postPro = {"PIXEL_PERFECT","GLOW"}
postPro = {}