---
-- UI module for global fonts, layout constants, and UI bars.
-- Provides access to fonts, z-indexes, and shared UI elements.
-- @module ui
-- @usage
--   local ui = require("ui.ui")
--   local font = ui.rains3xFont

local gfx <const> = playdate.graphics -- Playdate graphics module

local rains3xFont = gfx.font.new("fonts/font-rains-3x") -- Rains 3x font for UI
local fullCircleFont = gfx.font.new("fonts/font-full-circle") -- Full Circle font for UI

local TimerBar = import "timer_bar.lua" -- Timer bar UI module
local ScoreboardBar = import "scoreboard_bar.lua" -- Scoreboard bar UI module

local timerBar = nil -- Instance of TimerBar
local scoreboardBar = nil -- Instance of ScoreboardBar
local lastTimerValue = nil -- Last timer value for UI updates

-- Global screen dimensions
_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT = playdate.display.getWidth(), playdate.display.getHeight()

-- Global z-indexes for layering
_G.ZINDEX = {
    STARFIELD = 0,           -- starfield is always at the bottom
    FLYING_OBJECT_BASE = 50, -- flying objects will be 50 + i
    BEAM = 100,              -- beam and related effects
    CRT_MONITOR = 3000,      -- CRT monitor overlay
    SHIP_IMAGE = 5000,         -- background image below flying objects and beam
    SCOREBOARD = 9999,
    CRANK_INDICATOR = 10000,
    CRACKS = 500,
}

-- Banner padding constants for use in all scenes
_G.TITLE_BANNER_PAD = 8
_G.SUBTITLE_BANNER_PAD = 6
_G.INSTR_BANNER_PAD = 10

_G.SHIP_IMAGE_PATH = "sprites/ship_backgrounds/ship1"

-- Global constants for game dimensions
_G.TIMERBAR_HEIGHT = 16
_G.SCOREBOARD_HEIGHT = 42

-- Shared layout constants
_G.INSTR_LEFT_X = 0
_G.INSTR_RIGHT_X = _G.SCREEN_WIDTH
_G.INSTR_Y = _G.SCREEN_HEIGHT - 20

local function drawTimerBar(timeLeft)
    if not timerBar then
        timerBar = TimerBar.new(60, 0, 0, 400, 16)
        timerBar:add()
        lastTimerValue = 60
    end
    if timeLeft ~= lastTimerValue then
        timerBar.startTime = playdate.getCurrentTimeMilliseconds() - (60 - timeLeft) * 1000
        lastTimerValue = timeLeft
    end
end

local function drawScore(caught, missed, score)
    if not scoreboardBar then
        scoreboardBar = ScoreboardBar.new(0, 205, 400, 42)
        scoreboardBar:add()
    end
    scoreboardBar:setValues(caught, missed, score)
end

local function reset()
    timerBar = nil
    scoreboardBar = nil
    lastTimerValue = nil
end

local function pauseTimerBar()
    if timerBar and timerBar.pause then timerBar:pause() end
end

local function resumeTimerBar()
    if timerBar and timerBar.resume then timerBar:resume() end
end

return {

    drawScore = drawScore,
    drawTimerBar = drawTimerBar,
    reset = reset,
    pauseTimerBar = pauseTimerBar,
    resumeTimerBar = resumeTimerBar,
    titleText_font = rains3xFont,
    altText_font = fullCircleFont,
}