
function handleCommand(cmd)

    cmd = splitString(cmd, " ")

    if COMMANDS[cmd[1]] ~= nil then

        COMMANDS[cmd[1]](cmd)

    end

end

function ERROR(des)
    print("<CMD_ERROR> - " .. des)
end

--                                                       COMMANDS

function GIVE_COMMAND(cmd)

    local item = deepcopyTable(ITEMS[cmd[2]])
    
    if item ~= nil then
        item.amount = tonumber(cmd[3] or "1")

        item = player.hotbar:addItem(item)

        if item.amount ~= 0 then player.inventory:addItem(item) end

        if item.amount ~= 0 then table.insert(ROOM.items, newItem(player.collider.x + 24 * (boolToInt(player.collider.x - camera[1] < xM) * 2 - 1), player.collider.y, item)) end
    else
        ERROR("This item does not exist :/")
    end
end

function WARP_COMMAND(cmd)

    swtichRoom((cmd[2] or 1) - roomOn)

end

function TIME_MULT_COMMAND(cmd)

    timeMult = cmd[2]

end

function SPAWN_ENEMY_COMMAND(cmd)

    table.insert(ROOM.enemies, buildEnemy(cmd[2], player.collider.x, player.collider.y))

end

function CLEAR_ROOM_COMMAND(cmd)

    for id, E in ipairs(ROOM.enemies) do

        E.knockback = newVec(E.collider.x - player.collider.x, E.collider.y - player.collider.y)
        E.hp = 0

    end

    for id, S in ipairs(ROOM.structures) do

        if S.hp ~= nil then
            S.hp = 0
        end

    end

end

function STATS_COMMAND(cmd)

    showStats = cmd[2] or not showStats

end

function SAY_COMMAND(cmd)

    text = ""

    for id, word in ipairs(cmd) do
        if id ~= 1 then text = text.." "..word end
    end

    player:say(text)

end

function DIE_COMMAND(cmd)

    player.hp = 0

end

function FLYMODE_COMMAND(cmd)

    player.flyMode = not player.flyMode

end

function QUACK_COMMAND(cmd)

    playSound("quack")

end

function SET_QUAKE_COMMAND(cmd)

    timeUntillQuake = tonumber(cmd[2] or timeUntillQuake)

end

function CHARGE_ACTIVE_COMMAND(cmd)

    local activeItemSlot = player.wearing.slots["1,2"]

    if activeItemSlot ~= nil then
        local activeItem = activeItemSlot.item

        if activeItem ~= nil then

            activeItem.charge = 1

        end

    end
end

function INF_CRAFTING_COMMAND(cmd)

    infiniteMaterials = not infiniteMaterials

end

function HELP_COMMAND(cmd)

    print([[
    give:
       
       args: item name, amount

       desc: Gives you n amount of items
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    warp:
       
       args: room index

       desc: Teleports you to room x
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    setTime:
       
       args: multiplier

       desc: Sets the time multiplier
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    spawnEnemy:
       
       args: enemy name

       desc: Spawns enemy x directly on the player
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    clearRoom:
       
       args: _

       desc: Obliterates all the enemies in a room
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    stats:
       
       args: _

       desc: Shows/hides the stats
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    die:
       
       args: _

       desc: kills you
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    flyMode:
       
       args: _

       desc: Turns on/off the fly mode
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    setQuake:
       
       args: time

       desc: Sets the quake time
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    chargeActive:
       
       args: _

       desc: Charges your active item
    ]])

    print("\n ---------------------------------------------------- \n")

    print([[
    quack:
       
       args: _

       desc: Quacks
    ]])

end

COMMANDS = {
help = HELP_COMMAND,


flyMode = FLYMODE_COMMAND,
give = GIVE_COMMAND,

warp = WARP_COMMAND,
setTime = TIME_MULT_COMMAND,
stats = STATS_COMMAND,

spawnEnemy = SPAWN_ENEMY_COMMAND,
clearRoom = CLEAR_ROOM_COMMAND,

die = DIE_COMMAND,

setQuake = SET_QUAKE_COMMAND,

say = SAY_COMMAND,

infCrafting = INF_CRAFTING_COMMAND,

chargeActive = CHARGE_ACTIVE_COMMAND,

quack = QUACK_COMMAND
}

function SHOW_STATS()

    local letterYOffset = 58

    local statsGraphics = love.graphics.getStats()

    love.graphics.setCanvas(UI_LAYER)

    outlinedText(12, 12 + letterYOffset, 2, "FPS: "..tostring(love.timer.getFPS()), {255, 255, 255}, 1, 1)

    local objects = #ROOM.enemies + 2 + #ROOM.decorations.background + #ROOM.decorations.foreground + #ROOM.particleSystems + #ROOM.items + #playerProjectiles + #enemyProjectiles
    outlinedText(12, 36 + letterYOffset, 2, "OBJECTS:   "..tostring(objects), {255, 255, 255}, 1, 1)

    outlinedText(12, 60 + letterYOffset, 2, "ROOMS:   "..tostring(#ROOMS), {255, 255, 255}, 1, 1)

    outlinedText(12, 84 + letterYOffset, 2, "SEED:   "..tostring(love.math.getRandomSeed()), {255, 255, 255}, 1, 1)

    outlinedText(12, 108 + letterYOffset, 2, "SOUNDS PLAYING:   "..tostring(#SOUNDS_PLAYING), {255, 255, 255}, 1, 1)

    outlinedText(12, 132 + letterYOffset, 2, "GLOBAL TIMER:   "..tostring(round(globalTimer)), {255, 255, 255}, 1, 1)

    outlinedText(12, 156 + letterYOffset, 2, "DRAW CALLS:   "..tostring(round(statsGraphics.drawcalls)), {255, 255, 255}, 1, 1)

    outlinedText(12, 180 + letterYOffset, 2, "CANVAS SWITCHES:   "..tostring(round(statsGraphics.canvasswitches)), {255, 255, 255}, 1, 1)

    love.graphics.setCanvas(display)

end