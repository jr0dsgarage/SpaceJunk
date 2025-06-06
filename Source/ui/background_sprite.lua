-- BackgroundSprite: Playdate sprite for the background ship image
local gfx <const> = playdate.graphics

local BackgroundSprite = {}
BackgroundSprite.__index = BackgroundSprite

function BackgroundSprite.new(bgImg, zindex, width, height)
    local sprite = gfx.sprite.new(bgImg)
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(zindex)
    sprite:setSize(width, height)
    sprite:add()
    local self = setmetatable({ sprite = sprite }, BackgroundSprite)
    return self
end

function BackgroundSprite:remove()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
end

return BackgroundSprite
