---
-- SoundManager module for handling all game sound effects and music.
-- Centralizes sound logic for beeps, tunes, and capture/miss effects.
-- @module SoundManager
-- @usage
--   local SoundManager = require("audio.sound_manager")
--   local sm = SoundManager.new()

local snd = playdate.sound

local SoundManager = {}
SoundManager.__index = SoundManager

--- Create a new SoundManager instance.
-- @return SoundManager instance
function SoundManager.new()
    local self = setmetatable({}, SoundManager)
    self.captureSynth = snd.synth.new(snd.kWaveSquare)
    -- Add more synths or sounds as needed
    return self
end

--- Play a capture sound with pitch based on precision.
-- @param precision Number between 0 and 1
function SoundManager:playCapture(precision)
    -- precision: 0..1
    local freq = 440 + 200 * precision
    self.captureSynth:playNote(freq, 0.2, 0.2)
end

--- Play a sound for missed objects.
function SoundManager:playMiss()
    -- Play a low frequency, crunchy sound for missed objects
    -- Use a short, low note with a bit of noise
    local synth = playdate.sound.synth.new(playdate.sound.kWaveNoise)
    synth:setADSR(0.01, 0.05, 0, 0.1)
    synth:playNote(80, 0.15, 0.2) -- low frequency, short duration
end

--- Play a countdown beep with fade-out effect.
function SoundManager:playCountdownBeep()
    local BEEP_FREQ = 880 -- A5
    local BEEP_DURATION = 0.5
    local BEEP_VOLUME = 0.5
    local synth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    synth:playNote(BEEP_FREQ, BEEP_DURATION, BEEP_VOLUME)
    -- Fade out
    local steps = 10
    for i = 1, steps do
        playdate.timer.performAfterDelay(BEEP_DURATION * 1000 * (i/steps), function()
            local v = BEEP_VOLUME * (1 - i/steps)
            synth:setVolume(math.max(0, v))
        end)
    end
end

function SoundManager:playScoreTune(isHighScore)
    local TUNE_BASE_FREQS = {523.25, 587.33, 659.25, 698.46, 783.99} -- C5, D5, E5, F5, G5
    local TUNE_DURATION = 0.12
    local TUNE_VOLUME = 0.5
    local TUNE_OCTAVE_RATIO = 2 -- One octave up
    local TUNE_BASS_RATIO = 0.25 -- Two octaves down
    local melodySynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    local bassSynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    for i, f in ipairs(TUNE_BASE_FREQS) do
        local melodyFreq = isHighScore and (f * TUNE_OCTAVE_RATIO) or f
        local bassFreq = melodyFreq * TUNE_BASS_RATIO
        local duration = (i == #TUNE_BASE_FREQS) and (TUNE_DURATION * 2) or TUNE_DURATION
        playdate.timer.performAfterDelay((i-1)*TUNE_DURATION*1000, function()
            melodySynth:playNote(melodyFreq, duration, TUNE_VOLUME)
            bassSynth:playNote(bassFreq, duration, TUNE_VOLUME)
        end)
    end
end

return SoundManager
