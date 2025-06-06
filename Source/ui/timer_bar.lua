-- Source/timer_bar.lua
-- TimerBar: a visual timer for Playdate games
local gfx <const> = playdate.graphics

local TimerBar = {}
TimerBar.__index = TimerBar

function TimerBar.new(durationSeconds, x, y, width, height)
    local self = setmetatable({}, TimerBar)
    self.duration = durationSeconds or 60
    self.x = x or 0
    self.y = y or 0
    self.width = width or 400
    self.height = _G.TIMERBAR_HEIGHT
    self.startTime = playdate.getCurrentTimeMilliseconds()
    self.paused = false
    self.pauseTime = nil
    self.elapsed = 0
    -- Sprite setup
    self.sprite = playdate.graphics.sprite.new()
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:setZIndex(9999) -- topmost
    self.sprite:setSize(self.width, self.height)
    self.sprite.draw = function(_)
        self:drawBar()
    end
    return self
end

function TimerBar:add()
    if self.sprite then self.sprite:add() end
end

function TimerBar:remove()
    if self.sprite then self.sprite:remove() end
end

function TimerBar:reset()
    self.startTime = playdate.getCurrentTimeMilliseconds()
    self.paused = false
    self.pauseTime = nil
    self.elapsed = 0
end

function TimerBar:pause()
    if not self.paused then
        self.paused = true
        self.pauseTime = playdate.getCurrentTimeMilliseconds()
    end
end

function TimerBar:resume()
    if self.paused then
        local now = playdate.getCurrentTimeMilliseconds()
        self.startTime = self.startTime + (now - self.pauseTime)
        self.paused = false
        self.pauseTime = nil
    end
end

function TimerBar:getTimeLeft()
    if self.paused then
        self.elapsed = self.pauseTime - self.startTime
    else
        self.elapsed = playdate.getCurrentTimeMilliseconds() - self.startTime
    end
    local timeLeft = math.max(0, self.duration - math.floor(self.elapsed / 1000))
    return timeLeft
end

function TimerBar:isFinished()
    return self:getTimeLeft() <= 0
end

function TimerBar:drawBar()
    local gfx <const> = playdate.graphics
    if ui and ui.altText_font then
        gfx.setFont(ui.altText_font)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("TIME:", 5, 1)
    local lineX = 48
    local lineY = 8
    local lineW = self.width - 56
    local totalRects = self.duration
    local rectWidth = 4
    local rectHeight = 8
    local timeLeft = self:getTimeLeft()
    local gap = (lineW - (totalRects * rectWidth)) / (totalRects - 1)
    for i = 1, totalRects do
        local sx = lineX + lineW - ((i - 1) * (rectWidth + gap)) - rectWidth
        local sy = lineY - rectHeight/2
        if i > (totalRects - timeLeft) then
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(sx, sy, rectWidth, rectHeight)
        end
    end
end

return TimerBar
