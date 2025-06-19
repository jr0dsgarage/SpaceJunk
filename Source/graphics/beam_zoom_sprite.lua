---
-- BeamZoomSprite: UI sprite for visualizing beam proximity (zoom bar).
-- Draws a vertical bar with tick marks indicating beam radius.
-- @module BeamZoomSprite
-- @usage
--   local BeamZoomSprite = require("graphics.beam_zoom_sprite")
--   local zoomBar = BeamZoomSprite.new(parentScene)

local gfx <const> = playdate.graphics -- Playdate graphics module

local BeamZoomSprite = {} -- Table for BeamZoomSprite methods and metatable
BeamZoomSprite.__index = BeamZoomSprite -- Metatable index for BeamZoomSprite

--- Create a new BeamZoomSprite.
-- @param parentScene Reference to the parent scene (for beam radius info)
-- @return BeamZoomSprite instance
function BeamZoomSprite.new(parentScene)
    local self = setmetatable({}, BeamZoomSprite)
    self.parentScene = parentScene
    self.tickBarWidth = 7
    self.maxLeftShift = 5 -- maximum number of pixels to shift tick marks left at top/bottom
    self.width = self.tickBarWidth + self.maxLeftShift + 10 -- increase width to fit bent ticks
    self.largeTickPadding = 2 -- extra length for the larger tick
    self.largeTickSpacing = 5 -- draw a larger tick mark every nth tick
    self.height = _G.SCREEN_HEIGHT - (_G.TIMERBAR_HEIGHT + _G.SCOREBOARD_HEIGHT) - 8 - 20 -- 10px shorter on top and bottom
    self.x = _G.SCREEN_WIDTH - self.tickBarWidth - 30 - self.maxLeftShift -- move left so right edge stays in same place
    self.y = _G.TIMERBAR_HEIGHT + 4 + 15 -- move 10px down to keep centered
    self.sprite = gfx.sprite.new()
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:setZIndex(_G.ZINDEX and _G.ZINDEX.SCOREBOARD or 9998)
    self.sprite:setSize(self.width, self.height)
    self.sprite.draw = function(_)
        gfx.setColor(gfx.kColorWhite)
        -- Draw tick marks: density increases as beam gets closer to player
        local minTicks = 5
        local maxTicks = 60
        local beamRadius = self.parentScene.beamRadius
        local minBeam = self.parentScene.minBeamRadius 
        local maxBeam = self.parentScene.maxBeamRadius
        local beamPercent = (beamRadius - minBeam) / (maxBeam - minBeam)
        local nTicks = math.floor(minTicks + (1 - beamPercent) * (maxTicks - minTicks))
        local normalTickLength = self.tickBarWidth - self.largeTickPadding
        local largeTickLength = self.tickBarWidth
        for i = 0, nTicks do
            local norm = i / nTicks
            local density = 0.5 * (1 - math.cos(norm * math.pi))
            local y = math.floor(density * (self.height - 1))
            -- Bend: shift left more at top/bottom, less in the middle
            local bendNorm = math.abs((norm - 0.5) * 2) -- 0 at center, 1 at ends
            local leftShift = self.maxLeftShift * (1 - math.cos(bendNorm * math.pi)) / 2 -- smooth drop-off
            local x0, x1
            if i % self.largeTickSpacing == 0 then
                x0 = self.width - self.maxLeftShift - leftShift
                x1 = self.width - self.maxLeftShift - largeTickLength - leftShift
                gfx.drawLine(x0, y, x1, y)
            else
                x0 = self.width - self.maxLeftShift - leftShift
                x1 = self.width - self.maxLeftShift - normalTickLength - leftShift
                gfx.drawLine(x0, y, x1, y)
            end
        end
    end
    self.sprite:add()
    return self
end

function BeamZoomSprite:remove()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
end

return BeamZoomSprite
