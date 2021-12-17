-------- INIT SHADERS --------

SHADERS = {
    GLOW = love.graphics.newShader((love.filesystem.read("data/shaders/GLOW.fs")))
    ,
    PIXEL_PERFECT = love.graphics.newShader((love.filesystem.read("data/shaders/PIXEL_PERFECT.fs")))
    ,
    FLASH = love.graphics.newShader((love.filesystem.read("data/shaders/FLASH.fs")))
    ,
    LIGHT = love.graphics.newShader((love.filesystem.read("data/shaders/LIGHT.fs")))
    ,
    GLITCH = love.graphics.newShader((love.filesystem.read("data/shaders/GLITCH.fs")))
    ,
    EMPTY = love.graphics.newShader((love.filesystem.read("data/shaders/EMPTY.fs")))
    ,
    INVERT = love.graphics.newShader((love.filesystem.read("data/shaders/INVERT.fs")))
    ,
    GRAYSCALE = love.graphics.newShader((love.filesystem.read("data/shaders/GRAYSCALE.fs")))
}

SHADERS.GLOW:send("xRatio",aspectRatio[2])
SHADERS.GLITCH:send("mask",love.graphics.newImage("data/images/shaderMasks/glitch.png"))

-------- LIGHT SHADER FUNCTIONS --------
lights = {}

function shine(x,y,diffuse,power)
    table.insert(lights,{position={x,y},diffuse=diffuse,power=power})
end

function processLights(position,diffuse,power)
    SHADERS.LIGHT:send("offset",{w*0.5-dw*0.5*displayScale,h*0.5-dh*0.5*displayScale})
    SHADERS.LIGHT:send("numLights",table.getn(lights))

    for id,L in pairs(lights) do
        actualId = id - 1
        SHADERS.LIGHT:send("lights["..tostring(actualId).."].position",L.position)
        SHADERS.LIGHT:send("lights["..tostring(actualId).."].diffuse",L.diffuse)
        SHADERS.LIGHT:send("lights["..tostring(actualId).."].power",L.power)
    end
end

function resetLights()
    lights = {}
end

-- Table of all post process effects you want, example: postPro = {"PIXEL_PERFECT","GLOW"}
postPro = {}