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

return SoundManager
