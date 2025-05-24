-- scenes/game_scene.lua
local gfx <const> = playdate.graphics
local snd = playdate.sound
local captureSynth = snd.synth.new(snd.kWaveSquare)

local game_scene = {}

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
    -- Make sprites start off very small and grow larger
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
    -- Returns the current on-screen radius of the sprite
    local baseSize = 32 -- matches your sprite's native size
    local scale = math.max(0.05, self.size / baseSize)
    return (baseSize / 2) * scale
end

local BeamSprite = {}
BeamSprite.__index = BeamSprite

function BeamSprite.new(scene)
    local self = setmetatable({}, BeamSprite)
    self.scene = scene
    local sprite = gfx.sprite.new()
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(200) -- above flying objects
    sprite:setSize(scene.screenWidth, scene.screenHeight)
    sprite.draw = function(_)
        local cx, cy = math.floor(scene.beamX + 0.5), math.floor(scene.beamY + 0.5)
        local innerRadius = math.floor(scene.beamRadius + 0.5)
        local outerRadius = math.floor(scene.beamRadius + (scene.beamRadius / 10) + 0.5)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawCircleAtPoint(cx, cy, innerRadius)
        gfx.drawCircleAtPoint(cx, cy, outerRadius)
    end
    sprite:add()
    self.sprite = sprite
    return self
end

function game_scene:enter()
    -- Initialize or reset game state here
    self.screenWidth, self.screenHeight = playdate.display.getWidth(), playdate.display.getHeight()
    self.beamRadius = 20
    self.beamX, self.beamY = self.screenWidth / 2, self.screenHeight / 2
    self.minBeamRadius = 5
    self.maxBeamRadius = 75

    -- Stars
    self.numStars = 50
    self.stars = {}
    math.randomseed(playdate.getSecondsSinceEpoch())
    for i = 1, self.numStars do
        table.insert(self.stars, {
            x = math.random(0, self.screenWidth),
            y = math.random(0, self.screenHeight),
            size = math.random(1, 2)
        })
    end
    
    -- Flying objects
    self.flyingObjectImg = gfx.image.new("sprites/flyingObject_1.png")
    self.flyingObjects = {}
    self.maxFlyingObjects = 3
    self.maxObjectSize = self.maxBeamRadius  -- 4x as long lifespan
    for i = 1, self.maxFlyingObjects do
        self:spawnFlyingObject()
    end
    self.caught = 0
    self.missed = 0
    self.score = 0
    self.scorePopups = {}

    -- Create a background sprite for custom drawing
    if self.bgSprite then self.bgSprite:remove() end
    self.bgSprite = gfx.sprite.new()
    self.bgSprite:setCenter(0, 0)
    self.bgSprite:moveTo(0, 0)
    self.bgSprite:setZIndex(-100)
    self.bgSprite:setSize(self.screenWidth, self.screenHeight)
    self.bgSprite.draw = function(_)
        gfx.clear(gfx.kColorBlack)
        -- Stars
        gfx.setColor(gfx.kColorWhite)
        local maxOffset = 3
        local dx = math.max(-maxOffset, math.min(maxOffset, (self.beamX - self.screenWidth/2) * 0.01))
        local dy = math.max(-maxOffset, math.min(maxOffset, (self.beamY - self.screenHeight/2) * 0.01))
        for i = 1, #self.stars do
            local px = self.stars[i].x - dx * self.stars[i].size
            local py = self.stars[i].y - dy * self.stars[i].size
            if self.stars[i].size == 1 then
                gfx.drawPixel(px, py)
            else
                gfx.drawLine(px - 2, py, px + 2, py)
                gfx.drawLine(px, py - 2, px, py + 2)
            end
        end
        -- Score popups
        local now = playdate.getCurrentTimeMilliseconds()
        for i = #self.scorePopups, 1, -1 do
            local popup = self.scorePopups[i]
            if now - popup.time < 1000 then
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                gfx.setColor(gfx.kColorWhite)
                gfx.drawTextAligned("" .. tostring(popup.value), popup.x, popup.y, kTextAlignment.center)
            else
                table.remove(self.scorePopups, i)
            end
        end
        -- Crank alert
        if playdate.isCrankDocked() then
            playdate.ui.crankIndicator:draw()
        end
        -- Draw score
        ui.drawScore(self.caught, self.missed, self.score)
    end
    self.bgSprite:add()
    -- Add beam sprite above flying objects
    if self.beamSprite then self.beamSprite.sprite:remove() end
    self.beamSprite = BeamSprite.new(self)
end

function game_scene:spawnFlyingObject()
    local x = math.random(0, self.screenWidth)
    local y = math.random(0, self.screenHeight - 32)
    local size = 8 
    local speed = math.random(1, 3) / 5
    local obj = FlyingObjectSprite.new(x, y, size, speed, self.flyingObjectImg)
    -- Insert at the front of the list so older objects are at the end
    table.insert(self.flyingObjects, 1, obj)
    -- Update z-indices so older objects are always on top
    for i = 1, #self.flyingObjects do
        -- Oldest (last in list) gets highest z, newest (first) gets lowest
        self.flyingObjects[i].sprite:setZIndex(100 + i)
    end
end

function game_scene:update()
    -- Movement
    local moveSpeed = math.max(5, math.floor(self.beamRadius / 5))
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.beamY = self.beamY - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.beamY = self.beamY + moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.beamX = self.beamX - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.beamX = self.beamX + moveSpeed
    end
    self.beamX = math.max(0, math.min(self.screenWidth, self.beamX))
    self.beamY = math.max(0, math.min(self.screenHeight - 32, self.beamY))

    -- Crank
    local crankPos = playdate.getCrankPosition()
    local t = 1 - math.abs((crankPos % 360) / 180 - 1)
    self.beamRadius = self.minBeamRadius + (self.maxBeamRadius - self.minBeamRadius) * t

    -- Flying objects
    for i = #self.flyingObjects, 1, -1 do
        local obj = self.flyingObjects[i]
        obj:update()
        local dx = obj.x - self.beamX
        local dy = obj.y - self.beamY
        local dist = math.sqrt(dx * dx + dy * dy)
        local objRadius = obj:getRadius()
        if dist < self.beamRadius and self.beamRadius > objRadius then
            obj:remove()
            table.remove(self.flyingObjects, i)
            self:spawnFlyingObject()
            self.caught = self.caught + 1
            -- Score calculation
            local precision = 1 - (self.beamRadius - objRadius) / self.beamRadius
            local score = math.floor(100 * precision * (1 + objRadius / self.maxObjectSize))
            self.score = self.score + score
            table.insert(self.scorePopups,
                { x = obj.x, y = obj.y, value = score, time = playdate.getCurrentTimeMilliseconds() })
            captureSynth:playNote(440 + 200 * precision, 0.2, 0.2)
        end
    end
    
    -- Missed objects
    for i = #self.flyingObjects, 1, -1 do
        local obj = self.flyingObjects[i]
        if obj.size > self.maxObjectSize then
            obj:remove()
            table.remove(self.flyingObjects, i)
            self:spawnFlyingObject()
            self.missed = self.missed + 1
        end
    end
    -- At the end of update, force background sprite to redraw
    if self.bgSprite then self.bgSprite:markDirty() end
    -- Update beam sprite to redraw above flying objects
    if self.beamSprite and self.beamSprite.sprite then self.beamSprite.sprite:markDirty() end
end

return game_scene
