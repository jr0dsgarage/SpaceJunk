-- Source/flying_object.lua

local gfx <const> = playdate.graphics

local FlyingObjectSprite = {}
FlyingObjectSprite.__index = FlyingObjectSprite

function FlyingObjectSprite.new(x, y, size, speed, img)
    local self = setmetatable({}, FlyingObjectSprite)
    self.x = x
    self.y = y
    self.size = size
    self.speed = speed
    self.rotation = math.random() * 360 -- random initial rotation in degrees
    self.rotationSpeed = (math.random() - 0.5) * 4 -- random speed between -2 and 2 degrees per frame
    self.sprite = gfx.sprite.new(img)
    self.sprite:setCenter(0.5, 0.5)
    self.sprite:moveTo(x, y)
    self.sprite:setZIndex(100)
    self.sprite:setImageDrawMode(gfx.kDrawModeCopy)
    self.sprite:add()
    self:updateScale()
    self.sprite:setRotation(self.rotation)
    return self
end

function FlyingObjectSprite:updateScale()
    local baseSize = 32 -- matches your sprite's native size
    local scale = math.max(0.05, self.size / baseSize)
    self.sprite:setScale(scale)
end

function FlyingObjectSprite:update()
    self.size = self.size + self.speed
    self:updateScale()
    self.rotation = (self.rotation + self.rotationSpeed) % 360
    self.sprite:setRotation(self.rotation)
end

function FlyingObjectSprite:moveTo(x, y)
    self.x = x
    self.y = y
    self.sprite:moveTo(x, y)
end

function FlyingObjectSprite:remove()
    self.sprite:remove()
end

function FlyingObjectSprite:getRadius()
    local baseSize = 32 -- matches your sprite's native size
    local scale = math.max(0.05, self.size / baseSize)
    return (baseSize / 2) * scale
end

return FlyingObjectSprite
