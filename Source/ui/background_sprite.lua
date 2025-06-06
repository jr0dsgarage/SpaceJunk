-- BackgroundSprite: Playdate sprite for the background ship image
local gfx <const> = playdate.graphics

local BackgroundSprite = {}
BackgroundSprite.__index = BackgroundSprite

function BackgroundSprite.new(zindex, width, height)
    local bgImg = gfx.image.new("sprites/ui/background_ship.png")
    local sprite = gfx.sprite.new(bgImg)
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(zindex or 50)
    sprite:setSize(width or 400, height or 240)
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
