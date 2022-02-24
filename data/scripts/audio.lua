
SOUNDS = {
walk = love.audio.newSource("data/sounds/SFX/player/walk.wav", "stream"), -- Player sounds

hitOre = love.audio.newSource("data/sounds/SFX/structures/hitOre.wav", "stream"), -- Structure sounds
teleport = love.audio.newSource("data/sounds/SFX/structures/teleport.wav", "stream"),

inventoryClick = love.audio.newSource("data/sounds/SFX/inventory/tick.wav", "stream"), -- Inventory sounds
scroll = love.audio.newSource("data/sounds/SFX/inventory/scroll.wav", "stream"), 

slash = love.audio.newSource("data/sounds/SFX/slash.wav", "stream"), -- Item sounds

pickup = love.audio.newSource("data/sounds/SFX/inventory/pickup.wav", "stream"),

basicHit = love.audio.newSource("data/sounds/SFX/enemies/basicHit.wav", "stream"), -- Enemy sounds

slimeHitGround = love.audio.newSource("data/sounds/SFX/enemies/slimeHitGround.wav", "stream"),

giantFireflyShoot = love.audio.newSource("data/sounds/SFX/enemies/giantFireflyShoot.wav", "stream"),

quack = love.audio.newSource("data/sounds/SFX/quack.wav", "stream") -- Quack
}

SOUNDS_NUM_PLAYING = {}
for id,S in pairs(SOUNDS) do SOUNDS_NUM_PLAYING[id] = 0 end
    
SOUNDS_PLAYING = {}
    
function playSound(string, pitch, maxPlays)
    if (maxPlays or 99) > SOUNDS_NUM_PLAYING[string]  then
        local pitch = pitch or 1
        local NEW_SOUND = SOUNDS[string]:clone(); NEW_SOUND:setPitch(pitch); NEW_SOUND:play()
        table.insert(SOUNDS_PLAYING,{NEW_SOUND, string})
        SOUNDS_NUM_PLAYING[string] = SOUNDS_NUM_PLAYING[string] + 1
    end
end

function processSound()
    for id,S in ipairs(SOUNDS_PLAYING) do
        if not S[1]:isPlaying() then table.remove(SOUNDS_PLAYING,id); SOUNDS_NUM_PLAYING[S[2]] = SOUNDS_NUM_PLAYING[S[2]] - 1 end
    end
end