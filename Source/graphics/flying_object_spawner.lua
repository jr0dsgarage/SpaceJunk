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
    local y = math.random(_G.TimerBarHeight, self.screenHeight - _G.ScoreboardBarHeight) -- leave space for timer and scoreboard
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
