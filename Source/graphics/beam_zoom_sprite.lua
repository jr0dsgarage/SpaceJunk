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
    self.width = 7
    self.largeTickPadding = 2 -- extra length for the larger tick                                                        -- padding for every 5th tick mark
    self.largeTickSpacing = 5 -- draw a larger tick mark every nth tick
    self.height = _G.SCREEN_HEIGHT - (_G.TIMERBAR_HEIGHT + _G.SCOREBOARD_HEIGHT) -- was -4, now -8 for 2px less on top and bottom
    self.height = _G.SCREEN_HEIGHT - (_G.TIMERBAR_HEIGHT + _G.SCOREBOARD_HEIGHT) - 8 -- was -4, now -8 for 2px less on top and bottom
    self.x = _G.SCREEN_WIDTH - self.width
    self.y = _G.TIMERBAR_HEIGHT + 4 -- was +2, now +4 for 2px lower
    self.sprite = gfx.sprite.new()
    self.sprite:setCenter(0, 0)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:setZIndex(_G.ZINDEX and _G.ZINDEX.SCOREBOARD or 9998)
    self.sprite:setSize(self.width, self.height)
    self.sprite.draw = function(_)
        gfx.setColor(gfx.kColorWhite)
        -- Draw the main vertical line at the far right edge of the sprite
        gfx.drawLine(self.width - 1, 0, self.width - 1, self.height)
        -- Draw tick marks: density increases as beam gets closer to player
        local minTicks = 5
        local maxTicks = 60
        local beamRadius = self.parentScene.beamRadius
        local minBeam = self.parentScene.minBeamRadius 
        local maxBeam = self.parentScene.maxBeamRadius
        local beamPercent = (beamRadius - minBeam) / (maxBeam - minBeam)
        local nTicks = math.floor(minTicks + (1 - beamPercent) * (maxTicks - minTicks))
        local normalTickLength = self.width - self.largeTickPadding
        local largeTickLength = self.width
        for i = 0, nTicks do
            local norm = i / nTicks
            local density = 0.5 * (1 - math.cos(norm * math.pi))
            local y = math.floor(density * (self.height - 1))
            local x0, x1
            if i % self.largeTickSpacing == 0 then
                x0 = self.width
                x1 = self.width - largeTickLength
                gfx.drawLine(x0, y, x1, y)
            else
                x0 = self.width
                x1 = self.width - normalTickLength
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
