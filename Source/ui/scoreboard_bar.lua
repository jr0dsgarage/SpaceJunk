-- Source/scoreboard_bar.lua
-- ScoreboardBar: a visual score bar for Playdate games
local gfx <const> = playdate.graphics

local ScoreboardBar = {}
ScoreboardBar.__index = ScoreboardBar

function ScoreboardBar.new(x, y, width, height)
    local self = setmetatable({}, ScoreboardBar)
    self.x = x or 0
    self.y = y or 205
    self.width = width or 400
    self.height = _G.SCOREBOARD_HEIGHT
    -- Initialize score values
    self.caught = 0
    self.missed = 0
    self.score = 0
    -- Sprite setup
    self.sprite = gfx.sprite.new()
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:setZIndex(_G.ZINDEX.SCOREBOARD) -- below crank indicator
    self.sprite:setSize(self.width, self.height)
    self.sprite.draw = function(_)
        self:drawBar()
    end
    return self
end

function ScoreboardBar:setValues(caught, missed, score)
    self.caught = caught or 0
    self.missed = missed or 0
    self.score = score or 0
end

function ScoreboardBar:add()
    if self.sprite then self.sprite:add() end
end

function ScoreboardBar:remove()
    if self.sprite then self.sprite:remove() end
end

function ScoreboardBar:drawBar()
    local gfx <const> = playdate.graphics
    if ui and ui.altText_font then
        gfx.setFont(ui.altText_font)
    end
    -- gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    -- gfx.setColor(gfx.kColorWhite)
    gfx.drawTextAligned("CAUGHT", 0, 1, kTextAlignment.left)
    gfx.drawTextAligned("SCORE", 200, 6, kTextAlignment.center)
    gfx.drawTextAligned("MISSED", 400, 1, kTextAlignment.right)
    gfx.drawTextAligned(tostring(self.caught), 0, 19, kTextAlignment.left)
    gfx.drawTextAligned(tostring(self.score), 200, 19, kTextAlignment.center)
    gfx.drawTextAligned(tostring(self.missed), 400, 19, kTextAlignment.right)
    -- gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

return ScoreboardBar
