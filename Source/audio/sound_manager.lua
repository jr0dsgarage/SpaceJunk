---
-- SoundManager module for handling all game sound effects and music.
-- Centralizes sound logic for beeps, tunes, and capture/miss effects.
-- @module SoundManager
-- @usage
--   local SoundManager = require("audio.sound_manager")
--   local sm = SoundManager.new()

local snd = playdate.sound -- Playdate sound module
local nf = import("audio/note_frequency.lua") -- Musical note frequencies (alias: nf)
local SoundManager = {} -- Table for SoundManager methods and metatable
SoundManager.__index = SoundManager -- Metatable index for SoundManager

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
    local freq = nf.A4 + 200 * precision
    self.captureSynth:playNote(freq, 0.2, 0.2)
end

--- Play a sound for missed objects.
function SoundManager:playMiss()
    -- Play a low frequency, crunchy sound for missed objects
    -- Use a short, low note with a bit of noise
    local synth = playdate.sound.synth.new(playdate.sound.kWaveNoise)
    synth:setADSR(0.01, 0.05, 0, 0.1)
    synth:playNote(nf.E4 or 80, 0.15, 0.2) -- low frequency, short duration
end

--- Play a countdown beep with fade-out effect.
function SoundManager:playCountdownBeep()
    local BEEP_FREQ = nf.A5 -- A5
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

---
-- Play a score tune based on whether it's a high score.
-- Plays a simple melody with bass notes.
-- @param isHighScore Boolean indicating if it's a high score
function SoundManager:playScoreTune(isHighScore)
    local TUNE_BASE_FREQS = {
        nf.C5,
        nf.D5,
        nf.E5,
        nf.F5,
        nf.G5
    }
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

---
-- Play a note from the C major scale based on a normalized value (0..1).
-- @param scaleValue Number between 0 and 1 (e.g., match/score ratio)
-- @param duration Duration of the note
-- @param velocity Velocity/volume of the note
function SoundManager:playCMajorNote(scaleValue, duration, velocity)
    local cMajor = {
        nf.C4, nf.D4, nf.E4, nf.F4, nf.G4, nf.A4, nf.B4
    }
    local idx = math.floor((scaleValue or 0) * (#cMajor - 1) + 1)
    local note = cMajor[idx]
    if note then
        self.captureSynth:playNote(note, duration or 0.2, velocity or 0.2)
    end
end

---
-- Play a beep with a linear fade out.
-- @param freq Frequency in Hz
-- @param duration Duration in seconds
-- @param startVolume Initial volume (0..1)
function SoundManager:playBeepWithFade(freq, duration, startVolume)
    local synth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    synth:playNote(freq, duration, startVolume)
    local steps = 10
    for i = 1, steps do
        playdate.timer.performAfterDelay(duration * 1000 * (i/steps), function()
            local v = startVolume * (1 - i/steps)
            synth:setVolume(math.max(0, v))
        end)
    end
end

return SoundManager
