-- Source/sound_manager.lua

local snd = playdate.sound

local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    local self = setmetatable({}, SoundManager)
    self.captureSynth = snd.synth.new(snd.kWaveSquare)
    -- Add more synths or sounds as needed
    return self
end

function SoundManager:playCapture(precision)
    -- precision: 0..1
    local freq = 440 + 200 * precision
    self.captureSynth:playNote(freq, 0.2, 0.2)
end

function SoundManager:playMiss()
    -- Play a low frequency, crunchy sound for missed objects
    -- Use a short, low note with a bit of noise
    local synth = playdate.sound.synth.new(playdate.sound.kWaveNoise)
    synth:setADSR(0.01, 0.05, 0, 0.1)
    synth:playNote(80, 0.15, 0.2) -- low frequency, short duration
end

return SoundManager
