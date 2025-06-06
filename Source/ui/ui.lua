local gfx <const> = playdate.graphics

local rains3xFont = gfx.font.new("fonts/font-rains-3x")
local fullCircleFont = gfx.font.new("fonts/font-full-circle")

local TimerBar = import "timer_bar.lua"
local ScoreboardBar = import "scoreboard_bar.lua"

local timerBar = nil
local scoreboardBar = nil
local lastTimerValue = nil

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