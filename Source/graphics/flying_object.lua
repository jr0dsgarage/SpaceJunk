---
-- FlyingObjectSprite module for animated flying objects in the game.
-- Handles creation, scaling, rotation, and movement of flying object sprites.
-- @module FlyingObjectSprite
-- @usage
--   local FlyingObjectSprite = require("graphics.flying_object")
--   local obj = FlyingObjectSprite.new(x, y, size, speed, img)

local gfx <const> = playdate.graphics -- Playdate graphics module

local FlyingObjectSprite = {} -- Table for FlyingObjectSprite methods and metatable
FlyingObjectSprite.__index = FlyingObjectSprite -- Metatable index for FlyingObjectSprite

--- Create a new FlyingObjectSprite.
-- @param x X position
-- @param y Y position
-- @param size Initial size
-- @param speed Growth speed per frame
-- @param img Playdate image object
-- @return FlyingObjectSprite instance
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

--- Update the scale of the sprite based on its size.
function FlyingObjectSprite:updateScale()
    local baseSize = 32 -- matches your sprite's native size
    local scale = math.max(0.05, self.size / baseSize)
    self.sprite:setScale(scale)
end

--- Update the flying object's size and rotation each frame.
function FlyingObjectSprite:update()
    self.size = self.size + self.speed
    self:updateScale()
    self.rotation = (self.rotation + self.rotationSpeed) % 360
    self.sprite:setRotation(self.rotation)
end

--- Move the flying object to a new position.
-- @param x New X position
-- @param y New Y position
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
