-- scenes/game_scene.lua

-- Use global references instead of imports
local gfx <const> = playdate.graphics
local snd = playdate.sound
local captureSynth = snd.synth.new(snd.kWaveSquare)

local game_scene = {}

local FlyingObjectSprite = _G.FlyingObjectSprite
local BeamSprite = _G.BeamSprite
local Starfield = _G.Starfield
local ScorePopups = _G.ScorePopups
local CrankIndicatorSprite = _G.CrankIndicatorSprite
local SoundManager = _G.SoundManager
local FlyingObjectSpawner = _G.FlyingObjectSpawner

function game_scene:resetGameState()
    self.caught = 0
    self.missed = 0
    self.score = 0
    self.scorePopups = ScorePopups.new()
end

function game_scene:enter()
    -- Initialize or reset game state here
    self.screenWidth, self.screenHeight = playdate.display.getWidth(), playdate.display.getHeight()
    self.beamRadius = 20
    self.beamX, self.beamY = self.screenWidth / 2, self.screenHeight / 2
    self.minBeamRadius = 5
    self.maxBeamRadius = 75

    -- Stars
    self.starfield = Starfield.new(self.screenWidth, self.screenHeight, 50)
    
    -- Flying objects
    self.flyingObjectImgs = {
        gfx.image.new("sprites/asteroid.png"),
        gfx.image.new("sprites/bottle.png")
    }
    self.maxFlyingObjects = 3
    self.flyingObjectSpawner = FlyingObjectSpawner.new(self.flyingObjectImgs, self.screenWidth, self.screenHeight, self.maxFlyingObjects)
    self.maxObjectSize = self.maxBeamRadius  -- 4x as long lifespan
    for i = 1, self.maxFlyingObjects do
        self.flyingObjectSpawner:spawnFlyingObject()
    end
    self:resetGameState()

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
        self.starfield:draw(self.beamX, self.beamY, self.screenWidth, self.screenHeight)
        -- Score popups
        self.scorePopups:draw()
        -- Draw score
        ui.drawScore(self.caught, self.missed, self.score)
    end
    self.bgSprite:add()

    -- Add beam sprite above flying objects
    if self.beamSprite then self.beamSprite.sprite:remove() end
    self.beamSprite = BeamSprite.new(self)

    -- Add a foreground sprite for the crank indicator
    if self.crankIndicator then self.crankIndicator:remove() end
    self.crankIndicator = CrankIndicatorSprite.new(self.screenWidth, self.screenHeight)

    -- Sound manager
    self.soundManager = SoundManager.new()
end

function game_scene:spawnFlyingObject()
    return self.flyingObjectSpawner:spawnFlyingObject()
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
    for i = #self.flyingObjectSpawner.flyingObjects, 1, -1 do
        local obj = self.flyingObjectSpawner.flyingObjects[i]
        obj:update()
        local dx = obj.x - self.beamX
        local dy = obj.y - self.beamY
        local dist = math.sqrt(dx * dx + dy * dy)
        local objRadius = obj:getRadius()
        if dist < self.beamRadius and self.beamRadius > objRadius then
            self.flyingObjectSpawner:removeObjectAt(i)
            self:spawnFlyingObject()
            self.caught = self.caught + 1
            -- Score calculation
            local precision = 1 - (self.beamRadius - objRadius) / self.beamRadius
            -- New: scale down score for larger objects (inverse relationship)
            local sizeFactor = 1 - (objRadius / self.maxObjectSize) -- smaller objects get higher factor
            local score = math.floor(100 * precision * sizeFactor)
            self.score = self.score + score
            self.scorePopups:add(obj.x, obj.y, score)
            self.soundManager:playCapture(precision)
        end
    end

    -- Missed objects
    for i = #self.flyingObjectSpawner.flyingObjects, 1, -1 do
        local obj = self.flyingObjectSpawner.flyingObjects[i]
        if obj.size > self.maxObjectSize then
            self.flyingObjectSpawner:removeObjectAt(i)
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
