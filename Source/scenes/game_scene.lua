-- scenes/game_scene.lua
local gfx <const> = playdate.graphics
local snd = playdate.sound
local captureSynth = snd.synth.new(snd.kWaveSquare)

local game_scene = {}

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
    self.flyingObjects = {}
    self.maxFlyingObjects = 3
    self.maxObjectSize = self.maxBeamRadius / 3
    for i = 1, self.maxFlyingObjects do
        self:spawnFlyingObject()
    end
    self.caught = 0
    self.missed = 0
    self.score = 0
    self.scorePopups = {}
end

function game_scene:spawnFlyingObject()
    table.insert(self.flyingObjects, {
        x = math.random(0, self.screenWidth),
        y = math.random(0, self.screenHeight - 32),
        size = 1,
        speed = math.random(1, 3) / 10
    })
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
        obj.size = obj.size + obj.speed
        -- Check if object is inside the beam and beam is larger than object
        local dx = obj.x - self.beamX
        local dy = obj.y - self.beamY
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < self.beamRadius and self.beamRadius > obj.size then
            table.remove(self.flyingObjects, i)
            self:spawnFlyingObject()
            self.caught = self.caught + 1
            -- Score calculation
            local s1 = 1
            if self.beamRadius ~= self.maxBeamRadius then
                s1 = math.floor(1 + (100 - 1) * (1 - (math.abs(self.beamRadius - obj.size) / (self.maxBeamRadius - obj.size))))
            end
            s1 = math.max(1, math.min(100, s1))
            local minObjSize = 1
            local s2 = math.floor(100 * (1 - ((obj.size - minObjSize) / (self.maxObjectSize - minObjSize))))
            s2 = math.max(0, math.min(100, s2))
            local s = s1 + s2
            self.score = self.score + s
            -- Sound
            local minFreq = 220 -- A2 (220 Hz)
            local maxFreq = 880 -- A4 (880 Hz)
            local freq = minFreq + ((s - 1) / 199) * (maxFreq - minFreq)
            local norm = (obj.size - minObjSize) / (self.maxObjectSize - minObjSize)
            local volume = 0.05 + 0.20 * (norm * norm)
            captureSynth:playNote(freq, volume, 0.5)
            table.insert(self.scorePopups, {
                x = obj.x,
                y = obj.y,
                value = s,
                time = playdate.getCurrentTimeMilliseconds()
            })
        elseif obj.size > self.maxObjectSize then
            table.remove(self.flyingObjects, i)
            self:spawnFlyingObject()
            self.missed = self.missed + 1
        end
    end
end

function game_scene:draw()
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
    -- Beam
    local cx, cy = math.floor(self.beamX + 0.5), math.floor(self.beamY + 0.5)
    local innerRadius = math.floor(self.beamRadius + 0.5)
    local outerRadius = math.floor(self.beamRadius + (self.beamRadius / 10) + 0.5)
    gfx.drawCircleAtPoint(cx, cy, innerRadius)
    gfx.drawCircleAtPoint(cx, cy, outerRadius)
    -- Flying objects
    for i = 1, #self.flyingObjects do
        local obj = self.flyingObjects[i]
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(obj.x, obj.y, obj.size)
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
    ui.drawScore(self.caught, self.missed, self.score)
end

return game_scene
