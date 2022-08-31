
-- KEYBOARD

lastKeyPressed = "none"
-- Keyboard input
function pressed(string) return love.keyboard.isDown(string) end -- Returns if a key is pressed (just for consistency XD)

function justPressed(string) return lastKeyPressed == string end -- Returns if a key is pressed at that frame.

-- Updating the input (unimportant, not for use)
function setJustPressed(string) lastKeyPressed = string end

-- MOUSE

lastMouseButtonPressed = -1

function mousePressed(button) return love.mouse.isDown(button) end -- Returns if a key is pressed (just for consistency XD)

function mouseJustPressed(button) return lastMouseButtonPressed == button end -- Returns if a key is pressed at that frame.

scroll = 0
function getScroll() return scroll end

-- Updating the input (unimportant, not for use)
function setMouseJustPressed(button) lastMouseButtonPressed = button end

-- JOYSTICK

function joystickPressed(id,button) if JOYSTICKS[id] ~= nil then return JOYSTICKS[id]:isGamepadDown(button) end end

function joystickJustPressed(id,button) if JOYSTICKS[id] ~= nil then return JOYSTICK_LAST_PRESSES[id] == button end end

justPressedTrigger = {false, false}
holdingTriggers = {false, false}

function joystickJustPressedTriggerProcess(id)

    local axis = joystickGetAxis(id, 3)

    justPressedTrigger = {false, false}

    if axis.x > 0.4 then

        if not holdingTriggers[1] then justPressedTrigger[1] = true end
        holdingTriggers[1] = true

    else

        holdingTriggers[1] = false

    end

    if axis.y > 0.4 then

        if not holdingTriggers[2] then justPressedTrigger[2] = true end
        holdingTriggers[2] = true
        
    else

        holdingTriggers[2] = false

    end

end

function joystickGetAxis(id,axis)

    if JOYSTICKS[id] ~= nil then
        axis = axis * 2

        local x = JOYSTICKS[id]:getAxis(axis - 1)
        local y = JOYSTICKS[id]:getAxis(axis)

        return newVec(x,y)
    end

    return newVec(0, 0)
end

-- Get varying input

allInputs = {
    keyboard = pressed,
    mouse = mousePressed
}

allJustInputs = {
    keyboard = justPressed,
    mouse = mouseJustPressed
}

function getInput(data) return allInputs[data[1]](data[2]) end
 
function getJustInput(data) return allJustInputs[data[1]](data[2]) end

inputNames = {
    mouse = {

        "left click", "right click", "scroll click"

    },

    keyboard = {

        lshift = "left shift",
        rshift = "right shift",
        ["return"] = "enter",
        lctrl = "left control",
        rctrl = "right control"

    }
}

function getInputName(action)

    local inputType = OPT.keys[action][1]
    local action    = OPT.keys[action][2]

    if inputType == "mouse" then

        return inputNames.mouse[tonumber(action)] or action
    
    else

        return inputNames.keyboard[action] or action

    end

end