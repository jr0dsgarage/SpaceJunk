-- Source/crank_indicator_sprite.lua

local gfx <const> = playdate.graphics

local CrankIndicatorSprite = {}
CrankIndicatorSprite.__index = CrankIndicatorSprite

function CrankIndicatorSprite.new(screenWidth, screenHeight)
    local self = setmetatable({}, CrankIndicatorSprite)
    local sprite = gfx.sprite.new()
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(9999) -- topmost
    sprite:setSize(screenWidth, screenHeight)
    sprite.draw = function(_)
        if playdate.isCrankDocked() then
            local prevDrawMode = gfx.getImageDrawMode and gfx.getImageDrawMode() or nil
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            playdate.ui.crankIndicator:draw()
            if prevDrawMode then
                gfx.setImageDrawMode(prevDrawMode)
            else
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            end
        end
    end
    sprite:add()
    self.sprite = sprite
    return self
end

function CrankIndicatorSprite:remove()
    if self.sprite then self.sprite:remove() end
end

return CrankIndicatorSprite
