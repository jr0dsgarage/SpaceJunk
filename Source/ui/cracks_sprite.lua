-- CracksSprite: Playdate sprite for drawing cracks
local gfx <const> = playdate.graphics

local CracksSprite = {}
CracksSprite.__index = CracksSprite

function CracksSprite.new(image, zindex, width, height)
    local sprite = gfx.sprite.new(image)
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(zindex)
    sprite:setSize(width, height)
    sprite:add()
    local self = setmetatable({ sprite = sprite }, CracksSprite)
    return self
end

function CracksSprite:setImage(image)
    if self.sprite then
        self.sprite:setImage(image)
    end
end

function CracksSprite:remove()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
end

return CracksSprite
