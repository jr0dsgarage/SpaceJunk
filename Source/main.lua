import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"
import "Corelibs/ui"

local ui = import "ui"
local gfx <const> = playdate.graphics

-- Load Cyberball font
local cyberballFont = gfx.font.new("/fonts/Cyberball") -- Path is relative to Source

local beamRadius = 20
local screenWidth, screenHeight = 400, 240
local beamX, beamY = screenWidth/2, screenHeight/2 -- Initial circle position

-- Add this: generate random dots
local numDots = 50
local dots = {}
math.randomseed(playdate.getSecondsSinceEpoch())
for i = 1, numDots do
    table.insert(dots, {
        x = math.random(0, screenWidth),
        y = math.random(0, screenHeight),
        size = math.random(1, 2) -- Random size between 1 and 3
    })
end

local flyingObjects = {}
local maxFlyingObjects = 3
local maxObjectSize = 30

function spawnFlyingObject()
    table.insert(flyingObjects, {
        x = math.random(0, screenWidth),
        y = math.random(0, screenHeight),
        size = 1,
        speed = math.random(1, 3) / 4 -- How fast it grows
    })
end

-- Initialize flying objects
for i = 1, maxFlyingObjects do
    spawnFlyingObject()
end

local caught = 0
local missed = 0

function playdate.update()
    gfx.clear(gfx.kColorBlack)

    -- Draw white dots in the background
    gfx.setColor(gfx.kColorWhite)
    local maxOffset = 3
    local dx = math.max(-maxOffset, math.min(maxOffset, (beamX - screenWidth/2) * 0.01))
    local dy = math.max(-maxOffset, math.min(maxOffset, (beamY - screenHeight/2) * 0.01))
    for i = 1, #dots do
        -- Larger dots move more with parallax
        local px = dots[i].x - dx * dots[i].size
        local py = dots[i].y - dy * dots[i].size
        if dots[i].size == 1 then
            gfx.drawPixel(px, py)
        else
            gfx.fillCircleAtPoint(px, py, dots[i].size)
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

    -- Clamp circle center to screen boundaries
    beamX = math.max(0, math.min(screenWidth, beamX))
    beamY = math.max(0, math.min(screenHeight, beamY))

    -- Update circle radius based on crank (logarithmic feel)
    local crankChange = playdate.getCrankChange()
    local scale = math.max(0.1, math.log(beamRadius) / 10)
    beamRadius = math.max(5, math.min(100, beamRadius - crankChange * scale))

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
        if dist < beamRadius then
            table.remove(flyingObjects, i)
            spawnFlyingObject()
            caught = caught + 1
        -- Remove and respawn if too big (missed)
        elseif obj.size > maxObjectSize then
            table.remove(flyingObjects, i)
            spawnFlyingObject()
            missed = missed + 1
        end
    end

    -- Show crank alert if crank is docked
    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end

   
    ui.drawScore(caught, missed)

    playdate.timer.updateTimers()
end