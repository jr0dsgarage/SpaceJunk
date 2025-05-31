-- Source/score_popup.lua
local gfx <const> = playdate.graphics

local ScorePopups = {}
ScorePopups.__index = ScorePopups

-- Constants for bounce behavior
local POPUP_BOUNCE_DURATION <const> = 1000 -- ms
local POPUP_MIN_SPEED <const> = 20 -- px/sec (for lowest score)
local POPUP_MAX_SPEED <const> = 80 -- px/sec (for highest score)
local TOP_BAR_HEIGHT <const> = 24 -- px, adjust as needed
local POPUP_BOUNCE_PEAK <const> = 0.5 -- controls arc height (0-1)

function ScorePopups.new()
    local self = setmetatable({}, ScorePopups)
    self.popups = {}
    return self
end

function ScorePopups:add(x, y, value)
    -- Calculate bounce direction (random upward arc: 225° to 315°)
    local angle = math.rad(225 + math.random() * 90) -- 225 to 315 degrees
    -- Scale speed by value (clamped)
    local minScore, maxScore = 1, 1000
    local clampedValue = math.max(minScore, math.min(maxScore, value))
    local speed = POPUP_MIN_SPEED + (POPUP_MAX_SPEED - POPUP_MIN_SPEED) * ((clampedValue - minScore) / (maxScore - minScore))
    local vx = math.cos(angle) * speed / 1000 -- px/ms
    local vy = math.sin(angle) * speed / 1000 -- px/ms (will be negative)
    table.insert(self.popups, {
        x = x, y = y, value = value, time = playdate.getCurrentTimeMilliseconds(),
        vx = vx, vy = vy, startX = x, startY = y
    })
end

function ScorePopups:draw()
    local now = playdate.getCurrentTimeMilliseconds()
    for i = #self.popups, 1, -1 do
        local popup = self.popups[i]
        local elapsed = now - popup.time
        if elapsed < POPUP_BOUNCE_DURATION then
            -- Parabolic bounce: y = vt + arc
            local t = elapsed / POPUP_BOUNCE_DURATION
            local dx = popup.vx * elapsed
            local dy = popup.vy * elapsed
            -- Bounce arc (parabola, peak at t=0.5)
            local arc = POPUP_BOUNCE_PEAK * (4 * (t - 0.5) * (t - 0.5) - 1) * (POPUP_MAX_SPEED / 4) -- flip sign
            local drawX = popup.startX + dx
            local drawY = popup.startY + dy + arc
            -- Clamp to not go above top bar
            if drawY < TOP_BAR_HEIGHT then drawY = TOP_BAR_HEIGHT end
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawTextAligned(tostring(popup.value), drawX, drawY, kTextAlignment.center)
        else
            table.remove(self.popups, i)
        end
    end
end

return ScorePopups
