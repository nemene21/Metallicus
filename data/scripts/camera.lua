
camera = {0,0}; boundCamPos = {0,0}

lerpSpeed = 10

shakeStr = 0; shakes = 0; shakeTimer = newTimer(0); dir = 0; screenshake = {0,0}

-- Camera

function bindCamera(x,y)
    boundCamPos = {x,y}
end

function processCamera()
    shakeTimer:process()

    if shakeTimer:isDone() then
    if shakes > 0 then
        shakes = shakes - 1

        shakeTimer:reset()

        screenshake = {love.math.random(-shakeStr,shakeStr),love.math.random(-shakeStr,shakeStr)}
    else
        shakeStr = 0; screenshake = {0,0}
    end end

    camera[1] = lerp(camera[1],boundCamPos[1] + screenshake[1],dt*lerpSpeed)
    camera[2] = lerp(camera[2],boundCamPos[2] + screenshake[2],dt*lerpSpeed)
end

-- Screenshake

function shake(shakeStrNew,shakesNew,time,dir)
    print("sheke")
    dir = dir or 0

    if shakeStr <= shakeStrNew then
        shakeStr = shakeStrNew; shakes = shakesNew; shakeTimer.timeMax = time; shakeTimer.time = 0
    end
end

function lockScreenshake(bool) shakeTimer.playing = bool end