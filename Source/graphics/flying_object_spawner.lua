--- FlyingObjectSpawner is responsible for spawning and managing flying objects on the screen.
-- @classmod FlyingObjectSpawner

local gfx <const> = playdate.graphics -- Playdate graphics module

local FlyingObjectSpawner = {} -- Table for FlyingObjectSpawner methods and metatable
FlyingObjectSpawner.__index = FlyingObjectSpawner -- Metatable index for FlyingObjectSpawner

--- Create a new FlyingObjectSpawner.
-- @param flyingObjectImgs Table of images for flying objects.
-- @param screenWidth Width of the screen.
-- @param screenHeight Height of the screen.
-- @param maxFlyingObjects Maximum number of flying objects.
-- @return A new FlyingObjectSpawner instance.
function FlyingObjectSpawner.new(flyingObjectImgs, screenWidth, screenHeight, maxFlyingObjects)
    local self = setmetatable({}, FlyingObjectSpawner)
    self.flyingObjectImgs = flyingObjectImgs
    self.screenWidth =  _G.SCREEN_WIDTH
    self.screenHeight = _G.SCREEN_HEIGHT
    self.maxFlyingObjects = maxFlyingObjects or 3
    self.flyingObjects = {}
    return self
end

--- Spawn a new flying object at a random position.
-- @return The new flying object.
function FlyingObjectSpawner:spawnFlyingObject()
    local x = math.random(0, self.screenWidth)
    local y = math.random(_G.TIMERBAR_HEIGHT, self.screenHeight - _G.SCOREBOARD_HEIGHT) -- leave space for timer and scoreboard
    local size = 8
    local speed = math.random(1, 3) / 5
    local img = self.flyingObjectImgs[math.random(1, #self.flyingObjectImgs)]
    local obj = _G.FlyingObjectSprite.new(x, y, size, speed, img)
    table.insert(self.flyingObjects, 1, obj)
    self:updateZIndices()
    return obj
end

--- Update the Z indices of all flying objects for correct layering.
function FlyingObjectSpawner:updateZIndices()
    for i = 1, #self.flyingObjects do
        self.flyingObjects[i].sprite:setZIndex(_G.ZINDEX.FLYING_OBJECT_BASE  + i)
    end
end

--- Remove a flying object at a given index.
-- @param index The index of the object to remove.
function FlyingObjectSpawner:removeObjectAt(index)
    local obj = self.flyingObjects[index]
    if obj then obj:remove() end
    table.remove(self.flyingObjects, index)
    self:updateZIndices()
end

--- Draw a crack effect at the given position.
-- @param x X position.
-- @param y Y position.
function FlyingObjectSpawner:drawCrack(x, y)
    local function drawBranch(x, y, angle, length, depth)
        if depth > 3 or length < 2 then return end
        local rad = math.rad(angle)
        local x2 = x + math.cos(rad) * length
        local y2 = y + math.sin(rad) * length
        gfx.drawLine(x, y, x2, y2)
        -- Each branch can branch 0-2 times (randomly)
        local numSubBranches = math.random(0, 2)
        for i = 1, numSubBranches do
            local subAngle = angle + math.random(-50, 50)
            local subLength = length * (0.4 + math.random() * 0.3) -- 40-70% of parent
            drawBranch(x2, y2, subAngle, math.min(subLength, 4), depth + 1)
        end
    end
    local numMainBranches = math.random(3, 5)
    for i = 1, numMainBranches do
        local angle = math.random(0, 359)
        local length = math.random(6, 10)
        drawBranch(x, y, angle, length, 1)
    end
end

return FlyingObjectSpawner
