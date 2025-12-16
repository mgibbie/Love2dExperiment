-- Sound Manager
-- Handles all game audio

local M = {}

-- Sound sources
local sounds = {}
local music = nil

-- Volume settings
local masterVolume = 1.0
local sfxVolume = 0.8
local musicVolume = 0.5

-- Sound definitions
local SOUND_DEFS = {
    -- Card sounds
    card_flip = {file = "assets/sounds/card_flip.wav", volume = 0.6},
    card_slide = {file = "assets/sounds/card_slide.wav", volume = 0.5},
    card_place = {file = "assets/sounds/card_place.wav", volume = 0.7},
    card_select = {file = "assets/sounds/card_select.wav", volume = 0.5},
    
    -- Score sounds
    chip_add = {file = "assets/sounds/chip.wav", volume = 0.6},
    mult_add = {file = "assets/sounds/mult.wav", volume = 0.7},
    score_count = {file = "assets/sounds/count.wav", volume = 0.5},
    
    -- Joker sounds
    joker_trigger = {file = "assets/sounds/joker.wav", volume = 0.8},
    
    -- Shop sounds
    buy = {file = "assets/sounds/buy.wav", volume = 0.7},
    sell = {file = "assets/sounds/sell.wav", volume = 0.6},
    reroll = {file = "assets/sounds/reroll.wav", volume = 0.5},
    
    -- UI sounds
    button_hover = {file = "assets/sounds/hover.wav", volume = 0.3},
    button_click = {file = "assets/sounds/click.wav", volume = 0.5},
    
    -- Win/Lose
    win = {file = "assets/sounds/win.wav", volume = 0.8},
    lose = {file = "assets/sounds/lose.wav", volume = 0.7},
    
    -- Pack sounds
    pack_open = {file = "assets/sounds/pack_open.wav", volume = 0.8},
    card_reveal = {file = "assets/sounds/reveal.wav", volume = 0.6}
}

-- Initialize sound system
function M.init()
    -- Try to load sounds
    for name, def in pairs(SOUND_DEFS) do
        local success, source = pcall(function()
            if love.filesystem.getInfo(def.file) then
                return love.audio.newSource(def.file, "static")
            end
            return nil
        end)
        
        if success and source then
            source:setVolume(def.volume * sfxVolume * masterVolume)
            sounds[name] = source
        end
    end
end

-- Play a sound effect
function M.play(name, pitch)
    pitch = pitch or 1.0
    
    if sounds[name] then
        local source = sounds[name]:clone()
        source:setPitch(pitch)
        source:setVolume((SOUND_DEFS[name].volume or 0.5) * sfxVolume * masterVolume)
        source:play()
    else
        -- Fallback: generate a simple beep for testing
        M.playBeep(name)
    end
end

-- Generate a simple beep sound for testing
function M.playBeep(soundType)
    -- Create a simple sine wave based on sound type
    local sampleRate = 44100
    local duration = 0.1
    local frequency = 440
    
    if soundType == "chip_add" then
        frequency = 523.25  -- C5
        duration = 0.08
    elseif soundType == "mult_add" then
        frequency = 659.25  -- E5
        duration = 0.08
    elseif soundType == "card_select" then
        frequency = 392.00  -- G4
        duration = 0.05
    elseif soundType == "button_click" then
        frequency = 880.00  -- A5
        duration = 0.04
    elseif soundType == "joker_trigger" then
        frequency = 784.00  -- G5
        duration = 0.12
    elseif soundType == "win" then
        frequency = 1046.50 -- C6
        duration = 0.2
    end
    
    local samples = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local envelope = math.max(0, 1 - t / duration)
        local sample = math.sin(2 * math.pi * frequency * t) * envelope * 0.3
        soundData:setSample(i, sample)
    end
    
    local source = love.audio.newSource(soundData)
    source:setVolume(sfxVolume * masterVolume * 0.5)
    source:play()
end

-- Play music
function M.playMusic(file, loop)
    loop = loop ~= false
    
    if music then
        music:stop()
    end
    
    local success, source = pcall(function()
        if love.filesystem.getInfo(file) then
            return love.audio.newSource(file, "stream")
        end
        return nil
    end)
    
    if success and source then
        source:setLooping(loop)
        source:setVolume(musicVolume * masterVolume)
        source:play()
        music = source
    end
end

-- Stop music
function M.stopMusic()
    if music then
        music:stop()
        music = nil
    end
end

-- Set master volume
function M.setMasterVolume(vol)
    masterVolume = math.max(0, math.min(1, vol))
    M.updateVolumes()
end

-- Set SFX volume
function M.setSFXVolume(vol)
    sfxVolume = math.max(0, math.min(1, vol))
    M.updateVolumes()
end

-- Set music volume
function M.setMusicVolume(vol)
    musicVolume = math.max(0, math.min(1, vol))
    if music then
        music:setVolume(musicVolume * masterVolume)
    end
end

-- Update all sound volumes
function M.updateVolumes()
    for name, source in pairs(sounds) do
        local def = SOUND_DEFS[name]
        source:setVolume((def.volume or 0.5) * sfxVolume * masterVolume)
    end
    if music then
        music:setVolume(musicVolume * masterVolume)
    end
end

-- Get volume settings
function M.getVolumes()
    return {
        master = masterVolume,
        sfx = sfxVolume,
        music = musicVolume
    }
end

return M

