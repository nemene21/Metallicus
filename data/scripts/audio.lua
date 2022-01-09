
SOUNDS = {
walk = love.audio.newSource("data/sounds/SFX/player/walk.wav", "stream"), -- Player sounds

inventoryClick = love.audio.newSource("data/sounds/SFX/inventory/tick.wav", "stream"), -- Inventory sounds
scroll = love.audio.newSource("data/sounds/SFX/inventory/scroll.wav", "stream"), 

slash = love.audio.newSource("data/sounds/SFX/slash.wav", "stream"), -- Item sounds

basicHit = love.audio.newSource("data/sounds/SFX/enemies/basicHit.wav", "stream"), -- Enemy sounds

slimeHitGround = love.audio.newSource("data/sounds/SFX/enemies/slimeHitGround.wav", "stream")
}
    
SOUNDS_PLAYING = {}
    
function playSound(string,pitch)
    local pitch = pitch or 1
    local NEW_SOUND = SOUNDS[string]:clone(); NEW_SOUND:setPitch(pitch); NEW_SOUND:play()
    table.insert(SOUNDS_PLAYING,NEW_SOUND)
end
    
function processSound()
    for id,S in ipairs(SOUNDS_PLAYING) do
        if not S:isPlaying() then table.remove(SOUNDS_PLAYING,id) end
    end
end