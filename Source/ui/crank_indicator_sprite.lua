local gfx <const> = playdate.graphics

local CrankIndicatorSprite = {}
CrankIndicatorSprite.__index = CrankIndicatorSprite

function CrankIndicatorSprite.new(screenWidth, screenHeight)
    local self = setmetatable({}, CrankIndicatorSprite)
    local sprite = gfx.sprite.new()
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(_G.ZINDEX.CRANK_INDICATOR)
    sprite:setSize(screenWidth, screenHeight)
    sprite.draw = function(_)
        if playdate.isCrankDocked() then
            playdate.ui.crankIndicator:draw()
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
