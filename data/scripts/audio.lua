
SOUNDS = {
walk = love.audio.newSource("data/sounds/SFX/player/walk.wav", "stream"), -- Player sounds
enter = love.audio.newSource("data/sounds/SFX/player/enter.wav", "stream"),
fall = love.audio.newSource("data/sounds/SFX/player/fall.wav", "stream"),
jump = love.audio.newSource("data/sounds/SFX/player/jump.wav", "stream"),

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

MASTER_VOLUME = 1
SFX_VOLUME = 1
MUSIC_VOLUME = 0.5

SOUNDS_NUM_PLAYING = {}
for id,S in pairs(SOUNDS) do SOUNDS_NUM_PLAYING[id] = 0 end
    
SOUNDS_PLAYING = {}

MUSIC = {
cave = love.audio.newSource("data/sounds/music/cave.wav", "stream")
}

TRACK_PLAYING = "NONE"

function playTrack(track)

    if TRACK_PLAYING ~= "NONE" then MUSIC[TRACK_PLAYING]:stop() end
    TRACK_PLAYING = track

end


    
function playSound(string, pitch, maxPlays, vol)
    if (maxPlays or 99) > SOUNDS_NUM_PLAYING[string]  then
        local pitch = pitch or 1
        local NEW_SOUND = SOUNDS[string]:clone(); NEW_SOUND:setPitch(pitch); NEW_SOUND:setVolume((vol or 1) * MASTER_VOLUME * SFX_VOLUME); NEW_SOUND:play()
        table.insert(SOUNDS_PLAYING,{NEW_SOUND, string})
        SOUNDS_NUM_PLAYING[string] = SOUNDS_NUM_PLAYING[string] + 1
    end
end

trackPitch = 0.8

function processSound()
    for id,S in ipairs(SOUNDS_PLAYING) do
        if not S[1]:isPlaying() then table.remove(SOUNDS_PLAYING,id); SOUNDS_NUM_PLAYING[S[2]] = SOUNDS_NUM_PLAYING[S[2]] - 1 end
    end

    if MUSIC[TRACK_PLAYING] ~= nil then
        MUSIC[TRACK_PLAYING]:setVolume(MUSIC_VOLUME * MASTER_VOLUME)
        MUSIC[TRACK_PLAYING]:setPitch(trackPitch)
        
        if not MUSIC[TRACK_PLAYING]:isPlaying() then MUSIC[TRACK_PLAYING]:play() end
    end

end