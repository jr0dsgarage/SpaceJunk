---
-- Game scene module for main gameplay loop, logic, and rendering.
-- Handles game state, scoring, flying objects, and input.

local gfx <const> = playdate.graphics -- Playdate graphics module
local snd = playdate.sound -- Playdate sound module

local game_scene = {} -- Table for game scene methods and state

-- Constants for game configuration and layout
local BASE_SCORE <const> = 250 -- Base score for perfect match
local MIN_SCORE <const> = 1 -- Minimum possible score
local MAX_SCORE <const> = 250 -- Maximum possible score
local GAME_DURATION_MS <const> = 60 * 1000 -- 60 seconds in milliseconds

-- Beam Circle  constants
local INITIAL_BEAM_RADIUS <const> = 20 -- Initial radius of the beam
local MIN_BEAM_RADIUS <const> = 10 -- Minimum beam radius
local MAX_BEAM_RADIUS <const> = 75 -- Maximum beam radius

-- Flying object constants
local MAX_FLYING_OBJECTS <const> = 3 -- Maximum number of flying objects
local MAX_OBJECT_SIZE <const> = MAX_BEAM_RADIUS -- Maximum flying object size
local MOVE_SPEED_MIN <const> = 7 -- Minimum movement speed
local MOVE_SPEED_DIV <const> = 5 -- Speed divisor for movement

-- Crank indicator constants
local CRANK_INDICATOR_HEIGHT <const> = 32 -- Height of the crank indicator

-- C Major scale notes using note_frequency.lua
local nf = _G.NoteFrequency
local C_MAJOR_NOTES <const> = {
    nf.C4,
    nf.D4,
    nf.E4,
    nf.F4,
    nf.G4,
    nf.A4,
    nf.B4
}
local NOTE_DURATION <const> = 0.2 -- Duration of each note
local NOTE_VELOCITY <const> = 0.2 -- Velocity of each note

--- 
-- Resets the game state variables for a new game session
function game_scene:resetGameState()
    self.caught = 0
    self.missed = 0
    self.score = 0
    self.scorePopups = ScorePopups.new()
    self.startTime = playdate.getCurrentTimeMilliseconds()
    self.gameOver = false
    self._beeped = {} -- Reset beeps for countdown
end

