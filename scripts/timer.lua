
function processTimer(timer)
    timer.time = timer.time - dt * boolToInt(timer.playing)
end

function isTimerDone(timer) return timer.time < 0 end

function resetTimer(timer) timer.time = timer.timeMax end

function newTimer(time)
    time = time or 0
    return {
        playing=true, time=time, timeMax=time, isDone=isTimerDone, process=processTimer; reset=resetTimer
    }
end