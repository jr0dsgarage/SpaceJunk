-- Source/score_popup.lua
local gfx <const> = playdate.graphics

local ScorePopups = {}
ScorePopups.__index = ScorePopups

function ScorePopups.new()
    local self = setmetatable({}, ScorePopups)
    self.popups = {}
    return self
end

function ScorePopups:add(x, y, value)
    table.insert(self.popups, { x = x, y = y, value = value, time = playdate.getCurrentTimeMilliseconds() })
end

function ScorePopups:draw()
    local now = playdate.getCurrentTimeMilliseconds()
    for i = #self.popups, 1, -1 do
        local popup = self.popups[i]
        local popupY = popup.y
        if popupY > 195 then popupY = 190 end
        if now - popup.time < 1000 then
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawTextAligned(tostring(popup.value), popup.x, popupY, kTextAlignment.center)
        else
            table.remove(self.popups, i)
        end
    end
end

return ScorePopups
