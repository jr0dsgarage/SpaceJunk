local gfx <const> = playdate.graphics
local snd = playdate.sound
local captureSynth = snd.synth.new(snd.kWaveSquare)

local game_scene = {}

local BeamSprite = _G.BeamSprite
local Starfield = _G.Starfield
local ScorePopups = _G.ScorePopups
local CrankIndicatorSprite = _G.CrankIndicatorSprite
local SoundManager = _G.SoundManager
local FlyingObjectSpawner = _G.FlyingObjectSpawner

local gameDuration = 60 * 1000 -- 60 seconds in milliseconds

function game_scene:resetGameState()
    self.caught = 0
    self.missed = 0
    self.score = 0
    self.scorePopups = ScorePopups.new()
    self.startTime = playdate.getCurrentTimeMilliseconds()
    self.gameOver = false
end

function game_scene:enter()
    -- Initialize or reset game state here
    self.screenWidth, self.screenHeight = playdate.display.getWidth(), playdate.display.getHeight()
    self.beamRadius = 20
    self.beamX, self.beamY = self.screenWidth / 2, self.screenHeight / 2
    self.minBeamRadius = 5
    self.maxBeamRadius = 75
    self._scoreSceneSwitched = false
    self.soundManager = SoundManager.new()

    self.bgMusicPlayer = playdate.sound.fileplayer.new("audio/starz.mp3")
        self.bgMusicPlayer:play(0) -- loop forever

    -- Stars
    self.starfield = _G.sharedStarfield
    
    -- Flying objects
    self.flyingObjectImgs = {
        gfx.image.new("sprites/asteroid.png"),
        gfx.image.new("sprites/bottle.png")
    }
    self.maxFlyingObjects = 3
    self.flyingObjectSpawner = FlyingObjectSpawner.new(self.flyingObjectImgs, self.screenWidth, self.screenHeight, self.maxFlyingObjects)
    self.maxObjectSize = self.maxBeamRadius
    for i = 1, self.maxFlyingObjects do
        self.flyingObjectSpawner:spawnFlyingObject()
    end
    self:resetGameState()

    -- Create a background sprite for custom drawing
    self.bgSprite = gfx.sprite.new()
    self.bgSprite:setCenter(0, 0)
    self.bgSprite:moveTo(0, 0)
    self.bgSprite:setZIndex(-100)
    self.bgSprite:setSize(self.screenWidth, self.screenHeight)
    self.bgSprite.draw = function(_)
        gfx.clear(gfx.kColorBlack)
        self.starfield:draw(self.beamX, self.beamY, self.screenWidth, self.screenHeight)
        self.scorePopups:draw()
    end
    self.bgSprite:add()

    -- Beam and crank indicator
    self.beamSprite = BeamSprite.new(self)
    self.crankIndicator = CrankIndicatorSprite.new(self.screenWidth, self.screenHeight)

    -- Capture synth setup
    self.cMajorNotes = {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88} -- C4, D4, E4, F4, G4, A4, B4
end

function game_scene:spawnFlyingObject()
    return self.flyingObjectSpawner:spawnFlyingObject()
end

function game_scene:update()
    if self.gameOver then
        if rawget(_G, "switchToScoreScene") and not self._scoreSceneSwitched then
            self._scoreSceneSwitched = true
            _G.switchToScoreScene(self.score, self.caught, self.missed)
        end
        return
    end
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
            local sizeFactor = 1 - (objRadius / self.maxObjectSize)
            local score = math.floor(100 * precision * sizeFactor)
            self.score = self.score + score
            self.scorePopups:add(obj.x, obj.y, score)
            -- Play a note from the C major scale based on score (lower score = lower note)
            if self.cMajorNotes then
                local minScore, maxScore = 0, 100
                local clampedScore = math.max(minScore, math.min(maxScore, score))
                local scaleIdx = math.floor(((clampedScore - minScore) / (maxScore - minScore)) * (#self.cMajorNotes - 1) + 1)
                local note = self.cMajorNotes[scaleIdx]
                captureSynth:playNote(note, 0.2, 0.2)
            else
                self.soundManager:playCapture(precision)
            end
        end
    end

    -- Missed objects
    for i = #self.flyingObjectSpawner.flyingObjects, 1, -1 do
        local obj = self.flyingObjectSpawner.flyingObjects[i]
        if obj.size > self.maxObjectSize then
            self.flyingObjectSpawner:removeObjectAt(i)
            self:spawnFlyingObject()
            self.missed = self.missed + 1
            self.soundManager:playMiss()
        end
    end

    -- At the end of update, force background sprite to redraw
    if self.bgSprite then self.bgSprite:markDirty() end
    if self.beamSprite and self.beamSprite.sprite then self.beamSprite.sprite:markDirty() end

    -- Timer logic
    local now = playdate.getCurrentTimeMilliseconds()
    local elapsed = now - self.startTime
    self.timeLeft = math.max(0, math.ceil((gameDuration - elapsed) / 1000))
    if elapsed >= gameDuration then
        self.gameOver = true
        return
    end
end

function game_scene:draw()
    ui.drawTimerBar(self.timeLeft or gameDuration / 1000)
    ui.drawScore(self.caught, self.missed, self.score)
end

function game_scene:leave()
    if self.bgMusicPlayer then
        self.bgMusicPlayer:stop()
        self.bgMusicPlayer = nil
    end
end

function game_scene:usesSprites()
    return true
end

return game_scene
