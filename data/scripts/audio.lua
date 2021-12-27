
SOUNDS = {

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