--- 
-- Initializes the game scene, sets up objects, music, and background
function game_scene:enter()
    -- Initialize or reset game state here
    self.beamRadius = INITIAL_BEAM_RADIUS
    self.beamX, self.beamY = _G.SCREEN_WIDTH / 2, _G.SCREEN_HEIGHT / 2
    self.minBeamRadius = MIN_BEAM_RADIUS
    self.maxBeamRadius = MAX_BEAM_RADIUS
    self._scoreSceneSwitched = false
    self.soundManager = SoundManager.new()

    -- Use the globally initialized starfield
    self.starfield = _G.sharedStarfield

    -- Background sprite for drawing the starfield and score popups
    self.bgSprite = gfx.sprite.new()
    self.bgSprite:setCenter(0, 0)
    self.bgSprite:moveTo(0, 0)
    self.bgSprite:setZIndex(_G.ZINDEX and _G.ZINDEX.STARFIELD or 0)
    self.bgSprite:setSize(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    self.bgSprite.draw = function(_)
        gfx.clear(gfx.kColorBlack) -- this line prevents the starfield bgImg from being drawn
        -- Draw starfield in the same position as menu_scene for seamless transition
        local baseX = (_G.SCREEN_WIDTH or 400)/2
        local baseY = (_G.SCREEN_HEIGHT or 240)/2
        local width = (_G.SCREEN_WIDTH or 400)
        local height = (_G.SCREEN_HEIGHT or 240)
        if self.starfield and self.starfield.draw then
            -- Calculate gameplay parallax based on beam position
            local px = (self.beamX - width/2) * 0.005
            self.starfield:draw(baseX, baseY, 3*width, height, (self.starfield.parallaxX or 0) + px, 0)
        end
        self.scorePopups:draw()
    end
    self.bgSprite:add()

    -- Create a sprite for the background_ship image
    local shipImg = gfx.image.new(_G.SHIP_IMAGE_PATH)
    self.backgroundSpriteObj = _G.BackgroundSprite.new(self, shipImg, _G.ZINDEX and _G.ZINDEX.SHIP_IMAGE, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)

    -- Cracks sprite for drawing cracks above all other sprites
    self.cracksImage = gfx.image.new(_G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)
    self.cracks = {}
    self.cracksSpriteObj = _G.CracksSprite.new(self, self.cracksImage, _G.ZINDEX and _G.ZINDEX.CRACKS or 100, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)

    -- Beam and crank indicator
    self.beamSprite = BeamSprite.new(self)
    self.crankIndicator = CrankIndicatorSprite.new(self, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT)

    -- Capture synth setup
    self.cMajorNotes = C_MAJOR_NOTES


    -- Background music
    local ok, bgMusicPlayer = pcall(function()
        return playdate.sound.fileplayer.new("audio/starz.mp3")
    end)
    if ok and bgMusicPlayer then
        self.bgMusicPlayer = bgMusicPlayer
        self.bgMusicPlayer:play(0) -- loop forever
    else
        self.bgMusicPlayer = nil
    end

    -- Flying objects
    self.flyingObjectImgs = _G.spriteLoader.tableLoad("sprites/junk/")
    self.maxFlyingObjects = MAX_FLYING_OBJECTS
    self.flyingObjectSpawner = FlyingObjectSpawner.new(self.flyingObjectImgs, _G.SCREEN_WIDTH, _G.SCREEN_HEIGHT, self.maxFlyingObjects)
    self.maxObjectSize = MAX_OBJECT_SIZE
    for i = 1, self.maxFlyingObjects do
        self.flyingObjectSpawner:spawnFlyingObject()
    end

    -- Reset game state
    self:resetGameState()

    -- Beam Zoom Sprite (right side, between titlebar and scoreboard)
    if self.beamZoomSprite then
        self.beamZoomSprite:remove()
        self.beamZoomSprite = nil
    end
    self.beamZoomSprite = _G.BeamZoomSprite.new(self)

    -- CRT monitor overlay sprite (centered and stretched to play-field)
    local crtImg = gfx.image.new("sprites/ship_backgrounds/CRT_monitor_resized_cropped_transp.png")
    local playfieldY = _G.TIMERBAR_HEIGHT
    local playfieldHeight = _G.SCREEN_HEIGHT - (_G.TIMERBAR_HEIGHT + _G.SCOREBOARD_HEIGHT)
    local playfieldWidth = _G.SCREEN_WIDTH
    local imgW, imgH = 400, 240
    if crtImg and crtImg.getSize then
        imgW, imgH = crtImg:getSize()
    end
    local scaleX = playfieldWidth / imgW
    local scaleY = playfieldHeight / imgH
    self.crtMonitorSprite = gfx.sprite.new(crtImg)
    self.crtMonitorSprite:setCenter(0.5, 0.5)
    self.crtMonitorSprite:moveTo(_G.SCREEN_WIDTH/2, playfieldY + playfieldHeight/2)
    self.crtMonitorSprite:setZIndex(_G.ZINDEX and _G.ZINDEX.CRT_MONITOR or 3000)
    self.crtMonitorSprite:setScale(scaleX, scaleY)
    self.crtMonitorSprite:add()
end

-- Spawns a new flying object using the spawner
function game_scene:spawnFlyingObject()
    return self.flyingObjectSpawner:spawnFlyingObject()
end

-- Calculates the score for catching an object based on beam and object size
local function calculateScore(beamRadius, objRadius)
    local beamPercent = (beamRadius - MIN_BEAM_RADIUS) / (MAX_BEAM_RADIUS - MIN_BEAM_RADIUS)
    local objPercent = (objRadius - MIN_BEAM_RADIUS) / (MAX_BEAM_RADIUS - MIN_BEAM_RADIUS)
    local diff = beamPercent - objPercent
    -- Apply a steeper penalty if the beam is larger than the object
    local penalty
    if diff > 0 then
        penalty = math.exp(2.5 * diff) - 1  -- Exponential dropoff for oversize
    else
        penalty = math.abs(diff)          -- Linear penalty for undersize
    end
    local match = math.max(0, 1 - penalty)
    local earlyBonus = 1 - objPercent
    local minScore, maxScore = MIN_SCORE, MAX_SCORE
    local score = math.floor(BASE_SCORE * match * earlyBonus + minScore)
    return math.max(minScore, math.min(maxScore, score)), match, earlyBonus, minScore, maxScore
end

-- Handles removal of a flying object, updates score or cracks, and plays sounds
local function handleObjectRemoval(self, i, obj, caught)
    self.flyingObjectSpawner:removeObjectAt(i)
    self:spawnFlyingObject()
    if caught then
        self.caught = self.caught + 1
        local objRadius = obj:getRadius()
        local beamRadius = self.beamRadius
        local score, match, earlyBonus, minScore, maxScore = calculateScore(beamRadius, objRadius)
        self.score = self.score + score
        self.scorePopups:add(obj.x, obj.y, score)
        -- Play a note from the C major scale based on score (lower score = lower note)
        if self.soundManager and self.soundManager.playCMajorNote then
            local clampedScore = math.max(minScore, math.min(maxScore, score))
            local scaleIdx = ((clampedScore - minScore) / (maxScore - minScore))
            self.soundManager:playCMajorNote(scaleIdx, NOTE_DURATION, NOTE_VELOCITY)
        end
    else
        self.missed = self.missed + 1
        if self.soundManager and self.soundManager.playMiss then
            self.soundManager:playMiss()
        end
        -- Draw the crack permanently to cracksImage
        if self.cracksImage and self.flyingObjectSpawner and self.flyingObjectSpawner.drawCrack then
            gfx.pushContext(self.cracksImage)
            self.flyingObjectSpawner:drawCrack(obj.x, obj.y)
            gfx.popContext()
            if self.cracksSpriteObj then
                self.cracksSpriteObj:setImage(self.cracksImage)
            end
        end
    end
end

-- Updates the game state each frame: movement, collisions, timer, and transitions
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
    else -- Resume the game when the crank is undocked
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
    if self.gameOver then -- switch to the score scene
        if _G.switchToScoreScene and not self._scoreSceneSwitched then
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

    -- Timer logic
    local now = playdate.getCurrentTimeMilliseconds()
    local elapsed = now - self.startTime
    self.timeLeft = math.max(0, math.ceil((GAME_DURATION_MS - elapsed) / 1000))

    -- Play beeps at 3, 2, 1 seconds left
    if not self._beeped then self._beeped = {} end
    for i = 3, 1, -1 do
        if self.timeLeft == i and not self._beeped[i] then
            if self.soundManager and self.soundManager.playCountdownBeep then
                self.soundManager:playCountdownBeep()
            end
            self._beeped[i] = true
        end
    end

    if elapsed >= GAME_DURATION_MS then
        self.gameOver = true
        return
    end
end

-- Draws the timer bar and score bar UI for the game scene
function game_scene:draw()
    -- No manual draw for background_ship; sprite system handles it
    if _G.ui and _G.ui.drawTimerBar then _G.ui.drawTimerBar(self.timeLeft or GAME_DURATION_MS / 1000) end
    if _G.ui and _G.ui.drawScore then _G.ui.drawScore(self.caught, self.missed, self.score) end
end

-- Cleans up resources and stops music when leaving the game scene
function game_scene:leave()
    if self.bgMusicPlayer then
        self.bgMusicPlayer:stop()
        self.bgMusicPlayer = nil
    end
    if self.crtMonitorSprite then
        self.crtMonitorSprite:remove()
        self.crtMonitorSprite = nil
    end
end

-- Indicates that this scene uses Playdate sprites
function game_scene:usesSprites()
    return true
end

return game_scene
