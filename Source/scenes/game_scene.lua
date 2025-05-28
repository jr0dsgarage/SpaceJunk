local gfx <const> = playdate.graphics
local snd = playdate.sound
local captureSynth = snd.synth.new(snd.kWaveSquare)

local game_scene = {}

-- Constants for game configuration and layout
local GAME_DURATION_MS = 60 * 1000 -- 60 seconds in milliseconds
local INITIAL_BEAM_RADIUS = 20
local MIN_BEAM_RADIUS = 5
local MAX_BEAM_RADIUS = 75
local MAX_FLYING_OBJECTS = 3
local MAX_OBJECT_SIZE = MAX_BEAM_RADIUS
local MOVE_SPEED_MIN = 5
local MOVE_SPEED_DIV = 5
local CRANK_UNDOCKED_PAUSE = 0.04
local CRANK_INDICATOR_HEIGHT = 32
local NOTE_DURATION = 0.2
local NOTE_VELOCITY = 0.2
local SCORE_MIN = 0
local SCORE_MAX = 100

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
    self.beamRadius = INITIAL_BEAM_RADIUS
    self.beamX, self.beamY = _G.SCREEN_WIDTH / 2, _G.SCREEN_HEIGHT / 2
    self.minBeamRadius = MIN_BEAM_RADIUS
    self.maxBeamRadius = MAX_BEAM_RADIUS
    self._scoreSceneSwitched = false
    self.soundManager = SoundManager.new()

    -- Background music
    local ok, bgMusicPlayer = pcall(function()
        return playdate.sound.fileplayer.new("audio/starz.mp3")
    end)
    if ok and bgMusicPlayer then
        self.bgMusicPlayer = bgMusicPlayer
        self.bgMusicPlayer:play(0) -- loop forever
    else
        print("[Audio] Error loading background music: " .. tostring(bgMusicPlayer))
        self.bgMusicPlayer = nil
    end

    -- Stars
    self.starfield = _G.sharedStarfield
    
    -- Flying objects
    local flyingObjectImgs = {}
    local imgOk1, img1 = pcall(function() return gfx.image.new("sprites/asteroid.png") end)
    local imgOk2, img2 = pcall(function() return gfx.image.new("sprites/bottle.png") end)
    if imgOk1 and img1 then table.insert(flyingObjectImgs, img1) else print("[Graphics] Error loading asteroid.png") end
    if imgOk2 and img2 then table.insert(flyingObjectImgs, img2) else print("[Graphics] Error loading bottle.png") end
    self.flyingObjectImgs = flyingObjectImgs
    self.maxFlyingObjects = MAX_FLYING_OBJECTS
    self.flyingObjectSpawner = FlyingObjectSpawner.new(self.flyingObjectImgs, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, self.maxFlyingObjects)
    self.maxObjectSize = MAX_OBJECT_SIZE
    for i = 1, self.maxFlyingObjects do
        self.flyingObjectSpawner:spawnFlyingObject()
    end

    -- Reset game state
    self:resetGameState()

    -- Background sprite for drawing the starfield and score popups
    self.bgSprite = gfx.sprite.new()
    self.bgSprite:setCenter(0, 0)
    self.bgSprite:moveTo(0, 0)
    self.bgSprite:setZIndex(_G.ZINDEX and _G.ZINDEX.BACKGROUND or 0)
    self.bgSprite:setSize(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    self.cracksImage = gfx.image.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    self.cracks = {}
    self.bgSprite.draw = function(_)
        gfx.clear(gfx.kColorBlack)
        self.starfield:draw(self.beamX, self.beamY, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
        self.scorePopups:draw()
    end
    self.bgSprite:add()

    -- Cracks sprite for drawing cracks above all other sprites
    self.cracksSprite = gfx.sprite.new(self.cracksImage)
    self.cracksSprite:setCenter(0, 0)
    self.cracksSprite:moveTo(0, 0)
    self.cracksSprite:setZIndex(_G.ZINDEX and _G.ZINDEX.CRACKS or 100)
    self.cracksSprite:setSize(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    self.cracksSprite:add()

    -- Beam and crank indicator
    self.beamSprite = BeamSprite.new(self)
    self.crankIndicator = CrankIndicatorSprite.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)

    -- Capture synth setup
    self.cMajorNotes = {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88} -- C4, D4, E4, F4, G4, A4, B4
end

function game_scene:spawnFlyingObject()
    return self.flyingObjectSpawner:spawnFlyingObject()
end

local function handleObjectRemoval(self, i, obj, caught)
    self.flyingObjectSpawner:removeObjectAt(i)
    self:spawnFlyingObject()
    if caught then
        self.caught = self.caught + 1
        -- Score calculation
        local precision = 1 - (self.beamRadius - obj:getRadius()) / self.beamRadius
        local sizeFactor = 1 - (obj:getRadius() / self.maxObjectSize)
        local score = math.floor(100 * precision * sizeFactor)
        self.score = self.score + score
        self.scorePopups:add(obj.x, obj.y, score)
        -- Play a note from the C major scale based on score (lower score = lower note)
        if self.cMajorNotes then
            local clampedScore = math.max(SCORE_MIN, math.min(SCORE_MAX, score))
            local scaleIdx = math.floor(((clampedScore - SCORE_MIN) / (SCORE_MAX - SCORE_MIN)) * (#self.cMajorNotes - 1) + 1)
            local note = self.cMajorNotes[scaleIdx]
            if captureSynth and note then
                captureSynth:playNote(note, NOTE_DURATION, NOTE_VELOCITY)
            end
        elseif self.soundManager and self.soundManager.playCapture then
            self.soundManager:playCapture(precision)
        end
    else
        self.missed = self.missed + 1
        if self.soundManager and self.soundManager.playMiss then
            self.soundManager:playMiss()
        end
        self.scorePopups:add(obj.x, obj.y, 0)
        -- Draw the crack permanently to cracksImage
        if self.cracksImage and self.flyingObjectSpawner and self.flyingObjectSpawner.drawCrack then
            gfx.pushContext(self.cracksImage)
            self.flyingObjectSpawner:drawCrack(obj.x, obj.y)
            gfx.popContext()
            -- Update cracksSprite image
            if self.cracksSprite then
                self.cracksSprite:setImage(self.cracksImage)
            end
        end
    end
end

function game_scene:update()
    -- Pause the game if the crank is docked
    if playdate.isCrankDocked() then
        if self.bgMusicPlayer and self.bgMusicPlayer.isPlaying and self.bgMusicPlayer:isPlaying() then
            self.bgMusicPlayer:pause()
        end
        if _G.ui and _G.ui.pauseTimerBar then _G.ui.pauseTimerBar() end
        if not self.pauseTime then
            self.pauseTime = playdate.getCurrentTimeMilliseconds()
        end
        if self.crankIndicator then
            self.crankIndicator:drawIndicator()
        end
        return
    else
        if self.bgMusicPlayer and self.bgMusicPlayer.play and not self.bgMusicPlayer:isPlaying() then
            self.bgMusicPlayer:play(0)
        end
        if _G.ui and _G.ui.resumeTimerBar then _G.ui.resumeTimerBar() end
        if self.pauseTime then
            local pausedDuration = playdate.getCurrentTimeMilliseconds() - self.pauseTime
            self.startTime = self.startTime + pausedDuration
            self.pauseTime = nil
        end
    end
    if self.gameOver then
        if rawget(_G, "switchToScoreScene") and not self._scoreSceneSwitched then
            self._scoreSceneSwitched = true
            _G.switchToScoreScene(self.score, self.caught, self.missed)
        end
        return
    end
    -- Movement
    local moveSpeed = math.max(MOVE_SPEED_MIN, math.floor(self.beamRadius / MOVE_SPEED_DIV))
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
    self.beamX = math.max(0, math.min(_G.SCREEN_WIDTH, self.beamX))
    self.beamY = math.max(0, math.min(_G.SCREEN_HEIGHT - CRANK_INDICATOR_HEIGHT, self.beamY))

    -- Crank
    local crankPos = playdate.getCrankPosition()
    local t = 1 - math.abs((crankPos % 360) / 180 - 1)
    self.beamRadius = self.minBeamRadius + (self.maxBeamRadius - self.minBeamRadius) * t

    -- Flying objects (caught)
    for i = #self.flyingObjectSpawner.flyingObjects, 1, -1 do
        local obj = self.flyingObjectSpawner.flyingObjects[i]
        obj:update()
        local dx = obj.x - self.beamX
        local dy = obj.y - self.beamY
        local dist = math.sqrt(dx * dx + dy * dy)
        local objRadius = obj:getRadius()
        if dist < self.beamRadius and self.beamRadius > objRadius then
            handleObjectRemoval(self, i, obj, true)
        end
    end

    -- Flying objects (missed)
    for i = #self.flyingObjectSpawner.flyingObjects, 1, -1 do
        local obj = self.flyingObjectSpawner.flyingObjects[i]
        if obj.size > self.maxObjectSize then
            handleObjectRemoval(self, i, obj, false)
        end
    end

    -- At the end of update, force background sprite to redraw
    if self.bgSprite then self.bgSprite:markDirty() end
    if self.beamSprite and self.beamSprite.sprite then self.beamSprite.sprite:markDirty() end

    -- Timer logic
    local now = playdate.getCurrentTimeMilliseconds()
    local elapsed = now - self.startTime
    self.timeLeft = math.max(0, math.ceil((GAME_DURATION_MS - elapsed) / 1000))
    if elapsed >= GAME_DURATION_MS then
        self.gameOver = true
        return
    end
end

function game_scene:draw()
    if ui and ui.drawTimerBar then ui.drawTimerBar(self.timeLeft or GAME_DURATION_MS / 1000) end
    if ui and ui.drawScore then ui.drawScore(self.caught, self.missed, self.score) end
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
