import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

local ui = import "ui"
local gfx <const> = playdate.graphics

local snd = playdate.sound
local captureSynth = snd.synth.new(snd.kWaveSquare)

local screenWidth, screenHeight = playdate.display.getWidth(), playdate.display.getHeight() 

local beamRadius = 20 -- Initial Beam radius, will be adjusted by the crank
local beamX, beamY = screenWidth / 2, screenHeight / 2 -- Initial circle position
local minBeamRadius = 5
local maxBeamRadius = 75

-- Add this: generate random dots
local numStars = 50
local stars = {}
math.randomseed(playdate.getSecondsSinceEpoch())
for i = 1, numStars do
    table.insert(stars, {
        x = math.random(0, screenWidth),
        y = math.random(0, screenHeight),
        size = math.random(1, 2) -- Random size between 1 and 3
    })
end

local flyingObjects = {}
local maxFlyingObjects = 3
local maxObjectSize = maxBeamRadius / 3

function spawnFlyingObject()
    table.insert(flyingObjects, {
        x = math.random(0, screenWidth),
        y = math.random(0, screenHeight - 32),
        size = 1,
        speed = math.random(1, 3) / 10 -- How fast it grows
    })
end

-- Initialize flying objects
for i = 1, maxFlyingObjects do
    spawnFlyingObject()
end

local caught = 0
local missed = 0
local score = 0

-- Table to hold score popups
local scorePopups = {}

function playdate.update()
    gfx.clear(gfx.kColorBlack)

    -- Draw white stars in the background
    gfx.setColor(gfx.kColorWhite)
    local maxOffset = 3
    local dx = math.max(-maxOffset, math.min(maxOffset, (beamX - screenWidth/2) * 0.01))
    local dy = math.max(-maxOffset, math.min(maxOffset, (beamY - screenHeight/2) * 0.01))
    for i = 1, #stars do
        -- Larger dots move more with parallax
        local px = stars[i].x - dx * stars[i].size
        local py = stars[i].y - dy * stars[i].size
        if stars[i].size == 1 then
            gfx.drawPixel(px, py)
        else
            -- Draw a cross for larger dots
            gfx.drawLine(px - 2, py, px + 2, py)   -- horizontal line
            gfx.drawLine(px, py - 2, px, py + 2)   -- vertical line
        end
    end

    -- Draw the circle at its current position
    local cx, cy = math.floor(beamX + 0.5), math.floor(beamY + 0.5)
    local innerRadius = math.floor(beamRadius + 0.5)
    local outerRadius = math.floor(beamRadius + (beamRadius / 10) + 0.5)
    gfx.drawCircleAtPoint(cx, cy, innerRadius)
    gfx.drawCircleAtPoint(cx, cy, outerRadius)

    -- Movement speed inversely proportional to radius
    local moveSpeed = math.max(5, math.floor(beamRadius / 5))
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        beamY = beamY - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        beamY = beamY + moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        beamX = beamX - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        beamX = beamX + moveSpeed
    end

    -- Clamp circle center to screen boundaries minus the UI
    beamX = math.max(0, math.min(screenWidth, beamX))
    beamY = math.max(0, math.min(screenHeight - 32, beamY))

    -- Update circle radius based on crank position (0° = large, 180° = small)
    local crankPos = playdate.getCrankPosition() -- 0 to 359

    -- Map 0°/360° to maxRadius, 180° to minRadius
    local t = 1 - math.abs((crankPos % 360) / 180 - 1) -- t: 1 at 0°/360°, 0 at 180°
    beamRadius = minBeamRadius + (maxBeamRadius - minBeamRadius) * t

    -- Draw and update flying objects
    for i = #flyingObjects, 1, -1 do
        local obj = flyingObjects[i]
        obj.size = obj.size + obj.speed
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(obj.x, obj.y, obj.size)

        -- Check if object is inside the beam
        local dx = obj.x - beamX
        local dy = obj.y - beamY
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < beamRadius and beamRadius > obj.size then
            table.remove(flyingObjects, i)
            spawnFlyingObject()
            caught = caught + 1
            -- Calculate score based on how close beamRadius is to obj.size and how small the object is
            local s1 = 1
            if beamRadius ~= maxBeamRadius then
                s1 = math.floor(1 + (100 - 1) * (1 - (math.abs(beamRadius - obj.size) / (maxBeamRadius - obj.size))))
            end
            s1 = math.max(1, math.min(100, s1))
            -- Bonus for smaller objects: 100 for smallest, 0 for largest
            local minObjSize = 1
            local s2 = math.floor(100 * (1 - ((obj.size - minObjSize) / (maxObjectSize - minObjSize))))
            s2 = math.max(0, math.min(100, s2))
            local s = s1 + s2
            score = score + s
            -- Play sound with pitch based on score (higher score = higher pitch) and volume based on object size (smaller = quieter)
            local minFreq = 220 -- Hz (A3)
            local maxFreq = 880 -- Hz (A5)
            local freq = minFreq + ((s - 1) / 199) * (maxFreq - minFreq) -- s ranges from 1 to 200
            local minObjSize = 1
            local norm = (obj.size - minObjSize) / (maxObjectSize - minObjSize)
            local volume = 0.05 + 0.20 * (norm * norm) -- Squared scaling, min 0.05, max 0.25
            captureSynth:playNote(freq, volume, 0.5)
            -- Add a score popup at the object's position
            table.insert(scorePopups, {
                x = obj.x,
                y = obj.y,
                value = s,
                time = playdate.getCurrentTimeMilliseconds()
            })
        -- Remove and respawn if too big (missed)
        elseif obj.size > maxObjectSize then
            table.remove(flyingObjects, i)
            spawnFlyingObject()
            missed = missed + 1
        end
    end

    -- Draw score popups and remove expired ones
    local now = playdate.getCurrentTimeMilliseconds()
    for i = #scorePopups, 1, -1 do
        local popup = scorePopups[i]
        if now - popup.time < 1000 then
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawTextAligned("" .. tostring(popup.value), popup.x, popup.y, kTextAlignment.center)
        else
            table.remove(scorePopups, i)
        end
    end

    -- Show crank alert if crank is docked
    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end

    ui.drawScore(caught, missed, score)

    playdate.timer.updateTimers()
end