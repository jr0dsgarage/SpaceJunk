-- Source/flying_object_spawner.lua
-- Use global reference for FlyingObjectSprite
local FlyingObjectSprite = _G.FlyingObjectSprite
local gfx <const> = playdate.graphics

local FlyingObjectSpawner = {}
FlyingObjectSpawner.__index = FlyingObjectSpawner

function FlyingObjectSpawner.new(flyingObjectImgs, screenWidth, screenHeight, maxFlyingObjects)
    local self = setmetatable({}, FlyingObjectSpawner)
    self.flyingObjectImgs = flyingObjectImgs
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.maxFlyingObjects = maxFlyingObjects or 3
    self.flyingObjects = {}
    return self
end

function FlyingObjectSpawner:spawnFlyingObject()
    local x = math.random(0, self.screenWidth)
    local y = math.random(0, self.screenHeight - 32)
    local size = 8
    local speed = math.random(1, 3) / 5
    local img = self.flyingObjectImgs[math.random(1, #self.flyingObjectImgs)]    local obj = FlyingObjectSprite.new(x, y, size, speed, img)
    table.insert(self.flyingObjects, 1, obj)
    self:updateZIndices()
    return obj
end

function FlyingObjectSpawner:updateZIndices()
    for i = 1, #self.flyingObjects do
        self.flyingObjects[i].sprite:setZIndex(100 + i)
    end
end

function FlyingObjectSpawner:removeObjectAt(index)
    local obj = self.flyingObjects[index]
    if obj then obj:remove() end
    table.remove(self.flyingObjects, index)
    self:updateZIndices()
end

return FlyingObjectSpawner
