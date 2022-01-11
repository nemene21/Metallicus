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
}

SHADERS.GLOW:send("xRatio",aspectRatio[2])
SHADERS.BLUR:send("xRatio",aspectRatio[2])
SHADERS.GLOW_AND_LIGHT:send("xRatio",aspectRatio[2])
SHADERS.GLITCH:send("mask",love.graphics.newImage("data/images/shaderMasks/glitch.png"))
SHADERS.GLOW_AND_LIGHT:send("vignetteMask",love.graphics.newImage("data/images/shaderMasks/vignette.png"))

-------- LIGHT SHADER FUNCTIONS --------
lightImage = love.graphics.newCanvas(WS[1],WS[2])
ambientLight = {80,80,80}

LIGHT_ROUND = love.graphics.newImage("data/images/roundLight.png")

function processLight() SHADERS.GLOW_AND_LIGHT:send("lightImage",lightImage) end

function resetLight()
    love.graphics.setCanvas(lightImage)
    clear(ambientLight[1] * 0.5,ambientLight[2] * 0.5,ambientLight[3] * 0.5)
    love.graphics.setCanvas()
end

function shine(x,y,r,color)
    local color = color or {255,255,255}
    love.graphics.setCanvas(lightImage)
    setColor(color[1],color[2],color[3],128)
    love.graphics.draw(LIGHT_ROUND,x - camera[1],y - camera[2],0,r/300,r/300,LIGHT_ROUND:getWidth() * 0.5,LIGHT_ROUND:getHeight() * 0.5)
    love.graphics.setCanvas(display)
    setColor(255,255,255)
end

-- Table of all post process effects you want, example: postPro = {"PIXEL_PERFECT","GLOW"}
postPro = {}